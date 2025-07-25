`default_nettype none
module t01_ai_feature_extract (
	clk,
	reset,
	start_extract,
	next_board,
	extract_ready,
	lines_cleared,
	holes,
	bumpiness,
	height_sum
);
	reg _sv2v_0;
	input wire clk;
	input wire reset;
	input wire start_extract;
	input wire [199:0] next_board;
	output reg extract_ready;
	output reg [2:0] lines_cleared;
	output reg [7:0] holes;
	output reg [7:0] bumpiness;
	output reg [7:0] height_sum;
	reg [2:0] current_state;
	reg [2:0] next_state;
	wire [4:0] heights [0:9];
	wire [4:0] column_counter;
	wire [4:0] row_counter;
	wire seen_block [0:9];
	wire [7:0] holes_temp;
	wire [7:0] height_sum_temp;
	wire [2:0] lines_temp;
	wire [7:0] bumpiness_temp;
	reg [9:0] row_masks [0:19];
	reg row_full [0:19];
	reg [4:0] column_heights [0:9];
	reg [7:0] total_holes;
	reg [7:0] total_bumpiness;
	reg [7:0] total_height_sum;
	reg [2:0] total_lines;
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] r;
			for (r = 0; r < 20; r = r + 1)
				begin
					row_masks[r] = next_board[r * 10+:10];
					row_full[r] = row_masks[r] == 10'b1111111111;
				end
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		total_lines = 3'd0;
		begin : sv2v_autoblock_2
			reg signed [31:0] r;
			for (r = 0; r < 20; r = r + 1)
				if (row_full[r])
					total_lines = total_lines + 1;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_3
			reg signed [31:0] c;
			for (c = 0; c < 10; c = c + 1)
				begin
					column_heights[c] = 5'd0;
					begin : sv2v_autoblock_4
						reg signed [31:0] r;
						for (r = 19; r >= 0; r = r - 1)
							if ((column_heights[c] == 5'd0) && next_board[(r * 10) + c])
								column_heights[c] = r[4:0] + 5'd1;
					end
				end
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		total_height_sum = 8'd0;
		begin : sv2v_autoblock_5
			reg signed [31:0] c;
			for (c = 0; c < 10; c = c + 1)
				total_height_sum = total_height_sum + {3'b000, column_heights[c]};
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		total_holes = 8'd0;
		begin : sv2v_autoblock_6
			reg signed [31:0] c;
			for (c = 0; c < 10; c = c + 1)
				begin : sv2v_autoblock_7
					reg local_seen_block;
					reg [7:0] column_holes;
					local_seen_block = 1'b0;
					column_holes = 8'd0;
					begin : sv2v_autoblock_8
						reg signed [31:0] r;
						for (r = 19; r >= 0; r = r - 1)
							if (next_board[(r * 10) + c] == 1'b1)
								local_seen_block = 1'b1;
							else if (local_seen_block)
								column_holes = column_holes + 1;
					end
					total_holes = total_holes + column_holes;
				end
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		total_bumpiness = 8'd0;
		begin : sv2v_autoblock_9
			reg signed [31:0] c;
			for (c = 0; c < 9; c = c + 1)
				begin : sv2v_autoblock_10
					reg [4:0] height_diff;
					if (column_heights[c] > column_heights[c + 1])
						height_diff = column_heights[c] - column_heights[c + 1];
					else
						height_diff = column_heights[c + 1] - column_heights[c];
					total_bumpiness = total_bumpiness + {3'b000, height_diff};
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
		case (current_state)
			3'd0:
				if (start_extract)
					next_state = 3'd1;
				else
					next_state = 3'd0;
			3'd1: next_state = 3'd2;
			3'd2: next_state = 3'd3;
			3'd3: next_state = 3'd4;
			3'd4: next_state = 3'd5;
			3'd5:
				if (!start_extract)
					next_state = 3'd0;
				else
					next_state = 3'd5;
			default: next_state = 3'd0;
		endcase
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			lines_cleared <= 3'd0;
			holes <= 8'd0;
			bumpiness <= 8'd0;
			height_sum <= 8'd0;
			extract_ready <= 1'b0;
		end
		else
			case (current_state)
				3'd0:
					if (start_extract)
						extract_ready <= 1'b0;
				3'd1:
					;
				3'd2: lines_cleared <= total_lines;
				3'd3: holes <= total_holes;
				3'd4: begin
					bumpiness <= total_bumpiness;
					height_sum <= total_height_sum;
				end
				3'd5: extract_ready <= 1'b1;
				default:
					;
			endcase
	initial _sv2v_0 = 0;
endmodule