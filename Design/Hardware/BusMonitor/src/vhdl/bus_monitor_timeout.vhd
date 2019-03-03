----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.01.2019 12:33:41
-- Design Name: 
-- Module Name: bus_monitor_timeout - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision ´1.0
-- Additional Comments:
-- 0.01: Initial implementation
-- 1.0: retry mechanism added
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bus_monitor_timeout is
    generic(
		CLK_FREQ : integer; -- in Hz
		MASTER_TIMEOUT : integer; -- in ms
		SLAVE_TIMEOUT : integer -- in ms
	);

    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           UART_RX_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           UART_RX_DATA_VALID : in STD_LOGIC;
           RECFG : out STD_LOGIC_VECTOR (1 downto 0));
end bus_monitor_timeout;

architecture Behavioral of bus_monitor_timeout is

    --electronic control unit address (master)
    constant ADDRESS_ECU    : std_logic_vector(1 downto 0) := "11";
    --throttle sensor address (slave)
    constant ADDRESS_THS    : std_logic_vector(1 downto 0) := "01";
    --motor control unit address (slave)
    constant ADDRESS_MCU    : std_logic_vector(1 downto 0) := "10";
    
    --has to be calculated manually because of null range error (Synth 8-6774): (MASTER_TIMEOUT * CLK_FREQ) / 1000
    --must be set to 3E5 for simulation
    constant MASTER_TIMEOUT_TICKS : integer := 100E6;
    --has to be calculated manually because of null range error (Synth 8-6774): (SLAVE_TIMEOUT * CLK_FREQ) / 1000
    --must be set to 15E4 for simulation
    constant SLAVE_TIMEOUT_TICKS : integer := 50E6;

    --Bus Monitor regular States
	type bm_regular_state_t is (
		TIMEOUT_STATE_INIT_SLAVE_1_DATA_1,
		TIMEOUT_STATE_INIT_SLAVE_1_DATA_2,
		TIMEOUT_STATE_INIT_SLAVE_1_FINISHED,
		TIMEOUT_STATE_INIT_SLAVE_2_DATA_1,
		TIMEOUT_STATE_INIT_SLAVE_2_DATA_2,
		TIMEOUT_STATE_INIT_SLAVE_2_FINISHED,
		TIMEOUT_STATE_MASTER_DATA_RECEIVED,
		TIMEOUT_STATE_SLAVE_DATA_RECEIVED,
		TIMEOUT_STATE_MASTER_TIMEOUT_1,
		TIMEOUT_STATE_SLAVE_TIMEOUT_1,
		TIMEOUT_STATE_MASTER_TIMEOUT_2,
		TIMEOUT_STATE_SLAVE_TIMEOUT_2,
		TIMEOUT_STATE_STOP
	);
	
	--Bus Monitor Timeout States
    type bm_timeout_state_t is (
        TIMEOUT_STATE_IDLE,
        TIMEOUT_STATE_MASTER_TIMEOUT_1,
        TIMEOUT_STATE_SLAVE_TIMEOUT_1,
        TIMEOUT_STATE_MASTER_TIMEOUT_2,
        TIMEOUT_STATE_SLAVE_TIMEOUT_2,
        TIMEOUT_STATE_STOP
    );
	
	signal bm_regular_state      : bm_regular_state_t;
    signal bm_regular_state_next : bm_regular_state_t;
    
    signal bm_timeout_state      : bm_timeout_state_t;
    signal bm_timeout_state_next : bm_timeout_state_t;
    
    signal enable_master_watchdog       : std_logic;
    signal enable_master_watchdog_next  : std_logic;
    signal enable_slave_watchdog       : std_logic;
    signal enable_slave_watchdog_next  : std_logic;
    
    signal reset_watchdog       : std_logic;
    signal reset_watchdog_next  : std_logic;
    
    signal reconfiguration_device       : std_logic_vector(1 downto 0);
    signal reconfiguration_device_next  : std_logic_vector(1 downto 0);
    
    signal slave_address        : std_logic_vector(1 downto 0);
    signal slave_address_next   : std_logic_vector(1 downto 0);
    
    signal master_counter : integer range 0 to MASTER_TIMEOUT_TICKS;
    signal slave_counter : integer range 0 to SLAVE_TIMEOUT_TICKS;
    
    signal master_watchdog_overflow : std_logic;
    signal slave_watchdog_overflow : std_logic;
    
    signal last_data_byte       : std_logic_vector(7 downto 0);
    signal last_data_byte_next  : std_logic_vector(7 downto 0);

