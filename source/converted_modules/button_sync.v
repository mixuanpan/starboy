`default_nettype none
module button_sync (
	clk,
	rst,
	button_in,
	button_sync_out
);
	input wire clk;
	input wire rst;
	input wire button_in;
	output wire button_sync_out;
	reg sync_ff1;
	reg sync_ff2;
	always @(posedge clk or posedge rst)
		if (rst) begin
			sync_ff1 <= 1'b0;
			sync_ff2 <= 1'b0;
		end
		else begin
			sync_ff1 <= button_in;
			sync_ff2 <= sync_ff1;
		end
	assign button_sync_out = sync_ff2;
endmodule
