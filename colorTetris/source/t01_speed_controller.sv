`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_speed_controller
// Description : speeds up game based on score
// 
//
/////////////////////////////////////////////////////////////////
module t01_speed_controller (
    input logic clk,
    input logic reset,
    input logic [9:0] current_score,
    input logic [3:0] gamestate,
    output logic [24:0] scoremod
);
    logic [9:0] prev_score;
    logic [24:0] next_mod;
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            scoremod <= '0;
            prev_score <= '0;
        end else if (gamestate == 'd9) begin
            scoremod <= '0;
            prev_score <= '0;       
        end else begin
            scoremod <= next_mod;
            prev_score <= current_score;
        end
    end

    logic [9:0] prev_threshold, curr_threshold;
    logic [24:0] speed_increases;

    always_comb begin
        next_mod = scoremod;
        speed_increases = 0;
        prev_threshold = prev_score / 10;
        curr_threshold = current_score / 10;
        if (curr_threshold > prev_threshold) begin
            speed_increases = {15'b0, (curr_threshold - prev_threshold)} * 25'd1_000_000;
            next_mod = scoremod + speed_increases;
        end
    end
endmodule
