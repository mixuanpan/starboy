`default_nettype none
module t01_ai_MMU (
	clk,
	rst_n,
	start,
	layer_sel,
	act_valid,
	act_in,
	res_valid,
	res_out,
	done
);
	reg _sv2v_0;
	input wire clk;
	input wire rst_n;
	input wire start;
	input wire [1:0] layer_sel;
	input wire act_valid;
	input wire [7:0] act_in;
	output reg res_valid;
	output reg [17:0] res_out;
	output reg done;
	reg [3:0] d0_w [1:128];
	reg [3:0] d0_b [1:32];
	reg [3:0] d1_w [1:1024];
	reg [3:0] d1_b [1:32];
	reg [3:0] d2_w [1:1024];
	reg [3:0] d2_b [1:32];
	reg [3:0] d3_w [1:32];
	reg [3:0] d3_b [1:1];
	initial begin
		$readmemh("dense_0_param0_int4.mem", d0_w, 1, 128);
		$readmemh("dense_0_param1_int4.mem", d0_b, 1, 32);
		$readmemh("dense_1_param0_int4.mem", d1_w, 1, 1024);
		$readmemh("dense_1_param1_int4.mem", d1_b, 1, 32);
		$readmemh("dense_2_param0_int4.mem", d2_w, 1, 1024);
		$readmemh("dense_2_param1_int4.mem", d2_b, 1, 32);
		$readmemh("dense_3_param0_int4.mem", d3_w, 1, 32);
		$readmemh("dense_3_param1_int4.mem", d3_b, 1, 1);
	end
	reg signed [7:0] W [0:31][0:31];
	reg signed [17:0] B [0:31];
	reg [1:0] state;
	reg [1:0] next_state;
	reg [5:0] mac_counter;
	reg [5:0] bias_counter;
	reg [5:0] max_outputs;
	reg [5:0] max_inputs;
	reg signed [17:0] acc [0:31];
	reg signed [17:0] act_ext;
	reg signed [17:0] w_ext;
	reg signed [35:0] full_prod;
	reg signed [17:0] prod_18bit;
	reg signed [17:0] tmp;
	reg signed [17:0] q;
	always @(*) begin
		if (_sv2v_0)
			;
		case (layer_sel)
			2'b00: begin
				max_outputs = 6'd32;
				max_inputs = 6'd4;
			end
			2'b01: begin
				max_outputs = 6'd32;
				max_inputs = 6'd32;
			end
			2'b10: begin
				max_outputs = 6'd32;
				max_inputs = 6'd32;
			end
			2'b11: begin
				max_outputs = 6'd1;
				max_inputs = 6'd32;
			end
			default: begin
				max_outputs = 6'd32;
				max_inputs = 6'd32;
			end
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				begin
					begin : sv2v_autoblock_2
						reg signed [31:0] j;
						for (j = 0; j < 32; j = j + 1)
							W[i][j] = 8'b00000000;
					end
					B[i] = 18'b000000000000000000;
				end
		end
		case (layer_sel)
			2'b00: begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					begin
						begin : sv2v_autoblock_4
							reg signed [31:0] j;
							for (j = 0; j < 4; j = j + 1)
								W[i][j] = {{4 {d0_w[((i * 4) + j) + 1][3]}}, d0_w[((i * 4) + j) + 1]};
						end
						B[i] = {{14 {d0_b[i + 1][3]}}, d0_b[i + 1]};
					end
			end
			2'b01: begin : sv2v_autoblock_5
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					begin
						begin : sv2v_autoblock_6
							reg signed [31:0] j;
							for (j = 0; j < 32; j = j + 1)
								W[i][j] = {{4 {d1_w[((i * 32) + j) + 1][3]}}, d1_w[((i * 32) + j) + 1]};
						end
						B[i] = {{14 {d1_b[i + 1][3]}}, d1_b[i + 1]};
					end
			end
			2'b10: begin : sv2v_autoblock_7
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					begin
						begin : sv2v_autoblock_8
							reg signed [31:0] j;
							for (j = 0; j < 32; j = j + 1)
								W[i][j] = {{4 {d2_w[((i * 32) + j) + 1][3]}}, d2_w[((i * 32) + j) + 1]};
						end
						B[i] = {{14 {d2_b[i + 1][3]}}, d2_b[i + 1]};
					end
			end
			2'b11: begin
				begin : sv2v_autoblock_9
					reg signed [31:0] j;
					for (j = 0; j < 32; j = j + 1)
						W[0][j] = {{4 {d3_w[j + 1][3]}}, d3_w[j + 1]};
				end
				B[0] = {{14 {d3_b[1][3]}}, d3_b[1]};
			end
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= 2'd0;
			mac_counter <= 6'b000000;
			bias_counter <= 6'b000000;
		end
		else begin
			state <= next_state;
			case (state)
				2'd1:
					if (act_valid)
						mac_counter <= mac_counter + 1;
				2'd2: bias_counter <= bias_counter + 1;
				default: begin
					mac_counter <= 6'b000000;
					bias_counter <= 6'b000000;
				end
			endcase
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = state;
		case (state)
			2'd0:
				if (start)
					next_state = 2'd1;
			2'd1:
				if (act_valid && (mac_counter == (max_inputs - 1)))
					next_state = 2'd2;
			2'd2:
				if (bias_counter == (max_outputs - 1))
					next_state = 2'd0;
			default: next_state = 2'd0;
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin : sv2v_autoblock_10
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				acc[i] <= 18'b000000000000000000;
		end
		else if (start) begin : sv2v_autoblock_11
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				acc[i] <= 18'b000000000000000000;
		end
		else if ((state == 2'd1) && act_valid) begin
			act_ext = {{10 {act_in[7]}}, act_in};
			if (layer_sel == 2'b11) begin
				w_ext = {{10 {W[0][mac_counter[4:0]][7]}}, W[0][mac_counter[4:0]]};
				full_prod = act_ext * w_ext;
				prod_18bit = full_prod[17:0];
				acc[0] <= acc[0] + prod_18bit;
			end
			else begin : sv2v_autoblock_12
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					begin
						w_ext = {{10 {W[i][mac_counter[4:0]][7]}}, W[i][mac_counter[4:0]]};
						full_prod = act_ext * w_ext;
						prod_18bit = full_prod[17:0];
						acc[i] <= acc[i] + prod_18bit;
					end
			end
		end
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			res_valid <= 1'b0;
			res_out <= 18'b000000000000000000;
			done <= 1'b0;
		end
		else begin
			res_valid <= 1'b0;
			done <= 1'b0;
			if ((state == 2'd2) && (bias_counter < max_outputs)) begin
				tmp = acc[bias_counter[4:0]] + B[bias_counter[4:0]];
				q = (tmp[17] ? 18'b000000000000000000 : tmp);
				res_out <= q;
				res_valid <= 1'b1;
				if (bias_counter == (max_outputs - 1))
					done <= 1'b1;
			end
		end
	initial _sv2v_0 = 0;
endmodule