 /////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris_grid
// Description : test for now, just
// 
//
/////////////////////////////////////////////////////////////////
 
 
 module tetris_grid(
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

  logic [20:0][9:0][2:0] display_array;
  logic [4:0] blockY, blockYN; 

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        blockY <= 'd0;
    end else begin
        blockY <= blockYN;
    end
end

  always_comb begin
    // First, explicitly set ALL array elements to BLACK
    for (int i = 0; i <= 20; i++) begin
      for (int j = 0; j <= 9; j++) begin
        display_array[i][j] = BLACK;
      end
    end
    
    blockYN = 'b0;

    if (blockY < 18) begin
        blockYN = blockY + 'b1;  // all of this is making the block go down but it just loops
    end else begin
        blockYN = blockY;
    end

    // Create a simple 2x2 red square 
    display_array[blockY][4] = RED;
    display_array[blockY][5] = RED;
    display_array[blockY+1][4] = RED;
    display_array[blockY+1][5] = RED;
  end

  always_comb begin
      // Check if current pixel is within the grid area (245,90) to (395,390)
      in_grid = (x >= 10'd245) && (x < 10'd395) &&
                (y >= 10'd90) && (y < 10'd390);

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