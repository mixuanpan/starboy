// `default_nettype none

// /////////////////////////////////////////////////////////////////
// // HEADER 
// //
// // Module : tracker 
// // Description : track and update individual frames of the grid 
// // 
// //
// /////////////////////////////////////////////////////////////////

// // import tetris_pkg::*;

// module tracker (
//   input state_t state, // current state 
//   input logic [4:0][4:0][2:0] frame_i, // input frame 
//   input move_t move, 
//   input logic [2:0] color, // block color 
//   input logic en, 
//   output logic check_tb, 
//   output logic complete, // indicates the completion of the movement 
//   output logic [4:0][4:0][2:0] frame_o // output frame 
// );

//   logic check; // check if movement is available 
//   assign check_tb = check; 
//   always_comb begin 
//     frame_o = frame_i; 
//     check = 0; 
//     complete = 0; 

//     if (en) begin
//       case (state) 
//         A1: begin 
//           case (move) 
//             RIGHT: begin 
//               check = frame_i[1][1] == 3'b0 && frame_i[2][0] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][3] = 0; 
//                 frame_o[2][2] = 0; 
//                 frame_o[1][1] = color; 
//                 frame_o[2][0] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             LEFT: begin 
//               check = frame_i[1][4] == 3'b0 && frame_i[2][3] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][2] = 0; 
//                 frame_o[2][1] = 0; 
//                 frame_o[1][4] = color; 
//                 frame_o[2][3] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             ROR, ROL: begin 
//               check = frame_i[3][2] == 3'b0 && frame_i[1][1] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][2] = 0; 
//                 frame_o[1][3] = 0; 
//                 frame_o[3][2] = color; 
//                 frame_o[1][1] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             DOWN: begin 
//               check = frame_i[3][1] == 3'b0 && frame_i[3][2] == 3'b0 && frame_i[2][3] == 3'b0; 
//               if (check) begin 
//                 frame_o[2][1] = 0; 
//                 frame_o[1][2] = 0; 
//                 frame_o[1][3] = 0; 
//                 frame_o[3][1] = color; 
//                 frame_o[3][2] = color; 
//                 frame_o[2][3] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             default: begin 
//               frame_o = frame_i; 
//               complete = 1'b0; 
//             end
//           endcase
//         end

//         A2: begin 
//           case (move) 
//             RIGHT: begin 
//               check = frame_i[1][0] == 3'b0 && frame_i[2][0] == 3'b0 && frame_i[3][1] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[2][2] = 0;
//                 frame_o[2][3] = 0; 
//                 frame_o[1][0] = color; 
//                 frame_o[2][0] = color; 
//                 frame_o[3][1] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             LEFT: begin 
//               check = frame_i[1][2] == 3'b0 && frame_i[2][3] == 3'b0 && frame_i[3][3] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[2][1] = 0; 
//                 frame_o[3][2] = 0; 
//                 frame_o[1][2] = color; 
//                 frame_o[2][3] = color; 
//                 frame_o[3][3] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             ROR, ROL: begin 
//               check = frame_i[1][2] == 3'b0 && frame_i[1][3] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[3][2] = 0; 
//                 frame_o[1][2] = color; 
//                 frame_o[1][3] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             DOWN: begin 
//               check = frame_i[3][1] == 3'b0 && frame_i[4][2] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[2][2] = 0; 
//                 frame_o[3][1] = color; 
//                 frame_o[4][2] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             default: begin 
//               frame_o = frame_i; 
//               complete = 1'b0; 
//             end
//           endcase
//         end

