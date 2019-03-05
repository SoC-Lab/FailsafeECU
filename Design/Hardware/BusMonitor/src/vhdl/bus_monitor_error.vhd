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

entity bus_monitor_error is
    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           UART_RX_DATA : in STD_LOGIC_VECTOR(7 downto 0);
           UART_RX_DATA_VALID : in STD_LOGIC;
           RECFG : out STD_LOGIC_VECTOR (1 downto 0);
           EN : in STD_LOGIC);
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
		ERROR_STATE_INIT_1,
		ERROR_STATE_INIT_2,
		ERROR_STATE_MASTER_DATA_RECEIVED,
		ERROR_STATE_SLAVE_DATA_RECEIVED,
		ERROR_STATE_SLAVE_DATA_RETRY,
		ERROR_STATE_SLAVE_ACK_RECEIVED,
		ERROR_STATE_SLAVE_ACK_RETRY,
		ERROR_STATE_STOP
	);
	
	signal bm_error_state      : bm_error_state_t;
    signal bm_error_state_next : bm_error_state_t;
    
    signal reconfiguration_device       : std_logic_vector(1 downto 0);
    signal reconfiguration_device_next  : std_logic_vector(1 downto 0);
    
    signal slave_address        : std_logic_vector(1 downto 0);
    signal slave_address_next   : std_logic_vector(1 downto 0);
    
    signal received_master_data        : std_logic_vector(7 downto 0);
    signal received_master_data_next   : std_logic_vector(7 downto 0);
    
    

begin

    --data synchronization process (clocked)
	data_sync : process(CLK,RST)
	begin
	
        if(RST = '1') then

			bm_error_state <= ERROR_STATE_INIT_1;
			reconfiguration_device <= "00";
			slave_address <= "00";
			received_master_data <= x"00";

        elsif(rising_edge(CLK) and EN = '1') then

            bm_error_state <= bm_error_state_next;
            reconfiguration_device <= reconfiguration_device_next;
            slave_address <= slave_address_next;
            received_master_data <= received_master_data_next;

        end if;
	
    end process data_sync;

    --error state machine process (combinatorial)
    error_state_machine : process(  UART_RX_DATA_VALID,
                                    bm_error_state,
                                    reconfiguration_device,
                                    UART_RX_DATA,
                                    slave_address,
                                    received_master_data,
                                    EN)
    begin
    
        --prevent latches
        reconfiguration_device_next <= reconfiguration_device;
        bm_error_state_next <= bm_error_state;
        slave_address_next <= slave_address;
        received_master_data_next <= received_master_data;
        
        --check if uart provides valid data
        if(UART_RX_DATA_VALID = '1' and EN = '1') then
            case bm_error_state is
                when ERROR_STATE_INIT_1 =>
                    --necessary because during startup a faulty byte might be received
                    bm_error_state_next <= ERROR_STATE_INIT_2;
                when ERROR_STATE_INIT_2 =>
                    if((UART_RX_DATA(7 downto 6) = "00" and UART_RX_DATA(3 downto 2) = ADDRESS_ECU) or (UART_RX_DATA(7 downto 6) /= ADDRESS_ECU)) then
                        --if first packet after init is a master packet, discard next slave packet
                        bm_error_state_next <= ERROR_STATE_INIT_2;
                    else
                        bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                    end if;
                when ERROR_STATE_MASTER_DATA_RECEIVED =>
                    received_master_data_next <= UART_RX_DATA;
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
                            bm_error_state_next <= ERROR_STATE_STOP;
                        end if;
                    elsif(UART_RX_DATA(7 downto 6) = ADDRESS_ECU) then
                        --wrong ECU behaviour, init reconfiguration
                        reconfiguration_device_next <= ADDRESS_ECU;
                        bm_error_state_next <= ERROR_STATE_STOP;
                    else
                        bm_error_state_next <= ERROR_STATE_SLAVE_ACK_RECEIVED;
                        
                        slave_address_next <= UART_RX_DATA(7 downto 6);
                    end if;
                when ERROR_STATE_SLAVE_DATA_RECEIVED =>
                    if(UART_RX_DATA = received_master_data) then
                        bm_error_state_next <= ERROR_STATE_SLAVE_DATA_RETRY;
                    else
                        bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                        
                        if(UART_RX_DATA(7 downto 6) /= ADDRESS_ECU) then
                            --wrong slave behaviour, init reconfiguration
                            reconfiguration_device_next <= slave_address;
                            bm_error_state_next <= ERROR_STATE_STOP;
                        end if;
                    end if;
                when ERROR_STATE_SLAVE_DATA_RETRY =>
                    if(UART_RX_DATA = received_master_data) then
                        --wrong slave behaviour, init reconfiguration
                        reconfiguration_device_next <= slave_address;
                        
                        bm_error_state_next <= ERROR_STATE_STOP;
                    else
                        bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                                            
                        if(UART_RX_DATA(7 downto 6) /= ADDRESS_ECU) then
                            --wrong slave behaviour, init reconfiguration
                            reconfiguration_device_next <= slave_address;
                            bm_error_state_next <= ERROR_STATE_STOP;
                        end if;
                    end if;
                when ERROR_STATE_SLAVE_ACK_RECEIVED =>
                    if(UART_RX_DATA = received_master_data) then
                        bm_error_state_next <= ERROR_STATE_SLAVE_ACK_RETRY;
                    else
                        bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                        
                        if( UART_RX_DATA(7 downto 6) /= "00" or
                            UART_RX_DATA(5 downto 4) /= ADDRESS_ECU or
                            UART_RX_DATA(3 downto 2) /= slave_address or
                            UART_RX_DATA(1 downto 0) = "01" or
                            UART_RX_DATA(1 downto 0) = "10") then
                            
                            --wrong slave behaviour, init reconfiguration
                            reconfiguration_device_next <= slave_address;
                            bm_error_state_next <= ERROR_STATE_STOP;
                        end if;
                    end if;
                when ERROR_STATE_SLAVE_ACK_RETRY =>
                    if(UART_RX_DATA = received_master_data) then
                        --wrong slave behaviour, init reconfiguration
                        reconfiguration_device_next <= slave_address;
                        
                        bm_error_state_next <= ERROR_STATE_STOP;
                    else
                        bm_error_state_next <= ERROR_STATE_MASTER_DATA_RECEIVED;
                        
                        if( UART_RX_DATA(7 downto 6) /= "00" or
                            UART_RX_DATA(5 downto 4) /= ADDRESS_ECU or
                            UART_RX_DATA(3 downto 2) /= slave_address or
                            UART_RX_DATA(1 downto 0) = "01" or
                            UART_RX_DATA(1 downto 0) = "10") then
                            
                            --wrong slave behaviour, init reconfiguration
                            reconfiguration_device_next <= slave_address;
                            bm_error_state_next <= ERROR_STATE_STOP;
                        end if;
                    end if;
                when ERROR_STATE_STOP =>
                    --do nothing
                when others =>
                    --should no be reached
            end case;
        end if;
    
    end process error_state_machine;

    RECFG <=    reconfiguration_device;

end Behavioral;
