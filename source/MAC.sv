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

logic [63:0] multi;

assign multi = inp_north * inp_west;

always_ff @(posedge clk, posedge rst) begin
	if (rst) begin 
		result <= 64'd0;
		outp_east = 32'd0;
		outp_south = 32'd0;
	end else begin
		result <= result + multi;
		outp_east <= inp_west;
		outp_south <= inp_north;
	end
end
endmodule