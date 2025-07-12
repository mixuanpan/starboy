`timescale 1ns / 1ps

module tetris_grid(
    input  logic [9:0]       x,
    input  logic [9:0]       y,
    // Flattened 20×12-bit playfield (20 rows × 12 bits = 240 bits)
    input  logic [239:0]     display_array_flat,
    output logic [2:0]       shape_color
);

    // Reconstruct unpacked 20×12 array from packed vector
    logic [11:0] display_array [19:0];
    genvar i;
    generate
      for (i = 0; i < 20; i = i + 1) begin
        // slice out 12 bits per row
        assign display_array[i] = display_array_flat[i*12 +: 12];
      end
    endgenerate

    // Grid parameters
    localparam int BLOCK_SIZE = 15;

    // Colors
    localparam logic [2:0] BLACK = 3'b000;
    localparam logic [2:0] WHITE = 3'b111;

    // Intermediate signals
    logic            in_grid;
    integer          temp_x_i, temp_y_i;
    integer          grid_x, grid_y;
    logic            on_grid_line;

    always_comb begin
        // Default background color
        shape_color = BLACK;

        // Determine if current pixel is inside the grid area
        in_grid = (x >= 10'd245) && (x < 10'd395) &&
                  (y >= 10'd90)  && (y < 10'd390);

        // Compute raw differences as full 32-bit integers
        temp_x_i = int'(x) - 32'd245;
        temp_y_i = int'(y) - 32'd90;

        // Compute grid cell indices
        grid_x = temp_x_i / BLOCK_SIZE;
        grid_y = temp_y_i / BLOCK_SIZE;

        // Detect grid lines (block borders)
        on_grid_line = ((temp_x_i % BLOCK_SIZE) == 0) ||
                       ((temp_y_i % BLOCK_SIZE) == 0) ||
                       (x == 10'd394) || (y == 10'd389);

        if (in_grid) begin
            if (on_grid_line) begin
                shape_color = WHITE;
            end else if ((grid_y < 20) && (grid_x < 10)) begin
                // Map playfield occupancy to color, skip left-wall bit
                if (display_array[grid_y][grid_x + 1])
                    shape_color = WHITE;
                else
                    shape_color = BLACK;
            end
        end
    end

endmodule
