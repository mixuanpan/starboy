`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_mc_ci  
// Description : Memory Controller Commmand Interface 
// 
//
/////////////////////////////////////////////////////////////////

module ai_mc_ci #(
    parameter ADDR_W = 32, 
    parameter LEN_W = 16
)(
    input logic clk, rst, 

    // from Control Unit FSM 
    input logic read_req, write_req, // high for one cycle for read/write burst 
    input logic [ADDR_W-1:0] read_addr, write_addr, 
    input logic [LEN_W-1:0] read_len, write_len, 

    // From Burst Controller 
    input logic rd_cmd_ready, wr_cmd_ready, 

    // to Burst Controller 
    output logic rd_cmd_valid, wr_cmd_valid, 
    output logic [ADDR_W-1:0] rd_cmd_addr, wr_cmd_addr, 
    output logic [LEN_W-1:0] rd_cmd_len, wr_cmd_len 
);

    // read command latch & valid pulse 
    typedef enum logic {
        IDLE_R, 
        PEND_R 
    } rd_state_t; 
    rd_state_t c_state, n_state; 

    // latch registers 
    logic [ADDR_W-1:0] rd_addr_reg; 
    logic [LEN_W-1:0] rd_len_reg; 

    always_ff begin 
        if (rst) begin 
            c_state <= IDLE_R; 
            rd_addr_reg <= 0; 
            rd_len_reg <= 0; 
        end else begin 
            c_state <= n_state; 

            // latch on the incoming requeest edge 
            if (c_state == IDLE_R && read_req) begin 
                rd_addr_reg <= read_addr; 
                rd_len_reg <= read_len; 
            end 
        end 
    end

    always_comb begin 
        rd_cmd_valid = 0; 
        rd_cmd_addr = rd_addr_reg; 
        rd_cmd_addr = rd_len_reg; 
        n_state = c_state; 

        case (c_state) 
            IDLE_R: begin 
                n_state = PEND_R; 
            end

            PEND_R: begin 
                rd_cmd_valid = 1'b1; 
                if (rd_cmd_ready) begin 
                    n_state = IDLE_R; 
                end 
            end
        endcase
    end

    // write command latch & valid pulse 
    typedef enum logic {
        IDLE_R, 
        PEND_R 
    } rd_state_t; 
    rd_state_t c_state, n_state; 

    // latch registers 
    logic [ADDR_W-1:0] rd_addr_reg; 
    logic [LEN_W-1:0] rd_len_reg; 

    always_ff begin 
        if (rst) begin 
            c_state <= IDLE_R; 
            rd_addr_reg <= 0; 
            rd_len_reg <= 0; 
        end else begin 
            c_state <= n_state; 

            // latch on the incoming requeest edge 
            if (c_state == IDLE_R && read_req) begin 
                rd_addr_reg <= read_addr; 
                rd_len_reg <= read_len; 
            end 
        end 
    end

    always_comb begin 
        rd_cmd_valid = 0; 
        rd_cmd_addr = rd_addr_reg; 
        rd_cmd_addr = rd_len_reg; 
        n_state = c_state; 

        case (c_state) 
            IDLE_R: begin 
                n_state = PEND_R; 
            end

            PEND_R: begin 
                rd_cmd_valid = 1'b1; 
                if (rd_cmd_ready) begin 
                    n_state = IDLE_R; 
                end 
            end
        endcase
    end
endmodule 