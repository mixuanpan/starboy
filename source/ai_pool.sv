// `default_nettype none
// /////////////////////////////////////////////////////////////////
// // HEADER 
// //
// // Module : ai_pool  
// // Description : Max Pooling Unit with 2x2 window 
// //                (nh - f + 1)/s *(nw - f+ 1)/s *nc
// //                nh - height of feature map
// //                nw - width of feature map
// //                nc - number of channels in the feature map
// //                f  - size of filter
// //                s  - stride length
// // 
// //
// /////////////////////////////////////////////////////////////////
// module ai_pool #(
//     parameter int MAP_H = 20, // map height
//     parameter int MAP_W = 10, // map width 
//     parameter int K_WIDTH = 4, // kernel_size bits 
//     parameter int S_WIDTH = 4, // stride bits 
//     parameter int C_WIDTH = 3 // number of input channels 
// )(
//     input logic clk, rst, pool_en, pool_valid, 
//     input logic [MAP_H-1:0][MAP_W-1:0] feature_map, 
//     output logic [MAP_H/2-1:0][MAP_W/2-1:0] output_map, 
//     output logic done 
// );
//     logic [1:0] max_inx; // maximum number index 
//     logic [3:0] col_inx; 
//     logic [4:0] row_inx; 
//     logic [3:0] window; // 2x2 window in one list 
//     logic [1:0] window_inx; 

//     always_ff @(posedge clk, posedge rst) begin 
//         if (rst) begin 
//             max_inx <= 0; 
//             col_inx <= 0; 
//             row_inx <= 0; 
//             window <= feature_map[1:0][1:0]; 
//             window_inx <= 0; 
//             output_map <= 0; 
//             done <= 0; 
//         end else if (pool_en && pool_valid) begin 
//             if (row_inx == 'd20 && col_inx == 'd10) begin 
//                 done <= 1; 
//             end else begin 
//                 // load a small section of the input map to the window 
//                 window[0] <= feature_map[row_inx][col_inx]; 
//                 window[1] <= feature_map[row_inx][col_inx+1]; 
//                 window[2] <= feature_map[row_inx+1][col_inx]; 
//                 window[3] <= feature_map[row_inx][col_inx+1]; 

//                 // determine the maximum vlaue within the window 
//                 if (window_inx < 'd3) begin 
//                     if (window[window_inx] < window[window_inx+1]) begin 
//                         max_inx <= window_inx; 
//                     end else begin 
//                         max_inx <= window_inx + 'd1; 
//                     end 
//                     window_inx <= window_inx + 'd1; 
//                 end else begin 
//                     output_map[row_inx/2][col_inx/2] <= window[max_inx]; 
//                     if (col_inx < 'd8) begin 
//                         col_inx <= col_inx + 'd2; 
//                     end else begin 
//                         col_inx <= 0; 
//                         row_inx <= row_inx + 'd2; 
//                     end 
//                 end
//             end 
//         end 
//     end
// endmodule 