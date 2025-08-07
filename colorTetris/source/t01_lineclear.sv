`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_lineclear
// Description : clears lines
// 
//
/////////////////////////////////////////////////////////////////
module t01_lineclear (
    input logic clk,
    input logic reset,
    input logic [3:0] gamestate,
    input logic start_eval,                    // start flag
    input logic [19:0][9:0] input_array,       // input arrays
    input logic [19:0][9:0][2:0] input_color_array,       
    output logic [19:0][9:0] output_array,     // new arrays
    output logic [19:0][9:0][2:0] output_color_array,       
    output logic eval_complete,                // end flag
    output logic [9:0] score,                   // score
    output logic [2:0] lines_cleared_count // number of lines cleared 
);

// internal states
typedef enum logic [2:0] {
    IDLE,
    EVALUATING,
    CLEARING,
    COUNTING_LINES,
    APPLYING_SCORE,
    DONE
} line_clear_state_t;

line_clear_state_t current_state, next_state;

logic [4:0] eval_row;
logic [19:0][9:0] working_array;
logic [19:0][9:0][2:0] working_color_array; 
logic [9:0] current_score;
logic line_found;
logic [4:0] initial_eval_row;

// scoring lookup table
function logic [9:0] get_line_score(input logic [2:0] num_lines);
    case (num_lines)
        3'd1: get_line_score = 10'd1;   // single
        3'd2: get_line_score = 10'd3;   // Double  
        3'd3: get_line_score = 10'd5;   // triple
        3'd4: get_line_score = 10'd8;   // tetris
        default: get_line_score = 10'd0;
    endcase
endfunction

// state logic
always_comb begin
    next_state = current_state;
    case (current_state)
        IDLE: begin
            if (start_eval)
                next_state = EVALUATING;
        end
        EVALUATING: begin
            if (&working_array[eval_row]) begin
                next_state = CLEARING;
            end else begin
                if (eval_row == 0)
                    next_state = COUNTING_LINES;
                else
                    next_state = EVALUATING;
            end
        end
        
        CLEARING: begin
            next_state = EVALUATING;
        end
        
        COUNTING_LINES: begin
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

// state register
always_ff @(posedge clk, posedge reset) begin
    if (reset)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// main logic
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        eval_row <= 5'd19;
        working_array <= '0;
        current_score <= 10'd0;
        line_found <= 1'b0;
        working_color_array <= '0; 
        lines_cleared_count <= 3'd0;
        initial_eval_row <= 5'd19;
    end else if (gamestate == 'd9) begin
        eval_row <= 5'd19;
        working_array <= '0;
        current_score <= 10'd0;
        line_found <= 1'b0;
        working_color_array <= '0; 
        lines_cleared_count <= 3'd0;
        initial_eval_row <= 5'd19;
    end else begin
        case (current_state)
            IDLE: begin
                if (start_eval) begin
                    eval_row <= 5'd19;
                    working_array <= input_array;
                    working_color_array <= input_color_array;  // load input colors
                    line_found <= 1'b0;
                    lines_cleared_count <= 3'd0;
                    initial_eval_row <= 5'd19;
                end
            end
            
            EVALUATING: begin
                if (&working_array[eval_row]) begin
                    // full line found
                    line_found <= 1'b1;
                end else begin
                    if (eval_row > 0)
                        eval_row <= eval_row - 1;
                    line_found <= 1'b0;
                end
            end
            
            CLEARING: begin
                // clear the line and shift rows down
                line_found <= 1'b0;
                // increment lines cleared counter
                if (lines_cleared_count < 3'd4)
                    lines_cleared_count <= lines_cleared_count + 1;
                
                // shift rows down
                for (int k = 0; k < 20; k++) begin
                    if (k == 0) begin
                        working_array[0] <= '0;
                        working_color_array[0] <= '0; 
                    end
                    else if (k <= eval_row) begin
                        working_array[k] <= working_array[k-1];
                        working_color_array[k] <= working_color_array[k-1];
                    end
                end
            end
            
            COUNTING_LINES: begin
            end
            
            APPLYING_SCORE: begin
                if (lines_cleared_count > 0) begin
                    if (current_score <= 10'd999 - get_line_score(lines_cleared_count))
                        current_score <= current_score + get_line_score(lines_cleared_count);
                    else
                        current_score <= 10'd999;
                end
            end
            
            DONE: begin
            end
            
            default: begin
                eval_row <= 5'd19;
                working_array <= '0;
                line_found <= 1'b0;
                working_color_array <= '0; 
                lines_cleared_count <= 3'd0;
                initial_eval_row <= 5'd19;
            end
        endcase
    end
end

assign output_array = working_array;
assign output_color_array = working_color_array; 
assign eval_complete = (current_state == DONE);
assign score = current_score;

endmodule
