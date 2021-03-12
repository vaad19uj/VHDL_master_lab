library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
entity dc_disp_ctrl is 
	port(
		transmit_ready				: in std_logic;
		current_dc_update			: in std_logic;
		clk							: in std_logic;
		transmit_valid 			: out std_logic;
		transmit_data				: out std_logic_vector(7 downto 0);
		hex0							: out std_logic_vector(6 downto 0);	-- ones
		hex1							: out std_logic_vector(6 downto 0); -- tens
		hex2							: out std_logic_vector(6 downto 0);	-- hundreds
		reset							: in std_logic;
		current_dc					: in std_logic_vector(7 downto 0));
end entity dc_disp_ctrl;


architecture rtl of dc_disp_ctrl is

	-- types
	type t_bcd_state is (s_idle, s_wait, s_done);
	type t_transmit_byte_state is (s_idle, s_first, s_second, s_third, s_fourth, s_fifth);
	--type t_transmit_byte_state is (s_idle, s_hundreds, s_tens, s_ones, s_percent, s_carriage_return);
	
	-- components
	component bcd_decode is
   port(
      clk                     : in  std_logic;
      reset                   : in  std_logic;   -- active high reset
      input_vector            : in  std_logic_vector(7 downto 0);	
      valid_in                : in  std_logic;
      ready                   : out std_logic;  -- ready for data when high
      bcd_0                   : out std_logic_vector(3 downto 0); -- ones
      bcd_1                   : out std_logic_vector(3 downto 0); -- tens
      bcd_2                   : out std_logic_vector(3 downto 0); -- hundreds
      valid_out               : out std_logic); -- Set high one clock cycle when bcd* is valid
	end component bcd_decode;
	
	
	-- signals
	signal ASCII_dc_0 						: std_logic_vector(7 downto 0);
	signal ASCII_dc_1 						: std_logic_vector(7 downto 0);
	signal ASCII_dc_2 						: std_logic_vector(7 downto 0);
	signal ready 								: std_logic;
	signal valid_out							: std_logic := '0';
	signal valid_in							: std_logic := '0';
	signal bcd_0								: std_logic_vector(3 downto 0);
	signal bcd_1								: std_logic_vector(3 downto 0);
	signal bcd_2								: std_logic_vector(3 downto 0);
--	signal bcd									: std_logic_vector(7 downto 0);
	signal dc0									: integer range 0 to 9;
	signal dc1									: integer range 0 to 9;
	signal dc2									: integer range 0 to 1;
	signal bcd_state 							: t_bcd_state := s_idle;
	signal transmit_data_byte1				: std_logic_vector(7 downto 0);
	signal transmit_data_byte2				: std_logic_vector(7 downto 0);
	signal transmit_data_byte3				: std_logic_vector(7 downto 0);
	signal transmit_data_byte4				: std_logic_vector(7 downto 0);
	signal transmit_data_byte5				: std_logic_vector(7 downto 0);
	signal transmit_state					: t_transmit_byte_state := s_idle;
	signal dc									: integer range 0 to 100 := 0;
	signal transmit							: std_logic := '0'; -- flag to check transmit
	signal send_byte							: std_logic := '0';
	
	-- constants
	constant percent		 			: std_logic_vector(7 downto 0) := X"25";	
	constant space 		 			: std_logic_vector(7 downto 0) := X"20";	
	constant carriage_return 		: std_logic_vector(7 downto 0) := X"0D";	

	begin
	
		i_bcd_decode : bcd_decode
		port map(
			clk                     => clk,
			reset                   => reset, 
			input_vector            =>	current_dc,
			valid_in                => valid_in,
			ready                   => ready,
			bcd_0                   => bcd_0,
			bcd_1                   => bcd_1,
			bcd_2                   => bcd_2,
			valid_out               => valid_out
		); 
		
		
