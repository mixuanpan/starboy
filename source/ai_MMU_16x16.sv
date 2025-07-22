`default_nettype none
/////////////////////////////////////////////////////////////////
// Module : ai_MMU_16x16
// Description : Parameterized systolic array (16×16) using generate loops
//
/////////////////////////////////////////////////////////////////

module ai_MMU_16x16 #(
    parameter int N = 16, 

    // readmemh 
    parameter int N1 = 1, // first length 
    parameter int N2 = 32, // second length 
    parameter int N3 = 128, // third length 
    parameter int N4 = 1024 // fourth length 
) (
    input  logic clk,
    input  logic rst,
    // North inputs (columns 0..N-1)
    input  logic [31:0] inp_north [0:N-1],
    // West inputs (rows 0..N-1)
    input  logic [31:0] inp_west  [0:N-1],
    output logic done,
    // Final results (south-east corner of each PE)
    output logic [63:0] result    [0:N-1][0:N-1]
);

// read weights and biase 
    logic [7:0] d3_b [1];
    logic [7:0] d0_b [1:16];
    logic [7:0] d1_b [1:16];
    logic [7:0] d2_b [1:16];
    logic [7:0] d3_w [1:16];
    logic [7:0] d0_w [1:64];// weight of dense 0 
    logic [7:0] d1_w [1:512];
    logic [7:0] d2_w [1:512]; 

    initial begin 
        $readmemh("dense_0_param0_int4.mem", d0_w, 1, 64); 
        $readmemh("dense_0_param1_int4.mem", d0_b, 1, 16); 
        $readmemh("dense_1_param0_int4.mem", d1_w, 1, 512); 
        $readmemh("dense_1_param1_int4.mem", d1_b, 1, 16); 
        $readmemh("dense_2_param0_int4.mem", d2_w, 1, 512); 
        $readmemh("dense_2_param1_int4.mem", d2_b, 1, 16); 
        $readmemh("dense_3_param0_int4.mem", d3_w, 1, 16); 
        $readmemh("dense_3_param1_int4.mem", d3_b); 
    end

// systolic array 
    // Internal inter-PE wires
    logic [31:0] south     [0:N-1][0:N - 1],
                 east      [0:N - 1][0:N];

    // Initialize boundary wires: north and west edges
    genvar i, j;
    // Connect north inputs to each top-row PE
    generate
        for (j = 0; j < N; j++) begin : NORTH_EDGE
            assign south[0][j] = inp_north[j];
        end
        // Connect west inputs to each left-column PE
        for (i = 0; i < N; i++) begin : WEST_EDGE
            assign east[i][0] = inp_west[i];
        end
    endgenerate

    // Instantiate PEs in a 2D grid
    generate
        for (i = 0; i < N; i++) begin : ROWS
            for (j = 0; j < N; j++) begin : COLS
                ai_MAC pe_inst (
                    .inp_north(south[i][j]),
                    .inp_west (east[i][j]),
                    .clk      (clk),
                    .rst      (rst),
                    .outp_south(south[i+1][j]),
                    .outp_east (east[i][j+1]),
                    .result   (result[i][j])
                );
            end
        end
    endgenerate

    // Simple cycle counter & done flag
    logic [$clog2(N*2):0] count;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            done  <= 1'b0;
            count <= '0;
        end else begin
            if (count == {2*N - 2}[5:0]) begin
                done  <= 1'b1;
                count <= '0;
            end else begin
                done  <= 1'b0;
                count <= count + 1;
            end
        end
    end

endmodule