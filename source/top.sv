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
  logic [9:0] x,y;
  logic [2:0] shape_color;
  logic onehuzz, rst;

  vgadriver ryangosling (.clk(hz100), .rst(1'b0), .color_in(shape_color), .red(left[5]), .green(left[4]), .blue(left[3]), .hsync(left[7]), .vsync(left[6]), .x_out(x), .y_out(y));
 
  clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz));

  tetris_grid gurt (.x(x), .y(y), .shape_color(shape_color), .clk(onehuzz), .rst (rst));

endmodule