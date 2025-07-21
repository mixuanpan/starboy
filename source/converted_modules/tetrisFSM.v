module tetrisFSM (
	clk,
	reset,
	onehuzz,
	en_newgame,
	right_i,
	left_i,
	start_i,
	rotate_r,
	rotate_l,
	speed_up_i,
	display_array,
	gameover,
	score,
	speed_mode_o
);
	reg _sv2v_0;
	input wire clk;
	input wire reset;
	input wire onehuzz;
	input wire en_newgame;
	input wire right_i;
	input wire left_i;
	input wire start_i;
	input wire rotate_r;
	input wire rotate_l;
	input wire speed_up_i;
	output reg [199:0] display_array;
	output reg gameover;
	output wire [7:0] score;
	output wire speed_mode_o;
	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [199:0] stored_array;
	wire [199:0] cleared_array;
	reg [4:0] blockY;
	reg [3:0] blockX;
	reg [4:0] current_block_type;
	wire [15:0] current_block_pattern;
	wire eval_complete;
	wire rotate_direction;
	wire [2:0] current_state_counter;
	reg collision_bottom;
	reg collision_left;
	reg collision_right;
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
	wire [7:0] line_clear_score;
	assign score = line_clear_score;
	assign speed_mode_o = speed_up_sync_level;
	always @(posedge clk or posedge reset)
		if (reset) begin
			onehuzz_sync0 <= 1'b0;
			onehuzz_sync1 <= 1'b0;
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
		else if (current_state == 3'd2) begin
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
			current_state <= 3'd0;
		else
			current_state <= next_state;
	reg [4:0] next_current_block_type;
	always @(posedge clk or posedge reset)
		if (reset) begin
			blockY <= 5'd0;
			blockX <= 4'd3;
			current_block_type <= 5'd0;
		end
		else if (current_state == 3'd1) begin
			blockY <= 5'd0;
			blockX <= 4'd3;
			current_block_type <= {2'b00, current_state_counter};
		end
		else if (current_state == 3'd2) begin
			if (drop_tick && !collision_bottom)
				blockY <= blockY + 5'd1;
			if (left_pulse && !collision_left)
				blockX <= blockX - 4'd1;
			else if (right_pulse && !collision_right)
				blockX <= blockX + 4'd1;
		end
		else if (current_state == 3'd3) begin
			current_block_type <= next_current_block_type;
			if (collision_left) begin
				if (current_block_type == 5'd7)
					blockX <= blockX + 4'd2;
				else
					blockX <= blockX + 4'd1;
			end
			else if (collision_right) begin
				if (current_block_type == 5'd7)
					blockX <= blockX - 4'd2;
				else
					blockX <= blockX - 4'd1;
			end
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_current_block_type = current_block_type;
		if (current_state == 3'd3) begin
			if (rotate_direction == 1'b0)
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
			else
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
	end
	reg [199:0] falling_block_display;
	always @(posedge clk or posedge reset)
		if (reset)
			stored_array <= 1'sb0;
		else if (current_state == 3'd4)
			stored_array <= stored_array | falling_block_display;
		else if ((current_state == 3'd6) && line_eval_complete)
			stored_array <= line_clear_output;
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
		begin : sv2v_autoblock_1
			reg signed [31:0] row;
			for (row = 0; row < 4; row = row + 1)
				begin : sv2v_autoblock_2
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
						end
				end
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = current_state;
		gameover = current_state == 3'd7;
		start_line_eval = 1'b0;
		line_clear_input = stored_array;
		case (current_state)
			3'd0: begin
				if (start_i)
					next_state = 3'd1;
				display_array = stored_array;
			end
			3'd1: begin
				next_state = 3'd2;
				display_array = falling_block_display | stored_array;
			end
			3'd2: begin
				if ((collision_bottom && stick_delay_active) && drop_tick)
					next_state = 3'd4;
				else if ((current_block_type != 5'd1) && (rotate_pulse || rotate_pulse_l))
					next_state = 3'd3;
				display_array = falling_block_display | stored_array;
			end
			3'd4: begin
				if (|stored_array[0+:10])
					next_state = 3'd7;
				else
					next_state = 3'd5;
				display_array = falling_block_display | stored_array;
			end
			3'd3: begin
				display_array = falling_block_display | stored_array;
				next_state = 3'd2;
			end
			3'd5: begin
				next_state = 3'd6;
				display_array = stored_array;
				start_line_eval = 1'b1;
				line_clear_input = stored_array;
			end
			3'd6: begin
				if (line_eval_complete)
					next_state = 3'd1;
				display_array = line_clear_output;
			end
			3'd7: begin
				next_state = 3'd7;
				display_array = stored_array;
			end
			default: begin
				next_state = 3'd0;
				display_array = stored_array;
			end
		endcase
	end
	counter paolowang(
		.clk(clk),
		.rst(reset),
		.enable(1'b1),
		.block_type(current_state_counter)
	);
	lineclear mangomango(
		.clk(clk),
		.reset(reset),
		.start_eval(start_line_eval),
		.input_array(line_clear_input),
		.output_array(line_clear_output),
		.eval_complete(line_eval_complete),
		.score(line_clear_score)
	);
	synckey alexanderweyerthegreat(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, rotate_r}),
		.strobe(rotate_pulse)
	);
	synckey lanadelrey(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, rotate_l}),
		.strobe(rotate_pulse_l)
	);
	synckey puthputhboy(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, left_i}),
		.strobe(left_pulse)
	);
	synckey JohnnyTheKing(
		.rst(reset),
		.clk(clk),
		.in({19'b0000000000000000000, right_i}),
		.strobe(right_pulse)
	);
	button_sync brawlstars(
		.rst(reset),
		.clk(clk),
		.button_in(speed_up_i),
		.button_sync_out(speed_up_sync_level)
	);
	blockgen swabey(
		.current_block_type(current_block_type),
		.current_block_pattern(current_block_pattern)
	);
	initial _sv2v_0 = 0;
endmodule
