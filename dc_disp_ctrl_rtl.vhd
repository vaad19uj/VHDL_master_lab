library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
entity dc_disp_ctrl is 
	port(
		transmit_ready				: in std_logic;
		current_dc_update			: in std_logic;
		clk							: in std_logic;
		transmit_bit_valid 		: out std_logic;
		transmit_data				: out std_logic_vector(39 downto 0);	-- 5 byte
		hex0							: out std_logic_vector(6 downto 0);	-- ones
		hex1							: out std_logic_vector(6 downto 0); -- tens
		hex2							: out std_logic_vector(6 downto 0);	-- hundreds
		reset							: in std_logic;
		current_dc					: in std_logic_vector(6 downto 0));
end entity dc_disp_ctrl;


architecture rtl of dc_disp_ctrl is

	-- types
	type t_bcd_state is (s_idle, s_wait, s_done);
	
	-- components
	component bcd_decode is
   port(
      clk                     : in  std_logic;
      reset                   : in  std_logic;   -- active high reset
      input_vector            : in  std_logic_vector(6 downto 0);	
      valid_in                : in  std_logic;
      ready                   : out std_logic;  -- ready for data when high
      bcd_0                   : out std_logic_vector(3 downto 0); -- ones
      bcd_1                   : out std_logic_vector(3 downto 0); -- tens
      bcd_2                   : out std_logic_vector(3 downto 0); -- hundreds
      valid_out               : out std_logic); -- Set high one clock cycle when bcd* is valid
	end component bcd_decode;
	
	
	-- signals
	signal ASCII_dc_0 				: std_logic_vector(7 downto 0);
	signal ASCII_dc_1 				: std_logic_vector(7 downto 0);
	signal ASCII_dc_2 				: std_logic_vector(7 downto 0);
	signal ready 						: std_logic := '0';
	signal valid_out					: std_logic := '0';
	signal valid_in					: std_logic := '0';
	signal bcd_0						: std_logic_vector(3 downto 0);
	signal bcd_1						: std_logic_vector(3 downto 0);
	signal bcd_2						: std_logic_vector(3 downto 0);
	signal dc0							: integer range 0 to 9;
	signal dc1							: integer range 0 to 9;
	signal dc2							: integer range 0 to 1;
	signal bcd_state 					: t_bcd_state := s_idle;
