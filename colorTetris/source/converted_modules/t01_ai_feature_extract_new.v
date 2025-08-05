`default_nettype none
module t01_ai_feature_extract_new (
	clk,
	rst,
	extract_start,
	tetris_grid,
	ofm_done,
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
	input wire extract_start;
	input wire [199:0] tetris_grid;
	input wire ofm_done;
	output reg extract_ready;
	output wire [7:0] lines_cleared;
	output wire [7:0] holes;
	output wire [7:0] bumpiness;
	output wire [7:0] height_sum;
	output wire [2:0] state;
	reg [2:0] c_state;
	reg [2:0] n_state;
	assign state = c_state;
	wire [199:0] cleared_array;
	reg [199:0] working_array;
	wire [9:0] clear_score;
	reg clear_start;
	wire clear_complete;
	reg [7:0] c_lines_cleared;
	reg [7:0] n_lines_cleared;
	assign lines_cleared = c_lines_cleared;
	t01_lineclear line_clear_master(
		.clk(clk),
		.reset(rst || (extract_start && extract_ready)),
		.gamestate('d10),
		.start_eval(clear_start),
		.input_array(tetris_grid),
		.input_color_array(),
		.output_array(cleared_array),
		.output_color_array(),
		.eval_complete(clear_complete),
		.score(clear_score)
	);
	reg [49:0] heights;
	reg [49:0] n_heights;
	reg [3:0] height_column_counter;
	reg [3:0] n_height_column_counter;
	reg [7:0] height_sum_calc;
	always @(*) begin
		if (_sv2v_0)
			;
		height_sum_calc = (((((((({3'b000, heights[0+:5]} + {3'b000, heights[5+:5]}) + {3'b000, heights[10+:5]}) + {3'b000, heights[15+:5]}) + {3'b000, heights[20+:5]}) + {3'b000, heights[25+:5]}) + {3'b000, heights[30+:5]}) + {3'b000, heights[35+:5]}) + {3'b000, heights[40+:5]}) + {3'b000, heights[45+:5]};
	end
	assign height_sum = height_sum_calc;
	reg [7:0] bumpiness_calc;
	reg [4:0] working_heights [0:9];
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] col;
			for (col = 0; col < 10; col = col + 1)
				begin
					working_heights[col] = 0;
					begin : sv2v_autoblock_2
						reg signed [31:0] r;
						for (r = 0; r < 20; r = r + 1)
							if (working_array[(r * 10) + col])
								working_heights[col] = 5'd20 - r[4:0];
					end
				end
		end
		bumpiness_calc = 0;
		begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < 9; i = i + 1)
				if (working_heights[i] > working_heights[i + 1])
					bumpiness_calc = (bumpiness_calc + {3'b000, working_heights[i]}) - {3'b000, working_heights[i + 1]};
				else
					bumpiness_calc = (bumpiness_calc + {3'b000, working_heights[i + 1]}) - {3'b000, working_heights[i]};
		end
	end
	assign bumpiness = bumpiness_calc;
	reg [3:0] hole_column_counter;
	reg [3:0] n_hole_column_counter;
	reg [7:0] c_holes;
	reg [7:0] n_holes;
	reg [4:0] hole_row_counter;
	reg [4:0] n_hole_row_counter;
	assign holes = c_holes;
	always @(posedge clk or posedge rst)
		if (rst) begin
			c_state <= 3'd0;
			c_holes <= 0;
			working_array <= 0;
			height_column_counter <= 0;
			hole_column_counter <= 0;
			hole_row_counter <= 0;
			c_lines_cleared <= 0;
			heights[0+:5] <= 0;
			heights[5+:5] <= 0;
			heights[10+:5] <= 0;
			heights[15+:5] <= 0;
			heights[20+:5] <= 0;
			heights[25+:5] <= 0;
			heights[30+:5] <= 0;
			heights[35+:5] <= 0;
			heights[40+:5] <= 0;
			heights[45+:5] <= 0;
		end
		else if (extract_start) begin
			c_state <= n_state;
			c_holes <= n_holes;
			c_lines_cleared <= n_lines_cleared;
			if (clear_complete) begin
				if (lines_cleared > 0)
					working_array <= cleared_array;
				else
					working_array <= tetris_grid;
			end
			height_column_counter <= n_height_column_counter;
			hole_column_counter <= n_hole_column_counter;
			hole_row_counter <= n_hole_row_counter;
			heights[0+:5] <= n_heights[0+:5];
			heights[5+:5] <= n_heights[5+:5];
			heights[10+:5] <= n_heights[10+:5];
			heights[15+:5] <= n_heights[15+:5];
			heights[20+:5] <= n_heights[20+:5];
			heights[25+:5] <= n_heights[25+:5];
			heights[30+:5] <= n_heights[30+:5];
			heights[35+:5] <= n_heights[35+:5];
			heights[40+:5] <= n_heights[40+:5];
			heights[45+:5] <= n_heights[45+:5];
		end
	always @(*) begin
		if (_sv2v_0)
			;
		n_state = c_state;
		n_holes = c_holes;
		n_lines_cleared = c_lines_cleared;
		extract_ready = 0;
		clear_start = 0;
		n_heights[0+:5] = heights[0+:5];
		n_heights[5+:5] = heights[5+:5];
		n_heights[10+:5] = heights[10+:5];
		n_heights[15+:5] = heights[15+:5];
		n_heights[20+:5] = heights[20+:5];
		n_heights[25+:5] = heights[25+:5];
		n_heights[30+:5] = heights[30+:5];
		n_heights[35+:5] = heights[35+:5];
		n_heights[40+:5] = heights[40+:5];
		n_heights[45+:5] = heights[45+:5];
		n_height_column_counter = height_column_counter;
		n_hole_column_counter = hole_column_counter;
		n_hole_row_counter = hole_row_counter;
		case (c_state)
			3'd0: begin
				n_hole_column_counter = 0;
				n_height_column_counter = 0;
				n_hole_row_counter = 0;
				n_holes = 0;
				n_lines_cleared = 0;
				n_heights[0+:5] = 0;
				n_heights[5+:5] = 0;
				n_heights[10+:5] = 0;
				n_heights[15+:5] = 0;
				n_heights[20+:5] = 0;
				n_heights[25+:5] = 0;
				n_heights[30+:5] = 0;
				n_heights[35+:5] = 0;
				n_heights[40+:5] = 0;
				n_heights[45+:5] = 0;
				if (extract_start)
					n_state = 3'd1;
			end
			3'd1: begin
				n_height_column_counter = 0;
				clear_start = 1;
				if (clear_complete) begin
					clear_start = 0;
					n_lines_cleared = 0;
					begin : sv2v_autoblock_4
						reg signed [31:0] row;
						for (row = 0; row < 20; row = row + 1)
							if (&tetris_grid[row * 10+:10])
								n_lines_cleared = n_lines_cleared + 1;
					end
					n_state = 3'd2;
				end
			end
			3'd2:
				if (hole_column_counter >= 'd10)
					n_state = 3'd5;
				else if (height_column_counter >= 'd10) begin
					n_hole_row_counter = 0;
					n_state = 3'd4;
				end
				else begin
					n_heights[height_column_counter * 5+:5] = 0;
					begin : sv2v_autoblock_5
						reg signed [31:0] r;
						for (r = 0; r < 20; r = r + 1)
							if (working_array[(r * 10) + height_column_counter])
								n_heights[height_column_counter * 5+:5] = 5'd20 - r[4:0];
					end
					n_state = 3'd3;
				end
			3'd3: begin
				n_height_column_counter = height_column_counter + 1;
				n_state = 3'd2;
			end
			3'd4:
				if (hole_row_counter < heights[hole_column_counter * 5+:5]) begin
					if ((((5'd20 - heights[hole_column_counter * 5+:5]) + hole_row_counter) < 20) && !working_array[(((5'd20 - heights[hole_column_counter * 5+:5]) + hole_row_counter) * 10) + hole_column_counter])
						n_holes = c_holes + 1;
					n_hole_row_counter = hole_row_counter + 1;
				end
				else begin
					n_hole_column_counter = hole_column_counter + 1;
					n_hole_row_counter = 0;
					n_state = 3'd2;
				end
			3'd5: begin
				extract_ready = 1;
				if (ofm_done)
					n_state = 3'd0;
			end
			default:
				;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
