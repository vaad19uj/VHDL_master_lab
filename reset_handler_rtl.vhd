library ieee;
	use ieee.std_logic_1164.all;
	

entity reset_handler is 
	port(
		reset 			: in std_logic;
		reset_n 			: in std_logic;
		--reset_out 		: out std_logic;
		--reset_n_out 	: out std_logic;
		reset_int		: out std_logic);
end entity reset_handler;


architecture rtl of reset_handler is

	begin 

--	Both reset outputs shall be asynchronously set active and an internal couter shall be 
--	asynchonously reset if any of the reset inputs are set active. 
--	If both reset inputs are inacive a counter shall start counting up every clock cycle. 
--	When the counter has reaced its maximum (set by a generic value) the reset outputs 
--	shall be deasserted into inactive state. 

end architecture rtl;