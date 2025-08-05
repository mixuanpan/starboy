`default_nettype none
module t01_ai_game_engine (
	clk,
	rst,
	gamestate,
	col_right,
	col_left,
	ai_right,
	ai_left,
	ai_rotate,
	blockX,
	ai_new_spawn,
	c_piece_done,
	rotate_block_type,
	ai_rotated,
	need_rotate,
	ofm_done,
	extract_start,
	current_block_type
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [3:0] gamestate;
	input wire col_right;
	input wire col_left;
	output reg ai_right;
	output reg ai_left;
	output reg ai_rotate;
	output reg [3:0] blockX;
	output reg ai_new_spawn;
	output wire c_piece_done;
	output reg [4:0] rotate_block_type;
	input wire ai_rotated;
	output reg need_rotate;
	input wire ofm_done;
	output reg extract_start;
	input wire [4:0] current_block_type;
	reg [4:0] base_block_type;
	reg right_en;
	reg rot_en;
	reg first_move_buffer;
	reg rotated;
	reg collision_left;
	reg [4:0] last_current_block_type;
	reg [4:0] n_rotate_block_type;
	always @(posedge clk or posedge rst)
		if (rst) begin
			extract_start <= 0;
			rot_en <= 1;
			first_move_buffer <= 0;
			ai_new_spawn <= 0;
			blockX <= 0;
			base_block_type <= 0;
			last_current_block_type <= 0;
			rotated <= 0;
			need_rotate <= 0;
			rotate_block_type <= 0;
		end
		else if (gamestate == 'd1) begin
			extract_start <= 0;
			right_en <= 1;
			first_move_buffer <= 0;
			ai_new_spawn <= 0;
			rotated <= 0;
			if (~collision_left) begin
				if (blockX == 0)
					blockX <= 'd9;
				else
					blockX <= blockX - 1;
			end
		end
		else if (gamestate == 'd2) begin
			last_current_block_type <= current_block_type;
			if (!first_move_buffer)
				base_block_type <= current_block_type;
			else
				rotate_block_type <= n_rotate_block_type;
		end
		else if (gamestate == 'd3) begin
			rot_en <= 0;
			rotated <= 1;
		end
		else if (gamestate == 'd10) begin
			extract_start <= 1'b1;
			rot_en <= 0;
			need_rotate <= 0;
			if (rotated)
				last_current_block_type <= rotate_block_type;
			if (first_move_buffer) begin
				if (ofm_done) begin
					if (col_right) begin
						if (rotate_block_type == base_block_type)
							ai_new_spawn <= 1;
						else begin
							rot_en <= 1;
							if (ai_rotated)
								need_rotate <= 0;
							else
								need_rotate <= 1;
						end
					end
					else
						rot_en <= 0;
				end
			end
		end
		else if (gamestate == 'd11) begin
			extract_start <= 0;
			first_move_buffer <= 1'b1;
			need_rotate <= 0;
			if (~collision_left) begin
				if (blockX == 0)
					blockX <= 'd9;
				else
					blockX <= blockX - 1;
			end
		end
	wire left_pulse;
	always @(*) begin
		if (_sv2v_0)
			;
		ai_left = 0;
		if ((!first_move_buffer || need_rotate) && (gamestate == 'd2)) begin
			if (left_pulse)
				ai_left = 0;
			else
				ai_left = 1;
		end
		else if (rot_en) begin
			if (gamestate == 'd2) begin
				if (left_pulse)
					ai_left = 0;
				else
					ai_left = 1;
			end
		end
	end
	always @(posedge clk or posedge rst)
		if (rst) begin
			ai_right <= 1'sb0;
			ai_rotate <= 0;
		end
		else if (first_move_buffer) begin
			if (gamestate == 'd2) begin
				ai_right <= 1;
				if (rot_en)
					ai_rotate <= 1;
			end
			else begin
				ai_right <= 0;
				ai_rotate <= 0;
			end
		end
	t01_synckey alexanderweyerthegreat(
		.rst(rst),
		.clk(clk),
		.in({19'b0000000000000000000, ai_left}),
		.strobe(left_pulse)
	);
	reg [3:0] col_ext;
	reg [3:0] abs_col;
	reg collision_right;
	reg rotation_valid;
	always @(*) begin
		if (_sv2v_0)
			;
		collision_left = 1'b0;
		collision_right = 1'b0;
		rotation_valid = 1'b0;
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
	always @(*) begin
		if (_sv2v_0)
			;
		case (last_current_block_type)
			5'd0: n_rotate_block_type = 5'd7;
			5'd7: n_rotate_block_type = 5'd0;
			5'd1: n_rotate_block_type = 5'd1;
			5'd2: n_rotate_block_type = 5'd9;
			5'd9: n_rotate_block_type = 5'd2;
			5'd3: n_rotate_block_type = 5'd8;
			5'd8: n_rotate_block_type = 5'd3;
			5'd5: n_rotate_block_type = 5'd13;
			5'd13: n_rotate_block_type = 5'd14;
			5'd14: n_rotate_block_type = 5'd15;
			5'd15: n_rotate_block_type = 5'd5;
			5'd4: n_rotate_block_type = 5'd10;
			5'd10: n_rotate_block_type = 5'd11;
			5'd11: n_rotate_block_type = 5'd12;
			5'd12: n_rotate_block_type = 5'd4;
			5'd6: n_rotate_block_type = 5'd18;
			5'd18: n_rotate_block_type = 5'd17;
			5'd17: n_rotate_block_type = 5'd16;
			5'd16: n_rotate_block_type = 5'd6;
			default: n_rotate_block_type = current_block_type;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
