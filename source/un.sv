
logic hz100, reset; 
logic [7:0] ai_rank_score; // lower the better 
assign ai_rank_score = holes + bumpiness + height_sum - {5'b0, lines_cleared}; 

    logic          extract_start;
    logic          extract_ready;
    logic [2:0]           lines_cleared;
    logic [7:0]           holes;
    logic [7:0]           bumpiness;
    logic [7:0]           height_sum;
  
    t01_ai_feature_extract fe (
    .clk           (hz100),
    .reset         (reset),
    .start_extract (extract_start),
    .next_board    (next_boards),
    .extract_ready (extract_ready), // feature extraction is done 
    .lines_cleared (lines_cleared),
    .holes         (holes),
    .bumpiness     (bumpiness),
    .height_sum    (height_sum)
    );

    // workflow: convolution engine calculat ethe standards (from feature extract)
    // -> Relu & Max Pooling 
    // OFM with manhattan distance but flatten grid -> back to 2D array 
    // display it on vga 

    logic [DATA_WIDTH-1:0] relu_data_out; 
    logic relu_out_valid; 

    t01_ai_activation_unit activation_unit (
        .clk(hz100), .rst(reset), 
        .in_data(mmu_data_out[DATA_WIDTH-1:0]), .in_valid(mmu_valid && mmu_done), 
        .relu_en(seq_relu_valid), .out_data(relu_data_out), .out_valid(relu_out_valid)
    );