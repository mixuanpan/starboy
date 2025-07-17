`default_nettype none
module ai_top #(
    parameter int INST_WIDTH = 32,  // width of the instruction word 
    parameter int H_WIDTH = 10, // input height bits 
    parameter int W_WIDTH = 10, // input width bits 
    parameter int C_WIDTH = 8, // number of input channels 
    parameter int K_WIDTH = 4, // kernel_size bits 
    parameter int S_WIDTH = 4, // stride bits 
    parameter int TYPE_WIDTH = 4, // layer_type bits 
    parameter int HOUT_WIDTH = H_WIDTH + 1,
    parameter int WOUT_WIDTH = W_WIDTH + 1, 
    parameter ADDR_W = 32, 
    parameter LEN_W = 16  
)(); 
// connections for the ai 
    logic clk, rst, cs, we; 
    logic start_layer, start_decoded, relu_en, pool_en, seq_start; 
    logic mem_read_done, mem_write_done, seq_done, layer_done; 
    logic mem_read_req, mem_write_req, phase_fetch, phase_compute, phase_writeback;
    logic conv_valid, relu_valid, pool_valid; 

    logic [INST_WIDTH-1:0] inst_word_in; // 32-bit layer descripter 
    logic [H_WIDTH-1:0] in_height; 
    logic [W_WIDTH-1:0] in_width; 
    logic [C_WIDTH-1:0] in_ch; 
    logic [K_WIDTH-1:0] kernel_size; 
    logic [S_WIDTH-1:0] stride; 
    logic [TYPE_WIDTH-1:0] layer_type; 
    logic [ADDR_W-1:0] ifm_base, ofm_base, mem_read_addr, mem_write_addr; 
    logic [LEN_W-1:0] ifm_len, ofm_len, mem_read_len, mem_write_len; 
    logic [HOUT_WIDTH-1:0] row_cnt;
    logic [WOUT_WIDTH-1:0] col_cnt;

    // Control Unit - 134 cells, 
    ai_cu_id instruction_decoder (
        .clk(clk), .rst(rst), 
        .start_layer(start_layer), 
        .inst_word_in(inst_word_in), 
        .start_decoded(start_decoded), 
        .kernel_size(kernel_size), 
        .stride(stride), 
        .relu_en(relu_en), 
        .pool_en(pool_en), 
        .layer_type(layer_type)
    ); 

    ai_cu_fsm cu_fsm (
        .clk(clk), .rst(rst), 
        .start_decoded(start_decoded), 
        .mem_read_done(mem_read_done), 
        .mem_write_done(mem_write_done), 
        .seq_done(seq_done), 
        .ifm_base(ifm_base), .ofm_base(ofm_base), 
        .ifm_len(ifm_len), .ofm_len(ofm_len), 
        .mem_read_req(mem_read_req), .mem_write_req(mem_write_req), 
        .mem_read_addr(mem_read_addr), .mem_write_addr(mem_write_addr), 
        .mem_read_len(mem_read_len), .mem_write_len(mem_write_len), 
        .seq_start(seq_start), .phase_fetch(phase_fetch), .phase_compute(phase_compute), 
        .phase_writeback(phase_writeback), .layer_done(layer_done)
    );

    ai_cu_layer_config_csrs ai_config (
        .clk(clk), .rst(rst), .cs(cs), .we(we), 
        .addr(), .wdata(), .rdata(), 
        .in_height(), .in_width(), .in_ch(), .out_ch(), // width issues 
        .layer_type(), .kernel_size(), .stride(), 
        .relu_en(), .pool_en(), 
        .addr_ifm_base(ifm_base), .addr_wgt_base(), .addr_ofm_base(ofm_base)
    ); 

    ai_cu_sequencer sequencer (
        .clk(clk), .rst(rst), .start_decoded(start_decoded), 
        .in_height(), .in_width(), .in_ch(), .kernel_size(kernel_size), .stride(stride), 
        .relu_en(relu_en), .pool_en(pool_en), 
        .row_cnt(row_cnt), .col_cnt(col_cnt), 
        .conv_valid(conv_valid), .relu_valid(relu_valid), .pool_valid(pool_valid), 
        .seq_done(seq_done)
    ); 
endmodule 