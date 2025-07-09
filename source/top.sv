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
  // Your code goes here...
   logic [9:0] x, y;
  logic [2:0] grid_color, score_color, final_color;
  logic onehuzz;
  logic [7:0] current_score, next_score;
  
  // // For testing, increment score every second
  // // You can replace this with your actual line clear logic later
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
  
  // VGA driver
  vgadriver ryangosling (.clk(hz100), .rst(1'b0),  .color_in(final_color),  .red(left[5]),  .green(left[4]), .blue(left[3]), .hsync(left[7]),  .vsync(left[6]),  .x_out(x), .y_out(y)
  );
 
  // 1Hz clock divider
  clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz)
  );

  // Tetris grid
  tetris_grid gurt ( .x(x),  .y(y),  .shape_color(grid_color),  .clk(onehuzz),  .rst(reset)
  );
  
  // Score display
  scoredisplay score_disp (.clk(onehuzz),.rst(reset),.score(current_score),.x(x),.y(y),.shape_color(score_color)
  );
  
  // Color priority logic: score display takes priority over grid
  always_comb begin
    if (score_color != 3'b000) begin  // If score display has color
      final_color = score_color;
    end else begin
      final_color = grid_color;
    end
  end

endmodule