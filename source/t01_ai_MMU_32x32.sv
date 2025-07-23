`default_nettype none
/////////////////////////////////////////////////////////////////
// Module : t01_ai_MMU_16x16
// Description : Parameterized systolic array (16×16) using generate loops
//
/////////////////////////////////////////////////////////////////

module t01_ai_MMU_16x16 #(
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


// og packed array DO NOT USE 
logic [3:0] d3_b [1];
logic [3:0] d0_b [1:32];
logic [3:0] d1_b [1:32];
logic [3:0] d2_b [1:32];
logic [3:0] d3_w [1:32];
logic [3:0] d0_w [1:128];
logic [3:0] d1_w [1:1024];
logic [3:0] d2_w [1:1024];

// // unpacked 4-bit arrays
// logic [3:0] d3_b_unpacked [1:2];
// logic [3:0] d0_b_unpacked [1:32];  
// logic [3:0] d1_b_unpacked [1:32];  
// logic [3:0] d2_b_unpacked [1:32];  
// logic [3:0] d3_w_unpacked [1:32];  
// logic [3:0] d0_w_unpacked [1:128];  
// logic [3:0] d1_w_unpacked [1:1024];   
// logic [3:0] d2_w_unpacked [1:1024];   

//shoutout mixuan pan
initial begin 
    $readmemh("dense_0_param0_int4.mem", d0_w, 1, 128); 
    $readmemh("dense_0_param1_int4.mem", d0_b, 1, 32); 
    $readmemh("dense_1_param0_int4.mem", d1_w, 1, 1024); 
    $readmemh("dense_1_param1_int4.mem", d1_b, 1, 32); 
    $readmemh("dense_2_param0_int4.mem", d2_w, 1, 1024); 
    $readmemh("dense_2_param1_int4.mem", d2_b, 1, 32); 
    $readmemh("dense_3_param0_int4.mem", d3_w, 1, 32); 
    $readmemh("dense_3_param1_int4.mem", d3_b); 

    
    // // d0_w 
    // for (int i = 1; i <= 64; i++) begin
    //     d0_w_unpacked[2*i-1] = d0_w[i][3:0]; 
    //     d0_w_unpacked[2*i] = d0_w[i][7:4]; 
    // end
    
    // // d0_b
    // for (int i = 1; i <= 16; i++) begin
    //     d0_b_unpacked[2*i-1] = d0_b[i][3:0];
    //     d0_b_unpacked[2*i] = d0_b[i][7:4]; 
    // end
    
    // //  d1_w 
    // for (int i = 1; i <= 512; i++) begin
    //     d1_w_unpacked[2*i-1] = d1_w[i][3:0];
    //     d1_w_unpacked[2*i] = d1_w[i][7:4]; 
    // end
    
    // // d1_b
    // for (int i = 1; i <= 16; i++) begin
    //     d1_b_unpacked[2*i-1] = d1_b[i][3:0]; 
    //     d1_b_unpacked[2*i] = d1_b[i][7:4];  
    // end
    
    // // d2_w
    // for (int i = 1; i <= 512; i++) begin
    //     d2_w_unpacked[2*i-1] = d2_w[i][3:0];
    //     d2_w_unpacked[2*i] = d2_w[i][7:4]; 
    // end
    
    // // d2_b 
    // for (int i = 1; i <= 16; i++) begin
    //     d2_b_unpacked[2*i-1] = d2_b[i][3:0];
    //     d2_b_unpacked[2*i] = d2_b[i][7:4];
    // end
    
    // // d3_w 
    // for (int i = 1; i <= 16; i++) begin
    //     d3_w_unpacked[2*i-1] = d3_w[i][3:0];
    //     d3_w_unpacked[2*i] = d3_w[i][7:4]; 
    // end
    
    // // d3_b 
    // d3_b_unpacked[1] = d3_b[1][3:0];
    // d3_b_unpacked[2] = d3_b[1][7:4]; //not needed, but for consistency (zero)
end





// systolic array 
    // Internal inter-PE wires
    logic [31:0] south [0:N-1][0:N - 1], east [0:N - 1][0:N];

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
