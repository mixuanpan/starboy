`timescale 1us/1ps
module t01_ai_feature_extract_tb();
    // Clock and reset
    logic clk;
    logic reset;
    
    // DUT inputs
    logic start_extract;
    logic [199:0] next_board;
    
    // DUT outputs
    logic extract_ready;
    logic [2:0] lines_cleared;
    logic [7:0] holes;
    logic [7:0] bumpiness;
    logic [7:0] height_sum;
    
    // Test variables
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // DUT instantiation
    t01_ai_feature_extract dut (
        .clk(clk),
        .reset(reset),
        .start_extract(start_extract),
        .next_board(next_board),
        .extract_ready(extract_ready),
        .lines_cleared(lines_cleared),
        .holes(holes),
        .bumpiness(bumpiness),
        .height_sum(height_sum)
    );
    
    // Helper task to create a board pattern
    task create_board(input [19:0][9:0] board_rows);
        integer i;
        next_board = 200'b0;
        for (i = 0; i < 20; i++) begin
            next_board[i*10 +: 10] = board_rows[i];
        end
    endtask
    
    // Helper task to print board state (for debugging)
    task print_board();
        integer r, c;
        $display("Board state:");
        for (r = 19; r >= 0; r--) begin
            $write("Row %2d: ", r);
            for (c = 0; c < 10; c++) begin
                $write("%1b", next_board[r*10 + c]);
            end
            $display("");
        end
        $display("");
    endtask
    
    // Helper task to wait for extraction to complete
    task wait_for_extraction();
        start_extract = 1'b1;
        @(posedge clk);
        start_extract = 1'b0;
        
        // Wait for extract_ready
        while (!extract_ready) begin
            @(posedge clk);
        end
        
        // Give one more cycle for outputs to stabilize
        @(posedge clk);
    endtask
    
    // Test case verification task
    task verify_results(
        input [2:0] expected_lines,
        input [7:0] expected_holes,
        input [7:0] expected_bumpiness,
        input [7:0] expected_height_sum,
        input string test_name
    );
        test_count++;
        $display("\n=== Test: %s ===", test_name);
        $display("Expected - Lines: %d, Holes: %d, Bumpiness: %d, Height Sum: %d", 
                 expected_lines, expected_holes, expected_bumpiness, expected_height_sum);
        $display("Actual   - Lines: %d, Holes: %d, Bumpiness: %d, Height Sum: %d", 
                 lines_cleared, holes, bumpiness, height_sum);
        
        if (lines_cleared == expected_lines && 
            holes == expected_holes && 
            bumpiness == expected_bumpiness && 
            height_sum == expected_height_sum) begin
            $display("✓ PASS");
            pass_count++;
        end else begin
            $display("✗ FAIL");
            fail_count++;
        end
    endtask
    
    // Main test sequence
    initial begin
        $dumpfile("waves/t01_ai_feature_extract.vcd"); 
        $dumpvars(0, t01_ai_feature_extract_tb);
        // Initialize
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        reset = 1'b1;
        start_extract = 1'b0;
        next_board = 200'b0;
        
        // Wait for reset
        repeat(5) @(posedge clk);
        reset = 1'b0;
        repeat(2) @(posedge clk);
        
        $display("Starting Feature Extractor Tests...");
        
        // Test 1: Empty board
        create_board('{20{10'b0000000000}});
        wait_for_extraction();
        verify_results(3'd0, 8'd0, 8'd0, 8'd0, "Empty Board");
        
        // Test 2: Single block at bottom
        create_board('{
            19: 10'b0000000000,
            18: 10'b0000000000,
            17: 10'b0000000000,
            16: 10'b0000000000,
            15: 10'b0000000000,
            14: 10'b0000000000,
            13: 10'b0000000000,
            12: 10'b0000000000,
            11: 10'b0000000000,
            10: 10'b0000000000,
            9:  10'b0000000000,
            8:  10'b0000000000,
            7:  10'b0000000000,
            6:  10'b0000000000,
            5:  10'b0000000000,
            4:  10'b0000000000,
            3:  10'b0000000000,
            2:  10'b0000000000,
            1:  10'b0000000000,
            0:  10'b1000000000
        });
        wait_for_extraction();
        verify_results(3'd0, 8'd0, 8'd1, 8'd1, "Single Block Bottom Left");
        
        // Test 3: Full line (tetris)
        create_board('{
            19: 10'b0000000000,
            18: 10'b0000000000,
            17: 10'b0000000000,
            16: 10'b0000000000,
            15: 10'b0000000000,
            14: 10'b0000000000,
            13: 10'b0000000000,
            12: 10'b0000000000,
            11: 10'b0000000000,
            10: 10'b0000000000,
            9:  10'b0000000000,
            8:  10'b0000000000,
            7:  10'b0000000000,
            6:  10'b0000000000,
            5:  10'b0000000000,
            4:  10'b0000000000,
            3:  10'b0000000000,
            2:  10'b0000000000,
            1:  10'b0000000000,
            0:  10'b1111111111
        });
        wait_for_extraction();
        verify_results(3'd1, 8'd0, 8'd0, 8'd10, "Single Full Line");
        
        // Test 4: Holes test - column with hole
        create_board('{
            19: 10'b0000000000,
            18: 10'b0000000000,
            17: 10'b0000000000,
            16: 10'b0000000000,
            15: 10'b0000000000,
            14: 10'b0000000000,
            13: 10'b0000000000,
            12: 10'b0000000000,
            11: 10'b0000000000,
            10: 10'b0000000000,
            9:  10'b0000000000,
            8:  10'b0000000000,
            7:  10'b0000000000,
            6:  10'b0000000000,
            5:  10'b0000000000,
            4:  10'b0000000000,
            3:  10'b0000000000,
            2:  10'b1000000000,
            1:  10'b0000000000,
            0:  10'b1000000000
        });
        wait_for_extraction();
        verify_results(3'd0, 8'd1, 8'd0, 8'd3, "Single Hole");
        
        // Test 5: Bumpiness test - varying heights
        create_board('{
            19: 10'b0000000000,
            18: 10'b0000000000,
            17: 10'b0000000000,
            16: 10'b0000000000,
            15: 10'b0000000000,
            14: 10'b0000000000,
            13: 10'b0000000000,
            12: 10'b0000000000,
            11: 10'b0000000000,
            10: 10'b0000000000,
            9:  10'b0000000000,
            8:  10'b0000000000,
            7:  10'b0000000000,
            6:  10'b0000000000,
            5:  10'b0000000000,
            4:  10'b0000000000,
            3:  10'b0100000000,
            2:  10'b0100000000,
            1:  10'b0100000000,
            0:  10'b1100000000
        });
        wait_for_extraction();
        // Heights: [1,4,0,0,0,0,0,0,0,0]
        // Bumpiness: |1-4| + |4-0| + |0-0| + ... = 3 + 4 + 0 + ... = 7
        verify_results(3'd0, 8'd0, 8'd7, 8'd5, "Bumpiness Test");
        
        // Test 6: Complex scenario with multiple features
        create_board('{
            19: 10'b0000000000,
            18: 10'b0000000000,
            17: 10'b0000000000,
            16: 10'b0000000000,
            15: 10'b0000000000,
            14: 10'b0000000000,
            13: 10'b0000000000,
            12: 10'b0000000000,
            11: 10'b0000000000,
            10: 10'b0000000000,
            9:  10'b0000000000,
            8:  10'b0000000000,
            7:  10'b0000000000,
            6:  10'b0000000000,
            5:  10'b0000000000,
            4:  10'b1111111110,  // Almost full line
            3:  10'b1011111111,  // Full line except one hole
            2:  10'b1111111111,  // Full line
            1:  10'b1011111111,  // Hole in column 1
            0:  10'b1111111111   // Full line
        });
        wait_for_extraction();
        // Lines cleared: 2 (rows 2 and 0)
        // Holes: 2 (one in row 3 col 1, one in row 1 col 1)
        // Heights: [5,4,5,5,5,5,5,5,5,4] (accounting for missing blocks in full lines)
        // Height sum: 46
        // Bumpiness: |5-4| + |4-5| + |5-5| + ... + |5-4| = 1+1+0+0+0+0+0+0+1 = 3
        verify_results(3'd2, 8'd2, 8'd3, 8'd46, "Complex Scenario");
        
        // Test 7: Multiple full lines
        create_board('{
            19: 10'b0000000000,
            18: 10'b0000000000,
            17: 10'b0000000000,
            16: 10'b0000000000,
            15: 10'b0000000000,
            14: 10'b0000000000,
            13: 10'b0000000000,
            12: 10'b0000000000,
            11: 10'b0000000000,
            10: 10'b0000000000,
            9:  10'b0000000000,
            8:  10'b0000000000,
            7:  10'b0000000000,
            6:  10'b0000000000,
            5:  10'b0000000000,
            4:  10'b0000000000,
            3:  10'b1111111111,  // Full line
            2:  10'b1111111111,  // Full line  
            1:  10'b1111111111,  // Full line
            0:  10'b1111111111   // Full line
        });
        wait_for_extraction();
        verify_results(3'd4, 8'd0, 8'd0, 8'd40, "Four Full Lines");
        
        // Test 8: Maximum holes scenario
        create_board('{
            19: 10'b0000000000,
            18: 10'b0000000000,
            17: 10'b0000000000,
            16: 10'b0000000000,
            15: 10'b0000000000,
            14: 10'b0000000000,
            13: 10'b0000000000,
            12: 10'b0000000000,
            11: 10'b0000000000,
            10: 10'b0000000000,
            9:  10'b0000000000,
            8:  10'b0000000000,
            7:  10'b0000000000,
            6:  10'b0000000000,
            5:  10'b0000000000,
            4:  10'b1111111111,  // Top blocks
            3:  10'b0000000000,  // All holes
            2:  10'b0000000000,  // All holes
            1:  10'b0000000000,  // All holes
            0:  10'b1111111111   // Bottom blocks
        });
        wait_for_extraction();
        // Each column has 3 holes, 10 columns = 30 holes
        verify_results(3'd2, 8'd30, 8'd0, 8'd50, "Maximum Holes");
        
        // Wait a few more cycles
        repeat(10) @(posedge clk);
        
        // Print final results
        $display("\n" + "="*50);
        $display("TEST SUMMARY");
        $display("="*50);
        $display("Total Tests: %d", test_count);
        $display("Passed:      %d", pass_count);
        $display("Failed:      %d", fail_count);
        
        if (fail_count == 0) begin
            $display("🎉 ALL TESTS PASSED! 🎉");
        end else begin
            $display("❌ %d TESTS FAILED", fail_count);
        end
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #50000; // 50us timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end
    
endmodule