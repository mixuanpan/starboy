// // =========================================================================
// // OPTIMIZED SYSTOLIC WEIGHT LOADER MODULE
// // Addresses timing issues and memory access inefficiencies
// // =========================================================================

// module t01_ai_wb_load #(
//   parameter ARRAY_SIZE = 8,
//   parameter MAX_LAYER_INPUTS = 32,
//   parameter MAX_LAYER_OUTPUTS = 32,
//   parameter WEIGHT_WIDTH = 8,
//   parameter ADDR_WIDTH = 12  // Enough for 4K weights per layer
// )(
//   input logic clk,
//   input logic rst_n,
  
//   // Control interface
//   input logic start_load,
//   input logic [1:0] layer_sel,
//   output logic load_done,
  
//   // Weight output to systolic array
//   output logic weight_load_enable,
//   output logic [2:0] weight_row,
//   output logic [2:0] weight_col,
//   output logic [WEIGHT_WIDTH-1:0] weight_data,
  
//   // Memory interface (connect to your weight ROM/RAM)
//   output logic [ADDR_WIDTH-1:0] mem_addr,
//   input logic [WEIGHT_WIDTH-1:0] mem_data
// );

//   // =========================================================================
//   // LAYER CONFIGURATIONS
//   // =========================================================================
  
//   // Layer dimensions: [inputs, outputs]
//   typedef struct packed {
//     logic [5:0] num_inputs;   // Max 32 inputs
//     logic [5:0] num_outputs;  // Max 32 outputs
//     logic [ADDR_WIDTH-1:0] base_addr;  // Starting address in memory
//   } layer_config_t;
  
//   layer_config_t layer_configs [4];
  
//   // Initialize layer configurations
//   initial begin
//     // Layer 0: 4 Tetris features → 32 outputs
//     layer_configs[0] = '{num_inputs: 6'd4, num_outputs: 6'd32, base_addr: 12'h000};
    
//     // Layer 1: 32 inputs → 32 outputs  
//     layer_configs[1] = '{num_inputs: 6'd32, num_outputs: 6'd32, base_addr: 12'h080};
    
//     // Layer 2: 32 inputs → 32 outputs
//     layer_configs[2] = '{num_inputs: 6'd32, num_outputs: 6'd32, base_addr: 12'h480};
    
//     // Layer 3: 32 inputs → 1 output
//     layer_configs[3] = '{num_inputs: 6'd32, num_outputs: 6'd1, base_addr: 12'h880};
//   end

//   // =========================================================================
//   // STATE MACHINE
//   // =========================================================================
  
//   typedef enum logic [2:0] {
//     IDLE,
//     READ_WEIGHT,
//     LOAD_WEIGHT,
//     INCREMENT,
//     DONE
//   } loader_state_t;
  
//   loader_state_t state, next_state;
  
//   // Counters and control
//   logic [5:0] input_idx, output_idx;
//   logic [5:0] max_inputs, max_outputs;
//   logic [ADDR_WIDTH-1:0] base_addr;
//   logic [2:0] load_delay_counter;
  
//   // Pipeline registers for better timing
//   logic [WEIGHT_WIDTH-1:0] weight_data_reg;
//   logic [2:0] weight_row_reg, weight_col_reg;
//   logic weight_enable_reg;
  
//   // =========================================================================
//   // LAYER CONFIGURATION LOGIC
//   // =========================================================================
  
//   always_comb begin
//     max_inputs = layer_configs[layer_sel].num_inputs;
//     max_outputs = layer_configs[layer_sel].num_outputs;
//     base_addr = layer_configs[layer_sel].base_addr;
//   end
  
//   // =========================================================================
//   // MEMORY ADDRESS CALCULATION
//   // =========================================================================
  
//   always_comb begin
//     // Address = base_addr + (output_idx * max_inputs) + input_idx
//     mem_addr = base_addr + (output_idx * max_inputs) + input_idx;
//   end
  
//   // =========================================================================
//   // STATE MACHINE LOGIC
//   // =========================================================================
  
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       state <= IDLE;
//       input_idx <= 6'b0;
//       output_idx <= 6'b0;
//       load_delay_counter <= 3'b0;
      
//       // Pipeline registers
//       weight_data_reg <= 8'b0;
//       weight_row_reg <= 3'b0;
//       weight_col_reg <= 3'b0;
//       weight_enable_reg <= 1'b0;
//     end else begin
//       state <= next_state;
      
