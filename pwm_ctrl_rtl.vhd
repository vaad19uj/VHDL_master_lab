library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	

entity pwm_ctrl is 
	port(
		serial_on			: in std_logic;
		serial_off			: in std_logic;
		serial_up 			: in std_logic;
		serial_down 		: in std_logic;
		clk 					: in std_logic;
		reset					: in std_logic;
		key_on				: in std_logic;
		key_off				: in std_logic;
		key_up 				: in std_logic;
		key_down 			: in std_logic;
		current_dc_update	: out std_logic;
		ledg0 				: out std_logic;
		current_dc			: out std_logic_vector(7 downto 0));
end entity pwm_ctrl;


architecture rtl of pwm_ctrl is

	-- constants
	constant c_cnt_max									: natural := 50000; -- 50MHz/1000Hz
	constant periodtime									: natural := 50000;	-- 1ms
	constant c_percent_step								: natural := 500;

	--signals
	signal pwm_duty_cycle_percent 					: natural range 0 to 100 := 0;
	signal pwm_last_duty_cycle_percent				: natural range 0 to 100 := 100;
	signal update_last_on_percent						: std_logic;
	signal pwm_counter									: integer range 0 to c_cnt_max := 0; -- used for LED
	signal period_counter								: integer range 0 to c_cnt_max := 0;
	signal tick_1ms										: std_logic := '1';
	signal counter 										: natural range 0 to c_cnt_max;
	
	begin 
	
		pwm_counter <= pwm_duty_cycle_percent * c_percent_step;
	
		p_pulse : process(clk)
		begin
			if rising_edge(clk) then
				if(pwm_counter > period_counter) then
					ledg0 <= '1';
				else
					ledg0 <= '0';
				end if;
			end if;
		end process p_pulse;

		
		p_counter : process(clk)
		begin
			if rising_edge(clk) then
				if (period_counter < c_cnt_max) then
					period_counter <= period_counter + 1;
				else
					period_counter <= 0;
				end if;
			end if;
		end process p_counter;
		
		
		p_tick : process(clk)
		begin
		
			if rising_edge (clk) then
				if counter = c_cnt_max then
					tick_1ms <= '1';
					counter <= 0;
				else
					tick_1ms <= '0';
					counter <= counter + 1;
				end if;
			end if;
		end process p_tick;
		
		p_send : process(tick_1ms)
		begin
			if tick_1ms = '1' then
				current_dc_update <= '1';
				current_dc <= std_logic_vector(to_unsigned(pwm_duty_cycle_percent, current_dc'length));
				
			else
				current_dc_update <= '0';
			end if;
		end process p_send;
		
		p_pwm_ctrl : process(clk)
		begin
			if rising_edge(clk) then
			
				-- Default assignment
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