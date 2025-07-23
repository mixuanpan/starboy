`timescale 1ms/1us

module t01_ai_cu_fsm_tb #(
    parameter ADDR_W = 32, 
    parameter LEN_W = 16
);
    
    logic clk, rst, start_decoded, mem_read_done, mem_write_done, seq_done;
    logic [ADDR_W-1:0] ifm_base, ofm_base;
    logic [LEN_W-1:0] ifm_len, ofm_len;
    logic game_state_ready;
    logic cnn_inference_done;
    logic preprocess_done;
    logic postprocess_done;
    logic mem_read_req, mem_write_req;
    logic [ADDR_W-1:0] mem_read_addr, mem_write_addr;
    logic [LEN_W-1:0] mem_read_len, mem_write_len;
    logic seq_start;
    logic phase_fetch, phase_compute, phase_writeback;
    logic layer_done;
    logic preprocess_start, cnn_inference_start, postprocess_start, tetris_done; 
    logic[3:0] current_state; // just for testing 

    t01_ai_cu_fsm instruction_decoder (.start_decoded(start_decoded), .layer_done(layer_done), .preprocess_start(preprocess_start), .cnn_inference_start(cnn_inference_start), .postprocess_start(postprocess_start), .tetris_done(tetris_done), .current_state(current_state), .clk(clk), .rst(rst), .mem_read_done(mem_read_done), .mem_write_done(mem_write_done), .seq_done(seq_done), .ifm_base(ifm_base), .ofm_base(ofm_base), .ifm_len(ifm_len), .ofm_len(ofm_len), .game_state_ready(game_state_ready), .cnn_inference_done(cnn_inference_done), .preprocess_done(preprocess_done), .postprocess_done(postprocess_done), .mem_read_req(mem_read_req), .mem_write_req(mem_write_req), .mem_read_addr(mem_read_addr), .mem_write_addr(mem_write_addr), .mem_read_len(mem_read_len), .mem_write_len(mem_write_len), .seq_start(seq_start), .phase_fetch(phase_fetch), .phase_compute(phase_compute), .phase_writeback(phase_writeback));
    
    typedef enum logic [3:0] {
        S_IDLE, 
        S_TETRIS_PREPROCESS, // convert game grid to cnn input
        S_FETCH_IFM, 
        S_START_SEQ, 
        S_WAIT_SEQ, 
        S_CNN_INFERENCE, // run cnn forward pass 
        S_TETRIS_POSTPROCESS, // convert cnn output to moves 
        S_WRITEBACK, 
        S_DONE
    } cu_state_t; 

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 

    task tog_start();
      start_decoded = 1; #2;
      start_decoded = 0;  
    endtask 

    task tog_prep(); 
        preprocess_done = 1; #2;
        preprocess_done = 0;  
    endtask 

    task tog_read(); 
        mem_read_done = 1; #2; 
        mem_read_done = 0; 
    endtask 

    task tog_seq(); 
        seq_done = 1; #2; 
        seq_done = 0; 
    endtask 

    task tog_cnn(); 
        cnn_inference_done = 1; #2; 
        cnn_inference_done = 0; 
    endtask 

    task tog_post(); 
        postprocess_done = 1; #2; 
        postprocess_done = 0; #2; 
    endtask 

    task tog_write(); 
        mem_write_done = 1; #2; 
        mem_write_done = 0; #2; 
    endtask 
    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_cu_fsm.vcd"); 
        $dumpvars(0, t01_ai_cu_fsm_tb); 
        
        game_state_ready = 1'b1; 
        ifm_base = 'd333; ifm_len = 'd222;  
        ofm_base = 'd444; ofm_len = 'd555; 

        start_decoded = 0; preprocess_done = 0; mem_read_done = 0; 
        seq_done = 0; cnn_inference_done = 0; postprocess_done = 0; 
        mem_write_done = 0; 
        tog_rst(); 

    for (int i = 0; i < 1; i++) begin 
        if (current_state == S_IDLE) begin 
            tog_start(); 
        end 
        if (current_state == S_TETRIS_PREPROCESS) begin 
            tog_prep();
        end 
        if (current_state == S_FETCH_IFM) begin 
            #1; 
            tog_read(); 
        end 
        if (current_state == S_START_SEQ) begin 
            #1; 
        end 
        if (current_state == S_WAIT_SEQ) begin 
            #1; 
            tog_seq(); 
        end 
        if (current_state == S_CNN_INFERENCE) begin 
            #1; 
            tog_cnn(); 
        end 
        if (current_state == S_TETRIS_POSTPROCESS) begin 
            #1; 
            tog_post(); 
        end 
        if (current_state == S_WRITEBACK) begin 
            #1; 
            tog_write(); 
        end 
        if (current_state == S_DONE) begin 
            #1; 
        end 
    end 
        #1 $finish; 
    end
endmodule 