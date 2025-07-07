/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : MAC
// Description : single MAC unit
// 
//
/////////////////////////////////////////////////////////////////
<<<<<<< HEAD

module MAC(
	input logic [31:0] inp_north, 
	input logc [31:0] inp_west, 
	input logic clk, 
	input logic rst, 
	output logic [31:0] outp_south, 
	output logic [31:0] outp_east, 
	output logic [63:0] result
	);

	logic [63:0] multi;

	assign multi = inp_north * inp_west

	always_ff @(posedge clk, posedge rst) begin
		if (rst) begin
			result <= 64'd0;
			outp_east <= 32'd0;
			outp_south <= 32'd0;
		end else begin
			result <= result + multi;
			outp_east <= inp_west;
			outp_south <= inp_north;
		end
	end
endmodule

=======
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

  logic first;                     
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            first <= 1'b1;      // assert after reset
            acc_out <= '0;
            data_east <= '0;
            data_south <= '0;
        end else begin
            if (first) begin         // first cycle after reset
                acc_out <= sext;     // load the very first product
                first <= 1'b0;     // clear flag for all subsequent cycles
            end else begin
                acc_out <= acc_out + sext; // regular accumulation
            end
            data_east  <= data_west;      // shift registers unchanged
            data_south <= data_north;
        end
    end
endmodule
>>>>>>> 6c14f2e22eee0bbaadac11098fe72668bf639d61
