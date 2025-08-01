`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : feature_extractor
// Description : extracts features from the Tetris board state
// 
//
/////////////////////////////////////////////////////////////////
module t01_ai_feature_extract (
    input logic clk,
    input logic reset,
    input logic start_extract,
    input logic [199:0] next_board,
    
    output logic extract_ready,
    output logic [2:0] lines_cleared,
    output logic [7:0] holes,
    output logic [7:0] bumpiness,  
    output logic [7:0] height_sum
);

    typedef enum logic [2:0] {
        IDLE,
        COMPUTE_HEIGHTS,
        COMPUTE_LINES,
        COMPUTE_HOLES,
        COMPUTE_BUMPINESS,
        DONE
    } extract_state_t;
    extract_state_t current_state, next_state;

    logic [4:0] heights [0:9];
    logic [4:0] column_counter;
    logic [4:0] row_counter;
    logic seen_block [0:9];
    logic [7:0] holes_temp;
    logic [7:0] height_sum_temp;
    logic [2:0] lines_temp;
    logic [7:0] bumpiness_temp;
    
    logic [9:0] row_masks [0:19];
    logic row_full [0:19];
    logic [4:0] column_heights [0:9];
    logic [7:0] total_holes;
    logic [7:0] total_bumpiness;
    logic [7:0] total_height_sum;
    logic [2:0] total_lines;
    

    always_comb begin
        for (int r = 0; r < 20; r++) begin
            row_masks[r] = next_board[r*10 +: 10]; 
            row_full[r] = (row_masks[r] == 10'b1111111111);
        end
    end

    always_comb begin
        total_lines = 3'd0;
        for (int r = 0; r < 20; r++) begin
            if (row_full[r]) begin
                total_lines = total_lines + 1;
            end
        end
    end
    
always_comb begin
    for (int c = 0; c < 10; c++) begin
        column_heights[c] = 5'd0;
        // walk from top row (19) down to 0; first '1' sets the height
        for (int r = 19; r >= 0; r--) begin
            if (column_heights[c] == 5'd0 && next_board[r*10 + c]) begin
                // assign a 5‑bit value r+1
                column_heights[c] = r[4:0] + 5'd1;
            end
        end
    end
end
    always_comb begin
        total_height_sum = 8'd0;
        for (int c = 0; c < 10; c++) begin
            total_height_sum = total_height_sum + {3'b0, column_heights[c]};
        end
    end
   
    always_comb begin
        total_holes = 8'd0;
        for (int c = 0; c < 10; c++) begin
            logic local_seen_block;
            logic [7:0] column_holes;
            local_seen_block = 1'b0;
            column_holes = 8'd0;
            
            for (int r = 19; r >= 0; r--) begin
                if (next_board[r*10 + c] == 1'b1) begin
                    local_seen_block = 1'b1;
                end else if (local_seen_block) begin
                    column_holes = column_holes + 1;
                end
            end
            total_holes = total_holes + column_holes;
        end
    end

    always_comb begin
        total_bumpiness = 8'd0;
        for (int c = 0; c < 9; c++) begin 
            logic [4:0] height_diff;
            if (column_heights[c] > column_heights[c+1]) begin
                height_diff = column_heights[c] - column_heights[c+1];
            end else begin
                height_diff = column_heights[c+1] - column_heights[c];
            end
            total_bumpiness = total_bumpiness + {3'b0, height_diff};
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // State transition logic
    always_comb begin
        case (current_state)
            IDLE: begin
                if (start_extract)
                    next_state = COMPUTE_HEIGHTS;
                else
                    next_state = IDLE;
            end
            
            COMPUTE_HEIGHTS: begin
                next_state = COMPUTE_LINES;
            end
            
            COMPUTE_LINES: begin
                next_state = COMPUTE_HOLES;
            end
            
            COMPUTE_HOLES: begin
                next_state = COMPUTE_BUMPINESS;
            end
            
            COMPUTE_BUMPINESS: begin
                next_state = DONE;
            end
            
            DONE: begin
                if (!start_extract)
                    next_state = IDLE;
                else
                    next_state = DONE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            lines_cleared <= 3'd0;
            holes <= 8'd0;
            bumpiness <= 8'd0;
            height_sum <= 8'd0;
            extract_ready <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (start_extract) begin
                        extract_ready <= 1'b0;
                    end
                end
                
                COMPUTE_HEIGHTS: begin //heights already computed lol
                end
                
                COMPUTE_LINES: begin
                    lines_cleared <= total_lines;
                end
                
                COMPUTE_HOLES: begin
                    holes <= total_holes;
                end
                
                COMPUTE_BUMPINESS: begin
                    bumpiness <= total_bumpiness;
                    height_sum <= total_height_sum;
                end
                
                DONE: begin
                    extract_ready <= 1'b1;
                end

                default: begin end
            endcase
        end
    end

endmodule