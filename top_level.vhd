library ieee;
	use ieee.std_logic_1164.all;
	

entity top_level is 
	port(
		clk_50 			: in std_logic;	-- connected to internal PLL
		key_n 			: in std_logic_vector(3 downto 0);	
		fpga_in_rx 		: in std_logic;	-- serial input data
		
		fpga_out_rx 	: out std_logic;	-- serial output data
		ledg0 			: out std_logic; 
		ledr0 			: out std_logic;
		hex0 				: out std_logic_vector(6 downto 0);
		hex1 				: out std_logic_vector(6 downto 0);
		hex2 				: out std_logic_vector(6 downto 0));
end entity top_level;


architecture rtl of top_level is

	-- 
	
	-- signals
	signal received_byte_data 				: std_logic_vector(7 downto 0);
	signal received_bit_valid 				: std_logic := '0';
	signal transmit_byte_data 				: std_logic_vector(7 downto 0) := (others => '0');
	--signal reset_uart 						: std_logic := '0';
	
	-- constants
	constant c_reset_active_state 		: std_logic := '1';   
	constant c_serial_speed_bps 			: natural := 115200;     
	constant c_clk_period_ns 				: natural := 20; 
	constant c_parity							: natural := 0;
	--constant c_transmit_valid			   : std_logic := '0';

-- PLL 

-- reset handler

-- key ctrl

-- serial uart

	-- component serial_uart
	component serial_uart is
		generic(
			g_reset_active_state    : std_logic                      := '1';
			g_serial_speed_bps      : natural range 9600 to 115200   := 115200;
			g_clk_period_ns         : natural range 10 to 100        := 10;      -- 100 MHz standard clock
			g_parity                : natural range 0 to 2           := 0);      -- 0 = no, 1 = odd, 2 = even
		port(
			clk                     : in  std_logic;
			reset                   : in  std_logic;   -- active high reset
			rx                      : in  std_logic;
			tx                      : out std_logic;
	
			received_data           : out std_logic_vector(7 downto 0); -- Received data
			received_valid          : out std_logic;  -- Set high one clock cycle when byte is received.
			received_error          : out std_logic;  -- Stop bit was not high
			received_parity_error   : out std_logic;  -- Parity error detected
	
			transmit_ready          : out std_logic;
			transmit_valid          : in  std_logic;
			transmit_data           : in  std_logic_vector(7 downto 0));
	end component serial_uart;

-- serial ctrl

-- DC disp ctrl

-- pwm ctrl

	begin
	
	i_serial_uart : serial_uart
		generic map(
			g_reset_active_state    => c_reset_active_state,
			g_serial_speed_bps      => c_serial_speed_bps,
			g_clk_period_ns         => c_clk_period_ns,
			g_parity						=> c_parity
		)
		port map(
			clk                     => clk_50,
			reset                   => reset_uart,
			rx                      => rx_in, 
			tx                      => open,
	
			received_data           => received_byte_data,
			received_valid          => received_bit_valid,
			received_error          => ledr0,
			received_parity_error   => open,
	
			transmit_ready          => open,
			transmit_valid          => '0',
			transmit_data				=> transmit_byte_data
		);



end architecture rtl;