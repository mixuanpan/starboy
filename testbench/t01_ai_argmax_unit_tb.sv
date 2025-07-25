`timescale 1ns / 1ps

// Include the DUT module definition
`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_ai_argmax_unit
// Description : 
// 
//
/////////////////////////////////////////////////////////////////
module t01_ai_argmax_unit #(
    parameter Q_VALUE_WIDTH = 16,
    parameter MOVE_ID_WIDTH = 6
) (
    input logic clk,
    input logic rst,
    input logic start,
    input logic valid,
    input logic signed [Q_VALUE_WIDTH-1:0] q_value,
    input logic [MOVE_ID_WIDTH-1:0] move_id,
    input logic last,
    output logic [MOVE_ID_WIDTH-1:0] best_move_id,
    output logic signed [Q_VALUE_WIDTH-1:0] best_q_value,
    output logic done
);

    logic signed [Q_VALUE_WIDTH-1:0] best_q;
    logic [MOVE_ID_WIDTH-1:0] best_id;
    
    localparam logic signed [Q_VALUE_WIDTH-1:0] MIN_Q_VALUE = {1'b1, {(Q_VALUE_WIDTH-1){1'b0}}};
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            best_q <= MIN_Q_VALUE;
            best_id <= '0;
            done <= 1'b0;
        end else begin
            if (start) begin
                best_q <= MIN_Q_VALUE;
                best_id <= '0;
                done <= 1'b0;
            end
            else if (valid) begin
                if (q_value > best_q) begin
                    best_q <= q_value;
                    best_id <= move_id;
                end
                if (last) begin
                    done <= 1'b1;
                end else begin
                    done <= 1'b0;
                end
            end else begin
                done <= 1'b0;
            end
        end
    end

    // output
    always_comb begin
        best_move_id = best_id;
        best_q_value = best_q;
    end

endmodule

