// // module mylesmagic (
// //     input  logic clk,
// //     input  logic rst,
// //     input  logic [9:0] x,
// //     input  logic [9:0] y,
// //     output logic [2:0] shape_color
// // );

// //   localparam int BLOCK_SIZE = 15;

// //   localparam int GRID_COLS = 10; 
// //   localparam int GRID_ROWS = 20; 

// //   // colors  [2] = R, [1] = G, [0] = B
// //   localparam logic [2:0] BLACK = 3'b000;
// //   localparam logic [2:0] WHITE = 3'b111;
// //   localparam logic [2:0] RED   = 3'b100;
// //   localparam logic [2:0] GREEN = 3'b010;

// //   logic [3:0] pos_x;
// //   logic [4:0] pos_y;
// //   logic toggle;
// //   logic [2:0] current_color;

// //   logic [2:0] display_array [0:GRID_ROWS-1][0:GRID_COLS-1];

// //   always_ff @(posedge clk, posedge rst) begin
// //     if (rst) begin
// //       pos_x <= 4'd4;
// //       pos_y <= 5'd9;
// //       current_color <= RED;
// //       toggle <= 1'b0;
// //     end else begin
// //       toggle <= ~toggle;

//       if (toggle) begin
//         if (pos_y < GRID_ROWS-2) 
//           pos_y <= pos_y + 1;
//       end

//       if (pos_y == GRID_ROWS-2)
//         current_color <= GREEN;
//     end
//   end


// //   always_comb begin
// //     for (int r = 0; r < GRID_ROWS; r++)
// //       for (int c = 0; c < GRID_COLS; c++)
// //         display_array[r][c] = BLACK;
// //     display_array[pos_y]    [pos_x]     = current_color;
// //     display_array[pos_y]    [pos_x+1]   = current_color;
// //     display_array[pos_y+1]  [pos_x]     = current_color;
// //     display_array[pos_y+1]  [pos_x+1]   = current_color;
// //   end

// //   always_comb begin
// //     logic in_grid = (x >= 10'd245) && (x < 10'd395) &&
// //                     (y >= 10'd90)  && (y < 10'd390);

//     logic [9:0] temp_x = (x - 10'd245) / BLOCK_SIZE;
//     logic [9:0] temp_y = (y - 10'd90)  / BLOCK_SIZE;
//     logic [3:0] grid_x = temp_x[3:0];
//     logic [4:0] grid_y = temp_y[4:0];
//     logic on_grid_line = ((x - 10'd245) % BLOCK_SIZE == 0) ||
//                          ((y - 10'd90)  % BLOCK_SIZE == 0) ||
//                          (x == 10'd394) || (y == 10'd389);
//     if (in_grid) begin
//       if (on_grid_line)
//         shape_color = WHITE;
//       else if (grid_y < GRID_ROWS && grid_x < GRID_COLS)
//         shape_color = display_array[grid_y][grid_x];
//       else
//         shape_color = BLACK;
//     end else begin
//       shape_color = BLACK;
//     end
//   end

// // endmodule
