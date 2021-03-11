library ieee;
	use ieee.std_logic_1164.all;
	

entity serial_ctrl is 
	port(
		received_data 				: in std_logic_vector(7 downto 0);
		received_valid				: in std_logic;
		clk							: in std_logic;
		serial_up 					: out std_logic;
		serial_down 				: out std_logic;
		serial_off 					: out std_logic;
		serial_on 					: out std_logic);
end entity serial_ctrl;


architecture rtl of serial_ctrl is

	constant c_ascii_u_uc   : std_logic_vector(7 downto 0) := X"55";
   constant c_ascii_u_lc   : std_logic_vector(7 downto 0) := X"75";
   constant c_ascii_d_uc   : std_logic_vector(7 downto 0) := X"44";
   constant c_ascii_d_lc   : std_logic_vector(7 downto 0) := X"64";
   constant c_ascii_0      : std_logic_vector(7 downto 0) := X"30";
   constant c_ascii_1      : std_logic_vector(7 downto 0) := X"31";

	begin
	
	p_serial_ctrl : process(clk)
	begin
	
		if rising_edge(clk) then
			--if received_valid = '1' then
				case received_data is
				
				-- ASCII U 
				-- 85
				when c_ascii_u_lc =>
					
					-- When the ASCII Character ‘U’ or ‘u’ is received a one clock cycle 
					-- long pulse shall be generated on the serial_up output. 
					serial_up <= '1';
					serial_down <= '0';
					serial_off <= '0';
					serial_on <= '0';
					
					
				-- ASCII u
				-- 117
				when c_ascii_u_uc =>
				
				-- When the ASCII Character ‘U’ or ‘u’ is received a one clock cycle 
				-- long pulse shall be generated on the serial_up output. 
					serial_up <= '1';
					serial_down <= '0';
					serial_off <= '0';
					serial_on <= '0';
				
				-- ASCII D
				-- 68
				when c_ascii_d_lc => 
				
				-- The serial_down signal shall be controlled in the same way 
				-- when ASCII character ‘D’ or ‘d’ is received. 
					serial_up <= '0';
					serial_down <= '1';
					serial_off <= '0';
					serial_on <= '0';
				
				-- ASCII d
				-- 100
				when c_ascii_d_uc =>
				
				-- The serial_down signal shall be controlled in the same way 
				-- when ASCII character ‘D’ or ‘d’ is received.
					serial_up <= '0';
					serial_down <= '1';
					serial_off <= '0';
					serial_on <= '0';	
				
				-- ASCII 0
				when c_ascii_0 =>
				
				-- The serial_off signal shall be pulsed high when the number ‘0’ is received. 
					serial_up <= '0';
					serial_down <= '0';
					serial_off <= '1';
					serial_on <= '0';
				
				-- ASCII 1
				when c_ascii_1 =>
				
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
			--end if;
		end if;
	
	end process p_serial_ctrl;

end architecture rtl;