--	signal old_dc						: std_logic_vector(6 downto 0) := (others => '0');
	
	
	-- constants
	constant percent		 			: std_logic_vector(7 downto 0) := "00100101";	--37 decimal
	constant space 		 			: std_logic_vector(7 downto 0) := "00100000";	-- 32 decimal
	constant carriage_return 		: std_logic_vector(7 downto 0) := "00001101";	-- 13 decimal

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
		
		
		p_bcd : process(clk)
		begin
			if rising_edge(clk) then
			
				case bcd_state is
				
				when s_idle =>
				
					if current_dc_update = '1' then
						valid_in <= '1';
						bcd_state <= s_wait;
					end if;
				
				when s_wait =>
					
					valid_in <= '0';
					if valid_out = '1' then
						bcd_state <= s_done;
					end if;
				
				when s_done =>
				
					dc0 <= to_integer(bcd_0);
					dc1 <= to_integer(bcd_1);
					dc2 <= to_integer(bcd_2);
					bcd_state <= s_idle;
					
				when others =>
				
					bcd_state <= s_idle;
					
				end case;
			end if;
		end process p_bcd;
		

		p_dc : process(reset, clk)
		begin

			if rising_edge(clk) then
			
			transmit_bit_valid <= '0';
			
				if reset = '1' then
					transmit_bit_valid <= transmit_ready; -- only try to send if UART is ready
					-- 0% duty cycle
					--old_dc <= (others => '0');
					transmit_data <= space & space & ASCII_dc_0 & percent & carriage_return;
				
				--elsif transmit_ready = '1' and current_dc /= old_dc then 
				elsif transmit_ready = '1' and current_dc_update = '1' then
				
					-- 0-9
					if to_integer(current_dc) > 0 and to_integer(current_dc) < 10 then
						transmit_bit_valid <= transmit_ready; -- only try to send if UART is ready
						--old_dc <= current_dc;
						transmit_data <= space & space & ASCII_dc_0 & percent & carriage_return;
				
					-- 10-99
					elsif to_integer(current_dc) > 9 and to_integer(current_dc) < 100 then
						transmit_bit_valid <= transmit_ready; -- only try to send if UART is ready
					--	old_dc <= current_dc;
						transmit_data <= space & ASCII_dc_1 & ASCII_dc_0 & percent & carriage_return;
				
					-- 100
					elsif to_integer(current_dc) = 100 then
						transmit_bit_valid <= transmit_ready; -- only try to send if UART is ready
						--old_dc <= current_dc;
						transmit_data <= ASCII_dc_2 & ASCII_dc_1 & ASCII_dc_0 & percent & carriage_return;
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
					ASCII_dc_0 <= "00110000";
					
				else
					case dc0 is
						when 0 =>
						-- zero
							ASCII_dc_0 <= "00110000";
							hex0 <= (6 => '1', others => '0');
						when 1 =>
						-- one
							ASCII_dc_0 <= "00110001";
							hex0 <= (1 => '0', 2 => '0', others => '1');
						when 2 =>
						-- two
						-- two 
							ASCII_dc_0 <= "00110010";
							hex0 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
						when 3 =>
						-- three
							ASCII_dc_0 <= "00110011";
							hex0 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 4 =>
						-- four
							ASCII_dc_0 <= "00110100";
							hex0 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
						when 5 =>
						-- five
							ASCII_dc_0 <= "00110101";
							hex0 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 6 =>
						-- six
							ASCII_dc_0 <= "00110110";
							hex0 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
						when 7 =>
						-- seven
							ASCII_dc_0 <= "00110111";
							hex0 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
						when 8 =>
						-- eight
							ASCII_dc_0 <= "00111000";
							hex0 <= (others => '0');
						when 9 =>
						-- nine
							ASCII_dc_0 <= "00111001";
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
					hex1 <= (others => '1');
					ASCII_dc_1 <= "00110000";
					
				else
					case dc1 is
						when 0 =>
						-- zero
							ASCII_dc_1 <= "00110000";
							hex1 <= (6 => '1', others => '0');
						when 1 =>
						-- one
							ASCII_dc_1 <= "00110001";
							hex1 <= (1 => '0', 2 => '0', others => '1');
						when 2 =>
						-- two
						-- two 
							ASCII_dc_1 <= "00110010";
							hex1 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
						when 3 =>
						-- three
							ASCII_dc_1 <= "00110011";
							hex1 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 4 =>
						-- four
							ASCII_dc_1 <= "00110100";
							hex1 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
						when 5 =>
						-- five
							ASCII_dc_1 <= "00110101";
							hex1 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 6 =>
						-- six
							ASCII_dc_1 <= "00110110";
							hex1 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
						when 7 =>
						-- seven
							ASCII_dc_1 <= "00110111";
							hex1 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
						when 8 =>
						-- eight
							ASCII_dc_1 <= "00111000";
							hex1 <= (others => '0');
						when 9 =>
						-- nine
							ASCII_dc_1 <= "00111001";
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
				ASCII_dc_2 <= "00110000";
				hex2 <= (others => '1');
			elsif dc2 = 1 then
				ASCII_dc_2 <= "00110001";
				hex2 <= (1 => '0', 2 => '0', others => '1');
			elsif dc1 = 0 then
				-- zero
				ASCII_dc_2 <= "00110000";
				hex2 <= (6 => '1', others => '0');
			else
				-- turned off
				hex1 <= (others => '1');
			end if;
			
		end process p_current_dc2;
	
end architecture rtl;