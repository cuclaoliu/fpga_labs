library ieee;
use ieee.std_logic_1164.all;

entity pwm_core is
	port(
		clk			:	IN		std_logic;
		rst			:	IN		std_logic;
		period		:	IN		integer;		--pwm step value
		duty		:	IN		integer;		--duty value
		pwm_out		:	OUT		std_logic				--pwm output
	);
end entity;

architecture rtl of pwm_core is
	signal period_cnt		:	integer;
	signal		pwm_r		:	std_logic;
begin

	pwm_out 		<= 	pwm_r;

	--period counter, step is period value
	process(clk, rst)
	begin
		if rst='1' then
			period_cnt <= 0;
		elsif rising_edge(clk) then
			period_cnt <= period_cnt + period;
		end if;
	end process;
	

	process(clk, rst)
	begin
		if rst='1' then
			pwm_r <= '0';
		elsif rising_edge(clk) then
			if period_cnt >= duty then		--if period counter is bigger or equals to duty value, then set pwm value to high
				pwm_r <= '1';
			else
				pwm_r <= '0';
			end if;
		end if;
	end process;

end rtl;