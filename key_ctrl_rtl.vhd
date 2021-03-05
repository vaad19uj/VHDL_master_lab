library ieee;
	use ieee.std_logic_1164.all;
	

entity key_ctrl is 
	port(
		key_n 			: in std_logic_vector(3 downto 0);
		clock 			: in std_logic; -- 50MHz
		key_on 			: out std_logic;
		key_off 			: out std_logic;
		key_down 		: out std_logic;
		key_up 			: out std_logic);
end entity key_ctrl;


architecture rtl of key_ctrl is

	-- signals
	signal key_in_r 		: std_logic_vector(3 downto 0);
	signal key_in_2r 		: std_logic_vector(3 downto 0);
	signal ticks			: integer range 0 to 500000;

begin
	
	p_double_sync : process(clock)
	begin
		key_in_r <= key_n;
		key_in_2r <= key_in_r;
	end process p_double_sync;
	
	p_key_ctrl : process(clock)

	begin
		if rising_edge(clock) then
		ticks <= 0;
		
			if key_in_2r(0) = '0' then
				key_off <= '1';
				key_down <= 'X';
				key_up <= 'X';
				key_on <= 'X';
				
				if(ticks = 500000) then
					key_off <= '1';
					ticks <= 0;
				else 
					ticks <= ticks +1;
					key_off <= '0';
				end if;
			
			elsif key_in_2r(2) = '0' and key_in_2r(3) = '0' then
				key_down <= 'X';
				key_up <= 'X';
				
				
			elsif key_in_2r(1) = '0' then
				key_on <= '1';
					if(ticks = 500000) then
						key_on <= '1';
						ticks <= 0;
					else 
						ticks <= ticks +1;
						key_on <= '0';
					end if;
					
			elsif key_in_2r(2) = '0' then
				key_down <= '1';
				
				if(ticks = 500000) then
					key_down <= '1';
					ticks <= 0;
				else 
					ticks <= ticks +1;
					key_down <= '0';
				end if;
					
					
			elsif key_in_2r(3) = '0' then
				key_up <= '1';
				
				if(ticks = 500000) then
					key_up <= '1';
					ticks <= 0;
				else 
					ticks <= ticks +1;
					key_up <= '0';
				end if;
				
			else 
				key_off <= not key_in_2r(0);
				key_on <= not key_in_2r(1);
				key_down <= not key_in_2r(2);
				key_up <= not key_in_2r(3);
			
			end if;
		end if;
	end process p_key_ctrl;

end architecture rtl;