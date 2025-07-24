`timescale 1ns / 1ps

module tb_t01_ai_MMU;

  // Clock and reset
  logic clk;
  logic rst_n;
  
  // DUT inputs
  logic start;
  logic [1:0] layer_sel;
  logic act_valid;
  logic [7:0] act_in;
  
  // DUT outputs
  logic res_valid;
  logic [17:0] res_out;
  logic done;
  
  // Testbench variables
  logic [7:0] test_inputs [32];
  logic [17:0] expected_outputs [32];
  logic [17:0] actual_outputs [32];
  int output_count;
  int test_layer;
  int error_count;
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end
  
  // DUT instantiation
  t01_ai_MMU dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .layer_sel(layer_sel),
    .act_valid(act_valid),
    .act_in(act_in),
    .res_valid(res_valid),
    .res_out(res_out),
    .done(done)
  );
  
  // Memory files for expected results (you would populate these)
  // For now, we'll use simplified checking
  
  // Main test sequence
  initial begin
    $display("=== Starting MMU Testbench ===");
    
    // Initialize
    initialize_signals();
    reset_dut();
    
    // Test each layer
    for (test_layer = 0; test_layer < 4; test_layer++) begin
      $display("\n--- Testing Layer %0d ---", test_layer);
      test_layer_operation(test_layer);
      #100; // Wait between tests
    end
    
    // Test corner cases
    test_corner_cases();
    
    // Test reset during operation
    test_reset_during_operation();
    
    // Final results
    if (error_count == 0) begin
      $display("\n=== ALL TESTS PASSED ===");
    end else begin
      $display("\n=== %0d ERRORS DETECTED ===", error_count);
    end
    
    $finish;
  end
  
  // Initialize all signals
  task initialize_signals();
    rst_n = 1'b1;
    start = 1'b0;
    layer_sel = 2'b00;
    act_valid = 1'b0;
    act_in = 8'b0;
    output_count = 0;
    error_count = 0;
    
    // Initialize test inputs with known patterns
    for (int i = 0; i < 32; i++) begin
      test_inputs[i] = i + 1; // Simple incrementing pattern
    end
  endtask
  
  // Reset the DUT
  task reset_dut();
    $display("Applying reset...");
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;
    #10;
    
    // Check reset state
    if (res_valid !== 1'b0 || done !== 1'b0) begin
      $error("Reset failed - outputs not cleared");
      error_count++;
    end else begin
      $display("Reset successful");
    end
  endtask
  
  // Test a specific layer
  task test_layer_operation(int layer);
    int input_count;
    int max_inputs;
    
    layer_sel = layer[1:0];
    output_count = 0;
    
    // Determine number of inputs based on layer
    case (layer)
      0: max_inputs = 4;   // Layer 0: 4 inputs
      1: max_inputs = 32;  // Layer 1: 32 inputs  
      2: max_inputs = 32;  // Layer 2: 32 inputs
      3: max_inputs = 32;  // Layer 3: 32 inputs
      default: max_inputs = 32;
    endcase
    
    $display("Testing layer %0d with %0d inputs", layer, max_inputs);
    
    // Start the operation
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    
    // Send input data
    for (input_count = 0; input_count < max_inputs; input_count++) begin
      @(posedge clk);
      act_valid = 1'b1;
      act_in = test_inputs[input_count];
      $display("  Sending input[%0d] = 0x%02h", input_count, act_in);
    end
    
    @(posedge clk);
    act_valid = 1'b0;
    
    // Wait for completion and collect outputs
    fork
      begin
        // Timeout watchdog
        #10000;
        $error("Layer %0d test timeout", layer);
        error_count++;
      end
      begin
        // Collect outputs
        while (!done) begin
          @(posedge clk);
          if (res_valid) begin
            actual_outputs[output_count] = res_out;
            $display("  Output[%0d] = 0x%05h (%0d)", output_count, res_out, $signed(res_out));
            output_count++;
          end
        end
        disable; // Disable timeout
      end
    join_any
    
    // Verify output count
    int expected_outputs_count = (layer == 3) ? 1 : 32;
    if (output_count != expected_outputs_count) begin
      $error("Layer %0d: Expected %0d outputs, got %0d", layer, expected_outputs_count, output_count);
      error_count++;
    end else begin
      $display("Layer %0d: Correct number of outputs (%0d)", layer, output_count);
    end
    
    // Basic sanity checks on outputs
    verify_outputs(layer);
  endtask
  
  // Verify outputs make sense
  task verify_outputs(int layer);
    logic all_zero = 1'b1;
    logic any_negative = 1'b0;
    
    for (int i = 0; i < output_count; i++) begin
      if (actual_outputs[i] != 18'b0) all_zero = 1'b0;
      if (actual_outputs[i][17]) any_negative = 1'b1; // Check sign bit
    end
    
    // ReLU should ensure no negative outputs
    if (any_negative) begin
      $error("Layer %0d: Found negative outputs (ReLU failure)", layer);
      error_count++;
    end
    
    // Outputs shouldn't all be zero (unless weights/biases are zero)
    if (all_zero) begin
      $warning("Layer %0d: All outputs are zero - check weights/biases", layer);
    end
    
    $display("Layer %0d verification: No negative outputs = %0s", 
             layer, any_negative ? "FAIL" : "PASS");
  endtask
  
  // Test corner cases
  task test_corner_cases();
    $display("\n--- Testing Corner Cases ---");
    
    // Test with zero inputs
    test_zero_inputs();
    
    // Test with maximum positive inputs
    test_max_inputs();
    
    // Test with maximum negative inputs  
    test_min_inputs();
    
    // Test start signal during operation
    test_start_during_operation();
  endtask
  
  // Test with all zero inputs
  task test_zero_inputs();
    $display("Testing with zero inputs...");
    
    layer_sel = 2'b01; // Test layer 1
    
    for (int i = 0; i < 32; i++) begin
      test_inputs[i] = 8'b0;
    end
    
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    
    // Send zero inputs
    for (int i = 0; i < 32; i++) begin
      @(posedge clk);
      act_valid = 1'b1;
      act_in = 8'b0;
    end
    
    @(posedge clk);
    act_valid = 1'b0;
    
    // Wait for completion
    wait(done);
    $display("Zero input test completed");
  endtask
  
  // Test with maximum positive inputs
  task test_max_inputs();
    $display("Testing with maximum positive inputs...");
    
    layer_sel = 2'b01;
    
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    
    for (int i = 0; i < 32; i++) begin
      @(posedge clk);
      act_valid = 1'b1;
      act_in = 8'h7F; // Maximum positive 8-bit signed
    end
    
    @(posedge clk);
    act_valid = 1'b0;
    
    wait(done);
    $display("Maximum positive input test completed");
  endtask
  
  // Test with maximum negative inputs
  task test_min_inputs();
    $display("Testing with maximum negative inputs...");
    
    layer_sel = 2'b01;
    
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    
    for (int i = 0; i < 32; i++) begin
      @(posedge clk);
      act_valid = 1'b1;
      act_in = 8'h80; // Maximum negative 8-bit signed
    end
    
    @(posedge clk);
    act_valid = 1'b0;
    
    wait(done);
    $display("Maximum negative input test completed");
  endtask
  
  // Test start signal asserted during operation
  task test_start_during_operation();
    $display("Testing start during operation...");
    
    layer_sel = 2'b01;
    
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    
    // Send a few inputs
    for (int i = 0; i < 10; i++) begin
      @(posedge clk);
      act_valid = 1'b1;
      act_in = test_inputs[i];
    end
    
    // Assert start again during operation
    @(posedge clk);
    start = 1'b1;
    act_valid = 1'b0;
    @(posedge clk);
    start = 1'b0;
    
    // Continue with remaining inputs
    for (int i = 0; i < 32; i++) begin
      @(posedge clk);
      act_valid = 1'b1;
      act_in = test_inputs[i];
    end
    
    @(posedge clk);
    act_valid = 1'b0;
    
    wait(done);
    $display("Start during operation test completed");
  endtask
  
  // Test reset during operation
  task test_reset_during_operation();
    $display("\n--- Testing Reset During Operation ---");
    
    layer_sel = 2'b01;
    
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    
    // Send some inputs
    for (int i = 0; i < 15; i++) begin
      @(posedge clk);
      act_valid = 1'b1;
      act_in = test_inputs[i];
    end
    
    // Apply reset during operation
    $display("Applying reset during operation...");
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;
    #10;
    
    // Check that outputs are cleared
    if (res_valid !== 1'b0 || done !== 1'b0) begin
      $error("Reset during operation failed");
      error_count++;
    end else begin
      $display("Reset during operation successful");
    end
  endtask
  
  // Monitor for debugging
  always @(posedge clk) begin
    if (res_valid) begin
      $display("@%0t: res_valid=1, res_out=0x%05h (%0d)", 
               $time, res_out, $signed(res_out));
    end
    
    if (done) begin
      $display("@%0t: Operation completed (done=1)", $time);
    end
  end
  
  // Check for unexpected X/Z values
  always @(posedge clk) begin
    if (^res_out === 1'bX) begin
      $error("@%0t: res_out contains X values", $time);
      error_count++;
    end
    
    if (^{res_valid, done} === 1'bX) begin
      $error("@%0t: Control signals contain X values", $time);
      error_count++;
    end
  end

endmodule