--		p_serial : process(clk)
--		begin
--		
--			if rising_edge(clk) then
--			
--			transmit_valid <= '0';
--			
--				case transmit_state is
--				
--				when s_idle =>
--					
--					if transmit_ready = '1' then
--						transmit_state <= s_hundreds;
--					end if;
--				
--					transmit_valid <= '0';
--				
--				when s_hundreds =>
--				
--					case dc2 is
--					
--						when 0 =>
--						
--							transmit_data <= space;
--							transmit_valid <= '1';
--							transmit_state <= s_tens;
--							hex2 <= (6 => '1', others => '0');
--					
--						when 1 =>
--							
--							transmit_data <= X"31";
--							transmit_valid <= '1';
--							hex2 <= (1 => '0', 2 => '0', others => '1');
--							transmit_state <= s_tens;
--							
--						when others =>
--						
--							transmit_valid <= '0';
--					
--					end case;
--				
--				when s_tens =>
--				
--					case dc1 is
--						
--						when 0 =>
--							
--							transmit_data <= X"30";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (6 => '1', others => '0');
--							
--						
--						when 1 =>
--						
--							transmit_data <= X"31";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (1 => '0', 2 => '0', others => '1');
--						
--						when 2 =>
--						
--							transmit_data <= X"32";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
--						
--						when 3 =>
--						
--							transmit_data <= X"33";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
--						
--						when 4 =>
--							
--							transmit_data <= X"34";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
--						
--						when 5 =>
--						
--							transmit_data <= X"35";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
--						
--						when 6 =>
--						
--							transmit_data <= X"36";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
--						
--						when 7 =>
--						
--							transmit_data <= X"37";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
--						
--						when 8 =>
--							
--							transmit_data <= X"38";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (others => '0');
--						
--						when 9 =>
--						
--							transmit_data <= X"39";
--							transmit_valid <= '1';
--							transmit_state <= s_ones;
--							hex1 <= (4 => '1', others => '0');
--						
--						when others =>
--						
--							transmit_valid <= '0';
--							-- "-" for other ASCII values
--							hex1 <= (6 => '0', others => '1');
--					
--					end case;
--				
--				when s_ones =>
--				
--					case dc0 is
--						
--						when 0 =>
--							
--							transmit_data <= X"30";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (6 => '1', others => '0');
--							
--						
--						when 1 =>
--						
--							transmit_data <= X"31";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (1 => '0', 2 => '0', others => '1');
--						
--						when 2 =>
--						
--							transmit_data <= X"32";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
--						
--						when 3 =>
--						
--							transmit_data <= X"33";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
--						
--						when 4 =>
--							
--							transmit_data <= X"34";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
--						
--						when 5 =>
--						
--							transmit_data <= X"35";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
--						
--						when 6 =>
--						
--							transmit_data <= X"36";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
--						
--						when 7 =>
--						
--							transmit_data <= X"37";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
--						
--						when 8 =>
--							
--							transmit_data <= X"38";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (others => '0');
--						
--						when 9 =>
--						
--							transmit_data <= X"39";
--							transmit_valid <= '1';
--							transmit_state <= s_percent;
--							hex0 <= (4 => '1', others => '0');
--						
--						when others =>
--						
--							transmit_valid <= '0';
--							-- "-" for other ASCII values
--							hex0 <= (6 => '0', others => '1');
--					
--					end case;
--				
--				when s_percent =>
--				
--					transmit_data <= percent;
--					transmit_valid <= '1';
--				
--				when s_carriage_return =>
--					
--					transmit_data <= carriage_return;
--					transmit_valid <= '1';
--				
--				end case;
--			
--			end if;
--		end process p_serial;
--		
--		
--		p_convert_to_int : process(clk)
--		begin
--		
--			if rising_edge(clk) then
--				if current_dc_update = '1' then
--					valid_in <= ready;
--					if valid_out = '1' then
--						dc0 <= to_integer(unsigned(bcd_0));
--						dc1 <= to_integer(unsigned(bcd_1));
--						dc2 <= to_integer(unsigned(bcd_2));
--					end if;
--				else
--					valid_in <= '0';
--				end if;
--			end if;
--		end process p_convert_to_int;
		
		
		p_bcd : process(clk)
		begin
			if rising_edge(clk) then
				case bcd_state is
					
					when s_idle =>
					
						if ready = '1' and current_dc_update = '1' then
							bcd_state <= s_wait;
							valid_in <= '1';
						end if;
					
					when s_wait =>
					
						valid_in <= '0';
					
						if valid_out = '1' then
							bcd_state <= s_done;
						end if;
					
					when s_done =>
					
						dc0 <= to_integer(unsigned(bcd_0));
						dc1 <= to_integer(unsigned(bcd_1));
						dc2 <= to_integer(unsigned(bcd_2));
						bcd_state <= s_idle;
					
					when others =>
					
						bcd_state <= s_idle;
				
				end case;
			end if;
		end process p_bcd;
		
		
