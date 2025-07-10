`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_cu_fsm 
// Description : Control Unit FSM Controller 
// 
//
/////////////////////////////////////////////////////////////////

module ai_cu_fsm #(
    parameter ADDR_W = 32, 
    parameter LEN_W = 16
)(
    input logic clk, rst, start_decoded, mem_read_done, mem_write_done, seq_done, 
    
    // base addresses & lengths from CSRs 
    input logic [ADDR_W-1:0] ifm_base, wgt_base, ofm_base,  
    input logic [LEN_W-1:0] ifm_len, wgt_len, ofm_len, 
    
    // outputs to memory controller 
    output logic mem_read_req, mem_write_req, 
    output logic [ADDR_W-1:0] mem_read_addr, mem_write_addr, 
    output logic [LEN_W-1:0] mem_read_len, mem_write_len, 

    // output to sequencer 
    output logic seq_start, 

    // phase strobes - debugging 
    output logic phase_fetch, phase_compute, phase_writeback, 

    // done flag 
    output logic layer_done 
);

    typedef enum logic [2:0] {
        S_IDLE, 
        S_FETCH_IFM, 
        S_FETCH_WGT, 
        S_START_SEQ, 
        S_WAIT_SEQ, 
        S_WRITEBACK, 
        S_DONE
    } cu_state_t; 

    cu_state_t state, n_state; 

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

        case (state) 
            S_IDLE: begin 
                if (start_decoded) begin 
                    n_state = S_FETCH_IFM; 
                end 
            end

            S_FETCH_IFM: begin 
                phase_fetch = 1; 
                mem_read_req = 1; 
                mem_read_addr = wgt_base; 
                mem_read_len = wgt_len; 
                if (mem_read_done) begin 
                    n_state = S_START_SEQ; 
                end 
            end

            S_START_SEQ: begin 
                seq_start = 1;
                n_state = S_WAIT_SEQ; 
            end

            S_WAIT_SEQ
        endcase
    end
endmodule 