`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : top 
// Description : Top module of everything 
// 
//
/////////////////////////////////////////////////////////////////
    // typedef enum logic [4:0] {
    //     IDLE, // reset state 
    //     READY, // count down to start 
    //     NEW_BLOCK, // load new block 
    //     A1, // 011
    //     A2, 
    //     B1, // 101
    //     B2, 
    //     C1, // 111 
    //     C2, 
    //     D0, // 1001
    //     E1, // 1010 
    //     E2, 
    //     E3, 
    //     E4, 
    //     F1, // 1110 
    //     F2, 
    //     F3, 
    //     F4, 
    //     G1, // 10010
    //     G2, 
    //     G3, 
    //     G4, 
    //     EVAL, // evaluation 
    //     GAME_OVER // user run out of space 11000 
    // } state_t; 

    typedef enum logic [2:0] {
        RIGHT, 
        LEFT, 
        ROR, // ROTATE RIGHT
        ROL, // ROTATE LEFT 
        DOWN, 
        NONE
    } move_t; 

    typedef enum logic [2:0] {
        CL0, // BLACK   
        CL1, 
        CL2, 
        CL3, 
        CL4, 
        CL5, 
        CL6, 
        CL7
    } color_t; 
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

  // Tetris FSM 
  tetris_fsm game (.clk(hz100), .rst(reset), .en(pb[0]), .right(pb[8]), .left(pb[11]), .rl(pb[7]), .rr(pb[4]), .state_tb(), .grid());
  
  // VGA 
  logic [9:0] x,y;
  logic [2:0] shape_color;

  logic [20:0][9:0][2:0] display_array;

  vgadriver ryangosling (.clk(hz100), .rst(1'b0), .color_in(shape_color), .red(red), .green(green), .blue(blue), .hsync(right[1]), .vsync(right[0]), .x_out(x), .y_out(y));

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

  always_comb begin
    // First, explicitly set ALL array elements to BLACK
    for (int i = 0; i <= 20; i++) begin
      for (int j = 0; j <= 9; j++) begin
        display_array[i][j] = BLACK;
      end
    end
    
    // Create a simple 2x2 red square at position (8,4)
    display_array[14][4] = RED;
    display_array[14][5] = RED;
    display_array[15][4] = RED;
    display_array[15][5] = RED;
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