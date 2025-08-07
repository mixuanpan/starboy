`default_nettype none
module t01_clkdiv1hz (
	clk,
	rst,
	scoremod,
	speed_up,
	ai_new_spawn,
	top_level_state,
	newclk
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [24:0] scoremod;
	input wire speed_up;
	input wire ai_new_spawn;
	input wire [1:0] top_level_state;
	output reg newclk;
	reg [25:0] count;
	reg [25:0] count_n;
	reg newclk_n;
	reg [25:0] threshold;
	wire [25:0] clk_speed_div;
	assign clk_speed_div = (top_level_state == 2'b01 ? 26'd1250000 : (!ai_new_spawn ? 26'd100 : 26'd125000));
	always @(posedge clk or posedge rst)
		if (rst) begin
			count <= 1'sb0;
			newclk <= 1'sb0;
		end
		else begin
			count <= count_n;
			newclk <= newclk_n;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		count_n = count;
		newclk_n = 1'sb1;
		threshold = (speed_up ? clk_speed_div : 26'd12500000 - scoremod);
		if (count < threshold)
			count_n = count + 1;
		else begin
			count_n = 1'sb0;
			newclk_n = 1'sb0;
		end
	end
	initial _sv2v_0 = 0;
endmodule