//       case (state)
//         IDLE: begin
//           if (start_load) begin
//             input_idx <= 6'b0;
//             output_idx <= 6'b0;
//             load_delay_counter <= 3'b0;
//           end
//         end
        
//         READ_WEIGHT: begin
//           // Memory read takes 1 cycle, increment delay counter
//           load_delay_counter <= load_delay_counter + 1;
//         end
        
//         LOAD_WEIGHT: begin
//           // Pipeline the weight data for better timing
//           weight_data_reg <= mem_data;
//           weight_row_reg <= input_idx[2:0];  // Map to systolic array row
//           weight_col_reg <= output_idx[2:0]; // Map to systolic array col
//           weight_enable_reg <= 1'b1;
//           load_delay_counter <= 3'b0;
//         end
        
//         INCREMENT: begin
//           weight_enable_reg <= 1'b0;
          
//           if (input_idx < (max_inputs - 1)) begin
//             input_idx <= input_idx + 1;
//           end else begin
//             input_idx <= 6'b0;
//             if (output_idx < (max_outputs - 1)) begin
//               output_idx <= output_idx + 1;
//             end else begin
//               output_idx <= 6'b0;
//             end
//           end
//         end
        
//         DONE: begin
//           weight_enable_reg <= 1'b0;
//         end
//       endcase
//     end
//   end
  
//   // Next state logic
//   always_comb begin
//     next_state = state;
    
//     case (state)
//       IDLE: begin
//         if (start_load) begin
//           next_state = READ_WEIGHT;
//         end
//       end
      
//       READ_WEIGHT: begin
//         if (load_delay_counter >= 3'd1) begin  // Wait for memory read
//           next_state = LOAD_WEIGHT;
//         end
//       end
      
//       LOAD_WEIGHT: begin
//         next_state = INCREMENT;
//       end
      
//       INCREMENT: begin
//         if (input_idx == (max_inputs - 1) && output_idx == (max_outputs - 1)) begin
//           next_state = DONE;
//         end else begin
//           next_state = READ_WEIGHT;
//         end
//       end
      
//       DONE: begin
//         next_state = IDLE;
//       end
//     endcase
//   end
  
//   // =========================================================================
//   // OUTPUT ASSIGNMENTS
//   // =========================================================================
  
//   assign weight_load_enable = weight_enable_reg;
//   assign weight_row = weight_row_reg;
//   assign weight_col = weight_col_reg;
//   assign weight_data = weight_data_reg;
//   assign load_done = (state == DONE);

// endmodule

// // =========================================================================
// // WEIGHT MEMORY LAYOUT EXAMPLE
// // =========================================================================

// /*
// Memory Layout for Tetris AI Weights:

// Layer 0 (4 inputs × 32 outputs = 128 weights):
// Address 0x000-0x07F: W[0][0] to W[31][3]

// Layer 1 (32 inputs × 32 outputs = 1024 weights):  
// Address 0x080-0x47F: W[0][0] to W[31][31]

// Layer 2 (32 inputs × 32 outputs = 1024 weights):
// Address 0x480-0x87F: W[0][0] to W[31][31]

// Layer 3 (32 inputs × 1 output = 32 weights):
// Address 0x880-0x89F: W[0][0] to W[0][31]

// Total memory needed: ~2.2KB for all weights

// Weight Format:
// - 8-bit signed weights (-128 to +127)
// - Stored in row-major order: W[output][input]
// - Can be loaded from .mem file or initialized in ROM
// */

// // =========================================================================
// // INTEGRATION NOTES
// // =========================================================================

// /*
// Key Optimizations Implemented:

// 1. Pipeline Registers:
//    - Breaks up combinational paths for better timing
//    - weight_data_reg, weight_row_reg, weight_col_reg

// 2. Configurable Layer Dimensions:
//    - Handles different layer sizes efficiently
//    - Only loads necessary weights for each layer

// 3. Efficient Address Calculation:
//    - Simple base + offset addressing
//    - Minimizes combinational logic

// 4. Memory Read Timing:
//    - Accounts for memory read latency
//    - load_delay_counter prevents race conditions

// 5. Resource-Friendly:
//    - Uses BRAM-friendly access patterns
//    - Avoids large combinational unpacking

// Usage in your systolic array:
// 1. Connect mem_addr/mem_data to your weight ROM/RAM
// 2. The loader will automatically sequence through all weights
// 3. weight_load_enable pulses when each weight is ready
// 4. load_done signals when layer weights are fully loaded

// This addresses the timing violations and memory inefficiencies
// mentioned in your optimization discussion!
// */