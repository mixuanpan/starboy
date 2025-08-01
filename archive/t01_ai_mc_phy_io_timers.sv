`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_mc_phy_io_timers   
// Description : PHY & I/O Timers for SPI/QSPI Interface 
//                 - Generates SCK, CS_n, MOSI shift-out, and MISO strobe
//                 - Handles rd &wr bursts with mode (0-3) & clk div
//
/////////////////////////////////////////////////////////////////
module ai_mc_phy_io_timers #(
    parameter int ADDR_W = 32, 
    parameter int LEN_W = 16, 
    parameter int DATA_W = 32, 
    parameter int CLKDIV_W = 8 
)(
    input logic clk, rst, 

    // configuration: memory-mapped CSRs 
    input logic [1:0] spi_mode, // 0-3 for CPOL/CPHA 
    input logic [CLKDIV_W-1:0] clk_div, // clock divider ratio 

    // read-burst interface 
    input logic rd_start, 
    input logic [ADDR_W-1:0] rd_addr, 
    input logic [LEN_W-1:0] rd_len, 
    output logic rd_done, 

    // stream out to deserializer 
    output logic sample_strobe // strobe to latch MISO 
    output logic [DATA_W-1:0] miso_bits, // aligned bits for deserializer 
    input logic des_ready, // backpressure from deserializer 

    // write-burst interfafe
    input logic wr_start, wr_valid, 
    input logic [ADDR_W-1:0] wr_addr, // byte-address to start
    input logic [LEN_W-1:0] wr_len, // # of DATA_W-bit words
    input logic [DATA_W-1:0] wr_data, // word-aligned data from write-FIFO
    output logic wr_ready, wr_done, 

    // physical pins 
    output logic SCK, CS_n, MOSI, // SPI clock, chip-select (active low), master-out
    input logic MISO // master-in 
); 

// clk div -> sck generation 
    logic [CLKDIV_W-1:0] div_cnt; 

    always_ff @(posedge rst, posedge clk) begin 
        if (rst) begin 
            div_cnt <= 0; 
            SCK <= (spi_mode[1] ? 1'b1 : 1'b0); // CPOL
        end else if (div_cnt == 0) begin 
            div_cnt <= clk_div; 
            SCK <= ~SCK; 
        end else begin 
            div_cnt <= div_cnt -1; 
        end 
    end

    // determine sampling edge for MISO based on CPHA 
    logic sample_edge = (spi_mode[0] == 0) ? (SCK == ~spi_mode[1]) 
                                           : (SCK == spi_mode[1]); 
    assign sample_strobe = sample_edge; 

// burst-level fsm 
    typedef enum logic [2:0] {
        PHY_IDLE, 
        PHY_ADDR_CMD, 
        PHY_TRANSFER, 
        PHY_DONE
    } phy_state_t; 

    phy_state_t c_state, n_state; 

    // counters for bits and words 
    logic [5:0] c_bit_cnt, n_bit_cnt; // up to 32 bits per word
    logic [LEN_W-1:0] c_word_cnt, n_word_cnt; 

    // shift registers for MosI and MISO 
    logic [DATA_W-1:0] c_mosi_sr, n_mosi_sr, c_miso_sr, n_miso_sr, n_miso_bits; 
    logic n_CS_n, n_rd_done, n_wr_done, n_MOSI; 

    always_ff @(posedge rst, posedge clk) begin 
        if (rst) begin 
            c_state <= PHY_IDLE; 
            c_bit_cnt <= 0; c_word_cnt <= 0; 
            c_mosi_sr <= 0; c_miso_sr <= 0; 
            CS_n <= 1'b1; 
            rd_done <= 0; wr_done <= 0; wr_ready <= 0; 
            MOSI <= 0; miso_bits <= 0; 
        end else begin 
            c_state <= n_state; 
            c_bit_cnt <= n_bit_cnt; c_word_cnt <= n_word_cnt; 
            c_miso_sr <= n_miso_sr; c_mosi_sr <= n_mosi_sr; 
            CS_n <= n_CS_n; 
            rd_done <= n_rd_done; wr_done <= n_wr_done; n_wr_ready <= n_wr_done; 
            MOSI <= n_MOSI; miso_bits <= n_miso_bits; 
        end 
    end

    always_comb begin 
        n_state = c_state; n_bit_cnt = c_bit_cnt; 
        n_word_cnt = c_word_cnt; 
        n_mosi_sr = c_mosi_sr; n_miso_sr = c_miso_sr; 
        n_CS_n = CS_n; 
        n_rd_done = 0; n_wr_done = 0; n_wr_ready = wr_ready; 
        n_MOSI = MOSI; n_miso_bits = miso_bits; 

        case (c_state) 
            PHY_IDLE: begin 
                // preload MOSI shift-reg with command + addr header  
                n_wr_ready = 0; 
                n_CS_n = 0; 
                if (rd_start) begin 
                    n_state = PHY_ADDR_CMD; 
                end else if (wr_start) begin 
                    // preload header 
                    n_mosi_sr = {/*OPCODE*/, wr_addr, wr_len}; 
                    n_wr_ready = 1'b1; 
                    n_state = PHY_ADDR_CMD; 
                end 
            end 

            PHY_ADDR_CMD: begin 
                // shift out the header bits on MOSI 
                if (sample_strobe) begin 
                    n_MOSI = c_mosi_sr[DATA_W-1];
                    n_mosi_sr = {c_mosi_sr[DATA_W-2:0], 1'b0}; 
                    n_bit_cnt = c_bit_cnt + 1; 
                end 

                if (c_bit_cnt == DATA_W-1) begin 
                    n_state = PHY_TRANSFER; 
                end 
            end

            PHY_TRANSFER: begin 
                if (wr_start) begin 
                    // write path 
                    if(wr_valid && sample_strobe) begin 
                        n_MOSI = wr_data[DATA_W-1]; 
                        n_bit_cnt = c_bit_cnt + 1; 
                        n_word_cnt = (c_bit_cnt == DATA_W-1) ? c_word_cnt + 1 : c_word_cnt; 
                    end 

                    if (c_word_cnt == wr_len) begin 
                        n_state = PHY_DONE; 
                    end 
                end else if (rd_start) begin 
                    // read path 
                    if (sample_strobe) begin 
                        n_miso_sr = {c_miso_sr[DATA_W-2:0], MISO}; 
                        n_bit_cnt = c_bit_cnt + 1; 
                        if (c_bit_cnt == DATA_W-1) begin 
                            if (des_ready) begin 
                                n_miso_bits = {c_miso_sr[DATA_W-2:0], MISO}; 
                            end 
                            n_word_cnt = c_word_cnt + 1; 
                        end 
                    end
                    if (c_word_cnt == rd_len) begin 
                        n_state = PHY_DONE; 
                    end 
                end  
            end

            PHY_DONE: begin 
                n_CS_n = 1'b1; 
                n_wr_ready = 0; 
                n_rd_done = (c_word_cnt == rd_len); 
                n_wr_done = (c_word_cnt == wr_len); 
                n_state = PHY_IDLE; 
            end
        endcase
    end
endmodule 