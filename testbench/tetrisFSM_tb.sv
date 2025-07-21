`timescale 1ns/1ps

module tetrisFSM_tb;
  // Clock & reset
  reg         clk;
  reg         reset;

  // Tie‑off inputs
  reg         onehuzz    = 0;
  reg         en_newgame = 0;
  reg         right_i    = 0;
  reg         left_i     = 0;
  reg         start_i    = 0;
  reg         rotate_r   = 0;
  reg         rotate_l   = 0;
  reg         speed_up_i = 0;

  // DUT outputs
  wire [19:0][9:0] display_array;
  wire             gameover;
  wire       [7:0] score;
  wire             speed_mode_o;

  // Instantiate your FSM
  tetrisFSM dut (
    .clk           (clk),
    .reset         (reset),
    .onehuzz       (onehuzz),
    .en_newgame    (en_newgame),
    .right_i       (right_i),
    .left_i        (left_i),
    .start_i       (start_i),
    .rotate_r      (rotate_r),
    .rotate_l      (rotate_l),
    .speed_up_i    (speed_up_i),
    .display_array (display_array),
    .gameover      (gameover),
    .score         (score),
    .speed_mode_o  (speed_mode_o)
  );

  // Clock: 10 ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Waveform dump
  initial begin
    $dumpfile("waves/tetrisFSM.vcd");
    $dumpvars(0, tetrisFSM_tb);
  end

  // Flatten the packed 20×10 display_array into a 200‑bit vector
  wire [199:0] display_flat;
  genvar gi, gj;
  generate
    for (gi = 0; gi < 20; gi = gi + 1) begin: ROW
      for (gj = 0; gj < 10; gj = gj + 1) begin: COL
        // index = gi*10 + gj
        assign display_flat[gi*10 + gj] = display_array[gi][gj];
      end
    end
  endgenerate

  // Task to print display_flat as a 20×10 grid
  task print_display;
    integer row, col, idx;
    begin
      $display("Time = %0t ns", $time);
      for (row = 19; row >= 0; row = row - 1) begin
        for (col = 0; col < 10; col = col + 1) begin
          idx = row * 10 + col;
          $write("%b", display_flat[idx]);
        end
        $write("\n");
      end
      $display("====================================\n");
    end
  endtask

  // Main test: reset, start, then print for a few cycles
  initial begin
    reset = 1;
    #20;
    reset = 0;

    // Pulse start to get into SPAWN state
    #10 start_i = 1;
    #10 start_i = 0;

    // Print the display every clock for 20 cycles
    repeat (20) begin
      @(posedge clk);
      print_display();
    end

    $finish;
  end

endmodule
