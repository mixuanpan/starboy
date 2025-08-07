`default_nettype none
module t01_ai_tetrisFSM (
	clk,
	reset,
	onehuzz,
	right_i,
	left_i,
	start_i,
	rotate_r,
	rotate_l,
	speed_up_i,
	ai_done,
	ai_new_spawn,
	ofm_blockX,
	ai_need_rotate,
	ai_force_right,
	ai_block_type,
	ofm_block_type,
	top_level_state,
	ai_rotated,
	ai_blockX,
	ofm_block_type_input,
	display_array,
	final_display_color,
	gameover,
	score,
	speed_mode_o,
	gamestate,
	current_block_type,
	ai_col_right,
	next_block_type_o,
	next_block_preview
);
	reg _sv2v_0;
	input wire clk;
	input wire reset;
	input wire onehuzz;
	input wire right_i;
	input wire left_i;
	input wire start_i;
	input wire rotate_r;
	input wire rotate_l;
	input wire speed_up_i;
	input wire ai_done;
	input wire ai_new_spawn;
	input wire [3:0] ofm_blockX;
	input wire ai_need_rotate;
	input wire ai_force_right;
	input wire [4:0] ai_block_type;
	input wire [4:0] ofm_block_type;
	input wire [1:0] top_level_state;
	output reg ai_rotated;
	output wire [3:0] ai_blockX;
	output wire [4:0] ofm_block_type_input;
	output reg [199:0] display_array;
	output reg [599:0] final_display_color;
	output reg gameover;
	output wire [9:0] score;
	output wire speed_mode_o;
	output wire [3:0] gamestate;
	output reg [4:0] current_block_type;
	output wire ai_col_right;
	output wire [4:0] next_block_type_o;
	output reg [47:0] next_block_preview;
	localparam BLACK = 3'b000;
	localparam RED = 3'b100;
	localparam GREEN = 3'b010;
	localparam BLUE = 3'b001;
	localparam YELLOW = 3'b110;
	localparam MAGENTA = 3'b101;
	localparam CYAN = 3'b011;
	localparam WHITE = 3'b111;
	reg [599:0] line_clear_input_color;
	wire [599:0] line_clear_output_color;
	reg [599:0] color_array_reg;
	reg [599:0] color_array;
	reg [2:0] current_piece_color;
	reg [4:0] next_block_type;
	reg [2:0] next_piece_color;
	wire [15:0] next_block_pattern;
	reg first_spawn;
	reg [3:0] current_state;
	always @(posedge clk or posedge reset)
		if (reset)
			color_array_reg <= 1'sb0;
		else if (current_state == 4'd9)
			color_array_reg <= 1'sb0;
		else
			color_array_reg <= color_array;
	always @(*) begin
		if (_sv2v_0)
			;
		case (current_block_type)
			5'd0, 5'd7: current_piece_color = CYAN;
			5'd1: current_piece_color = YELLOW;
			5'd2, 5'd9: current_piece_color = GREEN;
			5'd3, 5'd8: current_piece_color = RED;
			5'd4, 5'd10, 5'd11, 5'd12: current_piece_color = WHITE;
			5'd5, 5'd13, 5'd14, 5'd15: current_piece_color = BLUE;
			5'd6, 5'd16, 5'd17, 5'd18: current_piece_color = MAGENTA;
			default: current_piece_color = BLACK;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (next_block_type)
			5'd0, 5'd7: next_piece_color = CYAN;
			5'd1: next_piece_color = YELLOW;
			5'd2, 5'd9: next_piece_color = GREEN;
			5'd3, 5'd8: next_piece_color = RED;
			5'd4, 5'd10, 5'd11, 5'd12: next_piece_color = WHITE;
			5'd5, 5'd13, 5'd14, 5'd15: next_piece_color = BLUE;
			5'd6, 5'd16, 5'd17, 5'd18: next_piece_color = MAGENTA;
			default: next_piece_color = BLACK;
		endcase
	end
	assign next_block_type_o = next_block_type;
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] row;
			for (row = 0; row < 4; row = row + 1)
				begin : sv2v_autoblock_2
					reg signed [31:0] col;
					for (col = 0; col < 4; col = col + 1)
						if (next_block_pattern[(row * 4) + col])
							next_block_preview[((row * 4) + col) * 3+:3] = next_piece_color;
						else
							next_block_preview[((row * 4) + col) * 3+:3] = BLACK;
				end
		end
	end
	reg [3:0] next_state;
	assign gamestate = current_state;
	reg [199:0] stored_array;
	reg [199:0] ai_stored_array;
	wire [199:0] cleared_array;
	reg [4:0] blockY;
	reg [3:0] blockX;
	wire [3:0] blockX_init;
	assign blockX_init = (top_level_state == 2'b10 ? 0 : 'd3);
	wire [15:0] current_block_pattern;
	wire [15:0] next_rotation_pattern;
	assign ai_blockX = blockX;
	wire eval_complete;
	wire [2:0] current_state_counter;
	wire [2:0] next_state_counter;
	reg rotation_valid;
	reg collision_bottom;
	reg collision_left;
	reg collision_right;
	assign ai_col_right = collision_right;
	reg collision_bottom_prev;
	reg stick_delay_active;
	wire rotate_pulse;
	wire left_pulse;
	wire right_pulse;
	wire rotate_pulse_l;
	wire speed_up_sync_level;
	wire speed_mode;
	reg onehuzz_sync0;
	reg onehuzz_sync1;
	wire drop_tick;
	reg start_line_eval;
	wire line_eval_complete;
	reg [199:0] line_clear_input;
	wire [199:0] line_clear_output;
	wire [9:0] line_clear_score;
	reg [199:0] falling_block_display;
	assign score = line_clear_score;
	assign speed_mode_o = speed_up_sync_level;
	always @(posedge clk or posedge reset)
		if (reset) begin
			next_block_type <= 5'd0;
			first_spawn <= 1'b1;
		end
		else if (current_state == 4'd9) begin
			next_block_type <= 5'd0;
			first_spawn <= 1'b1;
		end
		else if (current_state == 4'd1) begin
			if (first_spawn) begin
				next_block_type <= {2'b00, next_state_counter};
				first_spawn <= 1'b0;
			end
			else
				next_block_type <= {2'b00, next_state_counter};
		end
	always @(posedge clk or posedge reset)
		if (reset) begin
			onehuzz_sync0 <= 1'b0;
			onehuzz_sync1 <= 1'b0;
		end
		else if (current_state == 4'd9) begin
			onehuzz_sync0 <= 1'sb0;
			onehuzz_sync1 <= 1'sb0;
		end
		else begin
			onehuzz_sync0 <= onehuzz;
			onehuzz_sync1 <= onehuzz_sync0;
		end
	assign drop_tick = onehuzz_sync1 & ~onehuzz_sync0;
	always @(posedge clk or posedge reset)
		if (reset) begin
			collision_bottom_prev <= 1'b0;
			stick_delay_active <= 1'b0;
		end
		else if (current_state == 4'd9) begin
			collision_bottom_prev <= 1'b0;
			stick_delay_active <= 1'b0;
		end
		else if (current_state == 4'd2) begin
			collision_bottom_prev <= collision_bottom;
			if (collision_bottom && !collision_bottom_prev)
				stick_delay_active <= 1'b1;
			else if (!collision_bottom)
				stick_delay_active <= 1'b0;
		end
		else begin
			stick_delay_active <= 1'b0;
			collision_bottom_prev <= 1'b0;
		end
	always @(posedge clk or posedge reset)
		if (reset)
			current_state <= 4'd0;
		else
			current_state <= next_state;
	reg [4:0] next_current_block_type;
	reg [4:0] ai_last_block_type;
	reg ai_spawner;
	reg [4:0] ai_counter;
	assign ofm_block_type_input = ai_counter;
	always @(posedge clk or posedge reset)
		if (reset) begin
			blockY <= 0;
			blockX <= 0;
			current_block_type <= 5'd0;
			ai_last_block_type <= 0;
			ai_spawner <= 0;
			ai_counter <= 0;
			ai_rotated <= 0;
		end
		else if (current_state == 4'd9) begin
			blockY <= 5'd0;
			blockX <= blockX_init;
			current_block_type <= 5'd0;
			ai_spawner <= 0;
			ai_counter <= 0;
			ai_rotated <= 0;
		end
		else if (current_state == 4'd1) begin
			blockY <= 5'd0;
			blockX <= blockX_init;
			ai_spawner <= 1'b1;
			ai_rotated <= 0;
			ai_counter <= {2'b00, current_state_counter};
			if (top_level_state == 'b10)
				current_block_type <= {2'b00, current_state_counter};
			else if (top_level_state == 'b1) begin
				if (first_spawn)
					current_block_type <= {2'b00, current_state_counter};
				else
					current_block_type <= next_block_type;
			end
		end
		else if (current_state == 4'd11) begin
			blockY <= 0;
			if (~ai_spawner) begin
				if (ai_need_rotate) begin
					current_block_type <= ai_block_type;
					ai_counter <= ai_block_type;
					ai_rotated <= 1;
				end
				else begin
					current_block_type <= ai_counter;
					ai_rotated <= 0;
				end
			end
			else
				current_block_type <= current_block_type;
			if (ai_new_spawn) begin
				blockX <= ofm_blockX;
				current_block_type <= ofm_block_type;
			end
			else if (ai_need_rotate)
				blockX <= 0;
		end
		else if (current_state == 4'd2) begin
			if (drop_tick && !collision_bottom)
				blockY <= blockY + 5'd1;
			if (left_pulse && !collision_left)
				blockX <= blockX - 4'd1;
			else if (right_pulse && !collision_right)
				blockX <= blockX + 4'd1;
		end
		else if (current_state == 4'd10) begin
			if (ai_need_rotate) begin
				current_block_type <= ai_block_type;
				ai_counter <= ai_block_type;
				blockX <= 0;
				ai_rotated <= 1;
			end
			else begin
				current_block_type <= {2'b00, current_state_counter};
				if (ai_new_spawn)
					blockX <= ofm_blockX;
				else begin
					if (ai_force_right)
						blockX <= blockX + 1;
					else
						blockX <= ai_blockX;
					blockY <= 0;
				end
			end
			ai_spawner <= ai_new_spawn;
		end
		else if ((current_state == 4'd3) || (current_state == 4'd4)) begin
			if (rotation_valid)
				current_block_type <= next_current_block_type;
			else
				current_block_type <= current_block_type;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_current_block_type = current_block_type;
		if (current_state == 4'd3)
			case (current_block_type)
				5'd0: next_current_block_type = 5'd7;
				5'd7: next_current_block_type = 5'd0;
				5'd1: next_current_block_type = 5'd1;
				5'd2: next_current_block_type = 5'd9;
				5'd9: next_current_block_type = 5'd2;
				5'd3: next_current_block_type = 5'd8;
				5'd8: next_current_block_type = 5'd3;
				5'd5: next_current_block_type = 5'd13;
				5'd13: next_current_block_type = 5'd14;
				5'd14: next_current_block_type = 5'd15;
				5'd15: next_current_block_type = 5'd5;
				5'd4: next_current_block_type = 5'd10;
				5'd10: next_current_block_type = 5'd11;
				5'd11: next_current_block_type = 5'd12;
				5'd12: next_current_block_type = 5'd4;
				5'd6: next_current_block_type = 5'd18;
				5'd18: next_current_block_type = 5'd17;
				5'd17: next_current_block_type = 5'd16;
				5'd16: next_current_block_type = 5'd6;
				default: next_current_block_type = current_block_type;
			endcase
		else if (current_state == 4'd4)
			case (current_block_type)
				5'd0: next_current_block_type = 5'd7;
				5'd7: next_current_block_type = 5'd0;
				5'd1: next_current_block_type = 5'd1;
				5'd2: next_current_block_type = 5'd9;
				5'd9: next_current_block_type = 5'd2;
				5'd3: next_current_block_type = 5'd8;
				5'd8: next_current_block_type = 5'd3;
				5'd5: next_current_block_type = 5'd15;
				5'd15: next_current_block_type = 5'd14;
				5'd14: next_current_block_type = 5'd13;
				5'd13: next_current_block_type = 5'd5;
				5'd4: next_current_block_type = 5'd12;
				5'd12: next_current_block_type = 5'd11;
				5'd11: next_current_block_type = 5'd10;
				5'd10: next_current_block_type = 5'd4;
				5'd6: next_current_block_type = 5'd16;
				5'd16: next_current_block_type = 5'd17;
				5'd17: next_current_block_type = 5'd18;
				5'd18: next_current_block_type = 5'd6;
				default: next_current_block_type = current_block_type;
			endcase
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			stored_array <= 1'sb0;
			color_array <= 1'sb0;
			ai_stored_array <= 0;
		end
		else if (current_state == 4'd9) begin
			stored_array <= 1'sb0;
			color_array <= 1'sb0;
			ai_stored_array <= 0;
		end
		else if (current_state == 4'd5) begin
			stored_array <= stored_array | falling_block_display;
			begin : sv2v_autoblock_3
				reg signed [31:0] row;
				for (row = 0; row < 20; row = row + 1)
					begin : sv2v_autoblock_4
						reg signed [31:0] col;
						for (col = 0; col < 10; col = col + 1)
							if (falling_block_display[(row * 10) + col])
								color_array[((row * 10) + col) * 3+:3] <= current_piece_color;
					end
			end
		end
		else if ((current_state == 4'd7) && line_eval_complete) begin
			stored_array <= line_clear_output;
			color_array <= line_clear_output_color;
		end
	reg [4:0] row_ext;
	reg [4:0] abs_row;
	reg [3:0] col_ext;
	reg [3:0] abs_col;
	always @(*) begin
		if (_sv2v_0)
			;
		collision_bottom = 1'b0;
		collision_left = 1'b0;
		collision_right = 1'b0;
		falling_block_display = 1'sb0;
		rotation_valid = 1'b1;
		begin : sv2v_autoblock_5
			reg signed [31:0] row;
			for (row = 0; row < 4; row = row + 1)
				begin : sv2v_autoblock_6
					reg signed [31:0] col;
					for (col = 0; col < 4; col = col + 1)
						begin
							row_ext = {3'b000, row[1:0]};
							col_ext = {2'b00, col[1:0]};
							abs_row = blockY + row_ext;
							abs_col = blockX + col_ext;
							if (current_block_pattern[(row * 4) + col]) begin
								if ((abs_row < 5'd20) && (abs_col < 4'd10))
									falling_block_display[(abs_row * 10) + abs_col] = 1'b1;
								if (((abs_row + 5'd1) >= 5'd20) || (((abs_row + 5'd1) < 5'd20) && stored_array[((abs_row + 5'd1) * 10) + abs_col]))
									collision_bottom = 1'b1;
								if ((abs_col == 4'd0) || ((abs_col > 4'd0) && stored_array[(abs_row * 10) + (abs_col - 4'd1)]))
									collision_left = 1'b1;
								if (((abs_col + 4'd1) >= 4'd10) || (((abs_col + 4'd1) < 4'd10) && stored_array[(abs_row * 10) + (abs_col + 4'd1)]))
									collision_right = 1'b1;
							end
							if (next_rotation_pattern[(row * 4) + col]) begin
								if ((abs_row > 5'd19) || (abs_col > 4'd9))
									rotation_valid = 1'b0;
								else if (stored_array[(abs_row * 10) + abs_col])
									rotation_valid = 1'b0;
							end
						end
				end
		end
		begin : sv2v_autoblock_7
			reg signed [31:0] row;
			for (row = 0; row < 20; row = row + 1)
				begin : sv2v_autoblock_8
					reg signed [31:0] col;
					for (col = 0; col < 10; col = col + 1)
						if ((current_state == 4'd0) || (current_state == 4'd9))
							final_display_color[((row * 10) + col) * 3+:3] = BLACK;
						else if (falling_block_display[(row * 10) + col])
							final_display_color[((row * 10) + col) * 3+:3] = current_piece_color;
						else
							final_display_color[((row * 10) + col) * 3+:3] = (stored_array[(row * 10) + col] ? color_array_reg[((row * 10) + col) * 3+:3] : BLACK);
				end
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = current_state;
		gameover = current_state == 4'd8;
		start_line_eval = 1'b0;
		line_clear_input = stored_array;
		line_clear_input_color = color_array;
		case (current_state)
			4'd0: begin
				if (start_i)
					next_state = 4'd1;
				display_array = 1'sb0;
			end
			4'd1: begin
				next_state = 4'd2;
				display_array = falling_block_display | stored_array;
			end
			4'd11: begin
				next_state = 4'd2;
				display_array = falling_block_display | stored_array;
			end
			4'd2: begin
				if ((collision_bottom && stick_delay_active) && drop_tick) begin
					if ((top_level_state == 2'b10) && !ai_new_spawn)
						next_state = 4'd10;
					else
						next_state = 4'd5;
				end
				else if ((current_block_type != 5'd1) && rotate_pulse)
					next_state = 4'd3;
				else if ((current_block_type != 5'd1) && rotate_pulse_l)
					next_state = 4'd4;
				display_array = falling_block_display | stored_array;
			end
			4'd10: begin
				display_array = falling_block_display | stored_array;
				if (ai_done) begin
					if (ai_new_spawn)
						next_state = 4'd2;
					else
						next_state = 4'd11;
				end
			end
			4'd5: begin
				if (|stored_array[0+:10])
					next_state = 4'd8;
				else
					next_state = 4'd6;
				display_array = falling_block_display | stored_array;
			end
			4'd3: begin
				display_array = falling_block_display | stored_array;
				next_state = 4'd2;
			end
			4'd4: begin
				display_array = falling_block_display | stored_array;
				next_state = 4'd2;
			end
			4'd6: begin
				display_array = stored_array;
				next_state = 4'd7;
				start_line_eval = 1'b1;
				line_clear_input = stored_array;
				line_clear_input_color = color_array;
			end
			4'd7: begin
				if (line_eval_complete)
					next_state = 4'd1;
				display_array = line_clear_output;
			end
			4'd8: begin
				if (right_i)
					next_state = 4'd9;
				else
					next_state = 4'd8;
				display_array = stored_array;
			end
			4'd9: begin
				display_array = 1'sb0;
				if (start_i)
					next_state = 4'd1;
				else
					next_state = 4'd9;
			end
			default: begin
				next_state = 4'd0;
				display_array = stored_array;
			end
		endcase
	end
	t01_counter paolowang(
		.clk(clk),
		.rst(reset),
		.enable(1'b1),
		.block_type(current_state_counter),
		.lfsr_reg()
	);
	t01_counter nextblockgen(
		.clk(clk),
		.rst(reset),
		.enable(1'b1),
		.block_type(next_state_counter),
		.lfsr_reg()
	);
	t01_lineclear mangomango(
		.clk(clk),
		.reset(reset),
		.start_eval(start_line_eval),
		.gamestate(current_state),
		.input_array(line_clear_input),
		.input_color_array(line_clear_input_color),
		.output_array(line_clear_output),
		.output_color_array(line_clear_output_color),
		.eval_complete(line_eval_complete),
		.score(line_clear_score),
		.lines_cleared_count()
	);
	t01_synckey alexanderweyerthegreat(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, rotate_r}),
		.strobe(rotate_pulse)
	);
	t01_synckey lanadelrey(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, rotate_l}),
		.strobe(rotate_pulse_l)
	);
	t01_synckey puthputhboy(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, left_i}),
		.strobe(left_pulse)
	);
	t01_synckey JohnnyTheKing(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, right_i}),
		.strobe(right_pulse)
	);
	t01_button_sync brawlstars(
		.rst(reset),
		.clk(clk),
		.button_in(speed_up_i),
		.button_sync_out(speed_up_sync_level)
	);
	t01_blockgen swabey(
		.current_block_type(current_block_type),
		.current_block_pattern(current_block_pattern)
	);
	t01_blockgen rotation_gen(
		.current_block_type(next_current_block_type),
		.current_block_pattern(next_rotation_pattern)
	);
	t01_blockgen next_piece_gen(
		.current_block_type(next_block_type),
		.current_block_pattern(next_block_pattern)
	);
	initial _sv2v_0 = 0;
endmodule
