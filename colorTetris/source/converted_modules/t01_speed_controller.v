`default_nettype none
module t01_speed_controller (
	clk,
	reset,
	current_score,
	gamestate,
	scoremod
);
	reg _sv2v_0;
	input wire clk;
	input wire reset;
	input wire [9:0] current_score;
	input wire [3:0] gamestate;
	output reg [24:0] scoremod;
	reg [9:0] prev_score;
	reg [24:0] next_mod;
	always @(posedge clk or posedge reset)
		if (reset) begin
			scoremod <= 1'sb0;
			prev_score <= 1'sb0;
		end
		else if (gamestate == 'd9) begin
			scoremod <= 1'sb0;
			prev_score <= 1'sb0;
		end
		else begin
			scoremod <= next_mod;
			prev_score <= current_score;
		end
	reg [9:0] prev_threshold;
	reg [9:0] curr_threshold;
	reg [24:0] speed_increases;
	always @(*) begin
		if (_sv2v_0)
			;
		next_mod = scoremod;
		speed_increases = 0;
		prev_threshold = prev_score / 10;
		curr_threshold = current_score / 10;
		if (curr_threshold > prev_threshold) begin
			speed_increases = {15'b000000000000000, curr_threshold - prev_threshold} * 25'd1000000;
			next_mod = scoremod + speed_increases;
		end
	end
	initial _sv2v_0 = 0;
endmodule
