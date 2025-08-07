// // ============================================================================
// // 3. OPTIMIZED MMU MODULE
// // ============================================================================

// // Additional optimization suggestions:
// // 1. Consider quantization to INT8 or lower for better resource utilization
// // 2. Implement weight compression/sparsity if many weights are zero
// // 3. Add configurable precision for different layers
// // 4. Consider systolic array implementation for maximum throughput 

// module t01_ai_MMU_optimized (
//   input logic clk,
//   input logic rst_n,
//   input logic start,
//   input logic [1:0] layer_sel,
//   input logic act_valid,
//   input logic [7:0] act_in,
//   output logic res_valid,
//   output logic [17:0] res_out,
//   output logic done
// );

//   // ========================================================================
//   // MEMORY OPTIMIZATION: Use Block RAM inference
//   // ========================================================================
  
//   // Packed memory arrays for better BRAM inference
//   typedef struct {
//     logic [3:0] w [1024]; // Max weights per layer
//     logic [3:0] b [32];   // Max biases per layer
//   } layer_params_t;
//   // layer_params_t layer_mem [4]; // One for each layer

//   typedef struct packed {
//     logic [1023:0][3:0] w; // weights and biases
//     logic [31:0][3:0] b;   
//   } layer_t;
//   layer_t layer_mem[4]; 
//   // typedef struct packed {
//   //   layer_t w_b [1024];  
//   //   // layer_t w_b.b [32]; 
//   // } layer_p_t; 
//   // layer_p_t layer_mem[4]; 

//   initial begin
//     $readmemh("dense_0_param0_int4.mem", layer_mem[0].w, 1, 128);
//     $readmemh("dense_0_param1_int4.mem", layer_mem[0].w_b.b, 1, 32);
//     $readmemh("dense_1_param0_int4.mem", layer_mem[0].w_b.w, 1, 1024);
//     $readmemh("dense_1_param1_int4.mem", layer_mem[0].w_b.w, 1, 32);
//     $readmemh("dense_2_param0_int4.mem", layer_mem[0].w_b.w, 1, 1024);
//     $readmemh("dense_2_param1_int4.mem", layer_mem[0].w_b.w, 1, 32);
//     $readmemh("dense_3_param0_int4.mem", layer_mem[0].w_b.w, 1, 32);
//     $readmemh("dense_3_param1_int4.mem", layer_mem[0].w_b.w, 1, 1);
//   end

//   // ========================================================================
//   // PIPELINE OPTIMIZATION: 3-stage pipeline
//   // ========================================================================
  
//   typedef enum logic [2:0] {
//     IDLE,
//     FETCH_WEIGHTS,
//     MAC_PHASE,
//     BIAS_PHASE
//   } state_t;

//   state_t state, next_state;
  
//   // Pipeline registers
//   logic [7:0] act_pipe [3];
//   logic [7:0] weight_pipe [3];
//   logic [17:0] acc_pipe [3];
//   logic valid_pipe [3];
  
//   // Counters
//   logic [5:0] mac_counter;
//   logic [5:0] bias_counter;
//   logic [5:0] weight_addr;
  
//   // Configuration based on layer
//   logic [5:0] max_outputs, max_inputs;
//   logic [9:0] weight_base_addr;
  
//   always_comb begin
//     case (layer_sel)
//       2'b00: begin max_outputs = 32; max_inputs = 4;  weight_base_addr = 0;   end
//       2'b01: begin max_outputs = 32; max_inputs = 32; weight_base_addr = 0;   end  
//       2'b10: begin max_outputs = 32; max_inputs = 32; weight_base_addr = 0;   end
//       2'b11: begin max_outputs = 1;  max_inputs = 32; weight_base_addr = 0;   end
//       default: begin max_outputs = 32; max_inputs = 32; weight_base_addr = 0; end
//     endcase
//   end

//   // ========================================================================
//   // PARALLEL MAC UNITS (4 parallel multipliers)
//   // ========================================================================
  
//   localparam NUM_MAC_UNITS = 4;
  
//   logic signed [17:0] mac_results [NUM_MAC_UNITS];
//   logic [7:0] weights_parallel [NUM_MAC_UNITS];
//   logic mac_valid [NUM_MAC_UNITS];
  
