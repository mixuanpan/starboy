`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : feature_extractor
// Description : extracts features from the Tetris board state
// 
//
/////////////////////////////////////////////////////////////////
module t01_ai_feature_extract_new (
    input logic clk,
    input logic rst,
    input logic extract_start,
    input logic [19:0][9:0] tetris_grid, 
    input logic ofm_done, 
    
    output logic extract_ready,
    output logic [7:0] lines_cleared,
    output logic [7:0] holes,
    output logic [7:0] bumpiness,  
    output logic [7:0] height_sum
);
    // fsm state transition 
    typedef enum logic [2:0] {
        IDLE, 
        LINES, 
        HEIGHT, // heights & bumpiness 
        HOLES, 
        DONE 
    } extract_state_t; 

    extract_state_t c_state, n_state; 

    // line clear 
    logic [19:0][9:0] cleared_array, working_array, line_clear_input_array; // array after lines cleared 
    logic [9:0] clear_score; 
    logic [7:0] lines_cleared_tmp; // temporary and only latch when clear complete 
    logic clear_start, clear_complete; 
    
    // write back from scoring to lines cleared 
    always_comb begin 
        case (clear_score) 
            'd8: lines_cleared_tmp = 'd4; 
            'd5: lines_cleared_tmp = 'd3; 
            'd3: lines_cleared_tmp = 'd2; 
            default: lines_cleared_tmp = clear_score[7:0];  
        endcase
    end
    
    t01_lineclear line_clear_master (
        .clk(clk), 
        .reset(rst || (extract_start && extract_ready)), 
        .gamestate('d10), 
        .start_eval(clear_start), 
        .input_array(line_clear_input_array), 
        .input_color_array(), 
        .output_array(cleared_array), 
        .output_color_array(), 
        .eval_complete(clear_complete), 
        .score(clear_score)
    );

    // heights 
    `ifdef TESTBENCH
        logic [9:0][4:0] heights;
        logic [9:0][4:0] n_heights;
        logic [8:0][4:0] bump_spread; 
    `else
        logic [4:0] heights [0:9];
        logic [4:0] n_heights [0:9];
        logic [4:0] bump_spread [0:8];  
    `endif
    logic [3:0] height_column_counter, n_height_column_counter; 
    assign height_sum = {3'b0, heights[0]} + {3'b0, heights[1]} + {3'b0, heights[2]} + {3'b0, heights[3]} + {3'b0, heights[4]} + {3'b0, heights[5]} + {3'b0, heights[6]} + {3'b0, heights[7]} + {3'b0, heights[8]} + {3'b0, heights[9]}; 
    
    // bumpiness 
    assign bump_spread[0] = (heights[0] > heights[1]) ? heights[0] - heights[1] : heights[1] - heights[0]; 
    assign bump_spread[1] = (heights[1] > heights[2]) ? heights[1] - heights[2] : heights[2] - heights[1]; 
    assign bump_spread[2] = (heights[2] > heights[3]) ? heights[2] - heights[3] : heights[3] - heights[2]; 
    assign bump_spread[3] = (heights[3] > heights[4]) ? heights[3] - heights[4] : heights[4] - heights[3]; 
    assign bump_spread[4] = (heights[4] > heights[5]) ? heights[4] - heights[5] : heights[5] - heights[4]; 
    assign bump_spread[5] = (heights[5] > heights[6]) ? heights[5] - heights[6] : heights[6] - heights[5]; 
    assign bump_spread[6] = (heights[6] > heights[7]) ? heights[6] - heights[7] : heights[7] - heights[6]; 
    assign bump_spread[7] = (heights[7] > heights[8]) ? heights[7] - heights[8] : heights[8] - heights[7];
    assign bump_spread[8] = (heights[8] > heights[9]) ? heights[8] - heights[9] : heights[9] - heights[8]; 
    assign bumpiness = {3'b0, bump_spread[0]} + {3'b0, bump_spread[1]} + {3'b0, bump_spread[2]} + {3'b0, bump_spread[3]} + {3'b0, bump_spread[4]} + {3'b0, bump_spread[5]} + {3'b0, bump_spread[6]} + {3'b0, bump_spread[7]} + {3'b0, bump_spread[8]}; 
    
    // holes tracking
    logic [7:0] c_holes, n_holes;
    logic [3:0] hole_column_counter, n_hole_column_counter;

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_state <= IDLE; 
            c_holes <= 8'd0; 
            working_array <= 200'd0; 
            line_clear_input_array <= 200'd0; 
            height_column_counter <= 4'd0; 
            hole_column_counter <= 4'd0; 
            lines_cleared <= 8'd0; 
            heights[0] <= 5'd0;
            heights[1] <= 5'd0;
            heights[2] <= 5'd0;
            heights[3] <= 5'd0;
            heights[4] <= 5'd0;
            heights[5] <= 5'd0;
            heights[6] <= 5'd0;
            heights[7] <= 5'd0;
            heights[8] <= 5'd0;
            heights[9] <= 5'd0;
        end else if (clear_start && !extract_start) begin 
            line_clear_input_array <= tetris_grid; 
        end else if (extract_start) begin 
            c_state <= n_state; 
            c_holes <= n_holes; 
            
            if (c_state == LINES && clear_complete) begin 
                lines_cleared <= lines_cleared_tmp; 
                working_array <= cleared_array; 
            end 
            height_column_counter <= n_height_column_counter; 
            hole_column_counter <= n_hole_column_counter; 
            heights[0] <= n_heights[0];
            heights[1] <= n_heights[1];
            heights[2] <= n_heights[2];
            heights[3] <= n_heights[3];
            heights[4] <= n_heights[4];
            heights[5] <= n_heights[5];
            heights[6] <= n_heights[6];
            heights[7] <= n_heights[7];
            heights[8] <= n_heights[8];
            heights[9] <= n_heights[9];
        end
    end

    // Output assignment
    assign holes = c_holes;

    always_comb begin 
        // Default assignments to prevent latches
        n_state = c_state; 
        n_holes = c_holes; 
        extract_ready = 1'b0; 
        clear_start = 1'b0; 
        n_heights[0] = heights[0];
        n_heights[1] = heights[1];
        n_heights[2] = heights[2];
        n_heights[3] = heights[3];
        n_heights[4] = heights[4];
        n_heights[5] = heights[5];
        n_heights[6] = heights[6];
        n_heights[7] = heights[7];
        n_heights[8] = heights[8];
        n_heights[9] = heights[9];
        n_height_column_counter = height_column_counter; 
        n_hole_column_counter = hole_column_counter; 

        case (c_state) 
            IDLE: begin 
                n_hole_column_counter = 4'd0; 
                n_height_column_counter = 4'd0; 
                n_holes = 8'd0;  // Reset hole count
                n_heights[0] = 5'd0;
                n_heights[1] = 5'd0;
                n_heights[2] = 5'd0;
                n_heights[3] = 5'd0;
                n_heights[4] = 5'd0;
                n_heights[5] = 5'd0;
                n_heights[6] = 5'd0;
                n_heights[7] = 5'd0;
                n_heights[8] = 5'd0;
                n_heights[9] = 5'd0;
                if (extract_start) begin 
                    n_state = LINES; 
                end 
            end
            
            LINES: begin 
                clear_start = 1'b1; 
                if (clear_complete) begin 
                    clear_start = 1'b0; 
                    n_state = HEIGHT; 
                end
            end
            
            HEIGHT: begin 
                if (height_column_counter >= 4'd10) begin 
                    n_state = HOLES; 
                end else begin 
                    // Calculate height for current column - default to 0 if no blocks found
                    n_heights[height_column_counter] = 5'd0;
                    for (int r = 0; r < 20; r++) begin 
                        if (working_array[r][height_column_counter]) begin 
                            n_heights[height_column_counter] = 5'd20 - r[4:0]; 
                            break;  // Found first block from top
                        end
                    end
                    n_height_column_counter = height_column_counter + 4'd1; 
                end 
            end
            
            HOLES: begin 
                if (hole_column_counter >= 4'd10) begin 
                    n_state = DONE; 
                end else begin 
                    // Find first block from top in current column (matching Python logic)
                    automatic logic found_first_block = 1'b0;
                    automatic logic [4:0] first_block_row = 5'd0;
                    automatic logic [7:0] holes_in_column = 8'd0;
                    
                    // Scan from top (row 0) to find first block - matches Python's while loop
                    for (int r = 0; r < 20; r++) begin
                        if (working_array[r][hole_column_counter] && !found_first_block) begin
                            found_first_block = 1'b1;
                            first_block_row = r[4:0];
                            break;
                        end
                    end
                    
                    // Count empty spaces below first block - matches Python's col[i+1:]
                    if (found_first_block) begin
                        for (int r = {27'd0, first_block_row} + 32'd1; r < 32'd20; r++) begin
                            if (!working_array[r][hole_column_counter]) begin
                                holes_in_column = holes_in_column + 8'd1;
                            end
                        end
                    end
                    
                    n_holes = c_holes + holes_in_column;
                    n_hole_column_counter = hole_column_counter + 4'd1;
                end
            end
            
            DONE: begin 
                extract_ready = 1'b1; 
                if (ofm_done) begin 
                    n_state = IDLE; 
                end
            end
            
            default: ; 
        endcase
    end
endmodule