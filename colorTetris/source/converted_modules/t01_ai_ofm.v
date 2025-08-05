`default_nettype none
module t01_ai_ofm (
	clk,
	rst,
	mmu_done,
	mmu_result_i,
	blockX_i,
	block_type_i,
	gamestate,
	blockX_o,
	block_type_o,
	done
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire mmu_done;
	input wire [17:0] mmu_result_i;
	input wire [3:0] blockX_i;
	input wire [4:0] block_type_i;
	input wire [3:0] gamestate;
	output wire [3:0] blockX_o;
	output wire [4:0] block_type_o;
	output reg done;
	reg [4:0] c_block_type;
	reg [4:0] n_block_type;
	reg [3:0] c_blockX;
	reg [3:0] n_blockX;
	reg [17:0] c_mmu_result;
	reg [17:0] n_mmu_result;
	wire testing;
	assign testing = mmu_result_i > c_mmu_result;
	assign blockX_o = c_blockX;
	assign block_type_o = c_block_type;
	always @(posedge clk or posedge rst)
		if (rst) begin
			c_mmu_result <= 0;
			c_block_type <= 0;
			c_blockX <= 0;
			done <= 0;
		end
		else if (mmu_done) begin
			c_blockX <= n_blockX;
			c_block_type <= n_block_type;
			c_mmu_result <= n_mmu_result;
			done <= 1'b1;
		end
		else
			done <= 0;
	always @(*) begin
		if (_sv2v_0)
			;
		n_mmu_result = c_mmu_result;
		n_blockX = c_blockX;
		n_block_type = c_block_type;
		if (mmu_result_i > c_mmu_result) begin
			n_blockX = blockX_i;
			n_block_type = block_type_i;
			n_mmu_result = mmu_result_i;
		end
	end
	initial _sv2v_0 = 0;
endmodule
