`timescale 1ns/1ps
module MMU_tb;
  logic clk;
  logic reset;
  logic control;
  logic [31:0] data_arr;
  logic [31:0] wt_arr;
  logic [127:0] acc_out;

  integer cycle_count;
  integer start_cycle;
  integer done_cycle;
  bit measuring;
  
  MMU uut (.clk(clk), .control(control), .reset(reset), .data_arr(data_arr), .wt_arr(wt_arr), .acc_out(acc_out));

  //100 mhz clock
  localparam CLK_PER = 10;
  initial clk = 0;
  always #(CLK_PER/2) clk = ~clk;

  //waveform
  initial begin
    $dumpfile("waves/MMU_tb.vcd");
    $dumpvars(0, MMU);
  end

  initial begin
    //initialize
    reset = 1;
    control = 0;
    data_arr = 32'h0;
    wt_arr  = 32'h0;
    cycle_count = 0;
    measuring = 0;
    start_cycle = 0;
    done_cycle = 0;

    //hold reset
    repeat (2) @(posedge clk);
    reset = 0;

    //load weights 
    control = 1;
    @(posedge clk); wt_arr = 32'h0502_0304;//cycle 0
    @(posedge clk); wt_arr = 32'h0301_0203;//cycle 1
    @(posedge clk); wt_arr = 32'h0704_0102;//cycle 2
    @(posedge clk); wt_arr = 32'h0102_0403;//cycle 3

    //stream data
    @(posedge clk);
      control  = 0; 
      data_arr = 32'h0000_0001;//cycle 4
    @(posedge clk); data_arr = 32'h0000_0102;//cycle 5
    @(posedge clk); data_arr = 32'h0001_0200;//cycle 6
    @(posedge clk); data_arr = 32'h0001_0100;//cycle 7
    @(posedge clk); data_arr = 32'h0203_0200;//cycle 8
    @(posedge clk); data_arr = 32'h0401_0000;//cycle 9
    @(posedge clk); data_arr = 32'h0500_0000;//cycle 10

    //start measuring
    @(posedge clk);
      measuring = 1;
      start_cycle = cycle_count;

    //wait till output is zero
    wait (measuring && acc_out != 0);
    done_cycle = cycle_count;
    $display("→ HW latency: %0d cycles (≈%0dns)", 
             (done_cycle - start_cycle), 
             (done_cycle - start_cycle)*CLK_PER);
    $display("acc_out = %h at cycle %0d", acc_out, done_cycle);

    //finish
    # (5*CLK_PER) $finish;
  end

  //cycle counter
  always_ff @(posedge clk) begin
    if (reset) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
    end
  end

  //runtime monitor
  always_ff @(posedge clk) begin
    if (!reset) begin
      $display("[%0dns] ctrl=%0b data=%08h wt=%08h out=%032h", 
               cycle_count*CLK_PER, control, data_arr, wt_arr, acc_out);
    end
  end

endmodule
