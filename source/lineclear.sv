`default_nettype none
    // FSM States
    typedef enum logic [2:0] {
        INIT,
        SPAWN,
        FALLING,
        ROTATE, 
        STUCK,  
        LANDED,
        EVAL,
        GAMEOVER
    } game_state_t;

module lineclear (
    input logic clk, reset, 
    input logic [19:0][9:0] stored_array, 
    input game_state_t [2:0] current_state, 
    output logic [19:0][9:0] cleared_array, 
    output logic [7:0] score
); 

    logic [4:0] eval_row;
    logic line_clear_found;
    logic eval_complete;

    // Line clear logic - on clk for smooth operation
    logic [4:0] next_eval_row;
    logic next_eval_complete;
    logic [19:0][9:0] next_cleared_array;
    logic [7:0] next_score;

    // Sequential logic for line clear
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            eval_row <= 5'd19;
            eval_complete <= 1'b0;
            cleared_array <= '0;
            score <= 8'd0;
        end
        else begin
            eval_row <= next_eval_row;
            eval_complete <= next_eval_complete;
            cleared_array <= next_cleared_array;
            score <= next_score;
        end
    end

    // Combinational logic for line clear
    always_comb begin
        // Default assignments
        next_eval_row = eval_row;
        next_eval_complete = eval_complete;
        next_cleared_array = cleared_array;
        next_score = score;

        if (current_state == LANDED) begin
            // Initialize evaluation
            next_eval_row = 5'd19;
            next_eval_complete = 1'b0;
            next_cleared_array = stored_array;
        end
        else if (current_state == EVAL) begin
            if (&cleared_array[eval_row]) begin
                // Full line found - clear it
            
                // Increment score if not at max
                if (score < 8'd255)
                    next_score = score + 1;

                // Shift rows down
                for (logic [4:0] k = 0; k < 20; k = k + 1) begin
                    if (k == 0)
                        next_cleared_array[0] = '0;
                    else if (k <= eval_row)
                        next_cleared_array[k] = cleared_array[k-1];
                    else
                        next_cleared_array[k] = cleared_array[k];
                end
            
                // Stay on same row for cascading clears
                next_eval_row = eval_row;
            end
            else begin
                // No full line, move to next row
                if (eval_row == 0)
                    next_eval_complete = 1'b1;
                else
                    next_eval_row = eval_row - 1;
            end
        end
    end

endmodule 
