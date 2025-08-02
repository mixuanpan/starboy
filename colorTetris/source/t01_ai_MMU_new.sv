// `default_nettype none
// module t01_ai_MMU ( //32x32 matrix multiplication unit
//   input logic clk,
//   input logic rst_n,
//   input logic start, 
//   input logic act_valid,
//   input logic [7:0] act_in,
//   output logic res_valid, // valid result 
//   output logic [17:0] res_out, // result output 
//   output logic done 
// );

//   // Layer state machine
//   typedef enum logic [1:0] {
//     LAYER0,
//     LAYER1,
//     LAYER2,
//     LAYER3
//   } layer_state_t;

//   // Processing state machine
//   typedef enum logic [1:0] {
//     IDLE,
//     MAC_PHASE,
//     BIAS_PHASE,
//     NEXT_LAYER
//   } state_t;
  
//   state_t state, next_state;
//   layer_state_t layer_state, next_layer_state;

//   // Weight and bias memories (4-bit packed) - Fixed indexing
//   logic [3:0] d0_w [0:127];   // Layer 0: 4×32 = 128 weights
//   logic [3:0] d0_b [0:31];    // Layer 0: 32 biases
//   logic [3:0] d1_w [0:1023];  // Layer 1: 32×32 = 1024 weights
//   logic [3:0] d1_b [0:31];    // Layer 1: 32 biases
//   logic [3:0] d2_w [0:1023];  // Layer 2: 32×32 = 1024 weights
//   logic [3:0] d2_b [0:31];    // Layer 2: 32 biases
//   logic [3:0] d3_w [0:31];    // Layer 3: 32×1 = 32 weights
//   logic [3:0] d3_b [0:0];     // Layer 3: 1 bias

//   initial begin 
//     $readmemh("dense_0_param0_int4.mem", d0_w); 
//     $readmemh("dense_0_param1_int4.mem", d0_b); 
//     $readmemh("dense_1_param0_int4.mem", d1_w); 
//     $readmemh("dense_1_param1_int4.mem", d1_b); 
//     $readmemh("dense_2_param0_int4.mem", d2_w); 
//     $readmemh("dense_2_param1_int4.mem", d2_b); 
//     $readmemh("dense_3_param0_int4.mem", d3_w); 
//     $readmemh("dense_3_param1_int4.mem", d3_b); 
//   end

//   // Counters and control signals
//   logic [5:0] mac_counter;    // 0-31 for MAC operations
//   logic [5:0] bias_counter;   // 0-31 for BIAS operations
//   logic [5:0] max_outputs;    // Number of outputs for current layer
//   logic [5:0] max_inputs;     // Number of inputs for current layer
  
//   // Accumulators - only need 32 for intermediate layers
//   logic signed [17:0] acc [0:31];
  
//   // Internal computation signals
//   logic signed [17:0] act_ext;     // sign-extended activation
//   logic signed [17:0] w_ext;       // sign-extended weight  
//   logic signed [35:0] full_prod;   // full 36-bit product
//   logic signed [17:0] prod_18bit;  // truncated 18-bit product
//   logic signed [17:0] tmp;         // bias addition result
//   logic signed [17:0] q;           // post-ReLU result

//   // Intermediate layer outputs for feeding to next layer
//   logic signed [17:0] layer_outputs [0:31];
//   logic [5:0] output_count;
//   logic layer_complete;

//   // Functions to get weights and biases directly from memory
//   function automatic [7:0] get_weight;
//     input [1:0] layer;
//     input [5:0] output_idx;
//     input [5:0] input_idx;
//     begin
//       case (layer)
//         2'b00: get_weight = {{4{d0_w[output_idx*4 + input_idx][3]}}, d0_w[output_idx*4 + input_idx]};
//         2'b01: get_weight = {{4{d1_w[output_idx*32 + input_idx][3]}}, d1_w[output_idx*32 + input_idx]};
//         2'b10: get_weight = {{4{d2_w[output_idx*32 + input_idx][3]}}, d2_w[output_idx*32 + input_idx]};
//         2'b11: get_weight = {{4{d3_w[input_idx[4:0]][3]}}, d3_w[input_idx[4:0]]};
//         default: get_weight = 8'b0;
//       endcase
//     end
//   endfunction

