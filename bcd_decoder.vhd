library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

--=================================================================
--
-- BCD Decode
--
-- Transforms a 7 bit input vector to 3 BCD values.
-- Valid in shall be set high when input_vector is valid.
-- Valid_out shall be set high when transformed data is ready on
-- the bcd_* outputs
--
--=================================================================
entity bcd_decode is
   port(
      clk                     : in  std_logic;
      reset                   : in  std_logic;   -- active high reset
      
      -- input data interface
      input_vector            : in  std_logic_vector(6 downto 0);	-- 6 downto 0?
      valid_in                : in  std_logic;
      ready                   : out std_logic;  -- ready for data when high

      -- output result
      bcd_0                   : out std_logic_vector(3 downto 0); -- ones
      bcd_1                   : out std_logic_vector(3 downto 0); -- tens
      bcd_2                   : out std_logic_vector(3 downto 0); -- hundreds
      valid_out               : out std_logic); -- Set high one clock cycle when bcd* is valid
end entity bcd_decode;

architecture rtl of bcd_decode is

   -- Types and constants
	type t_main_state is (s_idle, s_shift, s_done);
	constant c_cnt_max : integer := 8;
   
   -- Signals
	signal bcd_state : t_main_state;
	signal counter : integer range 0 to c_cnt_max;
	
	begin 
	
	p_bcd : process(clk, reset)	-- double dabble, "shift and add 3"
	
	-- variables
	variable temp : std_logic_vector(7 downto 0);
	variable bcd : unsigned(11 downto 0);
	
	begin
	
		if reset = '1' then
		
			ready <= '0';
			bcd_0 <= (others => '0');
			bcd_1 <= (others => '0');
			bcd_2 <= (others => '0');
			valid_out <= '0';
			
		elsif rising_edge(clk) then
		
			case bcd_state is
			
				when s_idle =>
				
					ready <= '1'; -- ready for transformation
					counter <= 0;
					valid_out <= '0';
					
					bcd := (others => '0');
					temp := input_vector;
					
					if valid_in = '1' then 
						bcd_state <= s_shift;
					end if;
				
				when s_shift =>
				
					valid_out <= '0';
					ready <= '0';
				
					for i in 0 to 7 loop
						
						-- add 3 
						if bcd(3 downto 0) > 4 then
							bcd(3 downto 0) := bcd(3 downto 0) + 3;
						end if;
						
						if bcd(7 downto 4) > 4 then
							bcd(7 downto 4) := bcd(7 downto 4) + 3;
						end if;
						
						if bcd(11 downto 8) > 4 then
							bcd(11 downto 8) := bcd(11 downto 8) + 3;
						end if;
							
						if i = 7 then
							bcd_state <= s_done;
						end if;
						
						-- shift bcd left by 1 bit, copy MSB of temp into LSB of bcd
						bcd := bcd(10 downto 0) & temp(7);
						
						-- shift temp left by 1 bit
						temp := temp(6 downto 0) & '0';
						
					end loop;
					
				when s_done =>
				
					-- ones
					bcd_0 <= std_logic_vector(bcd(3 downto 0));
			
					-- tens
					bcd_1 <= std_logic_vector(bcd(7 downto 4));
				
					-- hundreds
					bcd_2 <= std_logic_vector(bcd(11 downto 8));
					
					valid_out <= '1';
					bcd_state <= s_idle;
					
				when others =>
				
					bcd_state <= s_idle;
				
			end case;
			
		end if;
	
	end process p_bcd;

end architecture rtl;


