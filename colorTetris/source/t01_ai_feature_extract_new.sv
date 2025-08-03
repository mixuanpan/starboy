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
    
    output logic extract_ready,
    output logic [9:0] lines_cleared,
    output logic [7:0] holes,
    output logic [7:0] bumpiness,  
    output logic [7:0] height_sum, 

    // for testing
    output logic [2:0] state 
);
    // fsm state transition 
    typedef enum logic [2:0] {
        IDLE, 
        LINES, 
        OTHER, // for loop buffer 
        HEIGHT, // heights & bumpiness 
        HOLES, 
        DONE 
    } extract_state_t; 

    extract_state_t c_state, n_state; 
    assign state = c_state; 

    // line clear 
    logic [3:0] gamestate; // gamestate simulator 
    logic [19:0][9:0] cleared_array; // array after lines cleared 
    logic clear_complete; 
    
    t01_lineclear line_clear_master (
        .clk(clk), 
        .reset(rst), 
        .gamestate(gamestate), 
        .start_eval(1'b1), 
        .input_array(tetris_grid), 
        .input_color_array(), 
        .output_array(cleared_array), 
        .output_color_array(), 
        .eval_complete(clear_complete), 
        .score(lines_cleared)
    );

    // heights 
    logic [4:0] heights [0:9]; 
    logic [3:0] height_column_counter, n_height_column_counter; 
    assign height_sum = {3'b0, heights[0]} + {3'b0, heights[1]} + {3'b0, heights[2]} + {3'b0, heights[3]} + {3'b0, heights[4]} + {3'b0, heights[5]} + {3'b0, heights[6]} + {3'b0, heights[7]} + {3'b0, heights[8]} + {3'b0, heights[9]}; 
    
    // bumpiness 
    logic [4:0] bump_spread [0:8]; 
    assign bump_spread[0] = heights[0] > heights[1] ? heights[0] - heights[1] : heights[1] - heights[0]; 
    assign bump_spread[1] = heights[1] > heights[2] ? heights[1] - heights[2] : heights[2] - heights[1]; 
    assign bump_spread[2] = heights[2] > heights[3] ? heights[2] - heights[3] : heights[3] - heights[2]; 
    assign bump_spread[3] = heights[3] > heights[4] ? heights[3] - heights[4] : heights[4] - heights[3]; 
    assign bump_spread[4] = heights[4] > heights[5] ? heights[4] - heights[5] : heights[5] - heights[4]; 
    assign bump_spread[5] = heights[5] > heights[6] ? heights[5] - heights[6] : heights[6] - heights[5]; 
    assign bump_spread[6] = heights[6] > heights[7] ? heights[6] - heights[7] : heights[7] - heights[6]; 
    assign bump_spread[7] = heights[7] > heights[8] ? heights[7] - heights[8] : heights[8] - heights[7]; 
    assign bumpiness = {3'b0, bump_spread[0]} + {3'b0, bump_spread[1]} + {3'b0, bump_spread[2]} + {3'b0, bump_spread[3]} + {3'b0, bump_spread[4]} + {3'b0, bump_spread[5]} + {3'b0, bump_spread[6]} + {3'b0, bump_spread[7]} + {3'b0, bump_spread[8]}; 
    
    // holes 
    logic [3:0] hole_column_counter, n_hole_column_counter; 
    logic hole_perceived, n_hole_perceived; 
    logic [7:0] c_holes, n_holes, c_hole_start_row, n_hole_start_row; 
    assign holes = c_holes; 

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_state <= IDLE; 
            c_holes <= 0; 
            height_column_counter <= 0; 
            hole_column_counter <= 0; 
            hole_perceived <= 0; 
            c_hole_start_row <= 'd18; 
        end else if (extract_start) begin 
            c_state <= n_state; 
            c_holes <= n_holes; 
            height_column_counter <= n_height_column_counter; 
            hole_column_counter <= n_hole_column_counter; 
            hole_perceived <= n_hole_perceived; 
            c_hole_start_row <= n_hole_start_row; 
        end
    end

    always_comb begin 
        n_state = c_state; 
        n_holes = c_holes; 
        gamestate = 'd9; 
        extract_ready = 0; 
        for (int r = 0; r < 20; r++) begin 
            heights[r] = 0; 
        end
        n_height_column_counter = height_column_counter; 
        n_hole_column_counter = hole_column_counter; 
        n_hole_perceived = hole_perceived; 
        n_hole_start_row = c_hole_start_row; 

        case (c_state) 
            IDLE: begin 

                if (extract_start) begin 
                    gamestate = 'd9; 
                    n_state = LINES; 
                end 
            end
            LINES: begin 
                gamestate = 'd10; 
                n_height_column_counter = 0; 
                if (clear_complete) begin 
                    n_state = OTHER; 
                end
            end
            OTHER: begin 
                if (hole_column_counter >= 'd10) begin 
                    n_state = DONE; 
                end else if (height_column_counter >= 'd10) begin 
                    // for (int r = {24'b0, c_hole_start_row}; r >= 32'd18 - {27'b0, heights[hole_column_counter]}; r++) begin 
                    n_hole_perceived = 0; 
                    for (int r = 18; r >= 1; r --) begin 
                        if (cleared_array[r-1][hole_column_counter] && !cleared_array[r][hole_column_counter] && cleared_array[r+1][hole_column_counter]) begin 
                            n_hole_start_row = r[7:0] + 'd2; 
                            n_hole_perceived = 1; 
                            n_state = HOLES; 
                        end else begin 
                            n_hole_start_row = r[7:0]; 
                        end
                    end
                    n_state = HOLES; 
                end else begin 
                    for (int r = 19; r >= 0; r--) begin 
                        if (|cleared_array[r][height_column_counter]) begin 
                            heights[height_column_counter] = 5'd20 - r[4:0]; 
                        end
                    end
                    n_state = HEIGHT; 
                end 
            end
            HEIGHT: begin 
                n_height_column_counter = height_column_counter + 1; 
                n_state = OTHER; 
            end
            HOLES: begin 
                if (hole_perceived) begin 
                    n_holes = c_holes + 1; 
                end
                if (c_hole_start_row <= 8'd18 - {3'b0, heights[hole_column_counter]}) begin 
                    n_hole_start_row = 0; 
                    n_hole_column_counter = hole_column_counter + 1;  
                end
                n_hole_perceived = 0;
                n_state = OTHER;
            end
            DONE: begin 
                extract_ready = 1; 
                if (!extract_start) begin 
                    n_state = IDLE; 
                end
            end
            default: ; 
        endcase
    end
endmodule 