//   function automatic [17:0] get_bias;
//     input [1:0] layer;
//     input [5:0] output_idx;
//     begin
//       case (layer)
//         2'b00: get_bias = {{14{d0_b[output_idx[4:0]][3]}}, d0_b[output_idx[4:0]]};
//         2'b01: get_bias = {{14{d1_b[output_idx[4:0]][3]}}, d1_b[output_idx[4:0]]};
//         2'b10: get_bias = {{14{d2_b[output_idx[4:0]][3]}}, d2_b[output_idx[4:0]]};
//         2'b11: get_bias = {{14{d3_b[0][3]}}, d3_b[0]};
//         default: get_bias = 18'b0;
//       endcase
//     end
//   endfunction

//   // Set max outputs and inputs based on current layer
//   always_comb begin
//     case (layer_state)
//       2'b00: begin // Layer 0: 4 inputs, 32 outputs
//         max_outputs = 6'd32;
//         max_inputs = 6'd4;
//       end
//       2'b01: begin // Layer 1: 32 inputs, 32 outputs
//         max_outputs = 6'd32;
//         max_inputs = 6'd32;
//       end
//       2'b10: begin // Layer 2: 32 inputs, 32 outputs
//         max_outputs = 6'd32;
//         max_inputs = 6'd32;
//       end
//       2'b11: begin // Layer 3: 32 inputs, 1 output
//         max_outputs = 6'd1;
//         max_inputs = 6'd32;
//       end
//       default: begin
//         max_outputs = 6'd32;
//         max_inputs = 6'd32;
//       end
//     endcase
//   end

//   // Layer state machine sequential logic
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       layer_state <= LAYER0;
//     end else begin
//       layer_state <= next_layer_state;
//     end
//   end

//   // Layer state machine combinational logic
//   always_comb begin
//     next_layer_state = layer_state;
    
//     if (layer_complete) begin
//       case (layer_state)
//         LAYER0: next_layer_state = LAYER1;
//         LAYER1: next_layer_state = LAYER2;
//         LAYER2: next_layer_state = LAYER3;
//         LAYER3: next_layer_state = LAYER0; // Reset for next inference
//         default: next_layer_state = LAYER0;
//       endcase
//     end
//   end

//   // Main state machine sequential logic
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       state <= IDLE;
//       mac_counter <= 6'b0;
//       bias_counter <= 6'b0;
//       output_count <= 6'b0;
//     end else begin
//       state <= next_state;
      
//       case (state)
//         MAC_PHASE: begin
//           if (act_valid || (layer_state != LAYER0)) begin
//             mac_counter <= mac_counter + 1;
//           end
//         end
        
//         BIAS_PHASE: begin
//           bias_counter <= bias_counter + 1;
//           if (bias_counter < max_outputs) begin
//             output_count <= output_count + 1;
//           end
//         end
        
//         NEXT_LAYER: begin
//           mac_counter <= 6'b0;
//           bias_counter <= 6'b0;
//           output_count <= 6'b0;
//         end
        
//         default: begin
//           mac_counter <= 6'b0;
//           bias_counter <= 6'b0;
//           output_count <= 6'b0;
//         end
//       endcase
//     end
//   end

//   // Main state machine combinational logic
//   always_comb begin
//     next_state = state;
//     layer_complete = 1'b0;
    
//     case (state)
//       IDLE: begin
//         if (start && layer_state == 2'b00) begin
//           next_state = MAC_PHASE;
//         end else if (layer_state != 2'b00) begin
//           // Automatically start next layer processing
//           next_state = MAC_PHASE;
//         end
//       end
      
//       MAC_PHASE: begin
//         if ((layer_state == 2'b00 && act_valid && mac_counter == (max_inputs - 1)) ||
//             (layer_state != 2'b00 && mac_counter == (max_inputs - 1))) begin
//           next_state = BIAS_PHASE;
//         end
//       end
      
//       BIAS_PHASE: begin
//         if (bias_counter == (max_outputs - 1)) begin
//           if (layer_state == 2'b11) begin
//             next_state = IDLE;
//             layer_complete = 1'b1;
//           end else begin
//             next_state = NEXT_LAYER;
//             layer_complete = 1'b1;
//           end
//         end
//       end
      
//       NEXT_LAYER: begin
//         next_state = IDLE;
//       end
      
//       default: begin
//         next_state = IDLE;
//       end
//     endcase
//   end

