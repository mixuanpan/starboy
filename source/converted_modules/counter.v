`default_nettype none
module counter (
	clk,
	rst,
	enable,
	block_type
);
	input wire clk;
	input wire rst;
	input wire enable;
	output wire [2:0] block_type;
	reg [15:0] lfsr_reg;
	wire feedback;
	assign feedback = ((lfsr_reg[15] ^ lfsr_reg[13]) ^ lfsr_reg[12]) ^ lfsr_reg[10];
	always @(posedge clk or posedge rst)
		if (rst)
			lfsr_reg <= 16'hace1;
		else if (enable)
			lfsr_reg <= {lfsr_reg[14:0], feedback};
	assign block_type = (lfsr_reg[2:0] == 3'd7 ? 3'd0 : lfsr_reg[2:0]);
endmodule
