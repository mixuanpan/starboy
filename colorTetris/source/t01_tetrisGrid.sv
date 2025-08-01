`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_tetrisGrid
// Description : grid display with white lines and black background
// 
//
/////////////////////////////////////////////////////////////////
module t01_tetrisGrid(
    input logic [9:0] x, y,
    input logic [19:0][9:0][2:0] final_display_color,
    input logic gameover,
    output logic [2:0] shape_color
);

    // grid parameters
    localparam BLOCK_SIZE = 15;
    
    // colors
    localparam BLACK   = 3'b000;
    localparam WHITE   = 3'b111;
    localparam RED   = 3'b100;

    logic in_grid;
    logic [9:0] temp_x, temp_y;
    logic [3:0] grid_x;
    logic [4:0] grid_y;
    logic on_grid_line;

    always_comb begin
        in_grid = (x >= 10'd245) && (x < 10'd395) && (y >= 10'd90) && (y < 10'd390);

        temp_x = (x - 10'd245) / BLOCK_SIZE;
        temp_y = (y - 10'd90) / BLOCK_SIZE;
        grid_x = temp_x[3:0];
        grid_y = temp_y[4:0];
 
        on_grid_line = ((x - 10'd245) % BLOCK_SIZE == 0) || ((y - 10'd90) % BLOCK_SIZE == 0) || (x == 10'd394) || (y == 10'd389);
        
    if (in_grid) begin
        if (on_grid_line && !gameover) begin
            shape_color = WHITE; 
        end else if (on_grid_line && gameover) begin
            shape_color = RED;
        end else begin
            if (grid_y < 5'd20 && grid_x < 4'd10) begin
                shape_color = final_display_color[grid_y][grid_x]; 
            end else begin
                shape_color = BLACK; 
            end
        end
    end else begin
        shape_color = BLACK;  
    end
end

endmodule