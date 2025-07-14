module dual_port_rom #(
    parameter int BYTES = 1153,
    parameter string MEMFILE = "all_layers.mem"
)(
    input  logic clk,
    input  logic [$clog2(BYTES)-1:0] addr_a,
    output logic [7:0]               dout_a,
    input  logic [$clog2(BYTES)-1:0] addr_b,
    output logic [7:0]               dout_b
);

    // Initialise once at configuration time
    initial $readmemh(MEMFILE, mem);

    // Registered (synchronous) read for timing cleanliness
    always_ff @(posedge clk) begin
        dout_a <= mem[addr_a];
        dout_b <= mem[addr_b];
    end
endmodule