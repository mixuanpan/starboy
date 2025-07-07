/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : MMU
// Description : Generates a systolic array [currently 4x4] uttilizing the given MACs  
// 
//
/////////////////////////////////////////////////////////////////

<<<<<<< HEAD
module MMU(
    input clk,
    input control,
    input reset,
    input [(bit_width * depth) - 1:0] data_arr,
    input [(bit_width * depth) - 1:0] wt_arr,
    output reg [acc_width * size - 1:0] acc_out
=======
module MMU #(
    parameter int DEPTH = 4,
    parameter int BW = 32,
    parameter int ACCW  = BW + 1 + $clog2(DEPTH)
)(
    input  logic clk,
    input  logic rst,
    input  logic signed [BW*DEPTH-1:0] data_west_bus,
    input  logic signed [BW*DEPTH-1:0]  data_north_bus,
    output logic signed [ACCW*DEPTH-1:0] acc_east_bus,
    output logic done
>>>>>>> 6c14f2e22eee0bbaadac11098fe72668bf639d61
);

    // internal links
    logic signed [BW-1:0]   dn  [0:DEPTH][0:DEPTH-1];
    logic signed [BW-1:0]   dw  [0:DEPTH-1][0:DEPTH];
    logic signed [ACCW-1:0] acc [0:DEPTH-1][0:DEPTH-1];

    // seed first row / column
    generate
        for (genvar k = 0; k < DEPTH; ++k) begin : gen_seed
            assign dn[0][k] = data_north_bus[k*BW +: BW];
            assign dw[k][0] = data_west_bus [k*BW +: BW];
        end
    endgenerate

    // PE grid
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

    // capture east-edge accumulators
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            acc_east_bus <= '0;
        else
            for (int k = 0; k < DEPTH; ++k)
                acc_east_bus[k*ACCW +: ACCW] <= acc[k][DEPTH-1];
    end

    // done pulse
    localparam int LAT  = 2*DEPTH - 1;
    localparam int CNTW = (LAT > 1) ? $clog2(LAT) : 1;
    logic [CNTW-1:0] cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            cnt <= '0;
        else
            cnt <= (cnt == LAT-1) ? '0 : cnt + 1'b1;
    end
    assign done = (cnt == LAT-1);
endmodule
