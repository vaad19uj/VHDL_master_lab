library ieee;
	use ieee.std_logic_1164.all;
	

entity top_level is 
	generic(
		g_simulation 	: boolean);
	port(
		clock_50 		: in std_logic;	-- connected to internal PLL
		key_n 			: in std_logic_vector(3 downto 0);	
		fpga_in_rx 		: in std_logic;	-- serial input data
		
		fpga_out_tx 	: out std_logic;	-- serial output data
		--ledg0 			: out std_logic; 
		--ledr0 			: out std_logic;
		ledr           : std_logic_vector(9 downto 0);
		ledg           : std_logic_vector(7 downto 0);
		hex0 				: out std_logic_vector(6 downto 0);
		hex1 				: out std_logic_vector(6 downto 0);
		hex2 				: out std_logic_vector(6 downto 0));
end entity top_level;


architecture rtl of top_level is
	
	-- signals

	-- constants
	constant c_reset_active_state 		: std_logic := '1';   
	constant c_serial_speed_bps 			: natural := 115200;     
	constant c_clk_period_ns 				: natural := 20; 
	constant c_parity							: natural := 0;


	begin
	
	b_gen_pll : if (not g_simulation) generate
   -- Instance of PLL
      i_altera_pll : entity work.altera_pll
      port map(
         areset						=> '0',        -- Reset towards PLL is inactive
         inclk0						=> clock_50,   -- 50 MHz input clock
         c0		      				=> open,       -- 25 MHz output clock unused
         c1		      				=> clk_50,     -- 50 MHz output clock
         c2		      				=> open,       -- 100 MHz output clock unused
         locked						=> pll_locked);-- PLL Locked output signal
			

	i_reset_ctrl : entity work.reset_ctrl
      generic map(
         g_reset_hold_clk  		=> 127)
      port map(
         clk         				=> clk_50,
         reset_in    				=> '0',
         reset_in_n  				=> pll_locked, -- reset active if PLL is not locked

         reset_out   				=> reset,
         reset_out_n 				=> open);
   end generate;
	

   b_sim_clock_gen : if g_simulation generate
      clk_50   <= clock_50;
      p_internal_reset : process
      begin
         reset    <= '1';
         wait until clock_50 = '1';
         wait for 1 us;
         wait until clock_50 = '1';
         reset    <= '0';
         wait;
      end process p_internal_reset;
   end generate;
	
	
	i_serial_uart : entity work.serial_uart
		generic map(
			g_reset_active_state    => c_reset_active_state,
			g_serial_speed_bps      => c_serial_speed_bps,
			g_clk_period_ns         => c_clk_period_ns,
			g_parity						=> c_parity)
		port map(
			clk                     => clk_50,
			reset                   => reset,
			rx                      => fpga_in_rx, 
			tx                      => fpga_out_tx,
	
			received_data           => received_byte_data,
			received_valid          => received_bit_valid,
			received_error          => ledr(0),
			received_parity_error   => open,
	
			transmit_ready          => transmit_ready,
			transmit_valid          => transmit_bit_valid,
			transmit_data				=> transmit_data);
		

	i_key_ctrl	: entity work.key_ctrl
		port map(
			key_n 						=> key_n,
			clock 						=> clk_50,
			key_on 						=> key_on,
			key_off 						=> key_off,
			key_down 					=> key_down,
			key_up 						=> key_up);
			
			
	i_pwm_ctrl : entity work.pwm_ctrl
		port map(
		serial_on						=> serial_on,
		serial_off						=> serial_off,
		serial_up 						=> serial_up,
		serial_down 					=> serial_down,
		clk 								=> clk_50,
		
		key_on							=> key_on,
		key_off							=> key_off,
		key_up 							=> key_up,
		key_down 						=> key_down,
		current_dc_update				=> current_dc_update,
		ledg0 							=> ledg(0),
		current_dc						=> current_dc);
		
		
	i_serial_ctrl : entity work.serial_ctrl
		port map(
		received_byte_data 			=> received_data,
		received_bit_valid			=> received_valid,
		clk								=> clk_50,
		serial_up 						=> serial_up,
		serial_down 					=> serial_down,
		serial_off 						=> serial_off,
		serial_on 						=> serial_on);
		
		
	i_dc_disp_ctrl : entity work.dc_disp_ctrl
		port map(
		transmit_ready					=> transmit_ready,
		current_dc_update				=> current_dc_update,
		clk								=> clk_50,
		transmit_bit_valid 			=> transmit_valid,
		transmit_data					=> transmit_data,
		hex0								=> hex0,
		hex1								=> hex1,
		hex2								=> hex2,
		reset								=> reset,
		current_dc						=> current_dc);

end architecture rtl;