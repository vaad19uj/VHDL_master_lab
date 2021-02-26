library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	

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

	-- types
	type natural_array is array (2 downto 0) of natural;
	
	-- signals
	signal current_dc 				: natural_array;
	signal ASCII_dc_0 				: std_logic_vector(7 downto 0);
	signal ASCII_dc_1 				: std_logic_vector(7 downto 0);
	signal ASCII_dc_2 				: std_logic_vector(7 downto 0);
	
	-- constants
	constant percent		 			: std_logic_vector(7 downto 0) := "00100101";	--37 decimal
	constant space 		 			: std_logic_vector(7 downto 0) := "00100000";	-- 32 decimal
	constant carriage_return 		: std_logic_vector(7 downto 0) := "00001101";	-- 13 decimal

	begin
	
	-- hex2 - 0 eller 1
	-- hex1 - 0-9
	-- hex0 - 0-9
	
		current_dc(0) 			<= current_dc0;
		current_dc(1) 			<= current_dc1;
		current_dc(2) 			<= current_dc2;
		
		p_dc : process(reset)
		begin
		
--			The duty cycle shall also be trasmitted on the serial interface whenever the duty cycle is updated. 
--			The transmitted data shall be five bytes of data. Three ASCII characters representing the duty cycle between 0 and 100 
--			followed by a ‘%’ character, followed by a carrage return.  
--			In the case of a duty cycle between 10 and 99 the first character shall be replaced with a space. 
--			And in the case when the duty cycle is between 0 and 9 the first two characters shall be space. 
--			In the case of a new duty cycle update have been reported before the current duty cycle information 
--			have been fully transmitted on the serial interface the serial send shall be directly started 
--			again when finished in order to update the serial interface with the latest information. 


			if transmit_ready = '1' then 
			
			-- 0-9
				transmit_data <= space & space & ASCII_dc_0 & percent & carriage_return;
			
			-- 10-99
				transmit_data <= space & ASCII_dc_1 & ASCII_dc_0 & percent & carriage_return;
			
			-- 100
				transmit_data <= ASCII_dc_2 & ASCII_dc_1 & ASCII_dc_0 & percent & carriage_return;
			
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
					case current_dc(0) is
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
					case current_dc(2) is
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
			if rising_edge(clk) then

				if reset = '1' then
					-- zero
					ASCII_dc_2 <= "00110000";
					hex2 <= (others => '1');
					
				else
					if current_dc(2) = 1 then 
						-- one
						ASCII_dc_2 <= "00110001";
						hex2 <= (1 => '0', 2 => '0', others => '1');
					else
						-- zero
						ASCII_dc_2 <= "00110000";
						hex2 <= (6 => '1', others => '0');
					end if;
				end if;
			end if;
		end process p_current_dc2;
	
end architecture rtl;