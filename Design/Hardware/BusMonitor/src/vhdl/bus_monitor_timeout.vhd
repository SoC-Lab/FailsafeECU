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
-- Revision 1.1
-- Additional Comments:
-- 0.01: Initial implementation
-- 1.0: retry mechanism added
-- 1.1: init sequence removed
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
		MASTER_TIMEOUT : integer -- in ms
	);

    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           UART_RX_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           UART_RX_DATA_VALID : in STD_LOGIC;
           RECFG : out STD_LOGIC_VECTOR (1 downto 0);
           EN : in STD_LOGIC);
end bus_monitor_timeout;

architecture Behavioral of bus_monitor_timeout is

    --electronic control unit address (master)
    constant ADDRESS_ECU    : std_logic_vector(1 downto 0) := "11";
    
    --has to be calculated manually because of null range error (Synth 8-6774): (MASTER_TIMEOUT * CLK_FREQ) / 1000
    --must be set to 3E5 for simulation, 200E6 for implementation
    constant MASTER_TIMEOUT_TICKS : integer := 200E6;
    
    --Bus Monitor regular States
	type bm_regular_state_t is (
		TIMEOUT_STATE_INIT_1,
		TIMEOUT_STATE_INIT_2,
		TIMEOUT_STATE_MASTER_DATA_RECEIVED,
		TIMEOUT_STATE_SLAVE_DATA_RECEIVED,
		TIMEOUT_STATE_STOP
	);
	
	--Bus Monitor Timeout States
    type bm_master_timeout_state_t is (
        TIMEOUT_STATE_IDLE,
        TIMEOUT_STATE_MASTER_TIMEOUT,
        TIMEOUT_STATE_STOP
    );
	
	signal bm_regular_state      : bm_regular_state_t;
    signal bm_regular_state_next : bm_regular_state_t;
    
    signal bm_master_timeout_state      : bm_master_timeout_state_t;
    signal bm_master_timeout_state_next : bm_master_timeout_state_t;
    
    signal enable_master_watchdog       : std_logic;
    signal enable_master_watchdog_next  : std_logic;
    
    signal reset_watchdog       : std_logic;
    signal reset_watchdog_next  : std_logic;
    
    signal reconfiguration_device       : std_logic_vector(1 downto 0);
    signal reconfiguration_device_next  : std_logic_vector(1 downto 0);
    
    signal master_counter : integer range 0 to MASTER_TIMEOUT_TICKS;
    
    signal master_watchdog_overflow : std_logic;
    
    signal last_data_byte       : std_logic_vector(7 downto 0);
    signal last_data_byte_next  : std_logic_vector(7 downto 0);

