`default_nettype none

module speed_controller (
    input logic clk,
    input logic reset,
    input logic [7:0] current_score,
    output logic [24:0] scoremod
);

    // Internal signals
    logic [7:0] prev_score;
    logic [4:0] increase;
    logic speed_increased, next_speed_increased;
    logic [24:0] next_mod;
    logic [4:0] newval;

    // Logic for increased timing as game progresses
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            scoremod <= '0;
            increase <= 1;
            prev_score <= '0;
            speed_increased <= 1'b0;
        end else begin
            scoremod <= next_mod;
            prev_score <= current_score;
            speed_increased <= next_speed_increased;
        end
    end

    always_comb begin
        next_mod = scoremod;
        newval = increase;
        next_speed_increased = speed_increased;
        
        // Reset flag when score changes but isn't at a multiple of 5
        if (current_score != prev_score && current_score % 5 != 0) begin
            next_speed_increased = 1'b0;
        end
        
        // Increase speed when we hit a multiple of 5 and haven't already increased
        if (current_score != prev_score && current_score % 5 == 0 && 
            current_score != '0 && !speed_increased) begin
            next_mod = scoremod + 25'd1_000_000;
            next_speed_increased = 1'b1;
        end
    end

endmodule