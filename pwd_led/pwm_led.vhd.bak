`timescale 1ns / 1ps

module pwm_leds (
	input					clk_50M,					//50MHz
	input	[0:0]			keys,						//low active
	output	[3:0]			leds						//high-off, low-on
);

	localparam 				CLK_FREQ = 50 ;				//50MHz
	localparam 				US_COUNT = CLK_FREQ ;		//1 us counter
	localparam 				MS_COUNT = CLK_FREQ*1000 ; 	//1 ms counter
	
	localparam 				DUTY_STEP = 32'd100000 ; 	//duty step
	localparam 				DUTY_MIN_VALUE = 32'hafffffff ;//duty minimum value
	localparam 				DUTY_MAX_VALUE = 32'hffffffff ;//duty maximum value
	enum logic[3:0]			{IDLE, PWM_PLUS, PWM_MINUS, PWM_GAP}	state;	

	wire					clk, rst_n;
	wire					pwm_out;			//pwm output
	reg		[31:0]			period;				//pwm step value
	reg		[31:0]			duty;				//duty value
	reg						pwm_flag ; 			//duty value plus and minus flag, 0: plus; 1:minus

	reg		[31:0] 			timer;				//duty adjustment counter

	assign			clk		=	clk_50M;
	assign			rst_n	=	keys[0];	
	assign 			leds[0]	= 	~pwm_out ; //leds low active

	always_ff@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0) begin
			period <= 32'd0;
			timer <= 32'd0;
			duty <= 32'd0;
			pwm_flag <= 1'b0 ;
			state <= IDLE;
		end else begin
			case(state)
				IDLE : begin
					period <= 32'd17179;				//The pwm step value, pwm 200Hz(period = 200*2^32/50000000)
					state <= PWM_PLUS;
					duty <= DUTY_MIN_VALUE;
					timer <= 32'd0;
				end
				PWM_PLUS : begin
					if (duty > DUTY_MAX_VALUE - DUTY_STEP) begin 	//if duty is bigger than DUTY MAX VALUE minus DUTY_STEP , begin to minus duty value
						pwm_flag <= 1'b1 ;
						duty <= duty - DUTY_STEP ;
					end else begin
						pwm_flag <= 1'b0 ;
						duty <= duty + DUTY_STEP ;
					end
					state <= PWM_GAP ;
					timer <= 32'd0;
				end
				PWM_MINUS : begin
					if (duty < DUTY_MIN_VALUE + DUTY_STEP) begin	//if duty is little than DUTY MIN VALUE plus duty step, begin to add duty value
						pwm_flag <= 1'b0 ;
						duty <= duty + DUTY_STEP ;
					end else begin
						pwm_flag <= 1'b1 ;
						duty <= duty - DUTY_STEP ;
					end
					state <= PWM_GAP ;
					timer <= 32'd0;
				end
				PWM_GAP : begin
					if(timer >= US_COUNT*100) begin					//adjustment gap is 100us
						if (pwm_flag)
							state <= PWM_MINUS;
						else
							state <= PWM_PLUS ;
						timer <= 32'd0;
					end else begin
						timer <= timer + 32'd1;
					end
				end
				default : begin
					state <= IDLE;
				end
			endcase
		end
	end
	
	//Instantiate pwm module
	pwm_core #(.PWM_WIDTH(32)) pwm_m0(
		.clk(clk),
		.rst(~rst_n),
		.period(period),
		.duty(duty),
		.pwm_out(pwm_out)
	);
endmodule
