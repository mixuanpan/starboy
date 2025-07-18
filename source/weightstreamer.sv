module weight_streaming_controller #(
    parameter int BYTES = 1153,
    parameter string MEMFILE = "all_layers.mem"
)(
    input  logic clk,
    input  logic rst,
    input  logic [1:0] layer_select, // 0=dense, 1=dense_1, 2=dense_2, 3=dense_3
    input  logic start_streaming,
    output logic streaming_done,
    output logic [7:0] weights_out [15:0],
    output logic weights_valid,
    output logic [7:0] bias_out,
    output logic bias_valid,
    output logic [4:0] bias_addr // Which neuron this bias belongs to
);

// Layer configuration table
typedef struct packed {
    logic [10:0] weight_start_addr; // Starting byte address in ROM
    logic [10:0] weight_end_addr; // Ending byte address
    logic [10:0] bias_start_addr; // Bias starting address
    logic [4:0] input_size; // Input dimension
    logic [4:0] output_size; // Output dimension
    logic [4:0] weights_per_byte; // Always 2 for 4-bit weights
} layer_config_t;

// Layer configuration lookup table
layer_config_t layer_configs [4] = '{
    //dense (4x32 = 128 weights + 32 biases)
    '{weight_start_addr: 11'd0,   weight_end_addr: 11'd63,   bias_start_addr: 11'd64,   input_size: 5'd4,  output_size: 5'd31, weights_per_byte: 5'd2},
    //dense_1 (32x32 = 1024 weights + 32 biases)  
    '{weight_start_addr: 11'd80,  weight_end_addr: 11'd591,  bias_start_addr: 11'd592,  input_size: 5'd31, output_size: 5'd31, weights_per_byte: 5'd2},
    //dense_2 (32x32 = 1024 weights + 32 biases)
    '{weight_start_addr: 11'd608, weight_end_addr: 11'd1119, bias_start_addr: 11'd1120, input_size: 5'd31, output_size: 5'd31, weights_per_byte: 5'd2},
    //dense_3 (32x1 = 32 weights + 1 bias)
    '{weight_start_addr: 11'd1136, weight_end_addr: 11'd1151, bias_start_addr: 11'd1152, input_size: 5'd31, output_size: 5'd0, weights_per_byte: 5'd2}
};

// Current layer configuration
layer_config_t current_layer;
assign current_layer = layer_configs[layer_select];

// ROM interface
logic [10:0] rom_addr_a, rom_addr_b;
logic [7:0] rom_data_a, rom_data_b;

dual_port_rom #(
    .BYTES(BYTES),
    .MEMFILE(MEMFILE)
) weight_rom (
    .clk(clk),
    .addr_a(rom_addr_a),
    .dout_a(rom_data_a),
    .addr_b(rom_addr_b), 
    .dout_b(rom_data_b)
);

//state machine
typedef enum logic [2:0] {
    IDLE,
    STREAM_WEIGHTS,
    STREAM_BIASES,
    DONE
} state_t;

state_t state, next_state;

// Streaming control registers
logic [10:0] weight_addr;
logic [4:0] output_neuron;
logic [4:0] input_idx;
logic [4:0] systolic_col;
logic weight_nibble_sel;    // 0=low nibble, 1=high nibble
logic [4:0] bias_count;

// Weight unpacking
logic [3:0] weight_low, weight_high;
logic [7:0] current_weight_byte;
logic [3:0] current_weight_nibble;

assign weight_low = current_weight_byte[3:0];
assign weight_high = current_weight_byte[7:4];
assign current_weight_nibble = weight_nibble_sel ? weight_high : weight_low;

// State machine
always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (start_streaming) 
                next_state = STREAM_WEIGHTS;
        end
        
        STREAM_WEIGHTS: begin
            // Check if we've streamed all weights for current layer
            if (weight_addr >= current_layer.weight_end_addr && 
                weight_nibble_sel && 
                output_neuron >= current_layer.output_size) begin
                next_state = STREAM_BIASES;
            end
        end
        
        STREAM_BIASES: begin
            if (bias_count >= current_layer.output_size) begin
                next_state = DONE;
            end
        end
        
        DONE: begin
            if (!start_streaming)
                next_state = IDLE;
        end
    endcase
end

// Address generation and streaming logic
always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        weight_addr <= 11'd0;
        output_neuron <= 5'd0;
        input_idx <= 5'd0;
        systolic_col <= 5'd0;
        weight_nibble_sel <= 1'b0;
        bias_count <= 5'd0;
        weights_valid <= 1'b0;
        bias_valid <= 1'b0;
        streaming_done <= 1'b0;
        
        for (int i = 0; i < 16; i++) begin
            weights_out[i] <= 8'd0;
        end
        bias_out <= 8'd0;
        bias_addr <= 5'd0;
        
    end else begin
        case (state)
            IDLE: begin
                weight_addr <= current_layer.weight_start_addr;
                output_neuron <= 5'd0;
                input_idx <= 5'd0;
                systolic_col <= 5'd0;
                weight_nibble_sel <= 1'b0;
                bias_count <= 5'd0;
                weights_valid <= 1'b0;
                bias_valid <= 1'b0;
                streaming_done <= 1'b0;
            end
            
            STREAM_WEIGHTS: begin
                weights_valid <= 1'b1;
                
                // Stream weights in systolic array order
                // Fill one column at a time, cycling through output neurons
                
                // Calculate which column of systolic array to target
                systolic_col <= input_idx % 16;
                
                // Sign-extend 4-bit weight to 8-bit
                weights_out[systolic_col] <= {{4{current_weight_nibble[3]}}, current_weight_nibble};
                
                // Advance to next weight
                if (weight_nibble_sel) begin
                    // Moving to next byte
                    weight_addr <= weight_addr + 1;
                    weight_nibble_sel <= 1'b0;
                    
                    // Check if we've completed current input dimension
                    if (input_idx >= current_layer.input_size) begin
                        input_idx <= 5'd0;
                        output_neuron <= output_neuron + 1;
                    end else begin
                        input_idx <= input_idx + 1;
                    end
                end else begin
                    // Moving to high nibble of same byte
                    weight_nibble_sel <= 1'b1;
                end
            end
            
            STREAM_BIASES: begin
                weights_valid <= 1'b0;
                bias_valid <= 1'b1;
                
                // Stream biases (each bias is 4 bits, 2 per byte)
                bias_addr <= bias_count;
                
                if (bias_count[0] == 1'b0) begin
                    // Low nibble
                    bias_out <= {{4{rom_data_a[3]}}, rom_data_a[3:0]};
                end else begin
                    // High nibble
                    bias_out <= {{4{rom_data_a[7]}}, rom_data_a[7:4]};
                end
                
                bias_count <= bias_count + 1;
            end
            
            DONE: begin
                weights_valid <= 1'b0;
                bias_valid <= 1'b0;
                streaming_done <= 1'b1;
            end
        endcase
    end
end

// ROM address assignment
always_comb begin
    case (state)
        STREAM_WEIGHTS: begin
            rom_addr_a = weight_addr;
            rom_addr_b = weight_addr + 1;  // Prefetch next byte
            current_weight_byte = rom_data_a;
        end
        
        STREAM_BIASES: begin
            rom_addr_a = current_layer.bias_start_addr + (bias_count >> 1);
            rom_addr_b = rom_addr_a;
            current_weight_byte = 8'd0;
        end
        
        default: begin
            rom_addr_a = 11'd0;
            rom_addr_b = 11'd0;
            current_weight_byte = 8'd0;
        end
    endcase
end
endmodule