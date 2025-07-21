`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_mc_deserializer 
// Description : Deseiralizer for SPI?QSPI read path 
//             - sampels N lanes of serial data on each strobe 
//             - accumulates into a shift register 
//             - emits a DATA_WIDTH-bit word plus a valid pulse 
//
//
/////////////////////////////////////////////////////////////////
module ai_mc_deserializer #(
    parameter int DATA_W = 32, // bits per word
    parameter int LANE_W = 1 // # 0f serial lanes (1 for SPI, 4 for QSPI)
)(
    input logic clk, rst, 
    
    // from PHY / I/O timers 
    input logic sample_strobe, // pulses once per lane_beaet
    input logic [LANE_W-1:0] miso, // serial input bits

    // to read-fifo 
    output logi [DATA_W-1:0] data_out, // assembled parallel word
    output logic valid_out // pulses when data_out is ready 
)
    localparam int BEATS_PER_WORD = DATA_W / LANE_W; // how many strobe cycles to get one full word 
    localparam int CNT_W = $clog2(BEATS_PER_WORD); // bit_width to count those beats

    // shift register and beat counter 
    logic [DATA_W-1:0] shift_reg; 
    logic [CNT_W-1:0] beats_cnt; 

    always_ff @(posedge rst, posedge clk) begin 
        if (rst) begin 
            shift_reg <= 0; 
            beats_cnt <= 0; 
            valid_out <= 0; 
            data_out <= 0; 
        end else begin 
            valid_out <= 1'b0; // default 
            if (sample_strobe) begin 
                // shift in new lane bits 
                shift_reg <= {shift_reg[DATA_W - LANE_W - 1:0], miso}; 

                if (beats_cnt == BEATS_PER_WORD-1) begin 
                    // last beat -> emit the full word next cycle 
                    data_out <= {shift_reg[DATA_WIDTH - LANE_W - 1:0], miso}; 
                    valid_out <= 1'b1; 
                    beats_cnt <= 0; 
                end else begin 
                    // not yet full 
                    beats_cnt <= beats_cnt + 'd1; 
                end 
            end 
        end 
    end 
endmodule 