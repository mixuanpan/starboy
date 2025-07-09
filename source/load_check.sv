// `default_nettype none

// /////////////////////////////////////////////////////////////////
// // HEADER 
// //
// // Module : load_check
// // Description : Checks the validity of a new block 
// // 
// //
// /////////////////////////////////////////////////////////////////

// import tetris_pkg::*;
//     // typedef enum logic [4:0] {
//     //     IDLE, // reset state 
//     //     READY, // count down to start 
//     //     NEW_BLOCK, // load new block 
//     //     A1, // 011
//     //     A2, 
//     //     B1, // 101
//     //     B2, 
//     //     C1, // 111 
//     //     C2, 
//     //     D0, // 1001
//     //     E1, // 1010 
//     //     E2, 
//     //     E3, 
//     //     E4, 
//     //     F1, // 1110 
//     //     F2, 
//     //     F3, 
//     //     F4, 
//     //     G1, // 10010
//     //     G2, 
//     //     G3, 
//     //     G4, 
//     //     EVAL, // evaluation 
//     //     GAME_OVER // user run out of space 11000 
//     // } state_t; 

//     // typedef enum logic [2:0] {
//     //     RIGHT, 
//     //     LEFT, 
//     //     ROR, // ROTATE RIGHT
//     //     ROL, // ROTATE LEFT 
//     //     DOWN
//     // } move_t; 

//     // typedef enum logic [2:0] {
//     //     CL0, // BLACK   
//     //     CL1, 
//     //     CL2, 
//     //     CL3, 
//     //     CL4, 
//     //     CL5, 
//     //     CL6, 
//     //     CL7
//     // } color_t; 

//     // typedef enum logic [4:0] {
//     //     IDLE, // reset state 
//     //     READY, // count down to start 
//     //     NEW_BLOCK, // load new block 
//     //     A1, // 011
//     //     A2, 
//     //     B1, // 101
//     //     B2, 
//     //     C1, // 111 
//     //     C2, 
//     //     D0, // 1001
//     //     E1, // 1010 
//     //     E2, 
//     //     E3, 
//     //     E4, 
//     //     F1, // 1110 
//     //     F2, 
//     //     F3, 
//     //     F4, 
//     //     G1, // 10010
//     //     G2, 
//     //     G3, 
//     //     G4, 
//     //     EVAL, // evaluation 
//     //     GAME_OVER // user run out of space 11000 
//     // } state_t; 

// module load_check (
//   input state_t block_type, 
//   input logic [9:0][2:0] row1, // check row 0
//   input color_t color, 
//   output logic valid, 
//   output logic [4:0] row_ref, 
//   output logic [3:0] col_ref, 
//   output logic [1:0][9:0][2:0] row01 // the first two rows of the grid 
// );
//   logic check; 
//   logic [3:0] col_index; 

//   always_comb begin 
//     check = 0; 
//     row01[0] = 0; 
//     row01[1] = row1; 
//     col_index = 0; 
//     valid = 0; 
//     row_ref = 0; 
//     col_ref = 0; 
    
//     if (block_type == E1 || block_type == F1 || block_type == G1) begin 
//       for (int i = 0; i <= 7; i++) begin 
//         check = (row1[i] == 3'b0) && (row1[i + 1] == 3'b0) && (row1[i + 2] == 3'b0); 
//         if (check) begin 
//           row01[1][i] = color; 
//           row01[1][i + 1] = color; 
//           row01[1][i + 2] = color; 
          
//           // break 
//           col_index = i[3:0]; 
//           i = 'd8; 
//         end
//       end

//     end 

//     // output reference row & col number 
//     if (valid) begin 

//       if (block_type == E1) begin 
//         row01[0][col_index+ 1] = color; 
//         valid = 1'b1; 
//       end
    
//       row_ref = 'd21;
//       if (col_index== 0) begin 
//         col_ref = 'd9; 
//       end else begin 
//         col_ref = col_index - 'd1; 
//       end  
//     end
//   end
// endmodule