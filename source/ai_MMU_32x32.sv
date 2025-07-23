`default_nettype none

/////////////////////////////////////////////////////////////////
//
// 
// Module : ai_MMU_32x32
// Description : 32×32 Broadcast-MAC MMU for AI accelerator
//               
//
/////////////////////////////////////////////////////////////////

module ai_MMU_32x32 #(
  parameter int IN_DIM = 32, // number of inputs per neuron
  parameter int OUT_DIM = 32, // number of neurons
  parameter int AW = 8, // activation width (bits)
  parameter int WW = 4, // weight width (bits)
  parameter int ACCW = 18 // accumulator width (bits) >= AW+WW+log2(IN_DIM)
) (
  input logic clk,
  input logic reset,
  input logic start, 
  input logic [1:0] layer_sel, // layer selection  
  input logic act_valid, 
  input logic [AW-1:0] act_in, 

  // results ;33 
  output logic res_valid,  
  output logic [ACCW-1:0] res_out, // the dot-product + bias + ReLU per neuron
  output logic done // Pulses high when last res_out emitted
);

    logic [7:0] d0_w_packed [1:64]; // dense_0: 4×32 weights 
    logic [7:0] d0_b_packed [1:16]; // dense_0: 32 biases 
    logic [7:0] d1_w_packed [1:512]; // dense_1: 32×32 weights 
    logic [7:0] d1_b_packed [1:16]; // dense_1: 32 biases
    logic [7:0] d2_w_packed [1:512]; // dense_2: 32×32 weights 
    logic [7:0] d2_b_packed [1:16]; // dense_2: 32 biases
    logic [7:0] d3_w_packed [1:16]; // dense_3: 32×1 weights 
    logic [7:0] d3_b_packed; // dense_3: 1 bias (single byte, only high 4 bits used)
      
    // shoutout mixuan pan
    initial begin
        $readmemh("dense_0_param0_int4.mem", d0_w_packed, 1, 64);
        $readmemh("dense_0_param1_int4.mem", d0_b_packed, 1, 16);
        $readmemh("dense_1_param0_int4.mem", d1_w_packed, 1, 512);
        $readmemh("dense_1_param1_int4.mem", d1_b_packed, 1, 16);
        $readmemh("dense_2_param0_int4.mem", d2_w_packed, 1, 512);
        $readmemh("dense_2_param1_int4.mem", d2_b_packed, 1, 16);
        $readmemh("dense_3_param0_int4.mem", d3_w_packed, 1, 16);
        $readmemh("dense_3_param1_int4.mem", d3_b_packed);
    end

    // unpack weight and bias arrays for current layer
    logic signed [WW-1:0] current_weights [0:OUT_DIM-1][0:IN_DIM-1];
    logic signed [ACCW-1:0] current_biases [0:OUT_DIM-1];

    // function to unpack 4-bit signed value from byte
    function automatic logic signed [WW-1:0] unpack_weight(input logic [7:0] packed_byte, input logic high_nibble);
        logic [3:0] nibble;
        nibble = high_nibble ? packed_byte[7:4] : packed_byte[3:0];
        unpack_weight = {{(WW-4){nibble[3]}}, nibble};
    endfunction

    // function to unpack 4-bit signed bias and extend to ACCW bits
    function automatic logic signed [ACCW-1:0] unpack_bias(input logic [7:0] packed_byte, input logic high_nibble);
        logic [3:0] nibble;
        nibble = high_nibble ? packed_byte[7:4] : packed_byte[3:0];
        unpack_bias = {{(ACCW-4){nibble[3]}}, nibble};
    endfunction

    // unpack weights and biases based on layer selection
    always_comb begin
        for (int i = 0; i < OUT_DIM; i++) begin
            for (int j = 0; j < IN_DIM; j++) begin // i LOVE nested for loops :D
                current_weights[i][j] = 4'b0;
            end
            current_biases[i] = {ACCW{1'b0}};
        end

        case (layer_sel)
            2'b00: begin // dense_0: 4×32 (
                for (int i = 0; i < OUT_DIM; i++) begin
                    for (int j = 0; j < 4; j++) begin  
                        int packed_idx = (i * 2) + (j / 2) + 1;  
                        logic high_nibble = (j % 2 == 0);
                        current_weights[i][j] = unpack_weight(d0_w_packed[packed_idx], high_nibble);
                    end
                    // unpack bias
                    int bias_packed_idx = (i / 2) + 1;  // +1 for 1-based indexing
                    logic bias_high_nibble = (i % 2 == 0);
                    current_biases[i] = unpack_bias(d0_b_packed[bias_packed_idx], bias_high_nibble);
                end
            end
           
            2'b01: begin // dense_1: 32×32
                for (int i = 0; i < OUT_DIM; i++) begin
                    for (int j = 0; j < IN_DIM; j++) begin
                        int weight_idx = i * IN_DIM + j;  // linear weight index
                        int packed_idx = (weight_idx / 2) + 1;  // +1 for 1-based indexing
                        logic high_nibble = (weight_idx % 2 == 0);
                        current_weights[i][j] = unpack_weight(d1_w_packed[packed_idx], high_nibble);
                    end
                    // unpack bias
                    int bias_packed_idx = (i / 2) + 1;  // +1 for 1-based indexing
                    logic bias_high_nibble = (i % 2 == 0);
                    current_biases[i] = unpack_bias(d1_b_packed[bias_packed_idx], bias_high_nibble);
                end
            end
           
            2'b10: begin // dense_2: 32×32
                for (int i = 0; i < OUT_DIM; i++) begin
                    for (int j = 0; j < IN_DIM; j++) begin
                        int weight_idx = i * IN_DIM + j;  // linear weight index
                        int packed_idx = (weight_idx / 2) + 1;  // +1 for 1-based indexing
                        logic high_nibble = (weight_idx % 2 == 0);
                        current_weights[i][j] = unpack_weight(d2_w_packed[packed_idx], high_nibble);
                    end
                    // unpack bias
                    int bias_packed_idx = (i / 2) + 1;  // +1 for 1-based indexing
                    logic bias_high_nibble = (i % 2 == 0);
                    current_biases[i] = unpack_bias(d2_b_packed[bias_packed_idx], bias_high_nibble);
                end
            end
           
            2'b11: begin // dense_3: 32×1 (output layer)
                for (int i = 0; i < OUT_DIM; i++) begin
                    // only first input (j=0) has weights for output layer
                    int packed_idx = (i / 2) + 1;  // +1 for 1-based indexing
                    logic high_nibble = (i % 2 == 0);
                    current_weights[i][0] = unpack_weight(d3_w_packed[packed_idx], high_nibble);
                   
                    // single bias for output
                    if (i == 0) begin
                        current_biases[i] = unpack_bias(d3_b_packed, 1'b1);  // use high nibble
                    end else begin
                        current_biases[i] = {ACCW{1'b0}};
                    end
                end
            end
        endcase
    end

    // 32×32 pe array with accumulators
    logic signed [ACCW-1:0] acc [0:OUT_DIM-1][0:IN_DIM-1];  // 32×32 accumulators
   
    // control state machien
    typedef enum logic [1:0] {
        IDLE,
        MAC,
        BIAS
    } state_t;
   
    state_t state, next_state;
    logic [5:0] cycle_cnt;

    // state machine sequential logic
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cycle_cnt <= 6'b0;
        end else begin
            state <= next_state;
           
            case (state)
                IDLE: begin
                    if (start) begin
                        cycle_cnt <= 6'b0;
                    end
                end
               
                MAC: begin
                    if (act_valid) begin
                        if (cycle_cnt < IN_DIM-1) begin
                            cycle_cnt <= cycle_cnt + 1;
                        end else begin
                            cycle_cnt <= 6'b0;
                        end
                    end
                end
               
                BIAS: begin
                    if (cycle_cnt < OUT_DIM-1) begin
                        cycle_cnt <= cycle_cnt + 1;
                    end else begin
                        cycle_cnt <= 6'b0;
                    end
                end
            endcase
        end
    end

    // state machine combinational logic
    always_comb begin
        next_state = state;
       
        case (state)
            IDLE: begin
                if (start) next_state = MAC;
            end
           
            MAC: begin
                if (cycle_cnt == IN_DIM-1 && act_valid) begin
                    next_state = BIAS;
                end
            end
           
            BIAS: begin
                if (cycle_cnt == OUT_DIM-1) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // sign extend activation for arithmetic
    logic signed [ACCW-1:0] act_extended;
    assign act_extended = {{(ACCW-AW){act_in[AW-1]}}, act_in};

    // 32×32 Processing Element Array
    genvar i, j;
    generate
        for (i = 0; i < OUT_DIM; i++) begin : PE_ROWS  // i = output neuron index (0-31)
            for (j = 0; j < IN_DIM; j++) begin : PE_COLS  // j = input feature index (0-31)
               
                // each PE has its own accumulator and processes one weight
                always_ff @(posedge clk, posedge reset) begin
                    if (reset) begin
                        acc[i][j] <= {ACCW{1'b0}};
                    end else if (start) begin
                        // clear all accumulators when starting new inference
                        acc[i][j] <= {ACCW{1'b0}};
                    end else if (state == MAC && act_valid && cycle_cnt == j) begin
                        // mac operation when input cycle 
                        logic signed [ACCW-1:0] weight_extended;
                        weight_extended = {{(ACCW-WW){current_weights[i][j][WW-1]}}, current_weights[i][j]};
                        acc[i][j] <= acc[i][j] + (act_extended * weight_extended);
                    end
                end
               
            end
        end
    endgenerate

    // sum accumulators for each neuron
    logic signed [ACCW-1:0] neuron_sum [0:OUT_DIM-1];
    logic signed [ACCW-1:0] neuron_biased [0:OUT_DIM-1];
    logic signed [ACCW-1:0] neuron_relu [0:OUT_DIM-1];

    generate
        for (i = 0; i < OUT_DIM; i++) begin : NEURON_SUM
            always_comb begin
                neuron_sum[i] = {ACCW{1'b0}};
                for (int k = 0; k < IN_DIM; k++) begin
                    neuron_sum[i] += acc[i][k];
                end
            end

            // add bias
            assign neuron_biased[i] = neuron_sum[i] + current_biases[i];

            // apply ReLU (except for output layer)
            assign neuron_relu[i] = (layer_sel == 2'b11) ? neuron_biased[i] :  // no ReLU on output layer
                                  (neuron_biased[i][ACCW-1]) ? {ACCW{1'b0}} : neuron_biased[i];
        end
    endgenerate

    // output control
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            res_valid <= 1'b0;
            res_out <= {ACCW{1'b0}};
            done <= 1'b0;
        end else begin
            // output results during BIAS phase
            res_valid <= (state == BIAS);
            res_out <= (state == BIAS) ? neuron_relu[cycle_cnt] : {ACCW{1'b0}};
            done <= (state == BIAS && cycle_cnt == OUT_DIM-1); // done signal
        end
    end

endmodule