// Testbench module
module tb_t01_ai_argmax_unit;

    // Parameters
    parameter Q_VALUE_WIDTH = 16;
    parameter MOVE_ID_WIDTH = 6;
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)

    // DUT signals
    logic clk;
    logic rst;
    logic start;
    logic valid;
    logic signed [Q_VALUE_WIDTH-1:0] q_value;
    logic [MOVE_ID_WIDTH-1:0] move_id;
    logic last;
    logic [MOVE_ID_WIDTH-1:0] best_move_id;
    logic signed [Q_VALUE_WIDTH-1:0] best_q_value;
    logic done;

    // Test variables
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    // Instantiate DUT
    t01_ai_argmax_unit #(
        .Q_VALUE_WIDTH(Q_VALUE_WIDTH),
        .MOVE_ID_WIDTH(MOVE_ID_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .valid(valid),
        .q_value(q_value),
        .move_id(move_id),
        .last(last),
        .best_move_id(best_move_id),
        .best_q_value(best_q_value),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("=== Starting ArgMax Unit Testbench ===");
        $display("Q_VALUE_WIDTH = %0d, MOVE_ID_WIDTH = %0d", Q_VALUE_WIDTH, MOVE_ID_WIDTH);
        
        // Initialize signals
        rst = 1;
        start = 0;
        valid = 0;
        q_value = 0;
        move_id = 0;
        last = 0;
        
        // Wait for reset
        repeat(3) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Test 1: Basic functionality - ascending values
        test_basic_ascending();
        
        // Test 2: Basic functionality - descending values
        test_basic_descending();
        
        // Test 3: Mixed positive and negative values
        test_mixed_values();
        
        // Test 4: All negative values
        test_all_negative();
        
        // Test 5: Identical values
        test_identical_values();
        
        // Test 6: Single value test
        test_single_value();
        
        // Test 7: Reset during operation
        test_reset_during_operation();
        
        // Test 8: Start signal during operation
        test_start_during_operation();
        
        // Test 9: Invalid data between valid data
        test_invalid_data();
        
        // Test 10: Maximum and minimum values
        test_extreme_values();

        // Final results
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** %0d TESTS FAILED ***", fail_count);
        end
        
        $finish;
    end

    // Task to send a single Q-value and move ID
    task send_data(input logic signed [Q_VALUE_WIDTH-1:0] q_val, 
                   input logic [MOVE_ID_WIDTH-1:0] mv_id, 
                   input logic is_last);
        @(posedge clk);
        valid = 1;
        q_value = q_val;
        move_id = mv_id;
        last = is_last;
        @(posedge clk);
        valid = 0;
        last = 0;
    endtask

    // Task to start a new sequence
    task start_sequence();
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
    endtask

    // Task to check results
    task check_result(input logic [MOVE_ID_WIDTH-1:0] expected_move,
                     input logic signed [Q_VALUE_WIDTH-1:0] expected_q,
                     input string test_name);
        test_count++;
        
        // Wait for done signal
        while (!done) @(posedge clk);
        
        if (best_move_id === expected_move && best_q_value === expected_q) begin
            $display("PASS: %s - Move: %0d, Q-value: %0d", test_name, best_move_id, best_q_value);
            pass_count++;
        end else begin
            $display("FAIL: %s", test_name);
            $display("  Expected - Move: %0d, Q-value: %0d", expected_move, expected_q);
            $display("  Got      - Move: %0d, Q-value: %0d", best_move_id, best_q_value);
            fail_count++;
        end
    endtask

    // Test 1: Basic ascending values
    task test_basic_ascending();
        $display("\n--- Test 1: Basic Ascending Values ---");
        start_sequence();
        send_data(16'sd100, 6'd1, 0);
        send_data(16'sd200, 6'd2, 0);
        send_data(16'sd300, 6'd3, 0);
        send_data(16'sd400, 6'd4, 1);
        check_result(6'd4, 16'sd400, "Basic Ascending");
    endtask

    // Test 2: Basic descending values
    task test_basic_descending();
        $display("\n--- Test 2: Basic Descending Values ---");
        start_sequence();
        send_data(16'sd400, 6'd1, 0);
        send_data(16'sd300, 6'd2, 0);
        send_data(16'sd200, 6'd3, 0);
        send_data(16'sd100, 6'd4, 1);
        check_result(6'd1, 16'sd400, "Basic Descending");
    endtask

    // Test 3: Mixed positive and negative values
    task test_mixed_values();
        $display("\n--- Test 3: Mixed Positive and Negative Values ---");
        start_sequence();
        send_data(-16'sd100, 6'd10, 0);
        send_data(16'sd50, 6'd11, 0);
        send_data(-16'sd200, 6'd12, 0);
        send_data(16'sd150, 6'd13, 1);
        check_result(6'd13, 16'sd150, "Mixed Values");
    endtask

    // Test 4: All negative values
    task test_all_negative();
        $display("\n--- Test 4: All Negative Values ---");
        start_sequence();
        send_data(-16'sd500, 6'd20, 0);
        send_data(-16'sd300, 6'd21, 0);
        send_data(-16'sd800, 6'd22, 0);
        send_data(-16'sd100, 6'd23, 1);
        check_result(6'd23, -16'sd100, "All Negative");
    endtask

    // Test 5: Identical values (should keep first one)
    task test_identical_values();
        $display("\n--- Test 5: Identical Values ---");
        start_sequence();
        send_data(16'sd250, 6'd30, 0);
        send_data(16'sd250, 6'd31, 0);
        send_data(16'sd250, 6'd32, 0);
        send_data(16'sd250, 6'd33, 1);
        check_result(6'd30, 16'sd250, "Identical Values");
    endtask

    // Test 6: Single value
    task test_single_value();
        $display("\n--- Test 6: Single Value ---");
        start_sequence();
        send_data(16'sd777, 6'd40, 1);
        check_result(6'd40, 16'sd777, "Single Value");
    endtask

    // Test 7: Reset during operation
    task test_reset_during_operation();
        $display("\n--- Test 7: Reset During Operation ---");
        start_sequence();
        send_data(16'sd100, 6'd50, 0);
        send_data(16'sd200, 6'd51, 0);
        
        // Apply reset
        @(posedge clk);
        rst = 1;
        @(posedge clk);
        rst = 0;
        
        // Check that outputs are reset
        if (done == 0 && best_q_value == {1'b1, {(Q_VALUE_WIDTH-1){1'b0}}} && best_move_id == 0) begin
            $display("PASS: Reset During Operation - State properly reset");
            pass_count++;
        end else begin
            $display("FAIL: Reset During Operation - State not properly reset");
            fail_count++;
        end
        test_count++;
    endtask

    // Test 8: Start signal during operation
    task test_start_during_operation();
        $display("\n--- Test 8: Start During Operation ---");
        start_sequence();
        send_data(16'sd100, 6'd60, 0);
        send_data(16'sd200, 6'd61, 0);
        
        // Start new sequence without finishing previous one
        start_sequence();
        send_data(16'sd50, 6'd62, 0);
        send_data(16'sd300, 6'd63, 1);
        check_result(6'd63, 16'sd300, "Start During Operation");
    endtask

    // Test 9: Invalid data between valid data
    task test_invalid_data();
        $display("\n--- Test 9: Invalid Data Between Valid Data ---");
        start_sequence();
        send_data(16'sd100, 6'd6, 0);
        
        // Send invalid data (valid = 0)
        @(posedge clk);
        valid = 0;
        q_value = 16'sd999; // This should be ignored
        move_id = 6'd7;
        @(posedge clk);
        
        send_data(16'sd200, 6'd8, 0);
        send_data(16'sd150, 6'd9, 1);
        check_result(6'd8, 16'sd200, "Invalid Data Ignored");
    endtask

    // Test 10: Extreme values
    task test_extreme_values();
        $display("\n--- Test 10: Extreme Values ---");
        start_sequence();
        send_data({1'b1, {(Q_VALUE_WIDTH-1){1'b0}}}, 6'd16, 0); // Most negative
        send_data({1'b0, {(Q_VALUE_WIDTH-1){1'b1}}}, 6'd17, 0); // Most positive
        send_data(16'sd0, 6'd18, 1);
        check_result(6'd17, {1'b0, {(Q_VALUE_WIDTH-1){1'b1}}}, "Extreme Values");
    endtask

    // Monitor for debugging (commented out to reduce output)
    // initial begin
    //     $monitor("Time=%0t clk=%b rst=%b start=%b valid=%b q_value=%0d move_id=%0d last=%b best_move_id=%0d best_q_value=%0d done=%b", 
    //              $time, clk, rst, start, valid, q_value, move_id, last, best_move_id, best_q_value, done);
    // end

    // Timeout protection
    initial begin
        #100000; // 100us timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule