/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : MMU
// Description : Generates a systolic array [currently 4x4] uttilizing the given MACs  
// 
//
/////////////////////////////////////////////////////////////////

module MMU #(
    parameter int DEPTH = 4,
    parameter int BW = 32,
    parameter int ACCW  = 2*BW
)(
    input logic clk,
    input logic rst,

    // packed west & north streams
    input  logic signed [BW*DEPTH-1:0] data_west_bus,
    input  logic signed [BW*DEPTH-1:0] data_north_bus,

    // east-edge accumulators packed the same way
    output logic signed [ACCW*DEPTH-1:0] acc_east_bus,
    output logic done           // one-cycle “pipe full” pulse
);
    
    logic signed [BW-1:0]dn[DEPTH:0][DEPTH-1:0]; // south-going
    logic signed [BW-1:0]dw[DEPTH-1:0][DEPTH:0]; // east-going
    logic signed [ACCW-1:0]acc[DEPTH-1:0][DEPTH-1:0];

    // seed north & west edges
    for (genvar k = 0; k < DEPTH; ++k) begin
        assign dn[0][k] = data_north_bus[k*BW +: BW];  // first row
        assign dw[k][0] = data_west_bus [k*BW +: BW];  // first column
    end

    //pe grid
    generate
        for (genvar i = 0; i < DEPTH; ++i)
            for (genvar j = 0; j < DEPTH; ++j) begin : gen_pe
                MAC #(.BW(BW), .ACCW(ACCW)) u_pe (
                    .clk        (clk),
                    .rst        (rst),
                    .data_north (dn[i][j]),
                    .data_west  (dw[i][j]),
                    .data_south (dn[i+1][j]),
                    .data_east  (dw[i][j+1]),
                    .acc_out    (acc[i][j])
                );
            end
    endgenerate

    //capture east-edge accumulators
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            acc_east_bus <= '0;
        else
            for (int k = 0; k < DEPTH; ++k)
                acc_east_bus[k*ACCW +: ACCW] <= acc[k][DEPTH-1];
    end

    //done pulse after pipe fills
    localparam int LAT = 2*DEPTH - 1;
    logic [$clog2(LAT)-1:0] cnt = '0;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt  <= '0;
            done <= 1'b0;
        end else begin
            done <= (cnt == LAT-1);
            cnt  <= (cnt == LAT-1) ? '0 : cnt + 1'b1;
        end
    end
endmodule
