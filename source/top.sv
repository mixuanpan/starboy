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
  tetris_fsm game (.clk(hz100), .rst(reset), .en(pb[0]), .right(pb[8]), .left(pb[11]), .rl(pb[7]), .rr(pb[4]), .state_tb(right[4:0]), .grid());
  
  // // VGA 
  logic [9:0] x,y;
  logic [2:0] shape_color;
  logic onehuzz, rst;

  vgadriver ryangosling (.clk(hz100), .rst(1'b0), .color_in(shape_color), .red(left[5]), .green(left[4]), .blue(left[3]), .hsync(left[7]), .vsync(left[6]), .x_out(x), .y_out(y));
 
  clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz));

  tetris_grid gurt (.x(x), .y(y), .shape_color(shape_color), .clk(onehuzz), .rst (rst));

endmodule