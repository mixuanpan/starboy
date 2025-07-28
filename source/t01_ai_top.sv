`default_nettype none
module t01_ai_top #(
    parameter int H_WIDTH = 10, // input height bits 
    parameter int W_WIDTH = 10, // input width bits 
    parameter int C_WIDTH = 8, // number of input channels 
    parameter int K_WIDTH = 4, // kernel size bits
    parameter int S_WIDTH = 4, // stride bits
    parameter int INST_WIDTH = K_WIDTH + S_WIDTH + TYPE_WIDTH + 2, // width of the instruction word 

    // derive output dims width at compile time 
    parameter int HOUT_WIDTH = H_WIDTH + 1,
    parameter int WOUT_WIDTH = W_WIDTH + 1 
); 
    // internal signals 
    logic hz100, reset; 

    // cu 
    logic [INST_WIDTH-1:0] id_inst_word; 
    logic id_start_decoded, id_relu_en, id_pool_en; 
    logic [K_WIDTH-1:0] id_kernel_size; 
    logic [S_WIDTH-1:0] id_stride; 
    logic [TYPE_WIDTH-1:0] id_layer_type; 

    logic fsm_layer_done; 

    logic seq_done; 

    // mc 
    logic ci_rd_done, ci_wr_done; 
    
    // control unit 
    t01_ai_cu_id instruction_decoder (
        .clk(hz100), .rst(reset), 
        .start_layer(fsm_layer_done), .inst_word_in(id_inst_word), 
        .start_decoded(id_start_decoded), .relu_en(id_relu_en), .pool_en(id_pool_en), 
        .kernel_size(id_kernel_size), .stride(id_stride), .layer_type(id_layer_type)
    ); 
    t01_ai_cu_fsm cu_fsm (
        .clk(hz100), .rst(reset), 
        .start_decoded(id_start_decoded), .mem_read_done(ci_rd_done), .mem_write_done(ci_wr_done), .seq_done(seq_done), 
        
    )
endmodule 