//   // Generate parallel MAC units
//   genvar i;
//   generate
//     for (i = 0; i < NUM_MAC_UNITS; i++) begin : mac_units
//       always_ff @(posedge clk) begin
//         if (act_valid && (mac_counter % NUM_MAC_UNITS == i)) begin
//           mac_results[i] <= $signed(act_in) * $signed(weights_parallel[i]);
//           mac_valid[i] <= 1'b1;
//         end else begin
//           mac_valid[i] <= 1'b0;
//         end
//       end
//     end
//   endgenerate

//   // ========================================================================
//   // OPTIMIZED ACCUMULATOR ARRAY with reduction tree
//   // ========================================================================
  
//   logic signed [17:0] acc [32];
//   logic signed [17:0] partial_sums [4];
  
//   // Reduction tree for parallel accumulation
//   always_comb begin
//     for (int j = 0; j < NUM_MAC_UNITS; j++) begin
//       partial_sums[j] = mac_valid[j] ? mac_results[j] : 18'b0;
//     end
//   end
  
//   // Main accumulator update
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       for (int j = 0; j < 32; j++) acc[j] <= 18'b0;
//     end else if (start) begin
//       for (int j = 0; j < 32; j++) acc[j] <= 18'b0;
//     end else if (state == MAC_PHASE && act_valid) begin
//       // Parallel accumulation with reduction
//       for (int j = 0; j < NUM_MAC_UNITS; j++) begin
//         if (mac_valid[j] && (({26'b0, mac_counter}/NUM_MAC_UNITS + j) < max_outputs)) begin
//           acc[{26'b0, mac_counter}/NUM_MAC_UNITS + j] <= acc[{26'b0, mac_counter}/NUM_MAC_UNITS + j] + partial_sums[j];
//         end
//       end
//     end
//   end

//   // ========================================================================
//   // OPTIMIZED STATE MACHINE with early termination
//   // ========================================================================
  
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       state <= IDLE;
//       mac_counter <= 6'b0;
//       bias_counter <= 6'b0;
//     end else begin
//       state <= next_state;
      
//       case (state)
//         MAC_PHASE: if (act_valid) mac_counter <= mac_counter + 1;
//         BIAS_PHASE: bias_counter <= bias_counter + 1;
//         default: begin
//           mac_counter <= 6'b0;
//           bias_counter <= 6'b0;
//         end
//       endcase
//     end
//   end

//   always_comb begin
//     next_state = state;
    
//     case (state)
//       IDLE: if (start) next_state = MAC_PHASE;
      
//       MAC_PHASE: begin
//         if (act_valid && mac_counter >= (max_inputs - 1)) begin
//           next_state = BIAS_PHASE;
//         end
//       end
      
//       BIAS_PHASE: begin
//         if (bias_counter >= (max_outputs - 1)) begin
//           next_state = IDLE;
//         end
//       end
//       default: ;
//     endcase
//   end

//   // ========================================================================
//   // OPTIMIZED OUTPUT with saturation and early ReLU
//   // ========================================================================
  
//   logic signed [17:0] bias_value, result_with_bias, relu_result;
  
//   // Pipeline bias addition and ReLU for better timing
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       res_valid <= 1'b0;
//       res_out <= 18'b0;
//       done <= 1'b0;
//     end else begin
//       res_valid <= 1'b0;
//       done <= 1'b0;
      
//       if (state == BIAS_PHASE && bias_counter < max_outputs) begin
//         // Get bias value
//         bias_value = {{14{layer_mem[layer_sel].b[bias_counter + 1][3]}}, layer_mem[layer_sel].b[bias_counter + 1]};
        
//         // Add bias with saturation check
//         result_with_bias = acc[bias_counter[4:0]] + bias_value;
        
//         // Apply ReLU with optimization for positive numbers
//         relu_result = (result_with_bias[17]) ? 18'b0 : result_with_bias;
        
//         res_out <= relu_result;
//         res_valid <= 1'b1;
        
//         if (bias_counter == (max_outputs - 1)) begin
//           done <= 1'b1;
//         end
//       end
//     end
//   end

// endmodule