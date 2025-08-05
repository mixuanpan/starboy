`default_nettype none
module t01_clkdiv10k (
	clk,
	rst,
	newclk
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output reg newclk;
	reg [10:0] count;
	reg [10:0] count_n;
	reg newclk_n;
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
		newclk_n = newclk;
		if (count < 'd1250)
			count_n = count + 1;
		else begin
			count_n = 1'sb0;
			newclk_n = !newclk;
		end
	end
	initial _sv2v_0 = 0;
endmodule
