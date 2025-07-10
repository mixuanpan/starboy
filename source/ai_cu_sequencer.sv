`default_nettype none 

module ai_cu_sequencer #(
    parameter int H_WIDTH = 10, // input height bits 
    parameter int W_WIDTH = 10, // input width bits 
    parameter int C_WIDTH = 8, // number of input channels 
    parameter int K_WIDTH = 4, // kernel size bits
    parameter int S_WIDTH = 4, // stride bits

    // derive output dims width at compile time 
    parameter int HOUT_WIDTH = H_WIDTH + 1,
    parameter int WOUT_WIDTH = W_WIDTH + 1 
)(
    input logic clk, rst, 
    input logic start_decoded, // from the instruction decoder 
    
    // configuration inputs 
    input logic [H_WIDTH-1:0] in_height, 
    input logic [W_WIDTH-1:0] in_width, 
    input logic [C_WIDTH-1:0] in_ch, 
    input logic [K_WIDTH-1:0] kernel_size, 
    input logic [S_WIDTH-1:0] stride, 
    input logic relu_en, pool_en,

    // outputs to datapath 
    output logic [HOUT_WIDTH-1:0] row_cnt, 
    output logic [WOUT_WIDTH-1:0] col_cnt, 
    output logic conv_valid, relu_valid, pool_valid, 

    // back to FSM 
    output logic seq_done
); 
    // compute output dimensions at layer start
    logic [HOUT_WIDTH-1:0] H_out, W_out; 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            H_out <= 0; 
            W_out <= 0; 
        end else if (start_decoded) begin 
            H_out <= ((in_height - {kernel_size}) / stride) + 1; 
            W_out <= ((in_width - {kernel_size}) / stride) + 1; 
        end 
    end
endmodule 