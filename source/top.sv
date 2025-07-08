`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  // Your code goes here...
//   vgadriver ryangosling (.clk(hz100), .rst(1'b0), .color_in(shape_color), .red(red), .green(green), .blue(blue), .hsync(right[1]), .vsync(right[0]), .x_out(x), .y_out(y));

// // vgaDesigner designer (.x(x), .y(y), .shape_color(shape_color));
// // always_comb begin
// //   if (x == 'd1 || y == 'd1) begin
// //     shape_color = 3'b111;
// //   end else begin
// //     shape_color = 3'b000;
// //   end
// // end
// // I Drive.....

//     // VGA display dimensions: 640x480
//     // Color encoding: [2:0] = [red, green, blue]
    
//     // Grid parameters
//     localparam BLOCK_SIZE = 15;
    
//     // Colors
//     localparam BLACK = 3'b000;
//     localparam WHITE = 3'b111;
//     localparam RED = 3'b100;
    
//     logic in_grid;
//     logic [9:0] temp_x, temp_y;
//     logic [3:0] grid_x, grid_y;
//     logic on_grid_line;
    
//     always_comb begin
//         // Check if current pixel is within the grid area (245,90) to (395,390)
//         in_grid = (x >= 10'd245) && (x < 10'd395) &&
//                   (y >= 10'd90) && (y < 10'd390);
        
//         // Calculate grid position with proper bit handling
//         temp_x = (x - 10'd245) / BLOCK_SIZE;
//         temp_y = (y - 10'd90) / BLOCK_SIZE;
//         grid_x = temp_x[3:0];
//         grid_y = temp_y[3:0];
        
//         // Check if we're on a grid line (border of blocks)
//         on_grid_line = ((x - 10'd245) % BLOCK_SIZE == 0) || 
//                        ((y - 10'd90) % BLOCK_SIZE == 0) ||
//                        (x == 10'd394) || (y == 10'd389);  // Right and bottom borders
        
//         // Assign colors
//         if (in_grid) begin
//             if (on_grid_line) begin
//                 shape_color = WHITE;  // White grid lines
//             end else begin
//                 shape_color = BLACK;  // Black inside blocks
//             end
//         end else begin
//             shape_color = BLACK;  // Black background outside grid
//         end
//     end



endmodule
