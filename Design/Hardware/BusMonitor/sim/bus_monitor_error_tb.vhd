----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.01.2019 18:45:38
-- Design Name: 
-- Module Name: bus_monitor_error_tb - Behavioral
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

entity bus_monitor_error_tb is
--  Port ( );
end bus_monitor_error_tb;

architecture Behavioral of bus_monitor_error_tb is

    constant CLK_PERIOD    : time:= 1 us;
    constant SEND_DELAY	   : time := 1 ms;

    signal rst : std_logic;
    signal clk : std_logic;
    signal en : std_logic := '1';
    signal uart_rx_data : std_logic_vector(7 downto 0);
    signal uart_rx_data_valid : std_logic;
    signal recfg : std_logic_vector(1 downto 0);

begin

    DUV : entity work.bus_monitor_error
		port map(
			RST => rst,
			CLK => clk,
			UART_RX_DATA => uart_rx_data,
			UART_RX_DATA_VALID => uart_rx_data_valid,
			RECFG => recfg
		);
		
    clk_gen : process
	begin

		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;

	end process clk_gen;
	
	test : process
	
		variable master_send_byte_1   : std_logic_vector(7 downto 0) := x"1C";
		variable master_send_byte_2   : std_logic_vector(7 downto 0) := x"BF";
		variable slave_send_byte_1   : std_logic_vector(7 downto 0) := x"FF";
		variable slave_send_byte_2   : std_logic_vector(7 downto 0) := x"3B";
		
		variable master_send_byte_error_1   : std_logic_vector(7 downto 0) := x"11";
		
		variable slave_send_byte_error_1   : std_logic_vector(7 downto 0) := x"01";

	begin

		-- reset --
		rst <='1';
		wait for(2.1*CLK_PERIOD);
		rst <='0';

        wait for 10 ns;

        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected after reset"
			severity failure;

        -- initialization phase slave 1 --
        uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 1"
			severity failure;
        
        uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 1"
			severity failure;
			
        uart_rx_data <= slave_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 1"
			severity failure;

        -- initialization phase slave 2 --
        uart_rx_data <= master_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 2"
			severity failure;
        
        uart_rx_data <= master_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 2"
			severity failure;
			
        uart_rx_data <= slave_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 2"
			severity failure;


        -- normal operation --
        uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
        
        uart_rx_data <= slave_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
			
        uart_rx_data <= master_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        uart_rx_data <= slave_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
			
		uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
        
        uart_rx_data <= slave_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
			
		--######################################################################
		--check master error behaviour
		
		uart_rx_data <= master_send_byte_error_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "11"
			report "TEST FAILED: normal operation detected during error"
			severity failure;
			
		-- reset --
		rst <='1';
		wait for(2.1*CLK_PERIOD);
		rst <='0';

        wait for 10 ns;

        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected after reset"
			severity failure;

        -- initialization phase slave 1 --
        uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 1"
			severity failure;
        
        uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 1"
			severity failure;
			
        uart_rx_data <= slave_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 1"
			severity failure;

        -- initialization phase slave 2 --
        uart_rx_data <= master_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 2"
			severity failure;
        
        uart_rx_data <= master_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 2"
			severity failure;
			
        uart_rx_data <= slave_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during initialization phase 2"
			severity failure;


        -- normal operation --
        uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
        
        uart_rx_data <= slave_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
			
        uart_rx_data <= master_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        uart_rx_data <= slave_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
			
		uart_rx_data <= master_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
        
        uart_rx_data <= slave_send_byte_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
			
		--######################################################################
		--check slave error behaviour
		
		uart_rx_data <= master_send_byte_2;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;
			
		uart_rx_data <= slave_send_byte_error_1;
        wait for 10 ns;
        uart_rx_data_valid <= '1';
        wait for CLK_PERIOD;
        uart_rx_data_valid <= '0';
        wait for SEND_DELAY;
        
        --check for reconfiguration device
		assert recfg = "10"
			report "TEST FAILED: normal operation detected during error"
			severity failure;
			
		report "TEST PASSED" severity NOTE;
		report "user forced exit of simulation" severity failure;

	end process test;

end Behavioral;
