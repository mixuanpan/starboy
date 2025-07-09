 /////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris_grid
// Description : test for now, just creates a simple grid with a square in it
// 
//
/////////////////////////////////////////////////////////////////
 
  module tetris_grid (
    input logic clk, rst,
    input logic [9:0] x, y,
    output logic [2:0] shape_color
 );
 
 // VGA display dimensions: 640x480
  // Color encoding: [2:0] = [red, green, blue]
  
  // Grid parameters
  localparam BLOCK_SIZE = 15;
  
  // Colors
  localparam BLACK = 3'b000;
  localparam WHITE = 3'b111;
  localparam RED = 3'b100;
  
  logic in_grid;
  logic [9:0] temp_x, temp_y;
  logic [3:0] grid_x;
  logic [4:0] grid_y;
  logic on_grid_line;

  logic [20:0][9:0][2:0] display_array, display_array_n;

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        display_array <= '0;  
    end else 
    begin
        display_array <= display_array_n;
    end
  end


  always_comb begin //controls luh pluh (updates block position)
    // First, explicitly set ALL array elements to BLACK
   display_array_n = display_array;
   
   for (int i = 0; i <= 20; i++) begin
      for (int j = 0; j <= 9; j++) begin
        display_array_n[i][j] = BLACK;
      end
    end
    
    // Create a simple 2x2 red square at position (8,4)
   display_array_n[5][4] = RED;
   display_array_n[5][5] = RED;
   display_array_n[6][4] = RED;
   display_array_n[6][5] = RED;
  end

  always_comb begin
      // Check if current pixel is within the grid area (245,90) to (395,390)
      in_grid = (x >= 10'd245) && (x < 10'd395) &&
                (y >= 10'd90) && (y < 10'd390);
        // tetrisGrid gurt (.x(x), .y(y), .shape_color(shape_color));

      // Calculate grid position with proper bit handling
      temp_x = (x - 10'd245) / BLOCK_SIZE;
      temp_y = (y - 10'd90) / BLOCK_SIZE;
      grid_x = temp_x[3:0];
      grid_y = temp_y[4:0];
      
      // Check if we're on a grid line (border of blocks)
      on_grid_line = ((x - 10'd245) % BLOCK_SIZE == 0) || 
                     ((y - 10'd90) % BLOCK_SIZE == 0) ||
                     (x == 10'd394) || (y == 10'd389);  // Right and bottom borders
      
      // Assign colors
      if (in_grid) begin
          if (on_grid_line) begin
              shape_color = WHITE;  // White grid lines
          end else begin
              // Map array contents to grid
              if (grid_y < 5'd20 && grid_x < 4'd10) begin
                  shape_color = display_array[grid_y][grid_x];
              end else begin
                  shape_color = BLACK;  // Fallback color
              end
          end
      end else begin
          shape_color = BLACK;  // Black background outside grid
      end
  end

endmodule