begin

    --data synchronization process (clocked)
	data_sync : process(CLK,RST)
	begin
	
        if(RST = '1') then

			bm_regular_state <= TIMEOUT_STATE_INIT_1;
			bm_master_timeout_state <= TIMEOUT_STATE_IDLE;
			enable_master_watchdog <= '1';
			reset_watchdog <= '0';
			reconfiguration_device <= "00";
			last_data_byte <= x"00";

        elsif(rising_edge(CLK) and EN = '1') then

            bm_regular_state <= bm_regular_state_next;
            bm_master_timeout_state <= bm_master_timeout_state_next;
            enable_master_watchdog <= enable_master_watchdog_next;
			reset_watchdog <= reset_watchdog_next;
			reconfiguration_device <= reconfiguration_device_next;
			last_data_byte <= last_data_byte_next;

        end if;
	
    end process data_sync;
    
    --master watchdog process (clocked)
	master_watchdog : process(CLK,RST)
	begin
	
	   if(RST = '1') then
	   
	       master_counter <= 0;
	       master_watchdog_overflow <= '0';
	   
	   elsif(rising_edge(CLK) and EN = '1') then
	   
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
    
    --timeout state machine process (combinatorial)
    timeout_state_machine : process(    UART_RX_DATA_VALID,
                                        bm_regular_state,
                                        bm_master_timeout_state,
                                        enable_master_watchdog,
                                        UART_RX_DATA,
                                        reconfiguration_device,
                                        master_watchdog_overflow,
                                        last_data_byte,
                                        EN)
    begin
    
        --prevent latches
        bm_regular_state_next <= bm_regular_state;
        enable_master_watchdog_next <= enable_master_watchdog;
        reset_watchdog_next <= '0';
        reconfiguration_device_next <= reconfiguration_device;
        bm_master_timeout_state_next <= bm_master_timeout_state;
        last_data_byte_next <= last_data_byte;
    
        --check if uart provides valid data
        if(UART_RX_DATA_VALID = '1' and EN = '1') then
            reset_watchdog_next <= '1';
        
            case bm_regular_state is
                when TIMEOUT_STATE_INIT_1 =>
                    --necessary because during startup a faulty byte might be received
                    bm_regular_state_next <= TIMEOUT_STATE_INIT_2;
                when TIMEOUT_STATE_INIT_2 =>
                    if(UART_RX_DATA(7 downto 6) = "00" and UART_RX_DATA(3 downto 2) = ADDRESS_ECU) then
                        --control byte sent by master
                        last_data_byte_next <= UART_RX_DATA;
                        bm_regular_state_next <= TIMEOUT_STATE_SLAVE_DATA_RECEIVED;
                        enable_master_watchdog_next <= '0';
                        
                        bm_master_timeout_state_next <= TIMEOUT_STATE_IDLE;
                    elsif(UART_RX_DATA(7 downto 6) /= ADDRESS_ECU and UART_RX_DATA(7 downto 6) /= "00") then
                        --data byte sent by master
                        last_data_byte_next <= UART_RX_DATA;
                        bm_regular_state_next <= TIMEOUT_STATE_SLAVE_DATA_RECEIVED;
                        enable_master_watchdog_next <= '0';
                        
                        bm_master_timeout_state_next <= TIMEOUT_STATE_IDLE;
                    else
                        --control or data byte sent by slave
                        bm_regular_state_next <= TIMEOUT_STATE_MASTER_DATA_RECEIVED;
                        enable_master_watchdog_next <= '1';
                    end if;
                when TIMEOUT_STATE_MASTER_DATA_RECEIVED =>
                    last_data_byte_next <= UART_RX_DATA;
                    
                    bm_regular_state_next <= TIMEOUT_STATE_SLAVE_DATA_RECEIVED;
                    enable_master_watchdog_next <= '0';
                    
                    bm_master_timeout_state_next <= TIMEOUT_STATE_IDLE;
                when TIMEOUT_STATE_SLAVE_DATA_RECEIVED =>
                    last_data_byte_next <= UART_RX_DATA;
                    if(UART_RX_DATA = last_data_byte) then
                        bm_regular_state_next <= TIMEOUT_STATE_SLAVE_DATA_RECEIVED;
                        enable_master_watchdog_next <= '0';
                        
                        bm_master_timeout_state_next <= TIMEOUT_STATE_IDLE;
                    else
                        bm_regular_state_next <= TIMEOUT_STATE_MASTER_DATA_RECEIVED;
                        enable_master_watchdog_next <= '1';
                    end if;
                when TIMEOUT_STATE_STOP =>
                    --do nothing
                when others =>
                    --never reached
            end case;
        end if;
        
        case bm_master_timeout_state is
            when TIMEOUT_STATE_IDLE =>
                if(master_watchdog_overflow = '1') then
                    bm_master_timeout_state_next <= TIMEOUT_STATE_MASTER_TIMEOUT;
                end if;
            when TIMEOUT_STATE_MASTER_TIMEOUT =>
                reconfiguration_device_next <= ADDRESS_ECU;
                bm_regular_state_next <= TIMEOUT_STATE_STOP;
                bm_master_timeout_state_next <= TIMEOUT_STATE_STOP;
            when TIMEOUT_STATE_STOP =>
                -- do nothing
            when others =>
                --never reached
        end case;
    
    end process timeout_state_machine;

    RECFG <=    reconfiguration_device;

end Behavioral;
