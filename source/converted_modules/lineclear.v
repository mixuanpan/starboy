`default_nettype none
module lineclear (
	clk,
	reset,
	start_eval,
	input_array,
	output_array,
	eval_complete,
	score
);
	reg _sv2v_0;
	input wire clk;
	input wire reset;
	input wire start_eval;
	input wire [199:0] input_array;
	output wire [199:0] output_array;
	output wire eval_complete;
	output wire [7:0] score;
	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [4:0] eval_row;
	reg [199:0] working_array;
	reg [7:0] current_score;
	reg line_found;
	reg [2:0] lines_cleared_count;
	reg [4:0] initial_eval_row;
	function [7:0] get_line_score;
		input reg [2:0] num_lines;
		case (num_lines)
			3'd1: get_line_score = 8'd1;
			3'd2: get_line_score = 8'd3;
			3'd3: get_line_score = 8'd5;
			3'd4: get_line_score = 8'd8;
			default: get_line_score = 8'd0;
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
			current_score <= 8'd0;
			line_found <= 1'b0;
			lines_cleared_count <= 3'd0;
			initial_eval_row <= 5'd19;
		end
		else
			case (current_state)
				3'd0:
					if (start_eval) begin
						eval_row <= 5'd19;
						working_array <= input_array;
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
							if (k == 0)
								working_array[0+:10] <= 1'sb0;
							else if (k <= eval_row)
								working_array[k * 10+:10] <= working_array[(k - 1) * 10+:10];
					end
				end
				3'd3:
					;
				3'd4:
					if (lines_cleared_count > 0) begin
						if (current_score <= (8'd255 - get_line_score(lines_cleared_count)))
							current_score <= current_score + get_line_score(lines_cleared_count);
						else
							current_score <= 8'd255;
					end
				3'd5:
					;
				default: begin
					eval_row <= 5'd19;
					working_array <= 1'sb0;
					line_found <= 1'b0;
					lines_cleared_count <= 3'd0;
					initial_eval_row <= 5'd19;
				end
			endcase
	assign output_array = working_array;
	assign eval_complete = current_state == 3'd5;
	assign score = current_score;
	initial _sv2v_0 = 0;
endmodule
