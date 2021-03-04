library ieee;
	use ieee.std_logic_1164.all;
	

entity dc_disp_ctrl is 
	generic(
	-- generic?
		current_dc0					: natural range 0 to 9;
		current_dc1					: natural range 0 to 9;
		current_dc2					: natural range 0 to 9);
	port(
		transmit_ready				: in std_logic;
		current_dc_update			: in std_logic;
		clk							: in std_logic;
		transmit_bit_valid 		: out std_logic;
		transmit_data				: out std_logic_vector(39 downto 0);	-- 5 byte
		hex0							: out std_logic_vector(6 downto 0);
		hex1							: out std_logic_vector(6 downto 0);
		hex2							: out std_logic_vector(6 downto 0);
		reset							: in std_logic);
end entity dc_disp_ctrl;


architecture rtl of dc_disp_ctrl is

	-- type
	type natural_array is array (2 downto 0) of natural;
	
	-- signals
	signal current_dc 		: natural_array;
	signal ASCII_dc_0 		: std_logic_vector(7 downto 0);
	signal ASCII_dc_1 		: std_logic_vector(7 downto 9);
	signal ASCII_dc_2 		: 

	begin
	
		current_dc(0) 			<= current_dc0;
		current_dc(1) 			<= current_dc1;
		current_dc(2) 			<= current_dc2;
		
		p_current_dc0 : process(clk, reset)
		begin 
			if rising_edge(clk) then

				if reset = '1' then
					-- zero
					hex0 <= (others => '1');
					
				else
					case current_dc(0) is
						when 0 =>
						-- zero
							hex0 <= (6 => '1', others => '0');
						when 1 =>
						-- one
							hex0 <= (1 => '0', 2 => '0', others => '1');
						when 2 =>
						-- two
							hex0 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
						when 3 =>
						-- three
							hex0 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 4 =>
						-- four
							hex0 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
						when 5 =>
						-- five
							hex0 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 6 =>
						-- six
							hex0 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
						when 7 =>
						-- seven
							hex0 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
						when 8 =>
						-- eight
							hex0 <= (others => '0');
						when 9 =>
						-- nine
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
					
				else
					case current_dc(1) is
						when 0 =>
						-- zero
							hex1 <= (6 => '1', others => '0');
						when 1 =>
						-- one
							hex1 <= (1 => '0', 2 => '0', others => '1');
						when 2 =>
						-- two
							hex1 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
						when 3 =>
						-- three
							hex1 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 4 =>
						-- four
							hex1 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
						when 5 =>
						-- five
							hex1 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 6 =>
						-- six
							hex1 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
						when 7 =>
						-- seven
							hex1 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
						when 8 =>
						-- eight
							hex1 <= (others => '0');
						when 9 =>
						-- nine
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
			if rising_edge(clk) then

				if reset = '1' then
					-- zero
					hex2 <= (others => '1');
					
				else
					case current_dc(2) is
						when 0 =>
						-- zero
							hex2 <= (6 => '1', others => '0');
						when 1 =>
						-- one
							hex2 <= (1 => '0', 2 => '0', others => '1');
						when 2 =>
						-- two
							hex2 <= (0 => '0', 1 => '0', 6 => '0', 4 => '0', 3 => '0', others => '1');
						when 3 =>
						-- three
							hex2 <= (0 => '0', 1 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 4 =>
						-- four
							hex2 <= (5 => '0', 6 => '0', 1 => '0', 2 => '0', others => '1');
						when 5 =>
						-- five
							hex2 <= (0 => '0', 5 => '0', 6 => '0', 2 => '0', 3 => '0', others => '1');
						when 6 =>
						-- six
							hex2 <= (0 => '0', 5 => '0', 6 => '0', 4 => '0', 3 => '0', 2 => '0', others => '1');
						when 7 =>
						-- seven
							hex2 <= (0 => '0', 1 => '0', 2 => '0', others => '1');
						when 8 =>
						-- eight
							hex2 <= (others => '0');
						when 9 =>
						-- nine
							hex2 <= (4 => '1', others => '0');
						when others =>
							-- turned off
							hex2 <= (others => '1');
					end case;
				end if;
			end if;
		end process p_current_dc2;
	
end architecture rtl;