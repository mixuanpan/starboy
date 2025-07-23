`default_nettype none
module speed_controller (
    input logic clk,
    input logic reset,
    input logic [7:0] current_score,
    output logic [24:0] scoremod
);
    // Internal signals
    logic [7:0] prev_score;
    logic [24:0] next_mod;
    
    // Logic for increased timing as game progresses
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            scoremod <= '0;
            prev_score <= '0;
        end else begin
            scoremod <= next_mod;
            prev_score <= current_score;
        end
    end
    
    always_comb begin
        logic [7:0] prev_threshold, curr_threshold;
        logic [24:0] speed_increases;
        
        next_mod = scoremod;
        
        // Calculate how many multiples of 5 each score represents
        prev_threshold = prev_score / 5;
        curr_threshold = current_score / 5;
        
        // If we've crossed one or more thresholds, add the appropriate speed increases
        if (curr_threshold > prev_threshold) begin
            speed_increases = (curr_threshold - prev_threshold) * 25'd1_000_000;
            next_mod = scoremod + speed_increases;
        end
    end
endmodule
