`default_nettype none
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
typedef enum logic [2:0] {
    IDLE,
    EVALUATING,
    CLEARING,
    COUNTING_LINES,
    APPLYING_SCORE,
    DONE
} line_clear_state_t;

line_clear_state_t current_state, next_state;

// Internal registers
logic [4:0] eval_row;
logic [19:0][9:0] working_array;
logic [7:0] current_score;
logic line_found;
logic [2:0] lines_cleared_count;  // Track how many lines cleared in this evaluation
logic [4:0] initial_eval_row;     // Store starting row for counting

// Scoring lookup table
function logic [7:0] get_line_score(input logic [2:0] num_lines);
    case (num_lines)
        3'd1: get_line_score = 8'd1;   // Single
        3'd2: get_line_score = 8'd3;   // Double  
        3'd3: get_line_score = 8'd5;   // Triple
        3'd4: get_line_score = 8'd8;   // Tetris
        default: get_line_score = 8'd0;
    endcase
endfunction

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
                    next_state = COUNTING_LINES;
                else
                    next_state = EVALUATING; // Continue to next row
            end
        end
        
        CLEARING: begin
            // After clearing, stay in EVALUATING to check same row again
            // (for cascading clears)
            next_state = EVALUATING;
        end
        
        COUNTING_LINES: begin
            // Count how many lines were cleared and apply score
            next_state = APPLYING_SCORE;
        end
        
        APPLYING_SCORE: begin
            next_state = DONE;
        end
        
        DONE: begin
            next_state = IDLE;
        end
        
        default: begin
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
        lines_cleared_count <= 3'd0;
        initial_eval_row <= 5'd19;
    end else begin
        case (current_state)
            IDLE: begin
                if (start_eval) begin
                    eval_row <= 5'd19;
                    working_array <= input_array;
                    line_found <= 1'b0;
                    lines_cleared_count <= 3'd0;
                    initial_eval_row <= 5'd19;
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
                
                // Increment lines cleared counter
                if (lines_cleared_count < 3'd4)
                    lines_cleared_count <= lines_cleared_count + 1;
                
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
            
            COUNTING_LINES: begin
                // Prepare to apply score based on lines cleared
                // lines_cleared_count already has the total
            end
            
            APPLYING_SCORE: begin
                // Apply the appropriate score based on lines cleared
                if (lines_cleared_count > 0) begin
                    // Add score with overflow protection
                    if (current_score <= 8'd255 - get_line_score(lines_cleared_count))
                        current_score <= current_score + get_line_score(lines_cleared_count);
                    else
                        current_score <= 8'd255; // Cap at max value
                end
            end
            
            DONE: begin
                // Evaluation complete, ready to return to IDLE
            end
            
            default: begin
                // Handle undefined states - reset to IDLE
                eval_row <= 5'd19;
                working_array <= '0;
                line_found <= 1'b0;
                lines_cleared_count <= 3'd0;
                initial_eval_row <= 5'd19;
            end
        endcase
    end
end

// Output assignments
assign output_array = working_array;
assign eval_complete = (current_state == DONE);
assign score = current_score;

endmodule