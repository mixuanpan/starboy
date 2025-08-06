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
	height_sum
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire extract_start;
	input wire [199:0] tetris_grid;
	input wire ofm_done;
	output reg extract_ready;
	output reg [7:0] lines_cleared;
	output wire [7:0] holes;
	output wire [7:0] bumpiness;
	output wire [7:0] height_sum;
	reg [2:0] c_state;
	reg [2:0] n_state;
	wire [199:0] cleared_array;
	reg [199:0] working_array;
	reg [199:0] line_clear_input_array;
	wire [9:0] clear_score;
	reg [7:0] lines_cleared_tmp;
	reg clear_start;
	wire clear_complete;
	always @(*) begin
		if (_sv2v_0)
			;
		case (clear_score)
			'd8: lines_cleared_tmp = 'd4;
			'd5: lines_cleared_tmp = 'd3;
			'd3: lines_cleared_tmp = 'd2;
			default: lines_cleared_tmp = clear_score[7:0];
		endcase
	end
	t01_lineclear line_clear_master(
		.clk(clk),
		.reset(rst || (extract_start && extract_ready)),
		.gamestate('d10),
		.start_eval(clear_start),
		.input_array(line_clear_input_array),
		.input_color_array(),
		.output_array(cleared_array),
		.output_color_array(),
		.eval_complete(clear_complete),
		.score(clear_score)
	);
	reg [49:0] heights;
	reg [49:0] n_heights;
	wire [44:0] bump_spread;
	reg [3:0] height_column_counter;
	reg [3:0] n_height_column_counter;
	assign height_sum = (((((((({3'b000, heights[0+:5]} + {3'b000, heights[5+:5]}) + {3'b000, heights[10+:5]}) + {3'b000, heights[15+:5]}) + {3'b000, heights[20+:5]}) + {3'b000, heights[25+:5]}) + {3'b000, heights[30+:5]}) + {3'b000, heights[35+:5]}) + {3'b000, heights[40+:5]}) + {3'b000, heights[45+:5]};
	assign bump_spread[0+:5] = (heights[0+:5] > heights[5+:5] ? heights[0+:5] - heights[5+:5] : heights[5+:5] - heights[0+:5]);
	assign bump_spread[5+:5] = (heights[5+:5] > heights[10+:5] ? heights[5+:5] - heights[10+:5] : heights[10+:5] - heights[5+:5]);
	assign bump_spread[10+:5] = (heights[10+:5] > heights[15+:5] ? heights[10+:5] - heights[15+:5] : heights[15+:5] - heights[10+:5]);
	assign bump_spread[15+:5] = (heights[15+:5] > heights[20+:5] ? heights[15+:5] - heights[20+:5] : heights[20+:5] - heights[15+:5]);
	assign bump_spread[20+:5] = (heights[20+:5] > heights[25+:5] ? heights[20+:5] - heights[25+:5] : heights[25+:5] - heights[20+:5]);
	assign bump_spread[25+:5] = (heights[25+:5] > heights[30+:5] ? heights[25+:5] - heights[30+:5] : heights[30+:5] - heights[25+:5]);
	assign bump_spread[30+:5] = (heights[30+:5] > heights[35+:5] ? heights[30+:5] - heights[35+:5] : heights[35+:5] - heights[30+:5]);
	assign bump_spread[35+:5] = (heights[35+:5] > heights[40+:5] ? heights[35+:5] - heights[40+:5] : heights[40+:5] - heights[35+:5]);
	assign bump_spread[40+:5] = (heights[40+:5] > heights[45+:5] ? heights[40+:5] - heights[45+:5] : heights[45+:5] - heights[40+:5]);
	assign bumpiness = ((((((({3'b000, bump_spread[0+:5]} + {3'b000, bump_spread[5+:5]}) + {3'b000, bump_spread[10+:5]}) + {3'b000, bump_spread[15+:5]}) + {3'b000, bump_spread[20+:5]}) + {3'b000, bump_spread[25+:5]}) + {3'b000, bump_spread[30+:5]}) + {3'b000, bump_spread[35+:5]}) + {3'b000, bump_spread[40+:5]};
	reg [3:0] hole_column_counter;
	reg [3:0] n_hole_column_counter;
	reg hole_perceived;
	reg n_hole_perceived;
	reg [7:0] c_holes;
	reg [7:0] n_holes;
	reg [7:0] c_hole_start_row;
	reg [7:0] n_hole_start_row;
	assign holes = c_holes;
	always @(posedge clk or posedge rst)
		if (rst) begin
			c_state <= 3'd0;
			c_holes <= 0;
			working_array <= 0;
			line_clear_input_array <= 0;
			height_column_counter <= 0;
			hole_column_counter <= 0;
			hole_perceived <= 0;
			c_hole_start_row <= 'd18;
			lines_cleared <= 0;
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
		else if (clear_start && !extract_start)
			line_clear_input_array <= tetris_grid;
		else if (extract_start) begin
			c_state <= n_state;
			c_holes <= n_holes;
			if ((c_state == 3'd1) && clear_complete) begin
				lines_cleared <= lines_cleared_tmp;
				working_array <= cleared_array;
			end
			height_column_counter <= n_height_column_counter;
			hole_column_counter <= n_hole_column_counter;
			hole_perceived <= n_hole_perceived;
			c_hole_start_row <= n_hole_start_row;
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
		n_hole_perceived = hole_perceived;
		n_hole_start_row = c_hole_start_row;
		case (c_state)
			3'd0: begin
				n_hole_column_counter = 0;
				n_height_column_counter = 0;
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
					n_state = 3'd2;
				end
			end
			3'd2:
				if (hole_column_counter >= 'd10)
					n_state = 3'd5;
				else if (height_column_counter >= 'd10) begin
					begin : sv2v_autoblock_1
						reg signed [31:0] r;
						for (r = 18; r >= 1; r = r - 1)
							if ((working_array[((r - 1) * 10) + hole_column_counter] && !working_array[(r * 10) + hole_column_counter]) && working_array[((r + 1) * 10) + hole_column_counter]) begin
								n_hole_start_row = r[7:0] - 'd2;
								n_hole_perceived = 1;
								n_state = 3'd4;
							end
							else begin
								if (r <= (32'd19 - {27'b000000000000000000000000000, heights[hole_column_counter * 5+:5]}))
									n_hole_start_row = r[7:0];
								n_hole_column_counter = hole_column_counter + 1;
								n_state = 3'd4;
							end
					end
					n_state = 3'd4;
				end
				else begin
					begin : sv2v_autoblock_2
						reg signed [31:0] r;
						for (r = 19; r >= 0; r = r - 1)
							if (|working_array[(r * 10) + height_column_counter])
								n_heights[height_column_counter * 5+:5] = 5'd20 - r[4:0];
					end
					n_state = 3'd3;
				end
			3'd3: begin
				n_height_column_counter = height_column_counter + 1;
				n_state = 3'd2;
			end
			3'd4: begin
				if (hole_perceived) begin
					n_hole_perceived = 0;
					n_holes = c_holes + 1;
				end
				if (c_hole_start_row <= (8'd19 - {3'b000, heights[hole_column_counter * 5+:5]})) begin
					n_hole_start_row = 0;
					n_hole_column_counter = hole_column_counter + 1;
				end
				n_hole_perceived = 0;
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
