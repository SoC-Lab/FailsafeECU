----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.01.2019 17:24:35
-- Design Name: 
-- Module Name: bus_monitor_error - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
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

entity bus_monitor_error is
    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           UART_RX_DATA : in STD_LOGIC_VECTOR(7 downto 0);
           UART_RX_DATA_VALID : in STD_LOGIC;
           RECFG : out STD_LOGIC_VECTOR (1 downto 0));
end bus_monitor_error;

architecture Behavioral of bus_monitor_error is

    --electronic control unit address (master)
    constant ADDRESS_ECU    : std_logic_vector(1 downto 0) := "11";
    --throttle sensor address (slave)
    constant ADDRESS_THS    : std_logic_vector(1 downto 0) := "01";
    --motor control unit address (slave)
    constant ADDRESS_MCU    : std_logic_vector(1 downto 0) := "10";

    --Bus Monitor Timeout States
	type bm_error_state_t is (
		ERROR_STATE_INIT_SLAVE_1_DATA_1,
		ERROR_STATE_INIT_SLAVE_1_DATA_2,
		ERROR_STATE_INIT_SLAVE_1_FINISHED,
		ERROR_STATE_INIT_SLAVE_2_DATA_1,
		ERROR_STATE_INIT_SLAVE_2_DATA_2,
		ERROR_STATE_INIT_SLAVE_2_FINISHED,
		ERROR_STATE_MASTER_DATA_RECEIVED,
		ERROR_STATE_SLAVE_DATA_RECEIVED,
		ERROR_STATE_SLAVE_ACK_RECEIVED
	);
	
	signal bm_error_state      : bm_error_state_t;
    signal bm_error_state_next : bm_error_state_t;
    
    signal reconfiguration_device       : std_logic_vector(1 downto 0);
    signal reconfiguration_device_next  : std_logic_vector(1 downto 0);
    
    signal slave_address        : std_logic_vector(1 downto 0);
    signal slave_address_next   : std_logic_vector(1 downto 0);

begin

    --data synchronization process (clocked)
	data_sync : process(CLK,RST)
	begin
	
        if(RST = '1') then

			bm_error_state <= ERROR_STATE_INIT_SLAVE_1_DATA_1;
			reconfiguration_device <= "00";
			slave_address <= "00";

        elsif(rising_edge(CLK)) then

            bm_error_state <= bm_error_state_next;
            reconfiguration_device <= reconfiguration_device_next;
            slave_address <= slave_address_next;

        end if;
	
    end process data_sync;

    --error state machine process (combinatorial)
    error_state_machine : process(  UART_RX_DATA_VALID,
                                    bm_error_state,
                                    reconfiguration_device,
                                    UART_RX_DATA,
                                    slave_address)
    begin
    
        --prevent latches
        reconfiguration_device_next <= reconfiguration_device;
        bm_error_state_next <= bm_error_state;
        slave_address_next <= slave_address;
        
        --check if uart provides valid data
        if(UART_RX_DATA_VALID = '1') then
            case bm_error_state is
                when ERROR_STATE_INIT_SLAVE_1_DATA_1 =>
                    bm_error_state_next <= ERROR_STATE_INIT_SLAVE_1_DATA_2;
                    
                    if(UART_RX_DATA /= x"1C") then
                        --wrong ECU behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_ECU;
                    end if;
                when ERROR_STATE_INIT_SLAVE_1_DATA_2 =>
                    bm_error_state_next <= ERROR_STATE_INIT_SLAVE_1_FINISHED;
                    
                    if(UART_RX_DATA /= x"1C") then
                        --wrong ECU behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_ECU;
                    end if;
                when ERROR_STATE_INIT_SLAVE_1_FINISHED =>
                    bm_error_state_next <= ERROR_STATE_INIT_SLAVE_2_DATA_1;
                
                    if(UART_RX_DATA(7 downto 6) /= ADDRESS_ECU) then
                        --wrong THS behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_THS;
                    end if;
                when ERROR_STATE_INIT_SLAVE_2_DATA_1 =>
                    bm_error_state_next <= ERROR_STATE_INIT_SLAVE_2_DATA_2;
                
                    if(UART_RX_DATA(7 downto 6) /= ADDRESS_MCU) then
                        --wrong ECU behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_ECU;
                    end if;
                when ERROR_STATE_INIT_SLAVE_2_DATA_2 =>
                    bm_error_state_next <= ERROR_STATE_INIT_SLAVE_2_FINISHED;
                
                    if(UART_RX_DATA(7 downto 6) /= ADDRESS_MCU) then
                        --wrong ECU behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_ECU;
                    end if;
                when ERROR_STATE_INIT_SLAVE_2_FINISHED =>
                    bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                    
                    if(UART_RX_DATA /= x"3B") then
                        --wrong MCU behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_MCU;
                    end if;
                when ERROR_STATE_MASTER_DATA_RECEIVED =>
                    if(UART_RX_DATA(7 downto 6) = "00") then
                        bm_error_state_next <= ERROR_STATE_SLAVE_DATA_RECEIVED;   
                        slave_address_next <= UART_RX_DATA(5 downto 4);
                        
                        if((UART_RX_DATA(5 downto 4) /= ADDRESS_MCU and
                            UART_RX_DATA(5 downto 4) /= ADDRESS_THS) or
                            UART_RX_DATA(3 downto 2) /= ADDRESS_ECU or
                            UART_RX_DATA(1 downto 0) = "01" or
                            UART_RX_DATA(1 downto 0) = "10") then
                            
                            --wrong ECU behaviour, init reconfiguration
                            reconfiguration_device_next <= ADDRESS_ECU;
                        end if;
                    elsif(UART_RX_DATA(7 downto 6) = ADDRESS_ECU) then
                        bm_error_state_next <= ERROR_STATE_SLAVE_ACK_RECEIVED;
                        
                        --wrong ECU behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_ECU;
                    else
                        bm_error_state_next <= ERROR_STATE_SLAVE_ACK_RECEIVED;
                        
                        slave_address_next <= UART_RX_DATA(7 downto 6);
                    end if;
                when ERROR_STATE_SLAVE_DATA_RECEIVED =>
                    bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                    
                    if(UART_RX_DATA(7 downto 6) /= ADDRESS_ECU) then
                        --wrong slave behaviour, init reconfiguration
                        reconfiguration_device_next <= slave_address;
                    end if;
                when ERROR_STATE_SLAVE_ACK_RECEIVED =>
                    bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                    
                    if( UART_RX_DATA(7 downto 6) /= "00" or
                        UART_RX_DATA(5 downto 4) /= ADDRESS_ECU or
                        UART_RX_DATA(3 downto 2) /= slave_address or
                        UART_RX_DATA(1 downto 0) = "01" or
                        UART_RX_DATA(1 downto 0) = "10") then
                        
                        --wrong slave behaviour, init reconfiguration
                        reconfiguration_device_next <= slave_address;
                        end if;
                when others =>
                    --should no be reached
            end case;
        end if;
    
    end process error_state_machine;

    RECFG <=    reconfiguration_device when EN='1' else
                "00" when EN='0';

end Behavioral;
