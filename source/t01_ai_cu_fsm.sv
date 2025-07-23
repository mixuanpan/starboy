`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_ai_cu_fsm 
// Description : Control Unit FSM Controller 
// 
//
/////////////////////////////////////////////////////////////////

module t01_ai_cu_fsm #(
    parameter ADDR_W = 32, 
    parameter LEN_W = 16
)(
    input logic clk, rst, start_decoded, mem_read_done, mem_write_done, seq_done, 
    
    // base addresses & lengths from CSRs 
    input logic [ADDR_W-1:0] ifm_base, ofm_base,  
    input logic [LEN_W-1:0] ifm_len, ofm_len, 
    
    // tetris inputs 
    input logic game_state_ready, // from game engine 
    input logic cnn_inference_done, // from cnn inference engine
    input logic preprocess_done, // from tetris preprocessor
    input logic postprocess_done, // from move selecttion 

    // outputs to memory controller 
    output logic mem_read_req, mem_write_req, 
    // first half is the ifm, second half is the weight 
    output logic [ADDR_W-1:0] mem_read_addr, mem_write_addr, 
    output logic [LEN_W-1:0] mem_read_len, mem_write_len, 

    // output to sequencer 
    output logic seq_start, 

    // phase strobes - debugging 
    output logic phase_fetch, phase_compute, phase_writeback, 

    // done flag 
    output logic layer_done, 

    output logic [3:0] current_state, // just for testing 
    // tetris outputs 
    output logic preprocess_start, cnn_inference_start, postprocess_start, tetris_done
);

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

    cu_state_t state, n_state; 

    assign current_state = state; 

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            state <= S_IDLE; 
        end else begin 
            state <= n_state; 
        end 
    end 

    always_comb begin 
        mem_read_req = 0; mem_read_addr = 0; mem_read_len = 0; 
        mem_write_req = 0; mem_write_addr = 0; mem_write_len = 0; 
        seq_start = 0; 
        phase_fetch = 0; phase_compute = 0; phase_writeback = 0; 
        layer_done = 0; 
        n_state = state; 

        preprocess_start = 0; cnn_inference_start = 0; 
        postprocess_start = 0; tetris_done = 0; 

        case (state) 
            S_IDLE: begin 
                if (start_decoded && game_state_ready) begin 
                    n_state = S_TETRIS_PREPROCESS; 
                end 
            end

            S_TETRIS_PREPROCESS: begin 
                preprocess_start = 1; 
                if (preprocess_done) begin 
                    n_state = S_FETCH_IFM; 
                end 
            end

            S_FETCH_IFM: begin 
                phase_fetch = 1; 
                mem_read_req = 1; 
                mem_read_addr = ifm_base; 
                mem_read_len = ifm_len; 
                if (mem_read_done) begin 
                    n_state = S_START_SEQ; 
                end 
            end

            S_START_SEQ: begin 
                seq_start = 1;
                n_state = S_WAIT_SEQ; 
            end

            S_WAIT_SEQ: begin 
                phase_compute = 1; 
                if (seq_done) begin 
                    n_state = S_CNN_INFERENCE; 
                end 
            end

            S_CNN_INFERENCE: begin 
                phase_compute = 1; 
                cnn_inference_start = 1; 
                if (cnn_inference_done) begin 
                    n_state = S_TETRIS_POSTPROCESS; 
                end 
            end

            S_TETRIS_POSTPROCESS: begin 
                postprocess_start = 1; 
                if (postprocess_done) begin 
                    n_state = S_WRITEBACK; 
                end 
            end

            S_WRITEBACK: begin 
                phase_writeback = 1; 
                mem_write_req = 1; 
                // ofm is only the first half 
                mem_write_addr = ofm_base; 
                mem_write_len = ofm_len; 
                if (mem_write_done) begin 
                    n_state = S_DONE; 
                end 
            end

            S_DONE: begin 
                layer_done = 1; 
                tetris_done = 1; 
                n_state = S_IDLE; 
            end

            default: begin end
        endcase
    end
endmodule 