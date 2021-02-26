library ieee;
	use ieee.std_logic_1164.all;
	

entity key_ctrl is 
	port(
		key_n 			: in std_logic_vector(3 downto 0);
		clock 			: in std_logic;
		key_on 			: out std_logic;
		key_off 			: out std_logic;
		key_down 		: out std_logic;
		key_up 			: out std_logic);
end entity key_ctrl;


architecture rtl of key_ctrl is

	-- signals
	signal key_in_r : std_logic_vector(3 downto 0);
	signal key_in_2r : std_logic_vector(3 downto 0);

begin
	
	p_double_sync : process(key_n)
	begin
		key_in_r <= key_n;
		key_in_2r <= key_in_r;
	end process p_double_sync;
	
	p_key_ctrl : process(clock)
	begin
		if rising_edge(clock) then
		
--			key_n(0) shall control key_off output 
--			key_n(1) shall control key_on output 
--			key_n(2) shall control key_down output 
--			key_n(3) shall control key_up output 
--			Key_n input bits 3, 2 and 1 shall be ignored if key_n(0) is pushed down. 
--			No pulses on key_up or key_down shall be generated if both key_n(2) and key_n(3) is pushed down simultaneously. 
--			The outputs from the compoent shall be set high one clock cycle if the inputs 
--			are detected to be low. If the inputs are held low the outputs shall be 
--			pulsed high one clock cycle every 10th millisecond. 

		end if;
	end process p_key_ctrl;

end architecture rtl;