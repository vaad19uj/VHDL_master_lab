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
	signal ticks			: natural range 0 to 500000 := 0;

begin
	
	p_double_sync : process(clock)
	begin
		if rising_edge(clock) then
			key_in_r 	<= key_n;
			key_in_2r	<= key_in_r;
		end if;
	end process p_double_sync;
	
	
	p_counter	: process(clock)
	begin
		if rising_edge(clock) then
			if key_in_2r /= "1111" then 
				if(ticks < 500000) then
					ticks 	<= ticks +1;
				else
					ticks 	<= 0;
				end if;
			else
				ticks 	<= 0;
			end if;
		end if;
	end process p_counter;
	
	
	p_key_ctrl : process(clock)

	begin
		if rising_edge(clock) then
			-- Default assignments
			key_off 	<= '0';
			key_down <= '0';
			key_up 	<= '0';
			key_on 	<= '0';
			if ticks = 0 then 
				if key_in_2r(0) = '0' then
					-- Key (0) is OFF
					key_off <= '1';
				elsif key_in_2r(1) = '0' then
					-- Key (1) is ON
					key_on <= '1';
				elsif key_in_2r(2) = '0' and key_in_2r(3) = '1' then
					key_down <= '1';
				elsif key_in_2r(3) = '0' and key_in_2r(2) = '1' then
					key_up <= '1';
				end if;
			end if;
			
		end if;
	end process p_key_ctrl;
end architecture rtl;