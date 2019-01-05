----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.12.2018 12:26:39
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is

    constant CLK_PERIOD    : time := 1 us;
    constant SEND_DELAY	   : time := 1 ms;
    constant BIT_PERIOD    : time := 26 us;

    signal rst : std_logic;
    signal clk : std_logic;
    signal en : std_logic := '1';
    signal uart_rx : std_logic;
    signal recfg : std_logic_vector(1 downto 0);

begin

    DUV : entity work.top
		port map(
			CLK => clk,
			RST => rst,
			EN => en,
			UART_RX => uart_rx,
			RECFG => recfg
		);

    --create clock, duty cycle 1:1
	clk_process: process
	begin
		clk<='0';
		wait for CLK_PERIOD/2;
		clk<='1';
		wait for CLK_PERIOD/2;
	end process;
	
	--main test procedure
	test: process
	    variable idle_bit	: std_logic := '1';
		variable start_bit	: std_logic := '0';
		variable stop_bit	: std_logic := '1';
		
		--bytes are reverted for uart transmission simulation
		variable master_send_byte_1		: std_logic_vector(7 downto 0) := "00111000"; --x1C (reverted)
		variable master_send_byte_2		: std_logic_vector(7 downto 0) := "11111101"; --xBF (reverted)
		
		variable slave_send_byte_1		: std_logic_vector(7 downto 0) := "11111111"; --xFF
		variable slave_send_byte_2		: std_logic_vector(7 downto 0) := "11011100"; --x3B (reverted)
		variable slave_send_error_byte_1	: std_logic_vector(7 downto 0) := "11111110"; --x7F (reverted)
		
		
		variable uart_master_byte_1       : std_logic_vector(0 to 12) :=
			idle_bit & idle_bit & start_bit & master_send_byte_1 & stop_bit & idle_bit;
        variable uart_master_byte_2       : std_logic_vector(0 to 12) :=
			idle_bit & idle_bit & start_bit & master_send_byte_2 & stop_bit & idle_bit;
		variable uart_slave_byte_1       : std_logic_vector(0 to 12) :=
			idle_bit & idle_bit & start_bit & slave_send_byte_1 & stop_bit & idle_bit;
		variable uart_slave_byte_2       : std_logic_vector(0 to 12) :=
			idle_bit & idle_bit & start_bit & slave_send_byte_2 & stop_bit & idle_bit;
		variable uart_slave_error_byte_1 : std_logic_vector(0 to 12) :=
			idle_bit & idle_bit & start_bit & slave_send_error_byte_1 & stop_bit & idle_bit;

	begin
		wait for (2 * CLK_PERIOD);


		--#####################################################################
		--reset


		--perform asynchronous reset
		rst <= '1';
		wait for (2.1 * CLK_PERIOD);
		rst <= '0';

		wait until rising_edge(clk);
		wait for 10 ns;
		
		--check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during reset"
			severity failure;

        --#####################################################################
        --test cases:
        --1.) initialization phase
        --2.) normal operation
        --3.) slave transmitts invalid data
        --4.) master runs into timeout
        --#####################################################################

		--#####################################################################
		--test case 1
		--master initializes slaves (6 bytes to transmit)

		-- feed uart_master_byte_1 bits
		for i in 0 to 12 loop
            uart_rx <= uart_master_byte_1(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_master_byte_1 bits
		for i in 0 to 12 loop
            uart_rx <= uart_master_byte_1(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_slave_byte_1 bits
		for i in 0 to 12 loop
            uart_rx <= uart_slave_byte_1(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_master_byte_2 bits
        for i in 0 to 12 loop
            uart_rx <= uart_master_byte_2(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_master_byte_2 bits
		for i in 0 to 12 loop
            uart_rx <= uart_master_byte_2(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_slave_byte_2 bits
		for i in 0 to 12 loop
            uart_rx <= uart_slave_byte_2(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
		--#####################################################################
        --test case 2
		--normal operation (4 bytes to transmit, 2 bytes per slave)
		
        -- feed uart_master_byte_1 bits
		for i in 0 to 12 loop
            uart_rx <= uart_master_byte_1(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_slave_byte_1 bits
		for i in 0 to 12 loop
            uart_rx <= uart_slave_byte_1(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_master_byte_2 bits
		for i in 0 to 12 loop
            uart_rx <= uart_master_byte_2(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_slave_byte_2 bits
		for i in 0 to 12 loop
            uart_rx <= uart_slave_byte_2(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;

        --#####################################################################
        --test case 3
		--slave responds invalid byte
		
        -- feed uart_master_byte_1 bits
		for i in 0 to 12 loop
            uart_rx <= uart_master_byte_1(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during normal operation"
			severity failure;

        wait for SEND_DELAY;
        
        -- feed uart_slave_error_byte_1 bits
		for i in 0 to 12 loop
            uart_rx <= uart_slave_error_byte_1(i);
            wait for BIT_PERIOD;
        end loop;

        --check for reconfigured device
		assert recfg = "01"
			report "TEST FAILED: normal operation detected during THS error"
			severity failure;

        wait for SEND_DELAY;
        
        
        --#####################################################################
        --test case 4
		--master runs into timeout
        
        --perform asynchronous reset
		rst <= '1';
		wait for (2.1 * CLK_PERIOD);
		rst <= '0';

		wait until rising_edge(clk);
		wait for 10 ns;
		
		--check for reconfigured device
		assert recfg = "00"
			report "TEST FAILED: error detected during reset"
			severity failure;
			
		wait for 310ms;	
		
		--check for reconfigured device
		assert recfg = "11"
			report "TEST FAILED: normal operation detected during ECU timeout"
			severity failure;
        
        --#####################################################################
		report "TEST PASSED" severity NOTE;
		report "user forced exit of simulation" severity failure;

				
		end process;

end Behavioral;