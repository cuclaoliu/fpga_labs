library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_led is
	port(
		CLOCK_50				:	in	std_logic;						--50MHz
		KEY					:	in	std_logic_vector(3 downto 0);	--low active
		LEDR				:	out	std_logic_vector(3 downto 0)	--high-off, low-on
	);
end entity;

architecture rtl of pwm_led is
	constant	CLK_FREQ 	:	integer		:= 50 ;				--50MHz
	constant	US_COUNT 	:	integer		:= CLK_FREQ ;				--1 us counter
	constant	MS_COUNT 	:	integer		:= CLK_FREQ*1000 ; 			--1 ms counter
	
	constant	DUTY_STEP	:	unsigned(31 downto 0)		:= 32D"100000" ; 	--duty step
	constant	DUTY_MIN_VALUE	:	unsigned(31 downto 0)		:= 32UX"afffffff";--duty minimum value
	constant	DUTY_MAX_VALUE	:	unsigned(31 downto 0)		:= 32UX"ffffffff";--duty maximum value
	
	type	state_type	is	(IDLE, PWM_PLUS, PWM_MINUS, PWM_GAP)	;	
	
	signal		state		:	state_type;

	signal	clk, rst_n		:	std_logic;
	signal	pwm_out			:	std_logic;			--pwm output
	signal	period			:	unsigned(31 downto 0);				--pwm step value
	signal	duty			:	unsigned(31 downto 0);				--duty value
	signal	pwm_flag		:	std_logic;			--duty value plus and minus flag, 0: plus; 1:minus

	signal	timer			:	unsigned(31 downto 0);				--duty adjustment counter

	component pwm_core is
		port(
			clk			:	IN		std_logic;
			rst			:	IN		std_logic;
			period		:	IN		unsigned(31 downto 0);		--pwm step value
			duty		:	IN		unsigned(31 downto 0);		--duty value
			pwm_out		:	OUT		std_logic				--pwm output
		);
	end component;

begin
	clk		<=	CLOCK_50;
	rst_n	<=	KEY(0);
	LEDR(0)	<= 	pwm_out ; --leds low active

	process(clk, rst_n)
	begin
		if rst_n = '0' then
			period <= (others=>'0');
			timer <= (others=>'0');
			duty <= (others=>'0');
			pwm_flag <= '0' ;
			state <= IDLE;
		elsif rising_edge(clk) then
			case state is
				when IDLE =>
					period <= 32D"17179";				--The pwm step value, pwm 200Hz(period = 200*2^32/50000000)
					state <= PWM_PLUS;
					duty <= DUTY_MIN_VALUE;
					timer <= (others=>'0');
				when PWM_PLUS =>
					if duty > DUTY_MAX_VALUE - DUTY_STEP then 	--if duty is bigger than DUTY MAX VALUE minus DUTY_STEP , begin to minus duty value
						pwm_flag <= '1' ;
						duty <= duty - DUTY_STEP ;
					else
						pwm_flag <= '0' ;
						duty <= duty + DUTY_STEP ;
					end if;
					state <= PWM_GAP ;
					timer <= (others=>'0');
				when PWM_MINUS =>
					if duty < DUTY_MIN_VALUE + DUTY_STEP then		--if duty is little than DUTY MIN VALUE plus duty step, begin to add duty value
						pwm_flag <= '0' ;
						duty <= duty + DUTY_STEP ;
					else
						pwm_flag <= '1' ;
						duty <= duty - DUTY_STEP ;
					end if;
					state <= PWM_GAP ;
					timer <= (others=>'0');
				when PWM_GAP =>
					if timer >= to_unsigned(US_COUNT*100, 32) then					--adjustment gap is 100us
						if pwm_flag='1' then
							state <= PWM_MINUS;
						else
							state <= PWM_PLUS ;
						end if;
						timer <= (others=>'0');
					else
						timer <= timer + 1;
					end if;
				when others =>
					state <= IDLE;
			end case;
		end if;
	end process;
	
	--Instantiate pwm 	
	pwm_m0 : pwm_core 
		port map(
		clk	=> clk,
		rst	=> not rst_n,
		period	=> period,
		duty	=> duty,
		pwm_out	=> pwm_out);
	
end	rtl;
