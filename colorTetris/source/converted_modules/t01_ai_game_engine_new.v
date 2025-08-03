`default_nettype none
module t01_ai_game_engine_new (
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
	extract_start,
	current_block_type,
	tetris_grid,
	extract_ready,
	lines_cleared,
	holes,
	bumpiness,
	height_sum,
	state
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [3:0] gamestate;
	input wire col_right;
	input wire col_left;
	output reg ai_right;
	output reg ai_left;
	output reg ai_rotation;
	output reg [3:0] blockX;
	output reg ai_new_spawn;
	output reg extract_start;
	input wire [4:0] current_block_type;
	input wire [199:0] tetris_grid;
	output reg extract_ready;
	output wire [9:0] lines_cleared;
	output wire [7:0] holes;
	output wire [7:0] bumpiness;
	output wire [7:0] height_sum;
	output wire [2:0] state;
	reg [4:0] base_block_type;
	reg right_en;
	reg rot_en;
	reg first_move_buffer;
	reg [2:0] c_state;
	reg [2:0] n_state;
	assign state = c_state;
	wire [199:0] cleared_array;
	wire clear_complete;
	reg start_eval;
	t01_lineclear line_clear_master(
		.clk(clk),
		.reset(rst),
		.gamestate(gamestate),
		.start_eval(start_eval),
		.input_array(tetris_grid),
		.input_color_array(),
		.output_array(cleared_array),
		.output_color_array(),
		.eval_complete(clear_complete),
		.score(lines_cleared)
	);
	reg [4:0] heights [0:9];
	reg [3:0] height_column_counter;
	reg [3:0] n_height_column_counter;
	assign height_sum = (((((((({3'b000, heights[0]} + {3'b000, heights[1]}) + {3'b000, heights[2]}) + {3'b000, heights[3]}) + {3'b000, heights[4]}) + {3'b000, heights[5]}) + {3'b000, heights[6]}) + {3'b000, heights[7]}) + {3'b000, heights[8]}) + {3'b000, heights[9]};
	wire [4:0] bump_spread [0:8];
	assign bump_spread[0] = (heights[0] > heights[1] ? heights[0] - heights[1] : heights[1] - heights[0]);
	assign bump_spread[1] = (heights[1] > heights[2] ? heights[1] - heights[2] : heights[2] - heights[1]);
	assign bump_spread[2] = (heights[2] > heights[3] ? heights[2] - heights[3] : heights[3] - heights[2]);
	assign bump_spread[3] = (heights[3] > heights[4] ? heights[3] - heights[4] : heights[4] - heights[3]);
	assign bump_spread[4] = (heights[4] > heights[5] ? heights[4] - heights[5] : heights[5] - heights[4]);
	assign bump_spread[5] = (heights[5] > heights[6] ? heights[5] - heights[6] : heights[6] - heights[5]);
	assign bump_spread[6] = (heights[6] > heights[7] ? heights[6] - heights[7] : heights[7] - heights[6]);
	assign bump_spread[7] = (heights[7] > heights[8] ? heights[7] - heights[8] : heights[8] - heights[7]);
	assign bumpiness = ((((((({3'b000, bump_spread[0]} + {3'b000, bump_spread[1]}) + {3'b000, bump_spread[2]}) + {3'b000, bump_spread[3]}) + {3'b000, bump_spread[4]}) + {3'b000, bump_spread[5]}) + {3'b000, bump_spread[6]}) + {3'b000, bump_spread[7]}) + {3'b000, bump_spread[8]};
	reg [3:0] hole_column_counter;
	reg [3:0] n_hole_column_counter;
	reg hole_perceived;
	reg n_hole_perceived;
	reg [7:0] c_holes;
	reg [7:0] n_holes;
	reg [7:0] c_hole_start_row;
	reg [7:0] n_hole_start_row;
	assign holes = c_holes;
	reg collision_left;
	reg move_cnt;
	always @(posedge clk or posedge rst)
		if (rst) begin
			extract_start <= 0;
			ai_rotation <= 0;
			rot_en <= 1;
			first_move_buffer <= 0;
			ai_new_spawn <= 0;
			base_block_type <= 0;
			blockX <= 0;
			move_cnt <= 0;
			c_state <= 3'd0;
			c_holes <= 0;
			height_column_counter <= 0;
			hole_column_counter <= 0;
			hole_perceived <= 0;
			c_hole_start_row <= 'd18;
		end
		else if (gamestate == 'd1) begin
			extract_start <= 0;
			rot_en <= 1;
			right_en <= 1;
			first_move_buffer <= 0;
			base_block_type <= current_block_type;
			move_cnt <= 0;
			if (~collision_left) begin
				if (blockX == 0)
					blockX <= 'd9;
				else
					blockX <= blockX - 1;
			end
		end
		else if (gamestate == 'd2)
			ai_right <= 1;
		else if (gamestate == 'd10) begin
			ai_right <= 0;
			move_cnt <= 0;
			ai_rotation <= 0;
			extract_start <= 1'b1;
			c_state <= n_state;
			c_holes <= n_holes;
			height_column_counter <= n_height_column_counter;
			hole_column_counter <= n_hole_column_counter;
			hole_perceived <= n_hole_perceived;
			c_hole_start_row <= n_hole_start_row;
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
	always @(*) begin
		if (_sv2v_0)
			;
		n_state = c_state;
		n_holes = c_holes;
		start_eval = 0;
		extract_ready = 0;
		begin : sv2v_autoblock_3
			reg signed [31:0] r;
			for (r = 0; r < 20; r = r + 1)
				heights[r] = 0;
		end
		n_height_column_counter = height_column_counter;
		n_hole_column_counter = hole_column_counter;
		n_hole_perceived = hole_perceived;
		n_hole_start_row = c_hole_start_row;
		case (c_state)
			3'd0:
				if (extract_start)
					n_state = 3'd1;
			3'd1: begin
				start_eval = 1;
				n_height_column_counter = 0;
				if (clear_complete)
					n_state = 3'd2;
			end
			3'd2:
				if (hole_column_counter >= 'd10)
					n_state = 3'd5;
				else if (height_column_counter >= 'd10) begin
					begin : sv2v_autoblock_4
						reg signed [31:0] r;
						for (r = 1; r >= 18; r = r + 1)
							if ((cleared_array[((r - 1) * 10) + hole_column_counter] && !cleared_array[(r * 10) + hole_column_counter]) && cleared_array[((r + 1) * 10) + hole_column_counter]) begin
								n_hole_start_row = r[7:0] + 'd2;
								n_hole_perceived = 1;
								n_state = 3'd4;
							end
					end
					n_state = 3'd4;
				end
				else begin
					begin : sv2v_autoblock_5
						reg signed [31:0] r;
						for (r = 19; r >= 0; r = r - 1)
							if (|cleared_array[(r * 10) + height_column_counter])
								heights[height_column_counter] = 5'd20 - r[4:0];
					end
					n_state = 3'd3;
				end
			3'd3: begin
				n_height_column_counter = height_column_counter + 1;
				n_state = 3'd2;
			end
			3'd4: begin
				if (hole_perceived)
					n_holes = c_holes + 1;
				if (c_hole_start_row >= (8'd18 - {3'b000, heights[hole_column_counter]})) begin
					n_hole_start_row = 0;
					n_hole_column_counter = hole_column_counter + 1;
				end
				n_hole_perceived = 0;
				n_state = 3'd2;
			end
			3'd5: begin
				extract_ready = 1;
				if (!extract_start)
					n_state = 3'd0;
			end
			default:
				;
		endcase
	end
	wire right_pulse;
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