--		p_bcd : process(clk)
--		begin
--			if rising_edge(clk) then
--			
--				case bcd_state is
--				
--				when s_idle =>
--				
--				bcd <= current_dc;
--				
--					--if current_dc_update = '1' then
--						valid_in <= '1';
--						bcd_state <= s_wait;
--					--end if;
--				
--				when s_wait =>
--					
--					valid_in <= '0';
--					if valid_out = '1' then
--						bcd_state <= s_done;
--					end if;
--				
--				when s_done =>
--				
--					dc0 <= to_integer(unsigned(bcd_0));
--					dc1 <= to_integer(unsigned(bcd_1));
--					dc2 <= to_integer(unsigned(bcd_2));
--					bcd_state <= s_idle;
--					
--				when others =>
--				
--					bcd_state <= s_idle;
--					
--				end case;
--			end if;
--		end process p_bcd;
		
		p_transmit_data : process(clk)
		begin
			if rising_edge(clk) then
			
				if transmit_ready = '1' then
					
					case transmit_state is
						
					when s_idle =>
					
						transmit_valid <= '0';
						transmit <= '0';
						
						--if transmit_ready = '1' then
							transmit_state <= s_first;
						--end if;
					
					when s_first =>
						
						transmit <= '1';
						transmit_data <= transmit_data_byte1;
						transmit_valid <= '1';
					
						--if transmit_ready = '1' then
							--transmit_valid <= '0';
							transmit_state <= s_second;
						--end if;
					
					when s_second =>
					
						transmit_data <= transmit_data_byte2;
						--transmit_valid <= '1';
					
						--if transmit_ready = '1' then
							--transmit_valid <= '0';
							transmit_state <= s_third;
						--end if;
					
					when s_third =>
					
						transmit_data <= transmit_data_byte3;
						--transmit_valid <= '1';
					
						--if transmit_ready = '1' then
							--transmit_valid <= '0';
							transmit_state <= s_fourth;
						--end if;
					
					when s_fourth =>
					
						transmit_data <= transmit_data_byte4;
						--transmit_valid <= '1';
					
						--if transmit_ready = '1' then
							--transmit_valid <= '0';
							transmit_state <= s_fifth;
						--end if;
						
					when s_fifth =>
					
						transmit_data <= transmit_data_byte5;
						--transmit_valid <= '1';
					
						--if transmit_ready = '1' then
							--transmit_valid <= '0';
							transmit_state <= s_idle;
						--end if;
					
					when others =>
						transmit <= '0';
						transmit_state <= s_idle;
						transmit_valid <= '0';
					
					end case;
			
				end if;
			
			end if;
		
		end process p_transmit_data;
		

		p_dc : process(reset, clk)
		begin

			if rising_edge(clk) then
			
				if current_dc_update = '1' then -- if we have an updated dc value
				
				dc <= to_integer(unsigned(current_dc));
				
					if transmit = '0' then			-- only change values when not busy transmitting
					
						if reset = '1' then
							-- 0% duty cycle
							transmit_data_byte1 <= space;
							transmit_data_byte2 <= space;
							transmit_data_byte3 <= ASCII_dc_0;
							transmit_data_byte4 <= percent;
							transmit_data_byte5 <= carriage_return;
							--send_byte <= '1';
						
						else 
							-- 0-9
							if dc > 0 and dc < 10 then
								transmit_data_byte1 <= space;
								transmit_data_byte2 <= space;
								transmit_data_byte3 <= ASCII_dc_0;
								transmit_data_byte4 <= percent;
								transmit_data_byte5 <= carriage_return;
								send_byte <= '1';
						
							-- 10-99
							elsif dc > 9 and dc < 100 then
								
								transmit_data_byte1 <= space;
								transmit_data_byte2 <= ASCII_dc_1;
								transmit_data_byte3 <= ASCII_dc_0;
								transmit_data_byte4 <= percent;
								transmit_data_byte5 <= carriage_return;
								--send_byte <= '1';
						
							-- 100
							elsif dc = 100 then
								transmit_data_byte1 <= ASCII_dc_2;
								transmit_data_byte2 <= ASCII_dc_1;
								transmit_data_byte3 <= ASCII_dc_0;
								transmit_data_byte4 <= percent;
								transmit_data_byte5 <= carriage_return;
								--send_byte <= '1';
							end if;
						end if;
						
						--else
						
