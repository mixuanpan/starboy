// module movedown(
//     input logic clk, rst,
//     input logic [19:0][9:0] input_array, 
//     input logic [2:0] current_state,
//     output logic [19:0][9:0]output_array,
//     output logic finish
// );

//     logic [4:0] blockY, blockYN, maxY, nextY;
//     logic collision_detected; 
//     logic [19:0][9:0] shifted_array, postest_array;

//     // Sequential logic for block position
//     always_ff @(posedge clk, posedge rst) begin
//         if (rst) begin
//             blockY <= 5'd0;
//         end else begin
//             blockY <= blockYN;
//         end
//     end


//     // Shift the input array down by blockY positions
//     always_comb begin
//         case(current_state)
//             3'd0: begin //line
//             maxY = 5'd16;
//             end
//             3'd1: begin //square
//             maxY = 5'd18;
//             end
//             3'd2: begin //L
//             maxY = 5'd17;
//             end
//             3'd3: begin// reverse L
//             maxY = 5'd17;
//             end
//             3'd4: begin // S
//             maxY = 5'd18;
//             end
//             3'd5: begin // Z
//             maxY = 5'd18;
//             end
//             3'd6: begin // T
//             maxY = 5'd18;
//             end
//             default: maxY = 5'd19;
//         endcase
//     end

//     always_comb begin

//         finish = '0;
//         blockYN = blockY;
        
//         // Move down if not at bottom (leave some space at bottom)
//         if (blockY < maxY && !collision_detected) begin
//             blockYN = blockY + 5'd1;
//         end else begin
//             blockYN = blockY; 
//             finish = '1; 
//         end
//     end

//        always_comb begin
//         // Initialize output array to all zeros
//         output_array = '0;
//         postest_array = '0;
        
//         // Place the block pattern at the current Y position
//         case(current_state)
//             3'd0: begin // LINE
//                 if (blockY + 3 < 20) begin
//                     output_array[blockY][4] = 'b1;
//                     output_array[blockY+1][4] = 'b1;
//                     output_array[blockY+2][4] = 'b1;
//                     output_array[blockY+3][4] = 'b1;

//                     postest_array[nextY][4] = 'b1;
//                     postest_array[nextY+1][4] = 'b1;
//                     postest_array[nextY+2][4] = 'b1;
//                     postest_array[nextY+3][4] = 'b1;       
//                  end
//             end
//             3'd1: begin // SMASHBOY
//                 if (blockY + 1 < 20) begin
//                     output_array[blockY][4] = 'b1;
//                     output_array[blockY][5] = 'b1;
//                     output_array[blockY+1][4] = 'b1;
//                     output_array[blockY+1][5] = 'b1;

//                     postest_array[nextY][4] = 'b1;
//                     postest_array[nextY][5] = 'b1;
//                     postest_array[nextY+1][4] = 'b1;
//                     postest_array[nextY+1][5] = 'b1; 
//                 end
//             end
//             3'd2: begin // L
//                 if (blockY + 2 < 20) begin
//                     output_array[blockY][4] = 'b1;
//                     output_array[blockY+1][4] = 'b1;
//                     output_array[blockY+2][4] = 'b1;
//                     output_array[blockY+2][5] = 'b1;

//                     postest_array[nextY][4] = 'b1;
//                     postest_array[nextY+1][4] = 'b1;
//                     postest_array[nextY+2][4] = 'b1;
//                     postest_array[nextY+2][5] = 'b1; 
//                 end
//             end
//             3'd3: begin // REVERSE_L
//                 if (blockY + 2 < 20) begin
//                     output_array[blockY][5] = 'b1;
//                     output_array[blockY+1][5] = 'b1;
//                     output_array[blockY+2][5] = 'b1;
//                     output_array[blockY+2][4] = 'b1;

//                     postest_array[nextY][5] = 'b1;
//                     postest_array[nextY+1][5] = 'b1;
//                     postest_array[nextY+2][5] = 'b1;
//                     postest_array[nextY+2][4] = 'b1; 
//                 end
//             end
//             3'd4: begin // S
//                 if (blockY + 1 < 20) begin
//                     output_array[blockY][6] = 'b1;
//                     output_array[blockY][5] = 'b1;
//                     output_array[blockY+1][5] = 'b1;
//                     output_array[blockY+1][4] = 'b1;

//                     postest_array[nextY][6] = 'b1;
//                     postest_array[nextY][5] = 'b1;
//                     postest_array[nextY+1][5] = 'b1;
//                     postest_array[nextY+1][4] = 'b1; 
//                 end
//             end
//             3'd5: begin // Z
//                 if (blockY + 1 < 20) begin
//                     output_array[blockY][4] = 'b1;
//                     output_array[blockY][5] = 'b1;
//                     output_array[blockY+1][5] = 'b1;
//                     output_array[blockY+1][6] = 'b1;

//                     postest_array[nextY][4] = 'b1;
//                     postest_array[nextY][5] = 'b1;
//                     postest_array[nextY+1][5] = 'b1;
//                     postest_array[nextY+1][6] = 'b1; 
//                 end
//             end
//             3'd6: begin // T
//                 if (blockY + 1 < 20) begin
//                     output_array[blockY][4] = 'b1;
//                     output_array[blockY+1][3] = 'b1;
//                     output_array[blockY+1][4] = 'b1;
//                     output_array[blockY+1][5] = 'b1;

//                     postest_array[nextY][4] = 'b1;
//                     postest_array[nextY+1][3] = 'b1;
//                     postest_array[nextY+1][4] = 'b1;
//                     postest_array[nextY+1][5] = 'b1; 
//                 end
//             end
//             default: begin
//                 // Do nothing for invalid state
//                 output_array = '0;
//                 postest_array = '0;
//             end
//         endcase
//     end

// assign collision_detected = |(postest_array & output_array);



// endmodule