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
-- Revision 1.1
-- Additional Comments:
-- 0.01: Initial implementation
-- 1.0: retry mechanism added
-- 1.1: REC_BLK added
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
           REC_ECU : out STD_LOGIC;
           REC_MCU : out STD_LOGIC;
           REC_THS : out STD_LOGIC;
           REC_BLK : out STD_LOGIC;
           MCU_GPIO_INT : in STD_LOGIC;
           MCU_GPIO_EXT : out STD_LOGIC);
end top;

architecture Behavioral of top is

    --clock frequency should be set to 1E6 for simulation, 100E6 for implementation
    constant CLK_FREQ    	: integer := 100E6;	-- clock frequency
    --baudrate should be set to 38400 for simulation, 9600 for implementation
	constant BAUDRATE    	: integer := 9600; -- UART baudrate
	--master timeout should be set to 300 for simulation, 2000 for implementation
	constant MASTER_TIMEOUT : integer := 2000; --ms
	--electronic control unit address (master)
    constant ADDRESS_ECU    : std_logic_vector(1 downto 0) := "11";
    --throttle sensor address (slave)
    constant ADDRESS_THS    : std_logic_vector(1 downto 0) := "01";
    --motor control unit address (slave)
    constant ADDRESS_MCU    : std_logic_vector(1 downto 0) := "10";
    --startup delay cycles
    constant STARTUP_DELAY_CYCLES   : integer := 200E6;
    
    signal data_in              : std_logic_vector(7 downto 0);
    signal data_ready           : std_logic;

    signal reconfigured_device_timeout : std_logic_vector(1 downto 0);
    signal reconfigured_device_error : std_logic_vector(1 downto 0);
    
    signal reconfigured_device : std_logic_vector(1 downto 0);
    signal reconfigured_device_next : std_logic_vector(1 downto 0);
    
    signal start_delay_counter : integer range 0 to 200E6;
    
    signal enable_monitoring : std_logic;

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
			MASTER_TIMEOUT => MASTER_TIMEOUT
		)

		port map(
			RST   		=> RST,
			CLK   		=> CLK,
			UART_RX_DATA => data_in,
			UART_RX_DATA_VALID	=> data_ready,
			RECFG => reconfigured_device_timeout,
			EN => enable_monitoring
		);
		
	--instantiate bus monitor error component
	bus_monitor_error : entity work.bus_monitor_error
		port map(
			RST   		=> RST,
			CLK   		=> CLK,
			UART_RX_DATA => data_in,
			UART_RX_DATA_VALID	=> data_ready,
			RECFG => reconfigured_device_error,
			EN => enable_monitoring
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
	
	--master watchdog process (clocked)
	start_delay : process(CLK,RST)
	begin
	
	   if(RST = '1') then
	   
	       start_delay_counter <= 0;
	       enable_monitoring <= '0';
	   
	   elsif(rising_edge(CLK)) then
	   
	       if(start_delay_counter >= STARTUP_DELAY_CYCLES) then
               enable_monitoring <= '1';
           else
               start_delay_counter <= start_delay_counter + 1;
           end if;
	   
	   end if;
	
	end process start_delay;
	
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
	
	REC_BLK <= '1' when reconfigured_device = "00" and EN = '1' else '0';
	REC_ECU <= '1' when reconfigured_device = ADDRESS_ECU and EN = '1' else '0';
	REC_MCU <= '1' when reconfigured_device = ADDRESS_MCU and EN = '1' else '0';
	REC_THS <= '1' when reconfigured_device = ADDRESS_THS and EN = '1' else '0';
	
	UART_TX_EXT <= UART_TX_INT when reconfigured_device /= "00" else '1';
	UART_RX_INT <= UART_RX_EXT when reconfigured_device /= "00" else '1';
	
	MCU_GPIO_EXT <= MCU_GPIO_INT when reconfigured_device = ADDRESS_MCU and EN = '1' else '1';
    
end Behavioral;