--							In the case of a new duty cycle update have been reported before the current duty cycle 
--							information have been fully transmitted on the serial interface the serial send shall be 
--							directly started again when finished in order to update the serial 
--							interface with the latest information. 
						
					end if;
				end if;
			end if;
		end process p_dc;
		
		p_current_dc0 : process(clk, reset)
		begin 
			if rising_edge(clk) then
				if reset = '1' then
					-- zero
					hex0 <= (others => '1');
					ASCII_dc_0 <= X"30";
					
				else
					case dc0 is
						when 0 =>
						-- zero
							ASCII_dc_0 <= X"30";
							hex0 <= (6 => '1', others => '0');
						when 1 =>
						-- one
							ASCII_dc_0 <= X"31";
							hex0 <= (1 => '0', 2 => '0', others => '1');
						when 2 =>
						-- two
						-- two 
							ASCII_dc_0 <= X"32";
							hex0 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
						when 3 =>
						-- three
							ASCII_dc_0 <= X"33";
							hex0 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 4 =>
						-- four
							ASCII_dc_0 <= X"34";
							hex0 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
						when 5 =>
						-- five
							ASCII_dc_0 <= X"35";
							hex0 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 6 =>
						-- six
							ASCII_dc_0 <= X"36";
							hex0 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
						when 7 =>
						-- seven
							ASCII_dc_0 <= X"37";
							hex0 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
						when 8 =>
						-- eight
							ASCII_dc_0 <= X"38";
							hex0 <= (others => '0');
						when 9 =>
						-- nine
							ASCII_dc_0 <= X"39";
							hex0 <= (4 => '1', others => '0');
						when others =>
							-- turned off
							hex0 <= (others => '1');
					end case;
				end if;
			end if;
		end process p_current_dc0;
		
		
		p_current_dc1 : process(clk, reset)
		begin 
			if rising_edge(clk) then
				if reset = '1' then
					-- zero
					hex1 <= (6 => '1', others => '0');
					ASCII_dc_1 <= X"30";
					
				else
					case dc1 is
						when 0 =>
						-- zero
							ASCII_dc_1 <= X"30";
							hex1 <= (6 => '1', others => '0');
						when 1 =>
						-- one
							ASCII_dc_1 <= X"31";
							hex1 <= (1 => '0', 2 => '0', others => '1');
						when 2 =>
						-- two
						-- two 
							ASCII_dc_1 <= X"32";
							hex1 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
						when 3 =>
						-- three
							ASCII_dc_1 <= X"33";
							hex1 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 4 =>
						-- four
							ASCII_dc_1 <= X"34";
							hex1 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
						when 5 =>
						-- five
							ASCII_dc_1 <= X"35";
							hex1 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 6 =>
						-- six
							ASCII_dc_1 <= X"36";
							hex1 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
						when 7 =>
						-- seven
							ASCII_dc_1 <= X"37";
							hex1 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
						when 8 =>
						-- eight
							ASCII_dc_1 <= X"38";
							hex1 <= (others => '0');
						when 9 =>
						-- nine
							ASCII_dc_1 <= X"39";
							hex1 <= (4 => '1', others => '0');
						when others =>
							-- turned off
							hex1 <= (others => '1');
					end case;
				end if;
			end if;
		end process p_current_dc1;
			
		p_current_dc2 : process(clk, reset)
		begin
			if reset = '1' then
				-- zero
				ASCII_dc_2 <= X"30";
				hex2 <= (others => '1');
			elsif dc2 = 1 then
				ASCII_dc_2 <= X"31";
				hex2 <= (1 => '0', 2 => '0', others => '1');
			elsif dc2 = 0 then
				-- zero
				ASCII_dc_2 <= X"30";
				hex2 <= (6 => '1', others => '0');
			else
				-- turned off
				hex2 <= (others => '1');
			end if;
			
		end process p_current_dc2;
	
end architecture rtl;