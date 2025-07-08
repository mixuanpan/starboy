`default_nettype none
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
  logic [21:0][9:0]grid_now; 
  tetris game(
    .clk(hz100), 
    .rst(reset), 
    .en(pb[0]), 
    .right(), .left(), .down(), .rr(), .rl(), .count_down(), 
    // .grid(grid_now), 
    .state_o(left[4:0])
  );  
  assign red = grid_now[0][0]; 


endmodule
