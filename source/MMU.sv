// /////////////////////////////////////////////////////////////////
// // Module : MMU_16x16
// // Description : Parameterized systolic array (16×16) using generate loops
// //
// /////////////////////////////////////////////////////////////////

// module MMU_16x16 #(
//     parameter int N = 16
// ) (
//     input  logic clk,
//     input  logic rst,
//     // North inputs (columns 0..N-1)
//     input  logic [31:0] inp_north [0:N-1],
//     // West inputs (rows 0..N-1)
//     input  logic [31:0] inp_west  [0:N-1],
//     output logic done,
//     // Final results (south-east corner of each PE)
//     output logic [63:0] result    [0:N-1][0:N-1]
// );

//     // Internal inter-PE wires
//     logic [31:0] south     [0:N-1][0:N - 1],
//                  east      [0:N - 1][0:N];

//     // Initialize boundary wires: north and west edges
//     genvar i, j;
//     // Connect north inputs to each top-row PE
//     generate
//         for (j = 0; j < N; j++) begin : NORTH_EDGE
//             assign south[0][j] = inp_north[j];
//         end
//         // Connect west inputs to each left-column PE
//         for (i = 0; i < N; i++) begin : WEST_EDGE
//             assign east[i][0] = inp_west[i];
//         end
//     endgenerate

//     // Instantiate PEs in a 2D grid
//     generate
//         for (i = 0; i < N; i++) begin : ROWS
//             for (j = 0; j < N; j++) begin : COLS
//                 MAC pe_inst (
//                     .inp_north(south[i][j]),
//                     .inp_west (east[i][j]),
//                     .clk      (clk),
//                     .rst      (rst),
//                     .outp_south(south[i+1][j]),
//                     .outp_east (east[i][j+1]),
//                     .result   (result[i][j])
//                 );
//             end
//         end
//     endgenerate

//     // Simple cycle counter & done flag
//     logic [$clog2(N*2):0] count;
//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             done  <= 1'b0;
//             count <= '0;
//         end else begin
//             if (count == {2*N - 2}[5:0]) begin
//                 done  <= 1'b1;
//                 count <= '0;
//             end else begin
//                 done  <= 1'b0;
//                 count <= count + 1;
//             end
//         end
//     end

// endmodule
 
// //  why is everything commented out </3 
// // BECAUSE THERE'S SOMETHING WRONG WITH THE CODE 