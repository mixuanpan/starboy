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

    // typedef enum logic [2:0] {
    //     RIGHT, 
    //     LEFT, 
    //     ROR, // ROTATE RIGHT
    //     ROL, // ROTATE LEFT 
    //     DOWN, 
    //     NONE
    // } move_t; 

    // typedef enum logic [2:0] {
    //     CL0, // BLACK   
    //     CL1, 
    //     CL2, 
    //     CL3, 
    //     CL4, 
    //     CL5, 
    //     CL6, 
    //     CL7
    // } color_t; 
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

   logic [9:0] x, y;
  logic [2:0] grid_color, score_color, starboy_color, final_color;  
  logic onehuzz;
  logic [7:0] current_score, next_score;
  

    localparam BLACK   = 3'b000;  // No color
    localparam RED     = 3'b100;  // Red only
    localparam GREEN   = 3'b010;  // Green only
    localparam BLUE    = 3'b001;  // Blue only

    localparam YELLOW  = 3'b110;  // Red + Green
    localparam MAGENTA = 3'b101;  // Red + Blue (Purple/Pink)
    localparam CYAN    = 3'b011;  // Green + Blue (Aqua)
    localparam WHITE   = 3'b111;  // All colors (Red + Green + Blue)

  logic [4:0] blockY, blockYN; 

  // // For testing, increment score every second
  always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
      current_score <= 8'd0;
    end else begin
      current_score <= next_score;
    end
  end
  always_comb begin
    next_score = 'd0;

    if (next_score < 8'd255) begin
      next_score = current_score + 'b1;
    end else begin
      next_score = current_score;
    end
  end
  
  logic [21:0][9:0][2:0] display_array;

  // VGA driver
  vgadriver ryangosling (.clk(hz100), .rst(1'b0),  .color_in(final_color),  .red(left[5]),  .green(left[4]), .blue(left[3]), .hsync(left[7]),  .vsync(left[6]),  .x_out(x), .y_out(y) );
 
  // 1Hz clock divider
  clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz));

  // Tetris grid
  tetris_grid gurt ( .x(x),  .y(y),  .shape_color(grid_color), .display_array(display_array));


    always_ff @(posedge onehuzz, posedge reset) begin
      if (reset) begin
          blockY <= 'd0;
      end else begin          //simple block going down and stays down
          blockY <= blockYN;
      end
    end

    always_comb begin
    // First, explicitly set ALL array elements to BLACK
    for (int i = 0; i <= 21; i++) begin
      for (int j = 0; j <= 9; j++) begin
        display_array[i][j] = BLACK;
      end
    end
    
    blockYN = 'b0;

    if (blockY < 18) begin
        blockYN = blockY + 'b1; 
    end else begin
        blockYN = blockY;
    end

    // Create a simple 2x2 red square 
    display_array[blockY][4] = RED;
    display_array[blockY][5] = RED;
    display_array[blockY+1][4] = RED;
    display_array[blockY+1][5] = RED;
  end

  
  // Score display
  scoredisplay score_disp (.clk(onehuzz),.rst(reset),.score(current_score),.x(x),.y(y),.shape_color(score_color));
  
    // STARBOY display
  starboydisplay starboy_disp (.clk(onehuzz),.rst(reset),.x(x),.y(y),.shape_color(starboy_color));

// Color priority logic: starboy and score display take priority over grid
always_comb begin
  if (starboy_color != 3'b000) begin  // If starboy display has color (highest priority)
    final_color = starboy_color;
  end else if (score_color != 3'b000) begin  // If score display has color
    final_color = score_color;
  end else begin
    final_color = grid_color;  // Default to grid color
  end
end

endmodule