// Integration of True Systolic Array with Tetris AI
// Shows how the 4 Tetris features flow through the network

module t01_ai_systolic_array (
  input logic clk,
  input logic rst,
  
  // From feature extraction
  input logic extract_ready,
  input logic [7:0] lines_cleared,
  input logic [7:0] holes,
  input logic [7:0] bumpiness,
  input logic [7:0] height_sum,
  
  // To game engine
  output logic ai_inference_done,
  output logic [17:0] ai_decision_score
);

  // =========================================================================
  // MULTI-LAYER SYSTOLIC ARRAY CONTROLLER
  // =========================================================================
  
  typedef enum logic [2:0] {
    IDLE,
    LOAD_WEIGHTS_L0,
    PROCESS_L0,
    LOAD_WEIGHTS_L1,
    PROCESS_L1,
    LOAD_WEIGHTS_L2,
    PROCESS_L2,
    LOAD_WEIGHTS_L3,
    PROCESS_L3,
    DONE
  } ai_controller_state_t;
  
  ai_controller_state_t ai_state, next_ai_state;
  
  // Systolic array interface
  logic systolic_start;
  logic [1:0] current_layer_sel;
  logic systolic_act_valid;
  logic [7:0] systolic_act_in;
  logic systolic_res_valid;
  logic [17:0] systolic_res_out;
  logic systolic_done;
  
  // Weight loader interface
  logic weight_load_start;
  logic weight_load_done;
  logic weight_load_enable;
  logic [2:0] weight_row, weight_col;
  logic [7:0] weight_data;
  
  // Feature input management
  logic [7:0] tetris_features [4];
  logic [2:0] feature_inject_counter;
  logic feature_injection_active;
  
  // Layer output storage
  logic [7:0] layer_results [32];
  logic [4:0] result_collect_counter;
  logic result_collection_active;
  
  // Store Tetris features when ready
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      for (int i = 0; i < 4; i++) tetris_features[i] <= 8'b0;
    end else if (extract_ready) begin
      tetris_features[0] <= lines_cleared;
      tetris_features[1] <= holes;
      tetris_features[2] <= bumpiness;
      tetris_features[3] <= height_sum;
    end
  end
  
  // =========================================================================
  // AI CONTROLLER STATE MACHINE
  // =========================================================================
  
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      ai_state <= IDLE;
      current_layer_sel <= 2'b00;
      feature_inject_counter <= 3'b0;
      result_collect_counter <= 5'b0;
      feature_injection_active <= 1'b0;
      result_collection_active <= 1'b0;
    end else begin
      ai_state <= next_ai_state;
      
      case (ai_state)
        PROCESS_L0: current_layer_sel <= 2'b00;
        PROCESS_L1: current_layer_sel <= 2'b01;
        PROCESS_L2: current_layer_sel <= 2'b10;
        PROCESS_L3: current_layer_sel <= 2'b11;
      endcase
      
      // Feature injection for Layer 0
      if (ai_state == PROCESS_L0 && !feature_injection_active) begin
        feature_injection_active <= 1'b1;
        feature_inject_counter <= 3'b0;
      end else if (feature_injection_active) begin
        if (feature_inject_counter < 3'd4) begin
          feature_inject_counter <= feature_inject_counter + 1;
        end else begin
          feature_injection_active <= 1'b0;
        end
      end
      
      // Result collection for Layers 0-2
      if (systolic_res_valid && (current_layer_sel != 2'b11)) begin
        if (!result_collection_active) begin
          result_collection_active <= 1'b1;
          result_collect_counter <= 5'b0;
        end
        
        if (result_collect_counter < 5'd31) begin
          layer_results[result_collect_counter] <= systolic_res_out[7:0];
          result_collect_counter <= result_collect_counter + 1;
        end
        
        if (result_collect_counter == 5'd31) begin
          result_collection_active <= 1'b0;
        end
      end
    end
  end
  
  // State transition logic
  always_comb begin
    next_ai_state = ai_state;
    systolic_start = 1'b0;
    weight_load_start = 1'b0;
    
    case (ai_state)
      IDLE: begin
        if (extract_ready) begin
          next_ai_state = LOAD_WEIGHTS_L0;
          weight_load_start = 1'b1;
        end
      end
      
      LOAD_WEIGHTS_L0: begin
        if (weight_load_done) begin
          next_ai_state = PROCESS_L0;
          systolic_start = 1'b1;
        end
      end
      
      PROCESS_L0: begin
        if (systolic_done) begin
          next_ai_state = LOAD_WEIGHTS_L1;
          weight_load_start = 1'b1;
        end
      end
      
      LOAD_WEIGHTS_L1: begin
        if (weight_load_done) begin
          next_ai_state = PROCESS_L1;
          systolic_start = 1'b1;
        end
      end
      
      PROCESS_L1: begin
        if (systolic_done) begin
          next_ai_state = LOAD_WEIGHTS_L2;
          weight_load_start = 1'b1;
        end
      end
      
      LOAD_WEIGHTS_L2: begin
        if (weight_load_done) begin
          next_ai_state = PROCESS_L2;
          systolic_start = 1'b1;
        end
      end
      
      PROCESS_L2: begin
        if (systolic_done) begin
          next_ai_state = LOAD_WEIGHTS_L3;
          weight_load_start = 1'b1;
        end
      end
      
      LOAD_WEIGHTS_L3: begin
        if (weight_load_done) begin
          next_ai_state = PROCESS_L3;
          systolic_start = 1'b1;
        end
      end
      
      PROCESS_L3: begin
        if (systolic_done) begin
          next_ai_state = DONE;
        end
      end
      
      DONE: begin
        next_ai_state = IDLE;
      end
    endcase
  end
  
  // =========================================================================
  // INPUT DATA MULTIPLEXING
  // =========================================================================
  
  always_comb begin
    systolic_act_valid = 1'b0;
    systolic_act_in = 8'b0;
    
    case (current_layer_sel)
      2'b00: begin // Layer 0: Feed Tetris features
        if (feature_injection_active && feature_inject_counter < 3'd4) begin
          systolic_act_valid = 1'b1;
          systolic_act_in = tetris_features[feature_inject_counter];
        end
      end
      
      default: begin // Layers 1-3: Feed previous layer results
        if (result_collection_active) begin
          systolic_act_valid = 1'b1;
          if (result_collect_counter < 5'd31) begin
            systolic_act_in = layer_results[result_collect_counter];
          end
        end
      end
    endcase
  end
  
  // =========================================================================
  // OUTPUT HANDLING
  // =========================================================================
  
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      ai_inference_done <= 1'b0;
      ai_decision_score <= 18'b0;
    end else begin
      ai_inference_done <= 1'b0;
      
      // Capture final result from Layer 3
      if (current_layer_sel == 2'b11 && systolic_res_valid) begin
        ai_decision_score <= systolic_res_out;
        ai_inference_done <= 1'b1;
      end
    end
  end

  // Weight loader
  t01_ai_wb_load weight_loader (
    .clk(clk),
    .rst_n(!rst),
    .start_load(weight_load_start),
    .layer_sel(current_layer_sel),
    
    .weight_load_enable(weight_load_enable),
    .weight_row(weight_row),
    .weight_col(weight_col),
    .weight_data(weight_data),
    .load_done(weight_load_done),
    
    .mem_addr(), // Connect to your memory
    .mem_data()  // Connect to your memory
  );
endmodule


// =========================================================================
// PROCESSING FLOW VISUALIZATION
// =========================================================================

/*
Layer 0 Processing:
Input: [lines_cleared, holes, bumpiness, height_sum] (4 values)
↓ (4×32 weight matrix)
Output: [32 intermediate features]

Layer 1 Processing:  
Input: [32 intermediate features from Layer 0]
↓ (32×32 weight matrix)
Output: [32 refined features]

Layer 2 Processing:
Input: [32 refined features from Layer 1]  
↓ (32×32 weight matrix)
Output: [32 final features]

Layer 3 Processing:
Input: [32 final features from Layer 2]
↓ (32×1 weight matrix)
Output: [1 decision score] ← This is your AI's move evaluation!

Key Benefits:
1. Only 4 feature calculations needed (done once in feature extraction)
2. All subsequent layers just process neural network weights
3. Systolic array provides massive parallelism for matrix operations
4. Final score directly usable by your game engine
*/