`default_nettype none
module t01_ai_MMU ( //32x32 matrix multiplication unit
  input logic clk,
  input logic rst_n,
  input logic start, 
  input logic [1:0] layer_sel, 
  input logic act_valid,
  input logic [7:0]  act_in,
  output logic res_valid,
  output logic [17:0] res_out,
  output logic done 
);

  // Weight and bias memories (4-bit packed)
  logic [3:0] d0_w [1:128];
  logic [3:0] d0_b [1:32];
  logic [3:0] d1_w [1:1024]; 
  logic [3:0] d1_b [1:32];
  logic [3:0] d2_w [1:1024];
  logic [3:0] d2_b [1:32];
  logic [3:0] d3_w [1:32];
  logic [3:0] d3_b [1:1];  // Fixed: Single element at index 1

  // my goat MIXUAN PAN 
  initial begin 
    $readmemh("dense_0_param0_int4.mem", d0_w, 1, 128); 
    $readmemh("dense_0_param1_int4.mem", d0_b, 1, 32); 
    $readmemh("dense_1_param0_int4.mem", d1_w, 1, 1024); 
    $readmemh("dense_1_param1_int4.mem", d1_b, 1, 32); 
    $readmemh("dense_2_param0_int4.mem", d2_w, 1, 1024); 
    $readmemh("dense_2_param1_int4.mem", d2_b, 1, 32); 
    $readmemh("dense_3_param0_int4.mem", d3_w, 1, 32); 
    $readmemh("dense_3_param1_int4.mem", d3_b, 1, 1); 
  end

  // Unpacked weight and bias arrays
  logic signed [7:0]  W [32][32]; // weights sign-extended to 8 bits
  logic signed [17:0] B [32]; // biases sign-extended to 18 bits

  // State machine
  typedef enum logic [1:0] {
    IDLE,
    MAC_PHASE,
    BIAS_PHASE
  } state_t;
  
  state_t state, next_state;
  
  logic [5:0] mac_counter;   // 0-31 for MAC (6 bits to match max_inputs)
  logic [5:0] bias_counter;  // 0-31 for BIAS (6 bits to match max_outputs)
  logic [5:0] max_outputs;   // Number of outputs for current layer (6 bits for value 32)
  logic [5:0] max_inputs;    // Number of inputs for current layer (6 bits for value 32)
  
  // Accumulators
  logic signed [17:0] acc [32];
  
  // Internal signals
  logic signed [17:0] act_ext; // sign-extended activation
  logic signed [17:0] w_ext; // sign-extended weight  
  logic signed [35:0] full_prod; // full 36-bit product
  logic signed [17:0] prod_18bit; // truncated 18-bit product
  logic signed [17:0] tmp; // bias addition result
  logic signed [17:0] q; // post-ReLU result

  // Set max outputs and inputs based on layer
  always_comb begin
    case (layer_sel)
      2'b00: begin // Layer 0: 4 inputs, 32 outputs
        max_outputs = 6'd32;
        max_inputs = 6'd4;
      end
      2'b01: begin // Layer 1: 32 inputs, 32 outputs
        max_outputs = 6'd32;
        max_inputs = 6'd32;
      end
      2'b10: begin // Layer 2: 32 inputs, 32 outputs
        max_outputs = 6'd32;
        max_inputs = 6'd32;
      end
      2'b11: begin // Layer 3: 32 inputs, 1 output
        max_outputs = 6'd1;
        max_inputs = 6'd32;
      end
      default: begin
        max_outputs = 6'd32;
        max_inputs = 6'd32;
      end
    endcase
  end

  // data unpacking based on layer_sel
  always_comb begin
    for (int i = 0; i < 32; i++) begin // sorry team
      for (int j = 0; j < 32; j++) begin
        W[i][j] = 8'b0;
      end
      B[i] = 18'b0;
    end
    
    case (layer_sel)
      2'b00: begin // layer 0: 4×32 weights (4 inputs, 32 outputs)
        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 4; j++) begin
            W[i][j] = {{4{d0_w[i*4 + j + 1][3]}}, d0_w[i*4 + j + 1]};
          end
          B[i] = {{14{d0_b[i + 1][3]}}, d0_b[i + 1]};
        end
      end
      
      2'b01: begin // layer 1: 32×32 weights
        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 32; j++) begin
            W[i][j] = {{4{d1_w[i*32 + j + 1][3]}}, d1_w[i*32 + j + 1]};
          end
          B[i] = {{14{d1_b[i + 1][3]}}, d1_b[i + 1]};
        end
      end
      
      2'b10: begin // layer 2: 32×32 weights  
        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 32; j++) begin
            W[i][j] = {{4{d2_w[i*32 + j + 1][3]}}, d2_w[i*32 + j + 1]};
          end
          B[i] = {{14{d2_b[i + 1][3]}}, d2_b[i + 1]};
        end
      end
      
      2'b11: begin // layer 3: 32×1 weights (32 inputs, 1 output) 
        for (int j = 0; j < 32; j++) begin
          W[0][j] = {{4{d3_w[j + 1][3]}}, d3_w[j + 1]};
        end
        B[0] = {{14{d3_b[1][3]}}, d3_b[1]};  // Fixed: Use index 1
      end
    endcase
  end

  // state machine sequential logic
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      mac_counter <= 6'b0;
      bias_counter <= 6'b0;
    end else begin
      state <= next_state;
      
      case (state)
        MAC_PHASE: begin
          if (act_valid) begin
            mac_counter <= mac_counter + 1;
          end
        end
        
        BIAS_PHASE: begin
          bias_counter <= bias_counter + 1;
        end
        
        default: begin
          mac_counter <= 6'b0;
          bias_counter <= 6'b0;
        end
      endcase
    end
  end

  // state machine combinational logic
  always_comb begin
    next_state = state;
    
    case (state)
      IDLE: begin
        if (start) begin
          next_state = MAC_PHASE;
        end
      end
      
      MAC_PHASE: begin
        if (act_valid && mac_counter == (max_inputs - 1)) begin  // Use max_inputs
          next_state = BIAS_PHASE;
        end
      end
      
      BIAS_PHASE: begin
        if (bias_counter == (max_outputs - 1)) begin  // Fixed: Use max_outputs
          next_state = IDLE;
        end
      end
      
      default: begin
        next_state = IDLE;
      end
    endcase
  end

  // accumulator management
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 32; i++) begin
        acc[i] <= 18'b0;
      end
    end else begin
      if (start) begin
        // clear accumulators on start
        for (int i = 0; i < 32; i++) begin
          acc[i] <= 18'b0;
        end
      end else if (state == MAC_PHASE && act_valid) begin
        act_ext = {{10{act_in[7]}}, act_in};  // sign-extend activation to 18 bits
        
        // Fixed: Only accumulate for valid outputs
        if (layer_sel == 2'b11) begin
          // Layer 3: Only accumulate for output 0
          w_ext = {{10{W[0][mac_counter[4:0]][7]}}, W[0][mac_counter[4:0]]};  // Cast to 5 bits for array indexing
          full_prod = act_ext * w_ext;
          prod_18bit = full_prod[17:0];
          acc[0] <= acc[0] + prod_18bit;
        end else begin
          // Layers 0,1,2: Accumulate for all 32 outputs
          for (int i = 0; i < 32; i++) begin
            w_ext = {{10{W[i][mac_counter[4:0]][7]}}, W[i][mac_counter[4:0]]};  // Cast to 5 bits for array indexing
            full_prod = act_ext * w_ext;
            prod_18bit = full_prod[17:0];
            acc[i] <= acc[i] + prod_18bit;
          end
        end
      end
    end
  end

  // output generation
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      res_valid <= 1'b0;
      res_out <= 18'b0;
      done <= 1'b0;
    end else begin
      res_valid <= 1'b0;
      done <= 1'b0;
      
      if (state == BIAS_PHASE && bias_counter < max_outputs) begin  // Fixed: Check bounds
        // add bias and apply ReLU
        tmp = acc[bias_counter[4:0]] + B[bias_counter[4:0]];  // Cast to 5 bits for array indexing
        q = (tmp[17]) ? 18'b0 : tmp;  // ReLU: if negative, output 0
        
        res_out <= q;
        res_valid <= 1'b1;
        
        if (bias_counter == (max_outputs - 1)) begin  // Fixed: Use max_outputs
          done <= 1'b1;
        end
      end
    end
  end

endmodule