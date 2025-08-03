`default_nettype none
module t01_debounce (
	clk,
	pb,
	button
);
	reg _sv2v_0;
	input wire clk;
	input wire pb;
	output wire button;
	reg Q0;
	reg Q1;
	reg Q2;
	reg slow_clk_en;
	reg [26:0] count;
	reg [26:0] nextcount;
	always @(posedge clk) count <= nextcount;
	always @(*) begin
		if (_sv2v_0)
			;
		if (count >= 27'd249999)
			nextcount = 0;
		else
			nextcount = count + 1;
		if (count == 27'd249999)
			slow_clk_en = 1'sb1;
		else
			slow_clk_en = 1'sb0;
	end
	always @(posedge clk)
		if (slow_clk_en == 1'b1) begin
			Q0 <= pb;
			Q1 <= Q0;
			Q2 <= Q1;
		end
		else begin
			Q0 <= Q0;
			Q1 <= Q1;
			Q2 <= Q2;
		end
	assign button = Q1 & !Q2;
	initial _sv2v_0 = 0;
endmodule
