`default_nettype none
module t01_synckey (
	in,
	clk,
	rst,
	strobe
);
	input wire in;
	input wire clk;
	input wire rst;
	output wire strobe;
	reg synchronizer_ff1;
	reg delayedClock_ff2;
	always @(posedge clk or posedge rst)
		if (rst) begin
			synchronizer_ff1 <= 0;
			delayedClock_ff2 <= 0;
		end
		else begin
			synchronizer_ff1 <= in;
			delayedClock_ff2 <= synchronizer_ff1;
		end
	assign strobe = synchronizer_ff1 & ~delayedClock_ff2;
endmodule