//   // Accumulator management
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       acc[0] <= 18'b0; acc[1] <= 18'b0; acc[2] <= 18'b0; acc[3] <= 18'b0;
//       acc[4] <= 18'b0; acc[5] <= 18'b0; acc[6] <= 18'b0; acc[7] <= 18'b0;
//       acc[8] <= 18'b0; acc[9] <= 18'b0; acc[10] <= 18'b0; acc[11] <= 18'b0;
//       acc[12] <= 18'b0; acc[13] <= 18'b0; acc[14] <= 18'b0; acc[15] <= 18'b0;
//       acc[16] <= 18'b0; acc[17] <= 18'b0; acc[18] <= 18'b0; acc[19] <= 18'b0;
//       acc[20] <= 18'b0; acc[21] <= 18'b0; acc[22] <= 18'b0; acc[23] <= 18'b0;
//       acc[24] <= 18'b0; acc[25] <= 18'b0; acc[26] <= 18'b0; acc[27] <= 18'b0;
//       acc[28] <= 18'b0; acc[29] <= 18'b0; acc[30] <= 18'b0; acc[31] <= 18'b0;
//       layer_outputs[0] <= 18'b0; layer_outputs[1] <= 18'b0; layer_outputs[2] <= 18'b0; layer_outputs[3] <= 18'b0;
//       layer_outputs[4] <= 18'b0; layer_outputs[5] <= 18'b0; layer_outputs[6] <= 18'b0; layer_outputs[7] <= 18'b0;
//       layer_outputs[8] <= 18'b0; layer_outputs[9] <= 18'b0; layer_outputs[10] <= 18'b0; layer_outputs[11] <= 18'b0;
//       layer_outputs[12] <= 18'b0; layer_outputs[13] <= 18'b0; layer_outputs[14] <= 18'b0; layer_outputs[15] <= 18'b0;
//       layer_outputs[16] <= 18'b0; layer_outputs[17] <= 18'b0; layer_outputs[18] <= 18'b0; layer_outputs[19] <= 18'b0;
//       layer_outputs[20] <= 18'b0; layer_outputs[21] <= 18'b0; layer_outputs[22] <= 18'b0; layer_outputs[23] <= 18'b0;
//       layer_outputs[24] <= 18'b0; layer_outputs[25] <= 18'b0; layer_outputs[26] <= 18'b0; layer_outputs[27] <= 18'b0;
//       layer_outputs[28] <= 18'b0; layer_outputs[29] <= 18'b0; layer_outputs[30] <= 18'b0; layer_outputs[31] <= 18'b0;
//     end else begin
//       if (state == IDLE && next_state == MAC_PHASE) begin
//         // Clear accumulators when starting MAC phase
//         acc[0] <= 18'b0; acc[1] <= 18'b0; acc[2] <= 18'b0; acc[3] <= 18'b0;
//         acc[4] <= 18'b0; acc[5] <= 18'b0; acc[6] <= 18'b0; acc[7] <= 18'b0;
//         acc[8] <= 18'b0; acc[9] <= 18'b0; acc[10] <= 18'b0; acc[11] <= 18'b0;
//         acc[12] <= 18'b0; acc[13] <= 18'b0; acc[14] <= 18'b0; acc[15] <= 18'b0;
//         acc[16] <= 18'b0; acc[17] <= 18'b0; acc[18] <= 18'b0; acc[19] <= 18'b0;
//         acc[20] <= 18'b0; acc[21] <= 18'b0; acc[22] <= 18'b0; acc[23] <= 18'b0;
//         acc[24] <= 18'b0; acc[25] <= 18'b0; acc[26] <= 18'b0; acc[27] <= 18'b0;
//         acc[28] <= 18'b0; acc[29] <= 18'b0; acc[30] <= 18'b0; acc[31] <= 18'b0;
//       end else if (state == MAC_PHASE) begin
//         // Determine input source
//         if (layer_state == 2'b00 && act_valid) begin
//           // Layer 0: use external input
//           act_ext = {{10{act_in[7]}}, act_in};
//         end else if (layer_state != 2'b00) begin
//           // Layers 1-3: use stored outputs from previous layer
//           act_ext = layer_outputs[mac_counter[4:0]];
//         end else begin
//           act_ext = 18'b0;
//         end
        
