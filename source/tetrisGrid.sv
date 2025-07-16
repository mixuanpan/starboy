/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris_grid
// Description : Grid display with white lines and black background
// 
//
/////////////////////////////////////////////////////////////////
 
 
module tetrisGrid(
    input logic [9:0] x, y,
    input logic [19:0][9:0] display_array,  // Game state as input (1 bit per cell)
    input logic gameover,
    output logic [2:0] shape_color
);

    // Grid parameters
    localparam BLOCK_SIZE = 15;
    
    // Colors
    localparam BLACK   = 3'b000;
    localparam WHITE   = 3'b111;
    localparam RED   = 3'b100;

    
    logic in_grid;
    logic [9:0] temp_x, temp_y;
    logic [3:0] grid_x;
    logic [4:0] grid_y;
    logic on_grid_line;

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
            if (on_grid_line && !gameover) begin
                shape_color = WHITE;  // White grid lines
            end else if (on_grid_line && gameover) begin
                shape_color = RED;
            end else begin
                // Map array contents to grid
                if (grid_y < 5'd20 && grid_x < 4'd10) begin
                    shape_color = display_array[grid_y][grid_x] ? WHITE : BLACK;
                end else begin
                    shape_color = BLACK;  // Fallback color
                end
            end
        end else begin
            shape_color = BLACK;  // Black background outside grid
        end
    end

endmodule