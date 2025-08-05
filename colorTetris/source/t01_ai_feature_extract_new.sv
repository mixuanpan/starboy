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
    logic [19:0][9:0] cleared_array, working_array; // array after lines cleared
    logic [9:0] clear_score;
    logic clear_start, clear_complete;
    logic [7:0] c_lines_cleared, n_lines_cleared;
    assign lines_cleared = c_lines_cleared;
    t01_lineclear line_clear_master (
        .clk(clk),
        .reset(rst || (extract_start && extract_ready)),
        .gamestate('d10),
        .start_eval(clear_start),
        .input_array(tetris_grid),
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
    `else
        logic [4:0] heights [0:9];
        logic [4:0] n_heights [0:9];
    `endif
    logic [3:0] height_column_counter, n_height_column_counter;
   
    // Fixed height sum calculation using heights from working_array
    logic [7:0] height_sum_calc;
    always_comb begin
        height_sum_calc = {3'b0, heights[0]} + {3'b0, heights[1]} + {3'b0, heights[2]} +
                         {3'b0, heights[3]} + {3'b0, heights[4]} + {3'b0, heights[5]} +
                         {3'b0, heights[6]} + {3'b0, heights[7]} + {3'b0, heights[8]} +
                         {3'b0, heights[9]};
    end
    assign height_sum = height_sum_calc;
   
    // Fixed bumpiness calculation using working_array (after line clears)
    logic [7:0] bumpiness_calc;
    logic [4:0] working_heights [0:9];
    always_comb begin
        // Calculate heights from working array for bumpiness
        for (int col = 0; col < 10; col++) begin
            working_heights[col] = 0;
            for (int r = 0; r < 20; r++) begin
                if (working_array[r][col]) begin
                    working_heights[col] = 5'd20 - r[4:0];
                    break;
                end
            end
        end
       
        // Calculate bumpiness from working heights
        bumpiness_calc = 0;
        for (int i = 0; i < 9; i++) begin
            if (working_heights[i] > working_heights[i+1]) begin
                bumpiness_calc = bumpiness_calc + {3'b0, working_heights[i]} - {3'b0, working_heights[i+1]};
            end else begin
                bumpiness_calc = bumpiness_calc + {3'b0, working_heights[i+1]} - {3'b0, working_heights[i]};
            end
        end
    end
    assign bumpiness = bumpiness_calc;
   
    // Fixed holes calculation
    logic [3:0] hole_column_counter, n_hole_column_counter;
    logic [7:0] c_holes, n_holes;
    logic [4:0] hole_row_counter, n_hole_row_counter;
    assign holes = c_holes;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            c_holes <= 0;
            working_array <= 0;
            height_column_counter <= 0;
            hole_column_counter <= 0;
            hole_row_counter <= 0;
            c_lines_cleared <= 0;
            heights[0] <= 0;
            heights[1] <= 0;
            heights[2] <= 0;
            heights[3] <= 0;
            heights[4] <= 0;
            heights[5] <= 0;
            heights[6] <= 0;
            heights[7] <= 0;
            heights[8] <= 0;
            heights[9] <= 0;
        end else if (extract_start) begin
            c_state <= n_state;
            c_holes <= n_holes;
            c_lines_cleared <= n_lines_cleared;
            if (clear_complete) begin
                if (lines_cleared > 0) begin
                    working_array <= cleared_array;
                end else begin
                    working_array <= tetris_grid;
                end
            end
            height_column_counter <= n_height_column_counter;
            hole_column_counter <= n_hole_column_counter;
            hole_row_counter <= n_hole_row_counter;
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

    always_comb begin
        n_state = c_state;
        n_holes = c_holes;
        n_lines_cleared = c_lines_cleared;
        extract_ready = 0;
        clear_start = 0;
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
        n_hole_row_counter = hole_row_counter;

        case (c_state)
            IDLE: begin
                n_hole_column_counter = 0;
                n_height_column_counter = 0;
                n_hole_row_counter = 0;
                n_holes = 0;
                n_lines_cleared = 0;
                n_heights[0] = 0;
                n_heights[1] = 0;
                n_heights[2] = 0;
                n_heights[3] = 0;
                n_heights[4] = 0;
                n_heights[5] = 0;
                n_heights[6] = 0;
                n_heights[7] = 0;
                n_heights[8] = 0;
                n_heights[9] = 0;
                if (extract_start) begin
                    n_state = LINES;
                end
            end
            LINES: begin
                n_height_column_counter = 0;
                clear_start = 1;
                if (clear_complete) begin
                    clear_start = 0;
                    // Calculate lines cleared by counting full rows in original grid
                    n_lines_cleared = 0;
                    for (int row = 0; row < 20; row++) begin
                        if (&tetris_grid[row]) begin // All bits set means full row
                            n_lines_cleared = n_lines_cleared + 1;
                        end
                    end
                    n_state = OTHER;
                end
            end
            OTHER: begin
                if (hole_column_counter >= 'd10) begin
                    n_state = DONE;
                end else if (height_column_counter >= 'd10) begin
                    // Start hole detection for current column
                    n_hole_row_counter = 0;
                    n_state = HOLES;
                end else begin
                    // Calculate height for current column from working_array (after line clears)
                    n_heights[height_column_counter] = 0; // Default to 0 height
                    for (int r = 0; r < 20; r++) begin
                        if (working_array[r][height_column_counter]) begin
                            n_heights[height_column_counter] = 5'd20 - r[4:0];
                            break; // Found first block from top
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
                // Check for holes in current column from top to height limit
                if (hole_row_counter < heights[hole_column_counter]) begin
                    // Convert logical row to grid row (top-down)
                    // If this position is empty (hole), increment counter
                    if ((5'd20 - heights[hole_column_counter] + hole_row_counter) < 20 &&
                        !working_array[5'd20 - heights[hole_column_counter] + hole_row_counter][hole_column_counter]) begin
                        n_holes = c_holes + 1;
                    end
                    n_hole_row_counter = hole_row_counter + 1;
                end else begin
                    // Move to next column
                    n_hole_column_counter = hole_column_counter + 1;
                    n_hole_row_counter = 0;
                    n_state = OTHER;
                end
            end
            DONE: begin
                extract_ready = 1;
                if (ofm_done) begin
                    n_state = IDLE;
                end
            end
            default: ;
        endcase
    end

endmodule