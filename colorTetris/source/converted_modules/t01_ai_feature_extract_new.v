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
	output reg [7:0] lines_cleared;
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
	always @(*) begin
		if (_sv2v_0)
			;
		case (clear_score)
			'd8: lines_cleared = 'd4;
			'd5: lines_cleared = 'd3;
			'd3: lines_cleared = 'd2;
			default: lines_cleared = clear_score[7:0];
		endcase
	end
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
	reg [4:0] heights [0:9];
	reg [4:0] n_heights [0:9];
	wire [4:0] bump_spread [0:8];
	reg [3:0] height_column_counter;
	reg [3:0] n_height_column_counter;
	assign height_sum = (((((((({3'b000, heights[0]} + {3'b000, heights[1]}) + {3'b000, heights[2]}) + {3'b000, heights[3]}) + {3'b000, heights[4]}) + {3'b000, heights[5]}) + {3'b000, heights[6]}) + {3'b000, heights[7]}) + {3'b000, heights[8]}) + {3'b000, heights[9]};
	assign bump_spread[0] = (heights[0] > heights[1] ? heights[0] - heights[1] : heights[1] - heights[0]);
	assign bump_spread[1] = (heights[1] > heights[2] ? heights[1] - heights[2] : heights[2] - heights[1]);
	assign bump_spread[2] = (heights[2] > heights[3] ? heights[2] - heights[3] : heights[3] - heights[2]);
	assign bump_spread[3] = (heights[3] > heights[4] ? heights[3] - heights[4] : heights[4] - heights[3]);
	assign bump_spread[4] = (heights[4] > heights[5] ? heights[4] - heights[5] : heights[5] - heights[4]);
	assign bump_spread[5] = (heights[5] > heights[6] ? heights[5] - heights[6] : heights[6] - heights[5]);
	assign bump_spread[6] = (heights[6] > heights[7] ? heights[6] - heights[7] : heights[7] - heights[6]);
	assign bump_spread[7] = (heights[7] > heights[8] ? heights[7] - heights[8] : heights[8] - heights[7]);
	assign bump_spread[8] = (heights[8] > heights[9] ? heights[8] - heights[9] : heights[9] - heights[8]);
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
	always @(posedge clk or posedge rst)
		if (rst) begin
			c_state <= 3'd0;
			c_holes <= 0;
			working_array <= 0;
			height_column_counter <= 0;
			hole_column_counter <= 0;
			hole_perceived <= 0;
			c_hole_start_row <= 'd18;
			heights[0] <= 0;
			heights[1] <= 0;
			heights[2] <= 0;
			heights[3] <= 0;
			heights[4] <= 0;
			heights[5] <= 0;
			heights[6] <= 0;
			heights[7] <= 0;
			heights[8] <= 0;
			heights[9] <= 0;
		end
		else if (extract_start) begin
			c_state <= n_state;
			c_holes <= n_holes;
			if (clear_complete) begin
				if (lines_cleared > 0)
					working_array <= cleared_array;
				else
					working_array <= tetris_grid;
			end
			height_column_counter <= n_height_column_counter;
			hole_column_counter <= n_hole_column_counter;
			hole_perceived <= n_hole_perceived;
			c_hole_start_row <= n_hole_start_row;
			heights[0] <= n_heights[0];
			heights[1] <= n_heights[1];
			heights[2] <= n_heights[2];
			heights[3] <= n_heights[3];
			heights[4] <= n_heights[4];
			heights[5] <= n_heights[5];
			heights[6] <= n_heights[6];
			heights[7] <= n_heights[7];
			heights[8] <= n_heights[8];
			heights[9] <= n_heights[9];
		end
	always @(*) begin
		if (_sv2v_0)
			;
		n_state = c_state;
		n_holes = c_holes;
		extract_ready = 0;
		clear_start = 0;
		n_heights[0] = heights[0];
		n_heights[1] = heights[1];
		n_heights[2] = heights[2];
		n_heights[3] = heights[3];
		n_heights[4] = heights[4];
		n_heights[5] = heights[5];
		n_heights[6] = heights[6];
		n_heights[7] = heights[7];
		n_heights[8] = heights[8];
		n_heights[9] = heights[9];
		n_height_column_counter = height_column_counter;
		n_hole_column_counter = hole_column_counter;
		n_hole_perceived = hole_perceived;
		n_hole_start_row = c_hole_start_row;
		case (c_state)
			3'd0: begin
				n_hole_column_counter = 0;
				n_height_column_counter = 0;
				n_heights[0] = 0;
				n_heights[1] = 0;
				n_heights[2] = 0;
				n_heights[3] = 0;
				n_heights[4] = 0;
				n_heights[5] = 0;
				n_heights[6] = 0;
				n_heights[7] = 0;
				n_heights[8] = 0;
				n_heights[9] = 0;
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
								if (r <= (32'd19 - {27'b000000000000000000000000000, heights[hole_column_counter]}))
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
								n_heights[height_column_counter] = 5'd20 - r[4:0];
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
				if (c_hole_start_row <= (8'd19 - {3'b000, heights[hole_column_counter]})) begin
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
