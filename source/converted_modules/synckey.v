`default_nettype none
module synckey (
	in,
	clk,
	rst,
	strobe
);
	input wire [19:0] in;
	input wire clk;
	input wire rst;
	output wire strobe;
	wire orIn;
	reg synchronizer_ff1;
	reg delayedClock_ff2;
	wire [4:0] out1;
	assign out1 = (in[19] ? 5'd19 : (in[18] ? 5'd18 : (in[17] ? 5'd17 : (in[16] ? 5'd16 : (in[15] ? 5'd15 : (in[14] ? 5'd14 : (in[13] ? 5'd13 : (in[12] ? 5'd12 : (in[11] ? 5'd11 : (in[10] ? 5'd10 : (in[9] ? 5'd9 : (in[8] ? 5'd8 : (in[7] ? 5'd7 : (in[6] ? 5'd6 : (in[5] ? 5'd5 : (in[4] ? 5'd4 : (in[3] ? 5'd3 : (in[2] ? 5'd2 : (in[1] ? 5'd1 : 5'd0)))))))))))))))))));
	assign orIn = |in;
	always @(posedge clk or posedge rst)
		if (rst) begin
			synchronizer_ff1 <= 0;
			delayedClock_ff2 <= 0;
		end
		else begin
			synchronizer_ff1 <= orIn;
			delayedClock_ff2 <= synchronizer_ff1;
		end
	assign strobe = synchronizer_ff1 & ~delayedClock_ff2;
endmodule
