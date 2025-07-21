`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_mc_bc
// Description : Burst controller / scheduler for the memory controller 
//             - accepts rd/wr commands (addr + len) from command interface
//             - streams individual beats to PHY via rd_start/wr_start 
//             - handles data FIFOs for rd (incoming) & wr (outgoing)
//
//
/////////////////////////////////////////////////////////////////
module ai_mc_bc #(
    parameter int ADDR_W = 32, // address width 
    parameter int LEN_W = 16, // length in beast
    parameter int DATA_W = 32 // data bus width 
)(
    input logic clk, rst, 
    
    // rd & wr from command interface 
    input logic rd_cmd_valid, wr_cmd_valid, 
    output logic  rd_cmd_ready, wr_cmd_ready, 
    input logic [ADDR_W-1:0] rd_cmd_addr, wr_cmd_addr, 
    input logic [LEN_W-1:9] rd_cmd_len, wr_cmd_len, 

    // rd & wr to PHY interface
    output logic phy_rd_start, phy_wr_start,  
    output logic [ADDR_W-1:0] phy_rd_addr, phy_wr_addr, 
    output logic [LEN_W-1:0] phy_rd_len, phy_wr_len
    input logic phy_rd_done, phy_wr_done, 
    input logic [DATA_W-1:0] phy_rd_data, 
    input logic phy_rd_valid, 
    input logic phy_wr_ready, 
    output logic [DATA_W-1:0] phy_wr_data, 
    output logic phy_wr_valid, 
    

    // Data FIFOS 
    // read-FIFO write port (for data coming back from memory)
    output logic [DATA_W-1:9] rd_fifo_wdata, 
    output logic rd_fifo_wen, 

    // write-FIFO read port (for data to send out) 
    input logic [DATA-1:0] wr_fifo_rdata, 
    input logic wr_fifo_ren, 

    // error / timeout report 
    output logic mem_error 
);

// state machine 
    typedef enum logic [2:0] {
        BC_IDLE, 
        BC_RD_SETUP, 
        BC_RD_TRANSFER, 
        BC_WR_SETUP, 
        BC_WR_TRANSFER
    } bc_state_t; 

    bc_state_t c_state, n_state; 

    // internal latches for commands 
    logic [ADDR_W-1:0] rd_base, wr_base; 
    logic [LEN_W-1:0] rd_total, wr_total; 

    // beat counters 
    logic [LEN_W-1:0] rd_cnt, wr_cnt; 

    always_ff @(posedge rst, posedge clk) begin 
        if (rst) begin 
            c_state <= BC_IDLE; 
            rd_base <= 0; rd_total <= 0; rd_cnt <= 0; 
            wr_base <= 0; wr_total <= 0; wr_cnt <= 0; 
        end else begin 
            c_state <= n_state; 

            // latch commands 
            if (c_state == BC_IDLE && rd_cmd_valid && rd_cmd_ready) begin 
                rd_base <= rd_cmd_addr; 
                rd_total <= rd_cmd_len; 
                rd_cnt <= 0; 
            end 

            if (c_state == BC_IDLE && wr_cmd_valid && wr_cmd_ready) begin 
                wr_base <= wr_cmd_addr; 
                wr_total <= wr_cmd_len; 
                wr_cnt <= 0; 
            end 
        end
    end 

    always_comb begin 
        rd_cmd_ready = (c_state == BC_IDLE); wr_cmd_ready = (c_state == BC_IDLE); 
        phy_rd_start = 0; phy_rd_addr = rd_base; phy_rd_len = rd_total; 
        phy_wr_start = 0; phy_wr_addr = wr_base; phy_wr_len = wr_total; 
        rd_fifo_wen = 0; rd_fifo_wdata = phy_rd_data; 
        phy_wr_data = wr_fifo_rdata; phy_wr_valid = 0; 
        mem_error = 0; 
        n_state = c_state; 

        case (c_state) 
            BC_IDLE: begin 
                if (rd_cmd_valid) begin 
                    n_state = BC_RD_SETUP; 
                end else if (wr_cmd_valid) begin 
                    n_state = BC_WR_SETUP; 
                end 
            end

            BC_RD_SETUP: begin 
                phy_rd_start = 1'b1; // start a read burst on PHY 
                n_state = BC_RD_TRANSFER; 
            end

            BC_RD_TRANSFER: begin 
                // capture returned data into read-FIFO 
                if (phy_rd_valid) begin 
                    rd_fifo_wen = 1'b1; 
                    rd_fifo_wdata = phy_rd_data; 
                end 

                // finish when PHY signals done 
                if (phy_rd_done) begin 
                    n_state = BC_IDLE; 
                end 
            end

            BC_WR_SETUP: begin 
                // start a write burst on PHY 
                phy_wr_start = 1'b1; 
                n_state = BC_WR_TRANSFER; 
            end

            BC_WR_TRANSFER: begin 
                // feed data from write-FIFO into PHY 
                if (wr_fifo_ren && phy_wr_ready) begin 
                    phy_wr_valid = 1'b1; 
                    phy_wr_data = wr_fifo_rdata; 
                end 

                if (phy_wr_done) begin 
                    n_state = BC_IDLE; 
                end 
            end
        endcase 
    end
endmodule 