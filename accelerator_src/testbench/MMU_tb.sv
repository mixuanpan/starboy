`timescale 1ns/1ps
module MMU_tb;
  logic clk;
  logic reset;
  logic control;
  logic [31:0] data_arr;
  logic [31:0] wt_arr;
  logic [127:0] acc_out;

  MMU uut (.clk(clk), .control (control), .reset(reset), .data_arr(data_arr), .wt_arr(wt_arr), .acc_out (acc_out));

  localparam CLK_PER = 10;
  initial clk = 0;
  always  #(CLK_PER/2) clk = ~clk;

  initial begin
    $dumpfile("waves/MMU_tb.vcd");
    $dumpvars(0, MMU_tb);    
  end

  initial begin
    //global reset
    reset    = 1'b1;
    control  = 1'b0;
    data_arr = 32'h0000_0000;
    wt_arr   = 32'h0000_0000;
    #(2*CLK_PER);
    reset    = 1'b0;

    //load four columns of weights
    repeat (1) @(posedge clk);// align to clock edge
    control = 1'b1;
    wt_arr  = 32'h0502_0304;//cycle 0

    @(posedge clk);
    wt_arr  = 32'h0301_0203;//cycle 1

    @(posedge clk);
    wt_arr  = 32'h0704_0102;//cycle 2

    @(posedge clk);
    wt_arr  = 32'h0102_0403;//cycle 3

    //stream seven rows of data
    @(posedge clk);
    control  = 1'b0;
    data_arr = 32'h0000_0001;//cycle 4

    @(posedge clk);
    data_arr = 32'h0000_0102;//cycle 5

    @(posedge clk);
    data_arr = 32'h0001_0200;//cycle 6

    @(posedge clk);
    data_arr = 32'h0001_0100;//cycle 7

    @(posedge clk);
    data_arr = 32'h0203_0200;//cycle 8

    @(posedge clk);
    data_arr = 32'h0401_0000;//cycle 9

    @(posedge clk);
    data_arr = 32'h0500_0000;//cycle 10

    //drain the pipeline & finish
    repeat (10) @(posedge clk);//10 extra idle clocks
    $display("Simulation finished at %t ns", $time);
    $finish;
  end
-
  //run-time monitor
  always_ff @(posedge clk) begin
    $display("[%t] control=%0d data_arr=%h wt_arr=%h  acc_out=%h", 
    $time, control, data_arr, wt_arr, acc_out);
  end
endmodule
