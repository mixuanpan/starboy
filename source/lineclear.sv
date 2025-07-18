module lineclear (
    input logic clk,
    input logic reset,
    input logic start_eval,                    // Signal to start line clearing evaluation
    input logic [19:0][9:0] input_array,       // Array to evaluate for line clears
    output logic [19:0][9:0] output_array,     // Array after line clears
    output logic eval_complete,                // Signal when evaluation is done
    output logic [7:0] score                   // Current score
);

// Internal state for line clearing process
typedef enum logic [1:0] {
    IDLE,
    EVALUATING,
    CLEARING,
    DONE
} line_clear_state_t;

line_clear_state_t current_state, next_state;

// Internal registers
logic [4:0] eval_row;
logic [19:0][9:0] working_array;
logic [7:0] current_score;
logic line_found;

// Next state logic
always_comb begin
    next_state = current_state;
    
    case (current_state)
        IDLE: begin
            if (start_eval)
                next_state = EVALUATING;
        end
        
        EVALUATING: begin
            if (&working_array[eval_row]) begin
                // Full line found
                next_state = CLEARING;
            end else begin
                // No full line
                if (eval_row == 0)
                    next_state = DONE;
                else
                    next_state = EVALUATING; // Continue to next row
            end
        end
        
        CLEARING: begin
            // After clearing, stay in EVALUATING to check same row again
            // (for cascading clears)
            next_state = EVALUATING;
        end
        
        DONE: begin
            next_state = IDLE;
        end
    endcase
end

// State register
always_ff @(posedge clk, posedge reset) begin
    if (reset)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// Main logic
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        eval_row <= 5'd19;
        working_array <= '0;
        current_score <= 8'd0;
        line_found <= 1'b0;
    end else begin
        case (current_state)
            IDLE: begin
                if (start_eval) begin
                    eval_row <= 5'd19;
                    working_array <= input_array;
                    line_found <= 1'b0;
                end
            end
            
            EVALUATING: begin
                if (&working_array[eval_row]) begin
                    // Full line found - will clear in next state
                    line_found <= 1'b1;
                end else begin
                    // No full line, move to next row
                    if (eval_row > 0)
                        eval_row <= eval_row - 1;
                    line_found <= 1'b0;
                end
            end
            
            CLEARING: begin
                // Clear the line and shift rows down
                line_found <= 1'b0;
                
                // Increment score if not at max
                if (current_score < 8'd255)
                    current_score <= current_score + 1;
                
                // Shift rows down
                for (int k = 0; k < 20; k++) begin
                    if (k == 0)
                        working_array[0] <= '0;
                    else if (k <= eval_row)
                        working_array[k] <= working_array[k-1];
                    // else working_array[k] stays the same
                end
                
                // Stay on same row to check for cascading clears
                // eval_row stays the same
            end
            
            DONE: begin
                // Evaluation complete, ready to return to IDLE
            end
        endcase
    end
end

// Output assignments
assign output_array = working_array;
assign eval_complete = (current_state == DONE);
assign score = current_score;

endmodule
