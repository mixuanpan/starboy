`default_nettype none
module t01_lineclear (
	clk,
	reset,
	gamestate,
	start_eval,
	input_array,
	input_color_array,
	output_array,
	output_color_array,
	eval_complete,
	score,
	lines_cleared_count
);
	reg _sv2v_0;
	input wire clk;
	input wire reset;
	input wire [3:0] gamestate;
	input wire start_eval;
	input wire [199:0] input_array;
	input wire [599:0] input_color_array;
	output wire [199:0] output_array;
	output wire [599:0] output_color_array;
	output wire eval_complete;
	output wire [9:0] score;
	output reg [2:0] lines_cleared_count;
	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [4:0] eval_row;
	reg [199:0] working_array;
	reg [599:0] working_color_array;
	reg [9:0] current_score;
	reg line_found;
	reg [4:0] initial_eval_row;
	function [9:0] get_line_score;
		input reg [2:0] num_lines;
		case (num_lines)
			3'd1: get_line_score = 10'd1;
			3'd2: get_line_score = 10'd3;
			3'd3: get_line_score = 10'd5;
			3'd4: get_line_score = 10'd8;
			default: get_line_score = 10'd0;
		endcase
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = current_state;
		case (current_state)
			3'd0:
				if (start_eval)
					next_state = 3'd1;
			3'd1:
				if (&working_array[eval_row * 10+:10])
					next_state = 3'd2;
				else if (eval_row == 0)
					next_state = 3'd3;
				else
					next_state = 3'd1;
			3'd2: next_state = 3'd1;
			3'd3: next_state = 3'd4;
			3'd4: next_state = 3'd5;
			3'd5: next_state = 3'd0;
			default: next_state = 3'd0;
		endcase
	end
	always @(posedge clk or posedge reset)
		if (reset)
			current_state <= 3'd0;
		else
			current_state <= next_state;
	always @(posedge clk or posedge reset)
		if (reset) begin
			eval_row <= 5'd19;
			working_array <= 1'sb0;
			current_score <= 10'd0;
			line_found <= 1'b0;
			working_color_array <= 1'sb0;
			lines_cleared_count <= 3'd0;
			initial_eval_row <= 5'd19;
		end
		else if (gamestate == 'd9) begin
			eval_row <= 5'd19;
			working_array <= 1'sb0;
			current_score <= 10'd0;
			line_found <= 1'b0;
			working_color_array <= 1'sb0;
			lines_cleared_count <= 3'd0;
			initial_eval_row <= 5'd19;
		end
		else
			case (current_state)
				3'd0:
					if (start_eval) begin
						eval_row <= 5'd19;
						working_array <= input_array;
						working_color_array <= input_color_array;
						line_found <= 1'b0;
						lines_cleared_count <= 3'd0;
						initial_eval_row <= 5'd19;
					end
				3'd1:
					if (&working_array[eval_row * 10+:10])
						line_found <= 1'b1;
					else begin
						if (eval_row > 0)
							eval_row <= eval_row - 1;
						line_found <= 1'b0;
					end
				3'd2: begin
					line_found <= 1'b0;
					if (lines_cleared_count < 3'd4)
						lines_cleared_count <= lines_cleared_count + 1;
					begin : sv2v_autoblock_1
						reg signed [31:0] k;
						for (k = 0; k < 20; k = k + 1)
							if (k == 0) begin
								working_array[0+:10] <= 1'sb0;
								working_color_array[0+:30] <= 1'sb0;
							end
							else if (k <= eval_row) begin
								working_array[k * 10+:10] <= working_array[(k - 1) * 10+:10];
								working_color_array[3 * (k * 10)+:30] <= working_color_array[3 * ((k - 1) * 10)+:30];
							end
					end
				end
				3'd3:
					;
				3'd4:
					if (lines_cleared_count > 0) begin
						if (current_score <= (10'd999 - get_line_score(lines_cleared_count)))
							current_score <= current_score + get_line_score(lines_cleared_count);
						else
							current_score <= 10'd999;
					end
				3'd5:
					;
				default: begin
					eval_row <= 5'd19;
					working_array <= 1'sb0;
					line_found <= 1'b0;
					working_color_array <= 1'sb0;
					lines_cleared_count <= 3'd0;
					initial_eval_row <= 5'd19;
				end
			endcase
	assign output_array = working_array;
	assign output_color_array = working_color_array;
	assign eval_complete = current_state == 3'd5;
	assign score = current_score;
	initial _sv2v_0 = 0;
endmodule
