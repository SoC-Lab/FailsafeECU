----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.12.2018 20:45:23
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           UART_RX_EXT : in STD_LOGIC;
           UART_TX_EXT : out STD_LOGIC;
           UART_RX_INT : out STD_LOGIC;
           UART_TX_INT : in STD_LOGIC;
           RECFG : out STD_LOGIC_VECTOR (1 downto 0));
end top;

architecture Behavioral of top is

    --clock frequency should be set to 1E6 for simulation
    constant CLK_FREQ    	: integer := 100E6;	-- clock frequency
	constant BAUDRATE    	: integer := 38400; -- UART baudrate
	--master timeout should be set to 300 for simulation
	constant MASTER_TIMEOUT : integer := 1000; --ms
	--slave timeout should be set to 150 for simulation
	constant SLAVE_TIMEOUT  : integer := 500; --ms
    
    signal data_in              : std_logic_vector(7 downto 0);
    signal data_ready           : std_logic;

    signal reconfigured_device_timeout : std_logic_vector(1 downto 0);
    signal reconfigured_device_error : std_logic_vector(1 downto 0);
    
    signal reconfigured_device : std_logic_vector(1 downto 0);
    signal reconfigured_device_next : std_logic_vector(1 downto 0);

begin

    --instantiate UART receive component
	uart_receive : entity work.uart_rx
		generic map(
			CLK_FREQ => CLK_FREQ,
			BAUDRATE => BAUDRATE
		)

		port map(
			clk   		=> CLK,
			rst   		=> RST,
			rx  		=> UART_RX_EXT,
			data  		=> data_in,
			data_new	=> data_ready
		);
		
	--instantiate bus monitor timeout component
	bus_monitor_timeout : entity work.bus_monitor_timeout
		generic map(
			CLK_FREQ => CLK_FREQ,
			MASTER_TIMEOUT => MASTER_TIMEOUT,
			SLAVE_TIMEOUT => SLAVE_TIMEOUT
		)

		port map(
			RST   		=> RST,
			CLK   		=> CLK,
			EN  		=> EN,
			UART_RX_DATA => data_in,
			UART_RX_DATA_VALID	=> data_ready,
			RECFG => reconfigured_device_timeout
		);
		
	--instantiate bus monitor error component
	bus_monitor_error : entity work.bus_monitor_error
		port map(
			RST   		=> RST,
			CLK   		=> CLK,
			EN  		=> EN,
			UART_RX_DATA => data_in,
			UART_RX_DATA_VALID	=> data_ready,
			RECFG => reconfigured_device_error
		);
		
		
    --data synchronization (clocked)
	data_sync : process(CLK,RST)
	begin

		if(RST = '1') then

            reconfigured_device <= "00";

		elsif(rising_edge(CLK)) then

            reconfigured_device <= reconfigured_device_next;

		end if;

	end process data_sync;
	
	--selection of reconfigured device (combinatorial)
	reconfigured_device_selection : process(   reconfigured_device_error,
	                                           reconfigured_device_timeout,
	                                           reconfigured_device)
	begin
	
	   --prevent latches
	   reconfigured_device_next <= reconfigured_device;
	
	   if(reconfigured_device_error /= "00") then
	       reconfigured_device_next <= reconfigured_device_error;
	   elsif(reconfigured_device_timeout /= "00") then
	       reconfigured_device_next <= reconfigured_device_timeout;
	   else
	       reconfigured_device_next <= "00";
	   end if;
	
	end process reconfigured_device_selection;
	
	RECFG <= reconfigured_device;
	
	UART_TX_EXT <= UART_TX_INT when reconfigured_device = "00" else '1';
	
	UART_RX_INT <= UART_RX_EXT when reconfigured_device = "00" else '1';
    
end Behavioral;
