// `default_nettype none
// module ai_top #(
//     parameter int INST_WIDTH = 32,  // width of the instruction word 
//     parameter int H_WIDTH = 10, // input height bits 
//     parameter int W_WIDTH = 10, // input width bits 
//     parameter int C_WIDTH = 8, // number of input channels 
//     parameter int K_WIDTH = 4, // kernel_size bits 
//     parameter int S_WIDTH = 4, // stride bits 
//     parameter int TYPE_WIDTH = 4, // layer_type bits 
//     parameter int HOUT_WIDTH = H_WIDTH + 1,
//     parameter int WOUT_WIDTH = W_WIDTH + 1, 
//     parameter ADDR_W = 32, 
//     parameter LEN_W = 16, 
//     parameter int MAP_H = 20, // map height
//     parameter int MAP_W = 10 // map width 
// )(); 
// // connections for the ai 
//     // control unit signals 
//     logic hz100, reset, cs, we; 
//     logic start_layer, start_decoded, relu_en, pool_en, seq_start; 
//     logic mem_read_done, mem_write_done, seq_done, layer_done; 
//     logic mem_read_req, mem_write_req, phase_fetch, phase_compute, phase_writeback;
//     logic conv_valid, relu_valid, pool_valid; 

//     logic [INST_WIDTH-1:0] inst_word_in; // 32-bit layer descripter 
//     logic [H_WIDTH-1:0] in_height; 
//     logic [W_WIDTH-1:0] in_width; 
//     logic [C_WIDTH-1:0] in_ch; 
//     logic [K_WIDTH-1:0] kernel_size; 
//     logic [S_WIDTH-1:0] stride; 
//     logic [TYPE_WIDTH-1:0] layer_type; 
//     logic [ADDR_W-1:0] ifm_base, ofm_base, mem_read_addr, mem_write_addr; 
//     logic [LEN_W-1:0] ifm_len, ofm_len, mem_read_len, mem_write_len; 
//     logic [HOUT_WIDTH-1:0] row_cnt;
//     logic [WOUT_WIDTH-1:0] col_cnt;

//     // memory controller arbiters & sequencers signals 
//     logic ifm_write_en, wgt_write_en; 
//     logic [ADDR_W-1:0] ifm_wr_addr, ifm_rd_addr, wgt_wr_addr, wgt_rd_addr; 
//     logic [LEN_W-1:0] ifm_wr_data, ifm_rd_data, wgt_wr_data, wgt_rd_data; 
    
//     // convolution engine signals 
//     logic [LEN_W-1:0] conv_data; 
//     logic conv_valid; 

//     // acivation unit signals 
//     logic [LEN_W-1:0] au_out_data; 
//     logic au_relu_valid; 

//     // max pooling unit signals
//     logic [MAP_H/2-1:0][MAP_W/2-1:0] pool_output_map; 
//     logic pool_done; 

//     // memory controllers signals
//     logic ofm_rd_valid; 
//     logic [ADDR_W-1:0] ofm_rd_addr; 
//     logic [LEN_W-1:0] ofm_rd_data; 

// // Control Unit - 134 cells, 
//     ai_cu_id instruction_decoder ( 
//         .clk(hz100), .rst(reset), 
//         .start_layer(start_layer), 
//         .inst_word_in(inst_word_in), 
//         .start_decoded(start_decoded), 
//         .kernel_size(kernel_size), 
//         .stride(stride), 
//         .relu_en(relu_en), 
//         .pool_en(pool_en), 
//         .layer_type(layer_type)
//     ); 

//     ai_cu_fsm cu_fsm (
//         .clk(hz100), .rst(reset), 
//         .start_decoded(start_decoded), 
//         .mem_read_done(mem_read_done), 
//         .mem_write_done(mem_write_done), 
//         .seq_done(seq_done), 
//         .ifm_base(ifm_base), .ofm_base(ofm_base), 
//         .ifm_len(ifm_len), .ofm_len(ofm_len), 
//         .mem_read_req(mem_read_req), .mem_write_req(mem_write_req), 
//         .mem_read_addr(mem_read_addr), .mem_write_addr(mem_write_addr), 
//         .mem_read_len(mem_read_len), .mem_write_len(mem_write_len), 
//         .seq_start(seq_start), .phase_fetch(phase_fetch), .phase_compute(phase_compute), 
//         .phase_writeback(phase_writeback), .layer_done(layer_done)
//     );

//     ai_cu_layer_config_csrs ai_config (
//         .clk(hz100), .rst(reset), .cs(cs), .we(we), 
//         .addr(), .wdata(), .rdata(), 
//         .in_height(), .in_width(), .in_ch(), .out_ch(), // width issues 
//         .layer_type(), .kernel_size(), .stride(), 
//         .relu_en(), .pool_en(), 
//         .addr_ifm_base(ifm_base), .addr_wgt_base(), .addr_ofm_base(ofm_base)
//     ); 

//     ai_cu_sequencer sequencer (
//         .clk(hz100), .rst(reset), .start_decoded(start_decoded), 
//         .in_height(), .in_width(), .in_ch(), .kernel_size(kernel_size), .stride(stride), 
//         .relu_en(relu_en), .pool_en(pool_en), 
//         .row_cnt(row_cnt), .col_cnt(col_cnt), 
//         .conv_valid(conv_valid), .relu_valid(relu_valid), .pool_valid(pool_valid), 
//         .seq_done(seq_done)
//     ); 

// // datapath 
//     ai_dual_port_bram ifm_buffer (
//         .clk(hz100), .write_en(ifm_write_en), .read_en(1'b1), 
//         .write_addr(ifm_wr_addr), .write_data(ifm_wr_data), 
//         .read_addr(ifm_rd_addr), .read_data(ifm_rd_data)
//     );

//     ai_dual_port_bram wgt_buffer (
//         .clk(hz100), .write_en(wgt_write_en), .read_en(1'b1), 
//         .write_addr(wgt_wr_addr), .write_data(wgt_wr_data), 
//         .read_addr(wgt_rd_addr), .read_data(wgt_rd_data)
//     );

//     ai_MMU convolution_engine (
//         .clk(hz100), .rst(reset), 
//         .inp_north(), .inp_west(), .done(), .result() 
//     );

//     ai_activation_unit activation_unit (
//         .clk(hz100), .rst(reset), 
//         .in_data(conv_data), .out_data(au_out_data), .out_valid(au_relu_valid)
//     );

//     ai_pool max_pooling_unit (
//         .clk(hz100), .rst(reset), .pool_en(pool_en), .pool_valid(pool_valid), 
//         .feature_map(au_out_data), .output_map(pool_output_map), .done(pool_done)
//     );

//     ai_dual_port_bram ofm_buffer ( // write port from pooling unit, read port to memory controller 
//         .clk(hz100), .rst(reset), .write_en(pool_valid), .read_en(ofm_rd_valid), 
//         .write_addr(), .write_data(pool_output_map), 
//         .read_addr(ofm_rd_addr), .read_data(ofm_rd_data)
//     );

// endmodule 