/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : MAC
// Description : single MAC unit
// 
//
/////////////////////////////////////////////////////////////////
module MAC #(
    parameter int BW   = 32,
    parameter int ACCW = BW + 1 + $clog2(16)  // safe for up to 16×16
)(
    input logic clk,
    input logic rst,

    input logic signed [BW-1:0] data_north,
    input logic signed [BW-1:0] data_west,

    output logic signed [BW-1:0] data_south,
    output logic signed [BW-1:0] data_east,
    output logic signed [ACCW-1:0] acc_out
);
    // one-cycle multiply
    logic signed [2*BW-1:0] product;
    always_comb product = data_north * data_west;

    // sign-extend product to ACCW
    localparam int EXT = ACCW - 2*BW;
	wire signed [ACCW-1:0] sext = (EXT==0) ? product : {{EXT{product[2*BW-1]}}, product};

	always_ff @(posedge clk, posedge rst) begin
	        if (rst) begin
	            acc_out    <= '0;
	            data_east  <= '0;
	            data_south <= '0;
	        end else begin
	            acc_out    <= acc_out + sext;
	            data_east  <= data_west;
	            data_south <= data_north;
	        end
	    end
endmodule
