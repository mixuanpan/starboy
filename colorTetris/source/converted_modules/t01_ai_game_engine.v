`default_nettype none
module t01_ai_game_engine (
	clk,
	rst,
	gamestate,
	col_right,
	col_left,
	ai_right,
	ai_left,
	ai_rotation,
	blockX,
	ai_new_spawn,
	extract_ready,
	extract_start,
	current_block_type
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [3:0] gamestate;
	input wire col_right;
	input wire col_left;
	output wire ai_right;
	output reg ai_left;
	output reg ai_rotation;
	output reg [3:0] blockX;
	output reg ai_new_spawn;
	input wire extract_ready;
	output reg extract_start;
	input wire [4:0] current_block_type;
	reg [4:0] base_block_type;
	reg right_en;
	reg rot_en;
	reg first_move_buffer;
	reg collision_left;
	reg move_cnt;
	wire right_pulse;
	always @(posedge clk or posedge rst)
		if (rst) begin
			extract_start <= 0;
			ai_rotation <= 0;
			rot_en <= 1;
			first_move_buffer <= 0;
			ai_new_spawn <= 0;
			base_block_type <= 0;
			blockX <= 0;
			move_cnt <= 1;
		end
		else if (gamestate == 'd1) begin
			extract_start <= 0;
			rot_en <= 1;
			right_en <= 1;
			first_move_buffer <= 0;
			base_block_type <= current_block_type;
			move_cnt <= 1;
			if (~collision_left) begin
				if (blockX == 0)
					blockX <= 'd9;
				else
					blockX <= blockX - 1;
			end
		end
		else if (gamestate == 'd2) begin
			if (first_move_buffer && move_cnt)
				;
			if (right_pulse)
				move_cnt <= 0;
		end
		else if (gamestate == 'd10) begin
			move_cnt <= 1;
			ai_rotation <= 0;
			extract_start <= 1'b1;
			if (first_move_buffer) begin
				if (extract_ready) begin
					if (col_right)
						ai_new_spawn <= 1;
				end
			end
		end
		else if (gamestate == 'd11) begin
			extract_start <= 0;
			first_move_buffer <= 1'b1;
			if (~collision_left) begin
				if (blockX == 0)
					blockX <= 'd9;
				else
					blockX <= blockX - 1;
			end
		end
	assign ai_right = gamestate == 'd2;
	reg [3:0] col_ext;
	reg [3:0] abs_col;
	reg collision_right;
	always @(*) begin
		if (_sv2v_0)
			;
		collision_left = 1'b0;
		collision_right = 1'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] row;
			for (row = 0; row < 4; row = row + 1)
				begin : sv2v_autoblock_2
					reg signed [31:0] col;
					for (col = 0; col < 4; col = col + 1)
						begin
							col_ext = {2'b00, col[1:0]};
							abs_col = blockX + col_ext;
							if (abs_col == 4'd0)
								collision_left = 1'b1;
							if ((abs_col + 4'd1) >= 4'd10)
								collision_right = 1'b1;
						end
				end
		end
	end
	wire left_pulse;
	always @(*) begin
		if (_sv2v_0)
			;
		ai_left = 0;
		if (first_move_buffer)
			;
		else if (left_pulse)
			ai_left = 0;
		else
			ai_left = 1;
	end
	wire rotate_pulse;
	wire right_i;
	t01_synckey alexanderweyerthegreat(
		.rst(rst),
		.clk(clk),
		.in({19'b0000000000000000000, ai_left}),
		.strobe(left_pulse)
	);
	t01_synckey aws(
		.rst(rst),
		.clk(clk),
		.in({19'b0000000000000000000, ai_right}),
		.strobe(right_pulse)
	);
	initial _sv2v_0 = 0;
endmodule
