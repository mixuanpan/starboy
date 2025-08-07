`default_nettype none
module t01_ai_ofm (
	clk,
	rst,
	mmu_done,
	blockX_i,
	block_type_i,
	gamestate,
	lines_cleared_i,
	bumpiness_i,
	heights_i,
	holes_i,
	blockX_o,
	block_type_o,
	done
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire mmu_done;
	input wire [3:0] blockX_i;
	input wire [4:0] block_type_i;
	input wire [3:0] gamestate;
	input wire [7:0] lines_cleared_i;
	input wire [7:0] bumpiness_i;
	input wire [7:0] heights_i;
	input wire [7:0] holes_i;
	output wire [3:0] blockX_o;
	output wire [4:0] block_type_o;
	output reg done;
	reg [4:0] c_block_type;
	reg [4:0] n_block_type;
	reg [3:0] c_blockX;
	reg [3:0] n_blockX;
	reg [17:0] c_mmu_result;
	reg [17:0] n_mmu_result;
	wire [17:0] value_i;
	reg [7:0] c_lines_cleared;
	reg [7:0] c_bumpiness;
	reg [7:0] c_heights;
	reg [7:0] c_holes;
	reg [7:0] n_lines_cleared;
	reg [7:0] n_bumpiness;
	reg [7:0] n_heights;
	reg [7:0] n_holes;
	assign value_i = ((({10'b0000000000, heights_i} * 'd6) + ({10'b0000000000, holes_i} * 'd4)) + ({10'b0000000000, bumpiness_i} * 'd2)) + ({10'b0000000000, lines_cleared_i} * 'd12);
	assign blockX_o = c_blockX;
	assign block_type_o = c_block_type;
	always @(posedge clk or posedge rst)
		if (rst) begin
			c_mmu_result <= 18'd262143;
			c_block_type <= 0;
			c_blockX <= 0;
			done <= 0;
			c_lines_cleared <= 0;
			c_bumpiness <= 8'd255;
			c_heights <= 8'd255;
			c_holes <= 8'd255;
		end
		else if (mmu_done) begin
			c_blockX <= n_blockX;
			c_block_type <= n_block_type;
			c_mmu_result <= n_mmu_result;
			done <= 1'b1;
			c_lines_cleared <= n_lines_cleared;
			c_bumpiness <= n_bumpiness;
			c_heights <= n_heights;
			c_holes <= n_holes;
		end
		else
			done <= 0;
	always @(*) begin
		if (_sv2v_0)
			;
		n_mmu_result = c_mmu_result;
		n_blockX = c_blockX;
		n_block_type = c_block_type;
		n_lines_cleared = c_lines_cleared;
		n_bumpiness = c_bumpiness;
		n_heights = c_heights;
		n_holes = c_holes;
		if (value_i < c_mmu_result) begin
			n_mmu_result = value_i;
			n_lines_cleared = lines_cleared_i;
			n_bumpiness = bumpiness_i;
			n_heights = heights_i;
			n_holes = holes_i;
			n_blockX = blockX_i;
			n_block_type = block_type_i;
		end
	end
	initial _sv2v_0 = 0;
endmodule