//         // Perform MAC operations
//         if ((layer_state == 2'b00 && act_valid) || layer_state != 2'b00) begin
//           if (layer_state == 2'b11) begin
//             // Layer 3: Only accumulate for output 0
//             w_ext = {{10{{get_weight(layer_state, 6'd0, mac_counter)}[7]}}, get_weight(layer_state, 6'd0, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[0] <= acc[0] + prod_18bit;
//           end else begin
//             // Layers 0,1,2: Accumulate for all 32 outputs
//             w_ext = {{10{{get_weight(layer_state, 6'd0, mac_counter)}[7]}}, get_weight(layer_state, 6'd0, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[0] <= acc[0] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd1, mac_counter)}[7]}}, get_weight(layer_state, 6'd1, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[1] <= acc[1] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd2, mac_counter)}[7]}}, get_weight(layer_state, 6'd2, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[2] <= acc[2] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd3, mac_counter)}[7]}}, get_weight(layer_state, 6'd3, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[3] <= acc[3] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd4, mac_counter)}[7]}}, get_weight(layer_state, 6'd4, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[4] <= acc[4] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd5, mac_counter)}[7]}}, get_weight(layer_state, 6'd5, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[5] <= acc[5] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd6, mac_counter)}[7]}}, get_weight(layer_state, 6'd6, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[6] <= acc[6] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd7, mac_counter)}[7]}}, get_weight(layer_state, 6'd7, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[7] <= acc[7] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd8, mac_counter)}[7]}}, get_weight(layer_state, 6'd8, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[8] <= acc[8] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd9, mac_counter)}[7]}}, get_weight(layer_state, 6'd9, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[9] <= acc[9] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd10, mac_counter)}[7]}}, get_weight(layer_state, 6'd10, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[10] <= acc[10] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd11, mac_counter)}[7]}}, get_weight(layer_state, 6'd11, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[11] <= acc[11] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd12, mac_counter)}[7]}}, get_weight(layer_state, 6'd12, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[12] <= acc[12] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd13, mac_counter)}[7]}}, get_weight(layer_state, 6'd13, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[13] <= acc[13] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd14, mac_counter)}[7]}}, get_weight(layer_state, 6'd14, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[14] <= acc[14] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd15, mac_counter)}[7]}}, get_weight(layer_state, 6'd15, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[15] <= acc[15] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd16, mac_counter)}[7]}}, get_weight(layer_state, 6'd16, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[16] <= acc[16] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd17, mac_counter)}[7]}}, get_weight(layer_state, 6'd17, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[17] <= acc[17] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd18, mac_counter)}[7]}}, get_weight(layer_state, 6'd18, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[18] <= acc[18] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd19, mac_counter)}[7]}}, get_weight(layer_state, 6'd19, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[19] <= acc[19] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd20, mac_counter)}[7]}}, get_weight(layer_state, 6'd20, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[20] <= acc[20] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd21, mac_counter)}[7]}}, get_weight(layer_state, 6'd21, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[21] <= acc[21] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd22, mac_counter)}[7]}}, get_weight(layer_state, 6'd22, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[22] <= acc[22] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd23, mac_counter)}[7]}}, get_weight(layer_state, 6'd23, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[23] <= acc[23] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd24, mac_counter)}[7]}}, get_weight(layer_state, 6'd24, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[24] <= acc[24] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd25, mac_counter)}[7]}}, get_weight(layer_state, 6'd25, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[25] <= acc[25] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd26, mac_counter)}[7]}}, get_weight(layer_state, 6'd26, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[26] <= acc[26] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd27, mac_counter)}[7]}}, get_weight(layer_state, 6'd27, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[27] <= acc[27] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd28, mac_counter)}[7]}}, get_weight(layer_state, 6'd28, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[28] <= acc[28] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd29, mac_counter)}[7]}}, get_weight(layer_state, 6'd29, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[29] <= acc[29] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd30, mac_counter)}[7]}}, get_weight(layer_state, 6'd30, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[30] <= acc[30] + prod_18bit;
            
//             w_ext = {{10{{get_weight(layer_state, 6'd31, mac_counter)}[7]}}, get_weight(layer_state, 6'd31, mac_counter)};
//             full_prod = act_ext * w_ext;
//             prod_18bit = full_prod[17:0];
//             acc[31] <= acc[31] + prod_18bit;
//           end
//         end
//       end
//     end
//   end

//   // Output generation and layer output storage
//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       res_valid <= 1'b0;
//       res_out <= 18'b0;
//       done <= 1'b0;
//     end else begin
//       res_valid <= 1'b0;
//       done <= 1'b0;
      
//       if (state == BIAS_PHASE && bias_counter < max_outputs) begin
//         // Add bias and apply ReLU
//         tmp = acc[bias_counter[4:0]] + get_bias(layer_state, bias_counter);
//         q = (tmp[17]) ? 18'b0 : tmp;  // ReLU: if negative, output 0
        
//         // Store outputs for next layer (except final layer)
//         if (layer_state != 2'b11) begin
//           layer_outputs[bias_counter[4:0]] <= q;
//         end
        
//         // For final layer (LAYER3), output the result
//         if (layer_state == 2'b11) begin
//           res_out <= q;
//           res_valid <= 1'b1;
//         end
        
//         // Signal completion
//         if (bias_counter == (max_outputs - 1)) begin
//           if (layer_state == 2'b11) begin
//             done <= 1'b1;
//           end
//         end
//       end
//     end
//   end

// endmodule