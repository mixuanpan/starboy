/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : MAC
// Description : single MAC unit
// 
//
/////////////////////////////////////////////////////////////////
module MAC (
	input logic [31:0] inp_north,
	input logic [31:0] inp_west,
	input logic clk,
	input logic rst,
	output logic [31:0] outp_south,
	output logic [31:0] outp_east,
	output logic [63:0] result
);

//pipelined ts so it takes half logic delay ;333
logic [63:0] multi_stage1;
logic [31:0] inp_north_reg, inp_west_reg;
logic [63:0] multi_stage2;

//stage 1 input to multiply
always_ff @(posedge clk, posedge rst) begin
	if (rst) begin 
		multi_stage1 <= 64'd0;
		inp_north_reg <= 32'd0;
		inp_west_reg <= 32'd0;
	end else begin 
		multi_stage1 <= inp_north * inp_west;
		inp_north_reg <= inp_north;
		inp_west_reg <= inp_west;
	end
end

//stage 2 result to accumulate
always_ff @(posedge clk, posedge rst) begin
	if (rst) begin
		multi_stage2 <= 64'd0;
		result <= 64'd0;
		outp_east <= 32'd0;
		outp_south <= 32'd0;
	end else begin
		multi_stage2 <= multi_stage1;
		result <= result + multi_stage2;
		outp_east <= inp_west_reg;
		outp_south <= inp_north_reg;
	end
end
endmodule