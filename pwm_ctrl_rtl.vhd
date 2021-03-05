library ieee;
	use ieee.std_logic_1164.all;
	

entity pwm_ctrl is 
	port(
		serial_on			: in std_logic;
		serial_off			: in std_logic;
		serial_up 			: in std_logic;
		serial_down 		: in std_logic;
		clk 					: in std_logic;
		
		key_on				: in std_logic;
		key_off				: in std_logic;
		key_up 				: in std_logic;
		key_down 			: in std_logic;
		current_dc_update	: out std_logic;
		ledg0 				: out std_logic;
		current_dc			: out std_logic_vector(6 downto 0));
end entity pwm_ctrl;


architecture rtl of pwm_ctrl is

	--signals
	signal pwm_duty_cycle_percent 					: natural range 0 to 100;
	signal pwm_last_duty_cycle_percent				: natural range 0 to 100;
	signal update_last_on_percent						: std_logic;
	

	begin 
	
		p_pwm_ctrl : process(clk)
		begin
			if rising_edge(clk) then
			
				update_last_on_percent <= '0';
			
				if key_off = '1' then
					pwm_duty_cycle_percent <= 0;
					
				elsif key_on = '1' then
					pwm_duty_cycle_percent <= pwm_last_duty_cycle_percent;
					
				elsif key_up = '1' and pwm_duty_cycle_percent = 0 then
					pwm_duty_cycle_percent <= 10;
					update_last_on_percent <= '1';
				
				elsif key_up = '1' and pwm_duty_cycle_percent < 100 then
					pwm_duty_cycle_percent <= pwm_last_duty_cycle_percent + 1;
					update_last_on_percent <= '1';
					
				elsif key_down = '1' and pwm_duty_cycle_percent > 10 then
					pwm_duty_cycle_percent <= pwm_last_duty_cycle_percent - 1;
					update_last_on_percent <= '1';
				
				elsif serial_on = '1' then
					pwm_duty_cycle_percent <= pwm_last_duty_cycle_percent;
					
				elsif serial_off = '1' then
					pwm_duty_cycle_percent <= 0;
				
				elsif serial_up = '1' and pwm_duty_cycle_percent = 0 then
					pwm_duty_cycle_percent <= 10;
					update_last_on_percent <= '1';
				
				elsif serial_up = '1' and pwm_duty_cycle_percent < 100 then
					pwm_duty_cycle_percent <= pwm_last_duty_cycle_percent + 1;
					update_last_on_percent <= '1';
				
				elsif serial_down = '1' and pwm_duty_cycle_percent > 10 then
					pwm_duty_cycle_percent <= pwm_last_duty_cycle_percent - 1;
					update_last_on_percent <= '1';
				
				end if;
				
				if update_last_on_percent = '1' then
					pwm_last_duty_cycle_percent <= pwm_duty_cycle_percent;
				end if;
			
				if reset = '1' then
					pwm_last_duty_cycle_percent <= 100;
					pwm_duty_cycle_percent <= 0;
				end if;
			end if;
		end process p_pwm_ctrl;
	
end architecture rtl;