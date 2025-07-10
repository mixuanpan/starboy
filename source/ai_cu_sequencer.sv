`default_nettype none 

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_cu_sequencer  
// Description : Control Unit Sequencer (Pipeline Controller)
// 
//
/////////////////////////////////////////////////////////////////

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

    // nested counters over outputs 
    logic [$bits(H_out)-1:0] r_cnt, c_cnt; 
    assign row_cnt = r_cnt; 
    assign col_cnt = c_cnt;  

    // conv_valid generator 
    // assume pipeline_fill = kernel_size -1 
    logic [$clog2(16)-1:0] fill_cnt; 
    assign conv_valid = (fill_cnt == kernel_size -1) && !(r_cnt == H_out - 1 && c_cnt == W_out - 1); 

    // gated enalbles 
    assign relu_valid = conv_valid & relu_en; 
    // for 2*2 pooling - pending 
    wire row_edge = (r_cnt % 2 == 1); 
    wire col_edge = (c_cnt % 2 == 1); 
    assign pool_valid = conv_valid & pool_en & row_edge & col_edge; 

    // done pulse 
    assign seq_done = conv_valid && (r_cnt == H_out - 1) && (c_cnt == W_out - 1); 
    
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            H_out <= 0; 
            W_out <= 0; 

            {r_cnt, c_cnt} <= 0;

            fill_cnt <= 0; 
        end else if (start_decoded) begin 
            H_out <= ((in_height - {7'b0, kernel_size}) / {7'b0, stride}) + 1; 
            W_out <= ((in_width - {7'b0, kernel_size}) / {7'b0, stride}) + 1; 

            {r_cnt, c_cnt} <= 0; 

            fill_cnt <= 0; 
        end else if (fill_cnt < kernel_size -1) begin 
            fill_cnt <= fill_cnt + 1; 
        end else if (conv_valid) begin 
            if(c_cnt == W_out - 1) begin 
                c_cnt <= 0; 
                if (r_cnt == H_out - 1) begin 
                    r_cnt <= 0; 
                end else begin 
                    r_cnt <= r_cnt + 1; 
                end
            end else begin 
                    c_cnt <= c_cnt + 1; 
            end 
        end
    end


endmodule 

//     On start_decoded you load H_out/W_out and reset the counters + pipeline‐fill counter.

//     fill_cnt ramps up from 0 to K–1, modeling the systolic-array warm-up latency.

//     Once filled, conv_valid pulses each cycle as you step through all output positions.

//     relu_valid and pool_valid simply gate that stream by your per-layer flags and pooling boundary logic.

//     When you hit the last element, seq_done goes high for one cycle and your FSM moves on.

// This structure keeps the “when” logic nicely isolated in one module, with only a handful of inputs (configs + start) and outputs (address counters + valid strobes + done).