//         B1: begin 
//           case (move) 
//             RIGHT: begin 
//               check = frame_i[1][0] == 3'b0 && frame_i[2][1] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][2] = 0; 
//                 frame_o[2][3] = 0; 
//                 frame_o[1][0] = color; 
//                 frame_o[2][1] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             LEFT: begin 
//               check = frame_i[1][3] == 3'b0 && frame_i[2][4] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[2][2] = 0; 
//                 frame_o[1][3] = color; 
//                 frame_o[2][4] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             ROR, ROL: begin 
//               check = frame_i[2][1] == 3'b0 && frame_i[3][1] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[2][3] = 0; 
//                 frame_o[2][1] = color; 
//                 frame_o[3][1] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             DOWN: begin 
//               check = frame_i[2][1] == 3'b0 && frame_i[3][2] == 3'b0 && frame_i[3][3] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[1][2] = 0; 
//                 frame_o[2][3] = 0; 
//                 frame_o[2][1] = color; 
//                 frame_o[3][2] = color; 
//                 frame_o[3][3] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             default: begin 
//               frame_o = frame_i; 
//               complete = 1'b0; 
//             end
//           endcase
//         end

//         B2: begin 
//           case (move) 
//             RIGHT: begin 
//               check = frame_i[1][1] == 3'b0 && frame_i[2][0] == 3'b0 && frame_i[3][0] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][2] = 0; 
//                 frame_o[2][2] = 0;
//                 frame_o[3][1] = 0; 
//                 frame_o[1][1] = color; 
//                 frame_o[2][0] = color; 
//                 frame_o[3][0] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             LEFT: begin 
//               check = frame_i[1][3] == 3'b0 && frame_i[2][3] == 3'b0 && frame_i[3][2] == 3'b0; 
//               if (check) begin 
//                 frame_o[2][1] = 0; 
//                 frame_o[3][1] = 0; 
//                 frame_o[1][2] = 0; 
//                 frame_o[1][3] = color; 
//                 frame_o[2][3] = color; 
//                 frame_o[3][2] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             ROR, ROL: begin 
//               check = frame_i[1][1] == 3'b0 && frame_i[2][3] == 3'b0; 
//               if (check) begin 
//                 frame_o[2][1] = 0; 
//                 frame_o[3][1] = 0; 
//                 frame_o[1][1] = color; 
//                 frame_o[2][3] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             DOWN: begin 
//               check = frame_i[4][1] == 3'b0 && frame_i[3][2] == 3'b0; 
//               if (check) begin 
//                 frame_o[2][1] = 0; 
//                 frame_o[1][2] = 0; 
//                 frame_o[4][1] = color; 
//                 frame_o[3][2] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             default: begin 
//               frame_o = frame_i; 
//               complete = 1'b0; 
//             end
//           endcase
//         end

//         C1: begin 
//           case (move) 
//             RIGHT: begin 
//               check = frame_i[1][0] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][4] = 0; 
//                 frame_o[1][0] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             LEFT: begin 
//               // the only case where the frame captured is different from RIGHT & DOWN 
//               check = frame_i[1][4] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][0] = 0; 
//                 frame_o[1][4] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             ROR, ROL: begin 
//               check = frame_i[0][2] == 3'b0 && frame_i[2][2] == 3'b0 && frame_i[3][2] == 3'b0; 
//               if (check) begin 
//                 frame_o[1][1] = 0; 
//                 frame_o[1][3] = 0; 
//                 frame_o[1][4] = 0; 
//                 frame_o[0][2] = color; 
//                 frame_o[2][2] = color; 
//                 frame_o[3][2] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             DOWN: begin 
//               check = frame_i[2][1] == 3'b0 && frame_i[2][2] == 3'b0 && frame_i[2][3] == 3'b0 && frame_i[2][4] == 3'b0; 
//               if (check) begin 
//                 frame_o[2][1] = 0; 
//                 frame_o[1][2] = 0; 
//                 frame_o[2][1] = color; 
//                 frame_o[2][2] = color; 
//                 frame_o[2][3] = color; 
//                 frame_o[2][4] = color; 
//                 complete = 1'b1; 
//               end
//             end

//             default: begin 
//               frame_o = frame_i; 
//               complete = 1'b0; 
//             end
//           endcase
//         end

//         default: begin 
//           frame_o = frame_i; 
//           complete = 1'b0; 
//         end
//       endcase
//     end
//   end

// endmodule