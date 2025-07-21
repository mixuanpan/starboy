`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_mc_agu  
// Description : Address Generator for Memory Controller:
//                 - Latches base address & length on cmd_valid  
//                 - Streams out one address per beat, incrementing by BEAT_BYTES  
//                 - Asserts gen_last on the final beat
//
/////////////////////////////////////////////////////////////////
module ai_mc_agu #(
    parameter int ADDR_W = 32, // width of the address bus 
    parameter int LEN_W = 16, // width of the length (in beats)
    parameter int BEAT_BYTES = 4 // bytes per burst beat 
)(
    input logic clk, rst, 
    
    // from command interface 
    input logic cmd_valid, cmd_ready, // 1 cycle pulse 
    input logic [ADDR_W-1:0] cmd_addr, // base address of the burst 
    input logic [LEN_W-1:0] cmd_len, // number of beats to generate 

    // to burst scheduler 
    output logic gen_valid, gen_ready, // back-pressure from PHY!! 
    output logic [ADDR_W-1:0] gen_addr, // burrent beat's address 
    output logic gen_last 
); 

    logic active; // in the middle of a burst 
    logic [ADDR_W-1:0] base_addr; // latched base address 
    logic [LEN_W-1:0] beats_total, beats_cnt; // latched beat coumt, index 

    assign cmd_ready = !active; // only accept a new command during idle state 
    assign gen_valid = active; // valid during a burst
    assign gen_addr = base_addr + (beats_cnt * BEAT_BYTES); // current beat's address computation 
    assign gen_last = active && (beats_cnt == beats_total - 'd1); // final beat 
    // latch the command on cmd_valid 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            active <= 0; 
            base_addr <= 0; 
            beats_total <= 0; 
            beats_cnt <= 0; 
        end else if (cmd_valid && cmd_ready) begin 
            active <= 1'b1; 
            base_addr <= cmd_addr;
            beats_total <= cmd_len; 
            beats_cnt <= 0; 
        end else if (active && cmd_valid && cmd_ready && gen_last) begin 
            active <= 0; // finish the last beat 
        end else if (active && cmd_valid && cmd_ready) begin 
            beats_cnt <= beats_cnt + 'd1; 
        end
    end
endmodule 