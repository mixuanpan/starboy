module weightstreamer (
    input logic clk,
    input logic rst,
    input logic [31:0] inp_north [0:15],
    input logic [31:0] inp_west  [0:15],
    output logic done,
    output logic [63:0] result    [0:15][0:15]
);

    // Instantiate the MMU with 16x16 PEs
    MMU_16x16 #(
        .N(16)
    ) mmu_inst (
        .clk(clk),
        .rst(rst),
        .inp_north(inp_north),
        .inp_west(inp_west),
        .done(done),
        .result(result)
    );