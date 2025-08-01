`default_nettype none
module t01_ai_top #(
    // dual port bram 
    parameter int DATA_WIDTH = 16, // bits per feature-map element 
    parameter int DEPTH = 1024, // number of words in the buffer 
    parameter int ADDR_W = $clog2(DEPTH), //

    // control unit sequencer
    parameter int H_WIDTH = 10, // input height bits 
    parameter int W_WIDTH = 10, // input width bits 
    parameter int C_WIDTH = 8, // number of input channels 
    parameter int K_WIDTH = 4, // kernel size bits
    parameter int S_WIDTH = 4, // stride bits
    parameter int INST_WIDTH = K_WIDTH + S_WIDTH + TYPE_WIDTH + 2, // width of the instruction word 

    // derive output dims width at compile time 
    parameter int HOUT_WIDTH = H_WIDTH + 1,
    parameter int WOUT_WIDTH = W_WIDTH + 1, 

    // pooling unit 
    parameter int MAP_H = 20, // map height
    parameter int MAP_W = 10 // map width 
); 
    // internal signals 
    logic hz100, reset; 

    logic [4:0] tetris_blockY; 
    logic [3:0] tetris_blockX; 
    logic [19:0][9:0] display_array, stored_array, falling_block_display; 

// Tetris 
    t01_ai_game_engine game_engine (
        .clk(hz100), .reset(reset), .en_newgame(), 
        .right_i(), .left_i(), .start_i(), .rotate_r(), .rotate_l(), .display_array(display_array), 
        .final_display_color(), .gameover(), .score(), // vga 
        .inst_word(id_inst_word), .stored_array(stored_array), 
        .falling_block_display(falling_block_display), .blockX(tetris_blockX), .blockY(tetris_blockY), 
        .finish_recording(finish_recording)

    );

    logic [39:0]          extract_start;
    logic [39:0]          extract_ready;
    logic [2:0]           lines_cleared;
    logic [7:0]           holes;
    logic [7:0]           bumpiness;
    logic [7:0]           height_sum;
  
    t01_ai_feature_extract fe (
    .clk           (clk),
    .reset         (~reset_n),
    .start_extract (extract_start),
    .next_board    (next_boards),
    .extract_ready (extract_ready),
    .lines_cleared (lines_cleared),
    .holes         (holes),
    .bumpiness     (bumpiness),
    .height_sum    (height_sum)
    );

// general data path 
    // logic wgt_wr_en, wgt_rd_en, ifm_wr_en, ifm_rd_en; 
    // logic [ADDR_W-1:0] wgt_wr_addr, wgt_rd_addr, ifm_wr_addr, ifm_rd_addr; 
    // logic [DATA_WIDTH-1:0] wgt_wr_data, wgt_rd_data, ifm_wr_data, ifm_rd_data; 

    // t01_ai_dual_port_bram weight_buffer (
    //     .clk(hz100), .rst(reset), 
    //     .write_en(wgt_wr_en), .write_addr(wgt_wr_addr), .write_data(wgt_wr_data), 
    //     .read_en(wgt_rd_en), .read_addr(wgt_rd_addr), .read_data(wgt_rd_data)
    // );

    // t01_ai_dual_port_bram input_feature_map ( // ifm 
    //     .clk(hz100), .rst(reset), 
    //     .write_en(ifm_wr_en), .write_addr(ifm_wr_addr), .write_data(ifm_wr_data), 
    //     .read_en(ifm_rd_en), .read_addr(ifm_rd_addr), .read_data(ifm_rd_data)
    // );

    logic [17:0] mmu_data_out; 
    logic mmu_valid, mmu_done; 
    
    logic        mmu_act_valid;
  logic [7:0]  mmu_act_in;
  logic        mmu_res_valid;
  logic [17:0] mmu_res_out;
  logic [1:0]  mmu_layer_sel;

  t01_ai_MMU mmu (
    .clk       (clk),
    .rst_n     (!reset),
    .start     (seq_conv_valid && id_layer_type == 'd5), // cu state - cnn inference 
    .layer_sel (mmu_layer_sel),
    .act_valid (mmu_act_valid),
    .act_in    (mmu_act_in),
    .res_valid (mmu_res_valid),
    .res_out   (mmu_res_out),
    .done      (cnn_inference_done)
  );

    logic [DATA_WIDTH-1:0] relu_data_out; 
    logic relu_out_valid; 

    t01_ai_activation_unit activation_unit (
        .clk(hz100), .rst(reset), 
        .in_data(mmu_data_out[DATA_WIDTH-1:0]), .in_valid(mmu_valid && mmu_done), 
        .relu_en(seq_relu_valid), .out_data(relu_data_out), .out_valid(relu_out_valid)
    );
    logic [MAP_H/2-1:0][MAP_W/2-1:0] pool_output_map; 
    logic pool_done; 

    t01_ai_pool pooling_unit ( // row_cnt + col_cnt from sequencer cu (?)
        .clk(hz100), .rst(reset), 
        .pool_en(relu_out_valid), .pool_valid(seq_pool_valid), 
        .feature_map(), .output_map(pool_output_map), .done(pool_done) 
    );

    t01_ai_argmax_unit output_feature_map ( // move id from inst_word 
        .clk(hz100), .rst(reset), .start(pool_done), .valid(seq_conv_valid && seq_relu_valid && seq_pool_valid), 
        .q_value(), 
    );

 

  //------------------------------------------------------------------------
  // 4) Argmax
  //------------------------------------------------------------------------
  logic        arg_start;
  logic        arg_valid;
  logic signed [17:0] arg_q_value;
  logic [5:0]  arg_move_id;
  logic        arg_last;
  logic        arg_done;

  t01_ai_argmax_unit #(
    .Q_VALUE_WIDTH (18),
    .MOVE_ID_WIDTH (6)
  ) amx (
    .clk         (clk),
    .rst         (~reset_n),
    .start       (arg_start),
    .valid       (arg_valid),
    .q_value     (arg_q_value),
    .move_id     (arg_move_id),
    .last        (arg_last),
    .best_move_id(best_move_id),
    .best_q_value(best_q_value),
    .done        (arg_done)
  );

// control unit  
    logic [H_WIDTH-1:0] id_height;
    logic [W_WIDTH-1:0] id_width;
    logic [C_WIDTH-1:0] id_ch;
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
        .falling_block_display(falling_block_display), .current_block_pattern(current_block_pattern), 
        
    ); 

    logic [HOUT_WIDTH-1:0] seq_row_cnt;
    logic [WOUT_WIDTH-1:0] seq_col_cnt;
    logic seq_conv_valid, seq_relu_valid, seq_pool_valid, seq_done; 

    t01_ai_cu_sequencer sequencer (
        .clk(hz100), .rst(reset), ,.start_decoded(id_start_decoded), 
        .in_height(id_height), .in_width(id_width), .in_ch(id_ch), .kernel_size(id_kernel_size), 
        .stride(id_stride), .relu_en(id_relu_en), .pool_en(id_pool_en), 
        .row_cnt(seq_row_cnt), .col_cnt(seq_col_cnt), 
        .conv_valid(seq_conv_valid), .relu_valid(seq_relu_valid), .pool_valid(seq_pool_valid), 
        .seq_done(seq_done)
    );


endmodule 