`timescale 1ns/1ps
module t01_ai_feature_extract_tb ;
  // Clock, reset, and DUT I/O
  logic        clk;
  logic        reset;
  logic        start_extract;
  logic [199:0] next_board;
  logic        extract_ready;
  logic [2:0]  lines_cleared;
  logic [7:0]  holes, bumpiness, height_sum;

  // Instantiate DUT
  t01_ai_feature_extract dut (
    .clk           (clk),
    .reset         (reset),
    .start_extract (start_extract),
    .next_board    (next_board),
    .extract_ready (extract_ready),
    .lines_cleared (lines_cleared),
    .holes         (holes),
    .bumpiness     (bumpiness),
    .height_sum    (height_sum)
  );

  // 100 MHz clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Simple reset task
  task do_reset();
    begin
      reset = 1; #10;
      reset = 0; #10;
    end
  endtask

  // Main test sequence
  initial begin
    $dumpfile("waves/t01_ai_feature_extract.vcd");
    $dumpvars(0, t01_ai_feature_extract_tb);
    

    // Reset DUT
    do_reset();

    // Test 1: empty board
    next_board     = 200'd0;
    start_extract  = 1; #10; start_extract = 0;
    wait (extract_ready); #1;
    $display("Test1 empty: lines=%0d holes=%0d bump=%0d hsum=%0d",
      lines_cleared, holes, bumpiness, height_sum);
    assert(lines_cleared == 0)  else $error("Empty: wrong lines");
    assert(holes         == 0)  else $error("Empty: wrong holes");
    assert(bumpiness     == 0)  else $error("Empty: wrong bumpiness");
    assert(height_sum    == 0)  else $error("Empty: wrong height_sum");

    // Test 2: single block at bottom-left (row 19, col 0)
    next_board     = 200'd0;
    next_board[0*10 + 0] = 1;        // bottom-left
    do_reset();
    start_extract  = 1; #10; start_extract = 0;
    wait (extract_ready); #1;
    $display("Test2 single: lines=%0d holes=%0d bump=%0d hsum=%0d",
      lines_cleared, holes, bumpiness, height_sum);
    assert(lines_cleared == 0)  else $error("Single: wrong lines");
    assert(holes         == 0)  else $error("Single: wrong holes");
    assert(bumpiness     == 1)  else $error("Single: wrong bumpiness");
    assert(height_sum    == 1)  else $error("Single: wrong height_sum");
    // Test 3: full bottom row
    next_board     = 200'd0;
    for (int c = 0; c < 10; c++)
      next_board[19*10 + c] = 1;
    do_reset();
    start_extract  = 1; #10; start_extract = 0;
    wait (extract_ready); #1;
    $display("Test3 full row: lines=%0d holes=%0d bump=%0d hsum=%0d",
      lines_cleared, holes, bumpiness, height_sum);
    assert(lines_cleared == 1)    else $error("Full row: wrong lines");
    assert(holes         == 190)  else $error("Full row: wrong holes");
    assert(bumpiness     == 0)    else $error("Full row: wrong bumpiness");
    assert(height_sum    == 200)  else $error("Full row: wrong height_sum");

    $display("✅ All tests passed");
    $finish;
  end
endmodule
