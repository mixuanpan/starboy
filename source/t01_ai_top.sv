`default_nettype none
module t01_ai_top #(
    // dual port bram 
    parameter int DATA_WIDTH = 16, // bits per feature-map element 
    parameter int DEPTH = 1024, // number of words in the buffer 
    parameter int ADDR_W = $clog2(DEPTH), //

    // instruction decoder 
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

// general data path 
    logic wgt_wr_en, wgt_rd_en, ifm_wr_en, ifm_rd_en; 
    logic [ADDR_W-1:0] wgt_wr_addr, wgt_rd_addr, ifm_wr_addr, ifm_rd_addr; 
    logic [DATA_WIDTH-1:0] wgt_wr_data, wgt_rd_data, ifm_wr_data, ifm_rd_data; 

    t01_ai_dual_port_bram weight_buffer (
        .clk(hz100), .rst(reset), 
        .write_en(wgt_wr_en), .write_addr(wgt_wr_addr), .write_data(wgt_wr_data), 
        .read_en(wgt_rd_en), .read_addr(wgt_rd_addr), .read_data(wgt_rd_data)
    );

    t01_ai_dual_port_bram input_feature_map ( // ifm 
        .clk(hz100), .rst(reset), 
        .write_en(ifm_wr_en), .write_addr(ifm_wr_addr), .write_data(ifm_wr_data), 
        .read_en(ifm_rd_en), .read_addr(ifm_rd_addr), .read_data(ifm_rd_data)
    );

    t01_ai_MMU convolution_engine (
        .clk(hz100), .rst_n(!reset), 
    );
// control unit  
    logic [INST_WIDTH-1:0] id_inst_word; 
    logic id_start_decoded, id_relu_en, id_pool_en; 
    logic [K_WIDTH-1:0] id_kernel_size; 
    logic [S_WIDTH-1:0] id_stride; 
    logic [TYPE_WIDTH-1:0] id_layer_type; 

    logic fsm_layer_done; 

    logic seq_done; 
    
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
// mc 
    logic ci_rd_done, ci_wr_done; 

endmodule 