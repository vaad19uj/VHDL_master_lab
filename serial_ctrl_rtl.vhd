library ieee;
	use ieee.std_logic_1164.all;
	

entity serial_ctrl is 
	port(
		received_byte_data 		: in std_logic_vector(7 downto 0);
		received_bit_valid		: in std_logic;
		clk							: in std_logic;
		serial_up 					: out std_logic;
		serial_down 				: out std_logic;
		serial_off 					: out std_logic;
		serial_on 					: out std_logic);
end entity serial_ctrl;


architecture rtl of serial_ctrl is

	begin
	
	p_serial_ctrl : process(clk)
	begin
	
		if rising_edge(clk) then
			if received_bit_valid = '1' then
				case received_byte_data is
				
				-- ASCII U 
				-- 85
				when "01010101" =>
					
					-- When the ASCII Character ‘U’ or ‘u’ is received a one clock cycle 
					-- long pulse shall be generated on the serial_up output. 
					serial_up <= '1';
					serial_down <= '0';
					serial_off <= '0';
					serial_on <= '0';
					
					
				-- ASCII u
				-- 117
				when "01110101" =>
				
				-- When the ASCII Character ‘U’ or ‘u’ is received a one clock cycle 
				-- long pulse shall be generated on the serial_up output. 
					serial_up <= '1';
					serial_down <= '0';
					serial_off <= '0';
					serial_on <= '0';
				
				-- ASCII D
				-- 68
				when "01000100" => 
				
				-- The serial_down signal shall be controlled in the same way 
				-- when ASCII character ‘D’ or ‘d’ is received. 
					serial_up <= '0';
					serial_down <= '1';
					serial_off <= '0';
					serial_on <= '0';
				
				-- ASCII d
				-- 100
				when "01100100" =>
				
				-- The serial_down signal shall be controlled in the same way 
				-- when ASCII character ‘D’ or ‘d’ is received.
					serial_up <= '0';
					serial_down <= '1';
					serial_off <= '0';
					serial_on <= '0';	
				
				-- ASCII 0
				when "00110000" =>
				
				-- The serial_off signal shall be pulsed high when the number ‘0’ is received. 
					serial_up <= '0';
					serial_down <= '0';
					serial_off <= '1';
					serial_on <= '0';
				
				-- ASCII 1
				when "00110001" =>
				
				-- And the serial_on signal shall be pulsed when the ASCII Character for number ‘1’ is received. 
					serial_up <= '0';
					serial_down <= '0';
					serial_off <= '0';
					serial_on <= '1';
				
				when others =>
					serial_up <= '0';
					serial_down <= '0';
					serial_off <= '0';
					serial_on <= '0';
				
				end case;
			end if;
		end if;
	
	end process p_serial_ctrl;

end architecture rtl;