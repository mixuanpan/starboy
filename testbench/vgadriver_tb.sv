`timescale 1ns/1ps

module vgadriver_tb;
  // clock & reset
  logic clk = 0;
  logic rst;

  // DUT I/Os
  logic [7:0] color_in;
  logic [9:0] x_out, y_out;
  logic hsync, vsync, blank;
  logic [7:0]  red, green, blue;

  // instantiate DUT
  vgadriver dut (
    .clk(clk),
    .rst(rst),
    .color_in(color_in),
    .x_out(x_out),
    .y_out(y_out),
    .hsync(hsync),
    .vsync(vsync),
    .blank(blank),
    .red(red),
    .green(green),
    .blue(blue)
  );

  // 25 MHz clock → 40 ns period
  always #20 clk = ~clk;

  initial begin
    // dump waveform
    $dumpfile("waves/vgadriver.vcd"); 
    $dumpvars(0, vgadriver_tb);

    //reset pulse
    rst = 1;
    #100;
    rst = 0;

    //drive a repeating color pattern
    forever begin
      @(negedge clk);
      color_in <= color_in + 1;
    end
  end

  // simple checks: print transitions of blank→active
  always_ff @(posedge clk) begin
    if (hsync && vsync && !blank) begin
      // start of a visible pixel
      $display("Visible region starts at t=%0t, x=%0d, y=%0d", $time, x_out, y_out);
    end
  end

  // finish after a few full frames
  initial begin
    // wait 800 µs ≈ 3 full 25 MHz/640×480@60Hz frames
    #800_000;
    $finish;
  end
endmodule
