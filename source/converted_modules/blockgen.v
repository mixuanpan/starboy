`default_nettype none
module blockgen (
	current_block_type,
	current_block_pattern
);
	reg _sv2v_0;
	input wire [4:0] current_block_type;
	output reg [15:0] current_block_pattern;
	always @(*) begin
		if (_sv2v_0)
			;
		current_block_pattern = 1'sb0;
		case (current_block_type)
			'd0: begin
				current_block_pattern[1] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[9] = 1;
				current_block_pattern[13] = 1;
			end
			'd7: begin
				current_block_pattern[4] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[6] = 1;
				current_block_pattern[7] = 1;
			end
			'd1: begin
				current_block_pattern[1] = 1;
				current_block_pattern[2] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[6] = 1;
			end
			'd2: begin
				current_block_pattern[2] = 1;
				current_block_pattern[3] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[6] = 1;
			end
			'd8: begin
				current_block_pattern[6] = 1;
				current_block_pattern[10] = 1;
				current_block_pattern[9] = 1;
				current_block_pattern[13] = 1;
			end
			'd3: begin
				current_block_pattern[1] = 1;
				current_block_pattern[2] = 1;
				current_block_pattern[6] = 1;
				current_block_pattern[7] = 1;
			end
			'd9: begin
				current_block_pattern[5] = 1;
				current_block_pattern[9] = 1;
				current_block_pattern[10] = 1;
				current_block_pattern[14] = 1;
			end
			'd4: begin
				current_block_pattern[1] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[9] = 1;
				current_block_pattern[10] = 1;
			end
			'd10: begin
				current_block_pattern[2] = 1;
				current_block_pattern[1] = 1;
				current_block_pattern[0] = 1;
				current_block_pattern[4] = 1;
			end
			'd11: begin
				current_block_pattern[1] = 1;
				current_block_pattern[2] = 1;
				current_block_pattern[6] = 1;
				current_block_pattern[10] = 1;
			end
			'd12: begin
				current_block_pattern[6] = 1;
				current_block_pattern[8] = 1;
				current_block_pattern[9] = 1;
				current_block_pattern[10] = 1;
			end
			'd5: begin
				current_block_pattern[2] = 1;
				current_block_pattern[6] = 1;
				current_block_pattern[10] = 1;
				current_block_pattern[9] = 1;
			end
			'd13: begin
				current_block_pattern[4] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[6] = 1;
				current_block_pattern[10] = 1;
			end
			'd14: begin
				current_block_pattern[1] = 1;
				current_block_pattern[2] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[9] = 1;
			end
			'd15: begin
				current_block_pattern[0] = 1;
				current_block_pattern[4] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[6] = 1;
			end
			'd6: begin
				current_block_pattern[2] = 1;
				current_block_pattern[5] = 1;
				current_block_pattern[6] = 1;
				current_block_pattern[7] = 1;
			end
			'd16: begin
				current_block_pattern[6] = 1;
				current_block_pattern[9] = 1;
				current_block_pattern[10] = 1;
				current_block_pattern[14] = 1;
			end
			'd17: begin
				current_block_pattern[5] = 1;
				current_block_pattern[6] = 1;
				current_block_pattern[7] = 1;
				current_block_pattern[10] = 1;
			end
			'd18: begin
				current_block_pattern[5] = 1;
				current_block_pattern[9] = 1;
				current_block_pattern[10] = 1;
				current_block_pattern[13] = 1;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
