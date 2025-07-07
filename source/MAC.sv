/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : MAC
// Description : single MAC unit
// 
//
/////////////////////////////////////////////////////////////////
module MAC #(
    parameter int  BW = 32,
    parameter int  ACCW  = 2*BW
)(
    input logic clk,
    input logic rst,

    // north & west inputs
    input logic signed [BW-1:0] data_north,
    input logic signed [BW-1:0] data_west,

    // south & east outputs (registered)
    output logic signed [BW-1:0] data_south,
    output logic signed [BW-1:0] data_east,

    // running dot-product result
    output logic signed [ACCW-1:0] acc_out
);

    // one-cycle multiply
    logic signed [2*BW-1:0] product = '0;
    always_comb product = data_north * data_west;

    // register slice & accumulation
	always_ff @(posedge clk, posedge rst) begin
	        if (rst) begin
	            acc_out <= '0;
	            data_east <= '0;
	            data_south <= '0;
	        end else begin
	            acc_out <= acc_out + {{(ACCW-2*BW){product[2*BW-1]}}, product}; // sign-extend
	            data_east <= data_west;
	            data_south <= data_north;
	        end
	    end
endmodule
