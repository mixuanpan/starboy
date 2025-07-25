`timescale 1ns / 1ps

module t01_ai_placement_engine_tb;
  // Clock & reset
  logic         clk;
  logic         reset;

  // DUT inputs (flattened)
  logic         start_placement;
  logic [199:0] display_array;
  logic [4:0]   piece_type;

  // DUT outputs (flattened)
  logic         placement_ready;
  logic [7999:0] next_boards;
  logic [5:0]   valid_placements;
  logic [79:0]  rotations;
  logic [159:0] x_positions;

  // Instantiate DUT
  t01_ai_placement_engine dut (
    .clk            (clk),
    .reset          (reset),
    .start_placement(start_placement),
    .display_array  (display_array),
    .piece_type     (piece_type),
    .placement_ready(placement_ready),
    .next_boards    (next_boards),
    .valid_placements(valid_placements),
    .rotations      (rotations),
    .x_positions    (x_positions)
  );

  // VCD dump
  initial begin
    $dumpfile("waves/t01_ai_placement_engine.vcd");
    $dumpvars(0, dut);
  end

  // 100 MHz clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset + init
  task reset_system();
    begin
      reset           = 1;
      start_placement = 0;
      display_array   = 200'd0;
      piece_type      = 0;
      @(posedge clk);
      reset = 0;
      @(posedge clk);
    end
  endtask

  // Wait until done
  task wait_for_completion();
    begin
      wait (placement_ready);
      @(posedge clk);
    end
  endtask

  // Empty board
  task create_empty_board();
    display_array = 200'd0;
  endtask

  // Partial board (two bottom rows with gaps)
  task create_partial_board();
    display_array = 200'd0;
    display_array[19*10 +:10] = 10'b1111011110;
    display_array[18*10 +:10] = 10'b1110111110;
  endtask

  // Almost-full board (rows 15–19 filled except rightmost col)
  task create_almost_full_board();
    display_array = 200'd0;
    for (int r = 15; r < 20; r++) begin
      display_array[r*10 +:10] = 10'b1111111110;
    end
  endtask

  // Test one piece on empty board:
  //   pid = piece_type, name = for display, expected_count = 6-bit expected
  task test_piece(
    input logic [4:0] pid,
    input string      name,
    input logic [5:0] expected_count
  );
    begin
      $display("\n--- Testing %s on empty board ---", name);
      reset_system();
      create_empty_board();
      piece_type = pid;
      #1 start_placement = 1;
      @(posedge clk);
      start_placement = 0;
      wait_for_completion();
      if (valid_placements == expected_count)
        $display("✓ PASS %s: got %0d placements", name, valid_placements);
      else
        $display("✗ FAIL %s: expected %0d, got %0d",
                 name, expected_count, valid_placements);
    end
  endtask

  // Print rotations & X
  task print_placements();
    for (int i = 0; i < valid_placements; i++) begin
      $display("  [%0d] rot=%0d, x=%0d",
               i,
               rotations[i*2 +:2],
               x_positions[i*4 +:4]);
    end
  endtask

  // Main TB
  initial begin
    $display("=== AI Placement Engine Testbench ===");

    // 1: I-piece (10 + 7)
    test_piece(5'd0, "I", 6'd17);

    // 2: O-piece (9×1)
    test_piece(5'd1, "O", 6'd9);

    // 3: S-piece (8+9=17)
    test_piece(5'd2, "S", 6'd17);

    // 4: Z-piece (8+9=17)
    test_piece(5'd3, "Z", 6'd17);

    // 5: J-piece (8+9+8+9=34)
    test_piece(5'd4, "J", 6'd34);

    // 6: L-piece (8+9+8+9=34)
    test_piece(5'd5, "L", 6'd34);

    // 7: T-piece (8+9+8+9=34)
    test_piece(5'd6, "T", 6'd34);

    // I-piece on partial board
    $display("\n--- I-piece on partial board ---");
    reset_system();
    create_partial_board();
    piece_type = 5'd0;
    #1 start_placement = 1; @(posedge clk);
    start_placement = 0;
    wait_for_completion();
    $display("I-piece valid placements = %0d", valid_placements);
    print_placements();

    // O-piece on almost-full board
    $display("\n--- O-piece on almost-full board ---");
    reset_system();
    create_almost_full_board();
    piece_type = 5'd1;
    #1 start_placement = 1; @(posedge clk);
    start_placement = 0;
    wait_for_completion();
    $display("O-piece valid placements = %0d", valid_placements);
    print_placements();

    $display("\n🎉 All tests done 🎉");
    $finish;
  end

  // Timeout watchdog
  initial begin
    #50000;  // 50 µs
    $error("Testbench timeout!");
    $finish;
  end

endmodule
