`timescale 1ns / 1ps

module pwm_core #(
	parameter PWM_WIDTH = 16 //pwm bit width
)(
	input							clk,
	input							rst,
	input	[PWM_WIDTH-1:0]			period, //pwm step value
	input	[PWM_WIDTH-1:0]			duty,
	//duty value
	output							pwm_out //pwm output
);

	reg		[PWM_WIDTH-1:0] 		period_cnt; //period counter
	reg 							pwm_r;
	
	assign 		pwm_out 			= 	pwm_r;

	//period counter, step is period value
	always_ff@(posedge clk or posedge rst) begin
		if(rst==1) begin
			period_cnt <= { PWM_WIDTH {1'b0} };
		end else begin
			period_cnt <= period_cnt + period;
		end
	end
	
	always_ff@(posedge clk or posedge rst) begin
		if(rst==1) begin
			pwm_r <= 1'b0;
		end else begin
			if (period_cnt >= duty) //if period counter is bigger or equals to duty value, then set pwm value to high
				pwm_r <= 1'b1;
			else
				pwm_r <= 1'b0;
		end
	end

endmodule