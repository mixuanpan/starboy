`default_nettype none
module t01_ai_placement_engine (
	clk,
	reset,
	start_placement,
	display_array,
	piece_type,
	placement_ready,
	next_boards,
	valid_placements,
	rotations,
	x_positions
);
	reg _sv2v_0;
	input wire clk;
	input wire reset;
	input wire start_placement;
	input wire [199:0] display_array;
	input wire [4:0] piece_type;
	output reg placement_ready;
	output reg [7999:0] next_boards;
	output reg [5:0] valid_placements;
	output reg [79:0] rotations;
	output reg [159:0] x_positions;
	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [1:0] current_rotation;
	reg [3:0] current_x;
	reg [5:0] placement_index;
	reg [15:0] current_pattern;
	reg [1:0] max_rotations;
	reg [3:0] min_x;
	reg [3:0] max_x;
	reg [199:0] current_board;
	reg [199:0] shifted_mask;
	reg [4:0] landing_row;
	reg [199:0] merged_board;
	reg collision_detected;
	reg valid_position;
	reg [15:0] piece_patterns [0:18];
	reg [3:0] legal_x_min [0:18];
	reg [3:0] legal_x_max [0:18];
	initial begin
		piece_patterns[0][0+:4] = 4'b0100;
		piece_patterns[0][4+:4] = 4'b0100;
		piece_patterns[0][8+:4] = 4'b0100;
		piece_patterns[0][12+:4] = 4'b0100;
		legal_x_min[0] = 0;
		legal_x_max[0] = 9;
		piece_patterns[7][0+:4] = 4'b0000;
		piece_patterns[7][4+:4] = 4'b1111;
		piece_patterns[7][8+:4] = 4'b0000;
		piece_patterns[7][12+:4] = 4'b0000;
		legal_x_min[7] = 0;
		legal_x_max[7] = 6;
		piece_patterns[1][0+:4] = 4'b0110;
		piece_patterns[1][4+:4] = 4'b0110;
		piece_patterns[1][8+:4] = 4'b0000;
		piece_patterns[1][12+:4] = 4'b0000;
		legal_x_min[1] = 0;
		legal_x_max[1] = 8;
		piece_patterns[2][0+:4] = 4'b0110;
		piece_patterns[2][4+:4] = 4'b1100;
		piece_patterns[2][8+:4] = 4'b0000;
		piece_patterns[2][12+:4] = 4'b0000;
		legal_x_min[2] = 0;
		legal_x_max[2] = 7;
		piece_patterns[9][0+:4] = 4'b1000;
		piece_patterns[9][4+:4] = 4'b1100;
		piece_patterns[9][8+:4] = 4'b0100;
		piece_patterns[9][12+:4] = 4'b0000;
		legal_x_min[9] = 0;
		legal_x_max[9] = 8;
		piece_patterns[3][0+:4] = 4'b1100;
		piece_patterns[3][4+:4] = 4'b0110;
		piece_patterns[3][8+:4] = 4'b0000;
		piece_patterns[3][12+:4] = 4'b0000;
		legal_x_min[3] = 0;
		legal_x_max[3] = 7;
		piece_patterns[8][0+:4] = 4'b0100;
		piece_patterns[8][4+:4] = 4'b1100;
		piece_patterns[8][8+:4] = 4'b1000;
		piece_patterns[8][12+:4] = 4'b0000;
		legal_x_min[8] = 0;
		legal_x_max[8] = 8;
		piece_patterns[4][0+:4] = 4'b1000;
		piece_patterns[4][4+:4] = 4'b1110;
		piece_patterns[4][8+:4] = 4'b0000;
		piece_patterns[4][12+:4] = 4'b0000;
		legal_x_min[4] = 0;
		legal_x_max[4] = 7;
		piece_patterns[10][0+:4] = 4'b1100;
		piece_patterns[10][4+:4] = 4'b1000;
		piece_patterns[10][8+:4] = 4'b1000;
		piece_patterns[10][12+:4] = 4'b0000;
		legal_x_min[10] = 0;
		legal_x_max[10] = 8;
		piece_patterns[11][0+:4] = 4'b1110;
		piece_patterns[11][4+:4] = 4'b0010;
		piece_patterns[11][8+:4] = 4'b0000;
		piece_patterns[11][12+:4] = 4'b0000;
		legal_x_min[11] = 0;
		legal_x_max[11] = 7;
		piece_patterns[12][0+:4] = 4'b0100;
		piece_patterns[12][4+:4] = 4'b0100;
		piece_patterns[12][8+:4] = 4'b1100;
		piece_patterns[12][12+:4] = 4'b0000;
		legal_x_min[12] = 0;
		legal_x_max[12] = 8;
		piece_patterns[5][0+:4] = 4'b0010;
		piece_patterns[5][4+:4] = 4'b1110;
		piece_patterns[5][8+:4] = 4'b0000;
		piece_patterns[5][12+:4] = 4'b0000;
		legal_x_min[5] = 0;
		legal_x_max[5] = 7;
		piece_patterns[13][0+:4] = 4'b1000;
		piece_patterns[13][4+:4] = 4'b1000;
		piece_patterns[13][8+:4] = 4'b1100;
		piece_patterns[13][12+:4] = 4'b0000;
		legal_x_min[13] = 0;
		legal_x_max[13] = 8;
		piece_patterns[14][0+:4] = 4'b1110;
		piece_patterns[14][4+:4] = 4'b1000;
		piece_patterns[14][8+:4] = 4'b0000;
		piece_patterns[14][12+:4] = 4'b0000;
		legal_x_min[14] = 0;
		legal_x_max[14] = 7;
		piece_patterns[15][0+:4] = 4'b1100;
		piece_patterns[15][4+:4] = 4'b0100;
		piece_patterns[15][8+:4] = 4'b0100;
		piece_patterns[15][12+:4] = 4'b0000;
		legal_x_min[15] = 0;
		legal_x_max[15] = 8;
		piece_patterns[6][0+:4] = 4'b0100;
		piece_patterns[6][4+:4] = 4'b1110;
		piece_patterns[6][8+:4] = 4'b0000;
		piece_patterns[6][12+:4] = 4'b0000;
		legal_x_min[6] = 0;
		legal_x_max[6] = 7;
		piece_patterns[16][0+:4] = 4'b1000;
		piece_patterns[16][4+:4] = 4'b1100;
		piece_patterns[16][8+:4] = 4'b1000;
		piece_patterns[16][12+:4] = 4'b0000;
		legal_x_min[16] = 0;
		legal_x_max[16] = 8;
		piece_patterns[17][0+:4] = 4'b1110;
		piece_patterns[17][4+:4] = 4'b0100;
		piece_patterns[17][8+:4] = 4'b0000;
		piece_patterns[17][12+:4] = 4'b0000;
		legal_x_min[17] = 0;
		legal_x_max[17] = 7;
		piece_patterns[18][0+:4] = 4'b0100;
		piece_patterns[18][4+:4] = 4'b1100;
		piece_patterns[18][8+:4] = 4'b0100;
		piece_patterns[18][12+:4] = 4'b0000;
		legal_x_min[18] = 0;
		legal_x_max[18] = 8;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		current_board = 200'd0;
		begin : sv2v_autoblock_1
			reg signed [31:0] row;
			for (row = 0; row < 20; row = row + 1)
				begin : sv2v_autoblock_2
					reg signed [31:0] col;
					for (col = 0; col < 10; col = col + 1)
						if (display_array[(row * 10) + col])
							current_board[(row * 10) + col] = 1'b1;
				end
		end
	end
	always @(posedge clk or posedge reset)
		if (reset)
			current_state <= 3'd0;
		else
			current_state <= next_state;
	always @(*) begin
		if (_sv2v_0)
			;
		case (piece_type[2:0])
			3'd0: max_rotations = 2'd1;
			3'd1: max_rotations = 2'd0;
			3'd2, 3'd3: max_rotations = 2'd1;
			3'd4, 3'd5, 3'd6: max_rotations = 2'd3;
			3'd7: max_rotations = 2'd1;
			default: max_rotations = 2'd0;
		endcase
	end
	reg [4:0] pattern_index;
	always @(*) begin
		if (_sv2v_0)
			;
		case (piece_type[2:0])
			3'd0: pattern_index = (current_rotation == 0 ? 5'd0 : 5'd7);
			3'd1: pattern_index = 5'd1;
			3'd2: pattern_index = (current_rotation == 0 ? 5'd2 : 5'd9);
			3'd3: pattern_index = (current_rotation == 0 ? 5'd3 : 5'd8);
			3'd4:
				case (current_rotation)
					2'd0: pattern_index = 5'd4;
					2'd1: pattern_index = 5'd10;
					2'd2: pattern_index = 5'd11;
					2'd3: pattern_index = 5'd12;
					default: pattern_index = 5'd4;
				endcase
			3'd5:
				case (current_rotation)
					2'd0: pattern_index = 5'd5;
					2'd1: pattern_index = 5'd13;
					2'd2: pattern_index = 5'd14;
					2'd3: pattern_index = 5'd15;
					default: pattern_index = 5'd5;
				endcase
			3'd6:
				case (current_rotation)
					2'd0: pattern_index = 5'd6;
					2'd1: pattern_index = 5'd18;
					2'd2: pattern_index = 5'd17;
					2'd3: pattern_index = 5'd16;
					default: pattern_index = 5'd6;
				endcase
			3'd7: pattern_index = 5'd0;
			default: pattern_index = 5'd0;
		endcase
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			current_rotation <= 2'd0;
			current_x <= 4'd0;
			placement_index <= 6'd0;
			valid_placements <= 6'd0;
			placement_ready <= 1'b0;
		end
		else
			case (current_state)
				3'd0:
					if (start_placement) begin
						current_rotation <= 2'd0;
						current_x <= 4'd0;
						placement_index <= 6'd0;
						valid_placements <= 6'd0;
						placement_ready <= 1'b0;
					end
				3'd1: begin
					current_pattern <= piece_patterns[pattern_index];
					min_x <= legal_x_min[pattern_index];
					max_x <= legal_x_max[pattern_index];
					current_x <= legal_x_min[pattern_index];
				end
				3'd2: begin
					if (valid_position && !collision_detected) begin
						next_boards[placement_index * 200+:200] <= merged_board;
						rotations[placement_index * 2+:2] <= current_rotation;
						x_positions[placement_index * 4+:4] <= current_x;
						placement_index <= placement_index + 1;
						valid_placements <= valid_placements + 1;
					end
					if (current_x < legal_x_max[pattern_index])
						current_x <= current_x + 1;
					else begin
						current_x <= legal_x_min[pattern_index];
						if (current_rotation < max_rotations)
							current_rotation <= current_rotation + 1;
					end
				end
				3'd5: placement_ready <= 1'b1;
			endcase
	always @(*) begin
		if (_sv2v_0)
			;
		case (current_state)
			3'd0:
				if (start_placement)
					next_state = 3'd1;
				else
					next_state = 3'd0;
			3'd1: next_state = 3'd2;
			3'd2:
				if ((current_x >= legal_x_max[pattern_index]) && (current_rotation >= max_rotations))
					next_state = 3'd5;
				else
					next_state = 3'd3;
			3'd3: next_state = 3'd4;
			3'd4: next_state = 3'd2;
			3'd5:
				if (!start_placement)
					next_state = 3'd0;
				else
					next_state = 3'd5;
			default: next_state = 3'd0;
		endcase
	end
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		shifted_mask = 200'd0;
		begin : sv2v_autoblock_3
			reg signed [31:0] row;
			for (row = 0; row < 4; row = row + 1)
				begin : sv2v_autoblock_4
					reg signed [31:0] col;
					for (col = 0; col < 4; col = col + 1)
						if (current_pattern[(row * 4) + col]) begin
							if ((sv2v_cast_32_signed(current_x) + col) < 10)
								shifted_mask[((row * 10) + sv2v_cast_32_signed(current_x)) + col] = 1'b1;
						end
				end
		end
	end
	reg [199:0] mask_at_row;
	function automatic signed [4:0] sv2v_cast_5_signed;
		input reg signed [4:0] inp;
		sv2v_cast_5_signed = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		landing_row = 5'd0;
		collision_detected = 1'b0;
		valid_position = 1'b1;
		mask_at_row = 200'd0;
		if (|(shifted_mask & current_board)) begin
			valid_position = 1'b0;
			landing_row = 5'd0;
		end
		else begin
			landing_row = 5'd0;
			begin : sv2v_autoblock_5
				reg signed [31:0] drop_row;
				for (drop_row = 0; drop_row <= 16; drop_row = drop_row + 1)
					begin
						mask_at_row = shifted_mask << (drop_row * 10);
						if (|(mask_at_row & current_board)) begin
							if (drop_row > 0)
								landing_row = sv2v_cast_5_signed(drop_row - 1);
							else
								landing_row = 5'd0;
							drop_row = 17;
						end
						else if (drop_row == 16)
							landing_row = 5'd16;
					end
			end
		end
	end
	always @(*) begin : sv2v_autoblock_6
		reg [199:0] final_mask;
		if (_sv2v_0)
			;
		final_mask = shifted_mask << (landing_row * 10);
		merged_board = current_board | final_mask;
	end
	initial _sv2v_0 = 0;
endmodule