begin

    --data synchronization process (clocked)
	data_sync : process(CLK,RST)
	begin
	
        if(RST = '1') then

			bm_regular_state <= TIMEOUT_STATE_INIT_SLAVE_1_DATA_1;
			bm_timeout_state <= TIMEOUT_STATE_IDLE;
			enable_master_watchdog <= '1';
			enable_slave_watchdog <= '0';
			reset_watchdog <= '0';
			reconfiguration_device <= "00";
			slave_address <= "00";
			last_data_byte <= x"00";

        elsif(rising_edge(CLK)) then

            bm_regular_state <= bm_regular_state_next;
            bm_timeout_state <= bm_timeout_state_next;
            enable_master_watchdog <= enable_master_watchdog_next;
			enable_slave_watchdog <= enable_slave_watchdog_next;
			reset_watchdog <= reset_watchdog_next;
			reconfiguration_device <= reconfiguration_device_next;
			slave_address <= slave_address_next;
			last_data_byte <= last_data_byte_next;

        end if;
	
    end process data_sync;
    
    --master watchdog process (clocked)
	master_watchdog : process(CLK,RST)
	begin
	
	   if(RST = '1') then
	   
	       master_counter <= 0;
	       master_watchdog_overflow <= '0';
	   
	   elsif(rising_edge(CLK)) then
	   
	       if(reset_watchdog = '1') then
	           master_counter <= 0;
	           master_watchdog_overflow <= '0';
	       elsif(enable_master_watchdog = '1') then
	       
	           if(master_counter >= MASTER_TIMEOUT_TICKS) then
	               master_watchdog_overflow <= '1';
	               master_counter <= 0;
	           else
	               master_watchdog_overflow <= '0';
	               master_counter <= master_counter + 1;
	           end if;
	       
	       end if;
	   
	   end if;
	
	end process master_watchdog;
	
	--slave watchdog process (clocked)
	slave_watchdog : process(CLK,RST)
	begin
	
	   if(RST = '1') then
	   
	       slave_counter <= 0;
	       slave_watchdog_overflow <= '0';
	   
	   elsif(rising_edge(CLK)) then
	   
	       if(reset_watchdog = '1') then
	           slave_counter <= 0;
	           slave_watchdog_overflow <= '0';
	       elsif(enable_slave_watchdog = '1') then
	       
	           if(slave_counter >= SLAVE_TIMEOUT_TICKS) then
	               slave_watchdog_overflow <= '1';
	               slave_counter <= 0;
	           else
	               slave_watchdog_overflow <= '0';
	               slave_counter <= slave_counter + 1;
	           end if;
	       
	       end if;
	   
	   end if;
	
	end process slave_watchdog;
    
    --timeout state machine process (combinatorial)
    timeout_state_machine : process(    UART_RX_DATA_VALID,
                                        bm_regular_state,
                                        bm_timeout_state,
                                        enable_master_watchdog,
                                        enable_slave_watchdog,
                                        slave_address,
                                        UART_RX_DATA,
                                        reconfiguration_device,
                                        master_watchdog_overflow,
                                        slave_watchdog_overflow,
                                        last_data_byte)
    begin
    
        --prevent latches
        bm_regular_state_next <= bm_regular_state;
        enable_master_watchdog_next <= enable_master_watchdog;
        enable_slave_watchdog_next <= enable_slave_watchdog;
        reset_watchdog_next <= '0';
        slave_address_next <= slave_address;
        reconfiguration_device_next <= reconfiguration_device;
        bm_timeout_state_next <= bm_timeout_state;
        last_data_byte_next <= last_data_byte;
    
        --check if uart provides valid data
        if(UART_RX_DATA_VALID = '1') then
            --reset timeout state
            bm_timeout_state_next <= TIMEOUT_STATE_IDLE;
            reset_watchdog_next <= '1';
        
            case bm_regular_state is
                when TIMEOUT_STATE_INIT_SLAVE_1_DATA_1 =>
                    bm_regular_state_next <= TIMEOUT_STATE_INIT_SLAVE_1_DATA_2;
                    enable_master_watchdog_next <= '1';
                    enable_slave_watchdog_next <= '0';
                when TIMEOUT_STATE_INIT_SLAVE_1_DATA_2 =>
                    bm_regular_state_next <= TIMEOUT_STATE_INIT_SLAVE_1_FINISHED;
                    enable_master_watchdog_next <= '0';
                    enable_slave_watchdog_next <= '1';
                    
                    --retrieve slave address out of packet sent by master
                    if(UART_RX_DATA(7 downto 6) = "00") then
                        slave_address_next <= UART_RX_DATA(5 downto 4);
                    else
                        slave_address_next <= UART_RX_DATA(7 downto 6);
                    end if;
                when TIMEOUT_STATE_INIT_SLAVE_1_FINISHED =>
                    bm_regular_state_next <= TIMEOUT_STATE_INIT_SLAVE_2_DATA_1;
                    enable_master_watchdog_next <= '1';
                    enable_slave_watchdog_next <= '0';
                when TIMEOUT_STATE_INIT_SLAVE_2_DATA_1 =>
                    bm_regular_state_next <= TIMEOUT_STATE_INIT_SLAVE_2_DATA_2;
                    enable_master_watchdog_next <= '1';
                    enable_slave_watchdog_next <= '0';
                when TIMEOUT_STATE_INIT_SLAVE_2_DATA_2 =>
                    bm_regular_state_next <= TIMEOUT_STATE_INIT_SLAVE_2_FINISHED;
                    enable_master_watchdog_next <= '0';
                    enable_slave_watchdog_next <= '1';
                    
                    --retrieve slave address out of packet sent by master
                    if(UART_RX_DATA(7 downto 6) = "00") then
                        slave_address_next <= UART_RX_DATA(5 downto 4);
                    else
                        slave_address_next <= UART_RX_DATA(7 downto 6);
                    end if;
                when TIMEOUT_STATE_INIT_SLAVE_2_FINISHED =>
                    bm_regular_state_next <= TIMEOUT_STATE_MASTER_DATA_RECEIVED;
                    enable_master_watchdog_next <= '1';
                    enable_slave_watchdog_next <= '0';
                when TIMEOUT_STATE_MASTER_DATA_RECEIVED =>
                    last_data_byte_next <= UART_RX_DATA;
                    if(UART_RX_DATA = last_data_byte) then
                        bm_regular_state_next <= TIMEOUT_STATE_MASTER_DATA_RECEIVED;
                        enable_master_watchdog_next <= '1';
                        enable_slave_watchdog_next <= '0';
                    else
                        bm_regular_state_next <= TIMEOUT_STATE_SLAVE_DATA_RECEIVED;
                        enable_master_watchdog_next <= '0';
                        enable_slave_watchdog_next <= '1';
                        
                        --retrieve slave address out of packet sent by master
                        if(UART_RX_DATA(7 downto 6) = "00") then
                            slave_address_next <= UART_RX_DATA(5 downto 4);
                        else
                            slave_address_next <= UART_RX_DATA(7 downto 6);
                        end if;
                    end if;
                when TIMEOUT_STATE_SLAVE_DATA_RECEIVED =>
                    last_data_byte_next <= UART_RX_DATA;
                    if(UART_RX_DATA = last_data_byte) then
                        bm_regular_state_next <= TIMEOUT_STATE_SLAVE_DATA_RECEIVED;
                        enable_master_watchdog_next <= '0';
                        enable_slave_watchdog_next <= '1';
                        
                        --retrieve slave address out of packet sent by master
                        if(UART_RX_DATA(7 downto 6) = "00") then
                            slave_address_next <= UART_RX_DATA(5 downto 4);
                        else
                            slave_address_next <= UART_RX_DATA(7 downto 6);
                        end if;
                    else
                        bm_regular_state_next <= TIMEOUT_STATE_MASTER_DATA_RECEIVED;
                        enable_master_watchdog_next <= '1';
                        enable_slave_watchdog_next <= '0';
                    end if;
                when others =>
                    --should no be reached
            end case;
        end if;
        
        case bm_timeout_state is
            when TIMEOUT_STATE_IDLE =>
                if(master_watchdog_overflow = '1') then
                    if(bm_regular_state = TIMEOUT_STATE_MASTER_DATA_RECEIVED) then
                        bm_timeout_state_next <= TIMEOUT_STATE_MASTER_TIMEOUT_1;
                    else
                        bm_timeout_state_next <= TIMEOUT_STATE_MASTER_TIMEOUT_2;
                    end if;
                elsif(slave_watchdog_overflow = '1') then
                    if(bm_regular_state = TIMEOUT_STATE_SLAVE_DATA_RECEIVED) then
                        bm_timeout_state_next <= TIMEOUT_STATE_SLAVE_TIMEOUT_1;
                    else
                        bm_timeout_state_next <= TIMEOUT_STATE_SLAVE_TIMEOUT_2;
                    end if;
                end if;
            when TIMEOUT_STATE_MASTER_TIMEOUT_1 =>
                if(master_watchdog_overflow = '1') then
                    bm_timeout_state_next <= TIMEOUT_STATE_MASTER_TIMEOUT_2;
                end if;
                enable_master_watchdog_next <= '1';
                enable_slave_watchdog_next <= '0';
            when TIMEOUT_STATE_MASTER_TIMEOUT_2 =>
                reconfiguration_device_next <= ADDRESS_ECU;
                bm_regular_state_next <= TIMEOUT_STATE_STOP;
                bm_timeout_state_next <= TIMEOUT_STATE_STOP;
            when TIMEOUT_STATE_SLAVE_TIMEOUT_1 =>
                if(master_watchdog_overflow = '1') then
                    bm_timeout_state_next <= TIMEOUT_STATE_SLAVE_TIMEOUT_2;
                end if;
                enable_master_watchdog_next <= '0';
                enable_slave_watchdog_next <= '1';
            when TIMEOUT_STATE_SLAVE_TIMEOUT_2 =>
                reconfiguration_device_next <= slave_address;
                bm_regular_state_next <= TIMEOUT_STATE_STOP;
                bm_timeout_state_next <= TIMEOUT_STATE_STOP;
            when TIMEOUT_STATE_STOP =>
                -- do nothing
            when others =>
                --do nothing
        end case;
    
    end process timeout_state_machine;

    RECFG <=    reconfiguration_device;

end Behavioral;
