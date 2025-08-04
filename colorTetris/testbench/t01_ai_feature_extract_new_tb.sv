`timescale 1ns/1ps  // Changed to ns for better precision

module t01_ai_feature_extract_new_tb();

    // Test parameters
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    parameter TIMEOUT_CYCLES = 1000;
    
    // Clock and reset
    logic clk;
    logic reset;
    
    // DUT inputs
    logic start_extract;
    logic [19:0][9:0] tetris_grid;
    logic ofm_done; 
    
    // DUT outputs
    logic extract_ready;
    logic [7:0] lines_cleared;
    logic [7:0] holes;
    logic [7:0] bumpiness;
    logic [7:0] height_sum;
    logic [2:0] state;
    
    // Test control variables
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Individual grid row signals for waveform viewing
    logic [9:0] grid_row_0, grid_row_1, grid_row_2, grid_row_3, grid_row_4;
    logic [9:0] grid_row_5, grid_row_6, grid_row_7, grid_row_8, grid_row_9;
    logic [9:0] grid_row_10, grid_row_11, grid_row_12, grid_row_13, grid_row_14;
    logic [9:0] grid_row_15, grid_row_16, grid_row_17, grid_row_18, grid_row_19;
    
    // Continuously assign grid rows for waveform visibility
    assign grid_row_0 = tetris_grid[0];   assign grid_row_1 = tetris_grid[1];
    assign grid_row_2 = tetris_grid[2];   assign grid_row_3 = tetris_grid[3];
    assign grid_row_4 = tetris_grid[4];   assign grid_row_5 = tetris_grid[5];
    assign grid_row_6 = tetris_grid[6];   assign grid_row_7 = tetris_grid[7];
    assign grid_row_8 = tetris_grid[8];   assign grid_row_9 = tetris_grid[9];
    assign grid_row_10 = tetris_grid[10]; assign grid_row_11 = tetris_grid[11];
    assign grid_row_12 = tetris_grid[12]; assign grid_row_13 = tetris_grid[13];
    assign grid_row_14 = tetris_grid[14]; assign grid_row_15 = tetris_grid[15];
    assign grid_row_16 = tetris_grid[16]; assign grid_row_17 = tetris_grid[17];
    assign grid_row_18 = tetris_grid[18]; assign grid_row_19 = tetris_grid[19];
    
    // DUT instantiation
    t01_ai_feature_extract_new dut (
        .clk(clk),
        .rst(reset),
        .extract_start(start_extract),
        .tetris_grid(tetris_grid),
        .extract_ready(extract_ready),
        .lines_cleared(lines_cleared),
        .holes(holes),
        .bumpiness(bumpiness),
        .height_sum(height_sum), 
        .ofm_done(ofm_done),
        .state(state)
    );
    
    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Reset task with proper timing
    task automatic reset_dut();
        reset = 1'b1;
        start_extract = 1'b0;
        ofm_done = 1'b0;
        repeat(3) @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
    endtask
    
    // Task to wait for ready signal with timeout
    task automatic wait_for_ready();
        int timeout_counter = 0;
        while (!extract_ready && timeout_counter < TIMEOUT_CYCLES) begin
            @(posedge clk);
            timeout_counter++;
        end
        if (timeout_counter >= TIMEOUT_CYCLES) begin
            $error("Timeout waiting for extract_ready at time %t", $time);
            fail_count++;
        end
    endtask
    
    // Task to toggle ofm_done to complete the cycle
    task automatic toggle_ofm_done();
        @(posedge clk);
        ofm_done = 1'b1;
        @(posedge clk);
        ofm_done = 1'b0;
        @(posedge clk);
    endtask
    
    // Task to run complete extraction cycle (start -> ready -> ofm_done -> back to idle)
    task automatic run_complete_extraction();
        // Start extraction
        start_extract = 1'b1;
        @(posedge clk);
        
        // Wait for processing to complete
        wait_for_ready();
        
        if (extract_ready) begin
            $display("Feature extraction completed at time %t", $time);
            $display("State: %d, Lines: %d, Holes: %d, Bumpiness: %d, Height: %d", 
                     state, lines_cleared, holes, bumpiness, height_sum);
            
            // Toggle ofm_done to return to IDLE state
            toggle_ofm_done();
            
            // Verify we're back in IDLE state
            if (state == 3'd0) begin  // IDLE = 0
                $display("Successfully returned to IDLE state");
            end else begin
                $display("WARNING: Did not return to IDLE state (state = %d)", state);
            end
        end
        
        start_extract = 1'b0;
        @(posedge clk);
    endtask
    
    // Task to initialize grid to all zeros
    task automatic clear_grid();
        for (int i = 0; i < 20; i++) begin
            tetris_grid[i] = 10'b0000000000;
        end
    endtask
    
    // Task to print grid for debugging (row 0 at top, row 19 at bottom)
    task automatic print_grid(string test_name);
        $display("\n=== Grid for %s ===", test_name);
        $display("    9876543210");  // Column numbers for reference
        for (int i = 0; i < 20; i++) begin
            $display("R%2d %b", i, tetris_grid[i]);
        end
        $display("========================\n");
    endtask
    
    // Task to check results
    task automatic check_results(
        string test_name,
        logic [7:0] expected_lines,
        logic [7:0] expected_holes,
        logic [7:0] expected_bumpiness,
        logic [7:0] expected_height
    );
        test_count++;
        $display("\n--- Test: %s ---", test_name);
        $display("Expected - Lines: %d, Holes: %d, Bumpiness: %d, Height: %d", 
                 expected_lines, expected_holes, expected_bumpiness, expected_height);
        $display("Actual   - Lines: %d, Holes: %d, Bumpiness: %d, Height: %d", 
                 lines_cleared, holes, bumpiness, height_sum);
        
        if (lines_cleared === expected_lines && 
            holes === expected_holes && 
            bumpiness === expected_bumpiness && 
            height_sum === expected_height) begin
            $display("✓ PASS");
            pass_count++;
        end else begin
            $display("✗ FAIL");
            fail_count++;
        end
    endtask
    
    // Test case: Empty grid
    task automatic test_empty_grid();
        $display("\n========== TEST: Empty Grid ==========");
        clear_grid();
        print_grid("Empty Grid");
        run_complete_extraction();
        check_results("Empty Grid", 8'd0, 8'd0, 8'd0, 8'd0);
    endtask
    
    // Test case: Full bottom rows
    task automatic test_full_rows();
        $display("\n========== TEST: Full Bottom Rows ==========");
        clear_grid();
        // Fill bottom 3 rows completely
        for (int i = 17; i < 20; i++) begin  // Bottom 3 rows (17, 18, 19)
            tetris_grid[i] = 10'b1111111111;
        end
        print_grid("Full Bottom Rows");
        run_complete_extraction();
        check_results("Full Bottom Rows", 8'd3, 8'd0, 8'd0, 8'd30); // 3 full rows * 10 height each
    endtask
    
    // Test case: Grid with holes
    task automatic test_holes();
        $display("\n========== TEST: Grid with Holes ==========");
        clear_grid();
        tetris_grid[19] = 10'b1111111111;  // Full bottom row
        tetris_grid[18] = 10'b1110111111;  // One hole at position 3
        tetris_grid[17] = 10'b1101011111;  // Two holes at positions 3 and 5
        tetris_grid[16] = 10'b1111111111;  // Full row above holes
        print_grid("Grid with Holes");
        run_complete_extraction();
        // Note: Expected values depend on your hole detection algorithm
        check_results("Grid with Holes", 8'd2, 8'd3, 8'd0, 8'd40);
    endtask
    
    // Test case: Bumpiness test
    task automatic test_bumpiness();
        $display("\n========== TEST: Bumpiness ==========");
        clear_grid();
        // Create a staircase pattern for predictable bumpiness
        tetris_grid[19] = 10'b1000000000;  // Column 0: height 1
        tetris_grid[18] = 10'b0100000000;  // Column 1: height 2  
        tetris_grid[19] |= 10'b0100000000;
        tetris_grid[17] = 10'b0010000000;  // Column 2: height 3
        tetris_grid[18] |= 10'b0010000000; 
        tetris_grid[19] |= 10'b0010000000;
        print_grid("Bumpiness Test");
        run_complete_extraction();
        // Bumpiness = |1-2| + |2-3| + |3-0| + ... = 1 + 1 + 3 + 0 + ... = expected value
        check_results("Bumpiness Test", 8'd0, 8'd0, 8'd5, 8'd6);
    endtask
    
    // Test case: Single column tower
    task automatic test_single_column();
        $display("\n========== TEST: Single Column Tower ==========");
        clear_grid();
        for (int i = 10; i < 20; i++) begin  // 10 blocks high in column 0
            tetris_grid[i] = 10'b1000000000;
        end
        print_grid("Single Column Tower");
        run_complete_extraction();
        // High bumpiness due to height difference between columns
        check_results("Single Column Tower", 8'd0, 8'd0, 8'd90, 8'd10);
    endtask
    
    // Test case: Multiple extractions with different grids
    task automatic test_multiple_extractions();
        $display("\n========== TEST: Multiple Extractions ==========");
        
        // First extraction - simple pattern
        clear_grid();
        tetris_grid[19] = 10'b1100000000;  // Two blocks at bottom
        tetris_grid[18] = 10'b1100000000;
        print_grid("Multiple Test - Pattern 1");
        run_complete_extraction();
        check_results("Multiple Test 1", 8'd0, 8'd0, 8'd18, 8'd4);
        
        // Second extraction - different pattern
        clear_grid();
        tetris_grid[19] = 10'b0011000000;  // Two blocks in different columns
        tetris_grid[18] = 10'b0011000000;
        print_grid("Multiple Test - Pattern 2");
        run_complete_extraction();
        check_results("Multiple Test 2", 8'd0, 8'd0, 8'd16, 8'd4);
        
        // Third extraction - full line
        clear_grid();
        tetris_grid[19] = 10'b1111111111;  // Full bottom line
        print_grid("Multiple Test - Pattern 3");
        run_complete_extraction();
        check_results("Multiple Test 3", 8'd1, 8'd0, 8'd0, 8'd10);
    endtask
    
    // Test case: Sequential grid changes
    task automatic test_sequential_changes();
        $display("\n========== TEST: Sequential Grid Changes ==========");
        
        // Start with empty grid, add blocks progressively
        clear_grid();
        
        for (int iteration = 1; iteration <= 3; iteration++) begin
            $display("\n--- Sequential Test Iteration %d ---", iteration);
            
            // Add more blocks each iteration
            for (int i = 0; i < iteration; i++) begin
                tetris_grid[19-i] = 10'b1111111111;  // Add full rows from bottom
            end
            
            print_grid($sformatf("Sequential Test - Iteration %d", iteration));
            run_complete_extraction();
            check_results($sformatf("Sequential Test %d", iteration), 
                         iteration[7:0], 8'd0, 8'd0, iteration[7:0] * 10);
        end
    endtask
    
    // Main test sequence
    initial begin
        // Setup waveform dump with grid visibility
        $dumpfile("waves/t01_ai_feature_extract_new.vcd");
        $dumpvars(0, t01_ai_feature_extract_new_tb);
        
        // Also dump individual grid rows for better waveform viewing
        $dumpvars(1, grid_row_0, grid_row_1, grid_row_2, grid_row_3, grid_row_4);
        $dumpvars(1, grid_row_5, grid_row_6, grid_row_7, grid_row_8, grid_row_9);
        $dumpvars(1, grid_row_10, grid_row_11, grid_row_12, grid_row_13, grid_row_14);
        $dumpvars(1, grid_row_15, grid_row_16, grid_row_17, grid_row_18, grid_row_19);
        
        $display("Starting Tetris Feature Extract Testbench");
        $display("Grid Layout: Row 0 (top) to Row 19 (bottom)");
        $display("==========================================");
        
        // Initialize signals
        start_extract = 1'b0;
        ofm_done = 1'b0;
        clear_grid();
        
        // Reset the DUT
        reset_dut();
        
        // Verify we start in IDLE state
        @(posedge clk);
        if (state != 3'd0) begin
            $error("DUT did not start in IDLE state (state = %d)", state);
        end else begin
            $display("✓ DUT correctly started in IDLE state");
        end
        
        // Run all test cases
        test_empty_grid();
        test_full_rows();
        test_holes();
        test_bumpiness();
        test_single_column();
        test_multiple_extractions();
        test_sequential_changes();
        
        // Test summary
        $display("\n==========================================");
        $display("Test Summary:");
        $display("Total Tests: %d", test_count);
        $display("Passed: %d", pass_count);
        $display("Failed: %d", fail_count);
        
        if (fail_count == 0) begin
            $display("🎉 ALL TESTS PASSED!");
        end else begin
            $display("❌ %d TESTS FAILED", fail_count);
        end
        $display("==========================================\n");
        
        // Wait a bit before finishing
        repeat(50) @(posedge clk);
        $finish;
    end
    
    // Safety timeout
    initial begin
        #(CLK_PERIOD * TIMEOUT_CYCLES * 50);  // Overall test timeout (increased for multiple tests)
        $error("Global test timeout reached!");
        $finish;
    end

endmodule