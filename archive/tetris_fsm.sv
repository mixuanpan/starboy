`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetrisFSM 
// Description : Tetris FSM controller 
// 
//
/////////////////////////////////////////////////////////////////
module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, start_i, rotate_r, rotate_l, 
    output logic [19:0][9:0] display_array,
    output logic gameover,
    output logic [2:0] state, // output state for testing 
    output logic [7:0] score
);

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

game_state_t current_state, next_state;
assign state = current_state; 
assign gameover = current_state == GAMEOVER;

logic [19:0][9:0] stored_array;
logic [19:0][9:0] cleared_array;

logic [4:0] blockY;
logic [3:0] blockX;
// logic [2:0] current_block_type;

// Block representation as 4x4 grid for rotation support
logic [3:0][3:0] current_block_pattern, blockgen_pattern, rotated_pattern;
logic [1:0] rotate; 
logic [3:0] rotation_done; 
assign rotate = {rotate_l, rotate_r}; 
shift_reg traingle (.clk(clk), .rst(reset), .mode_i(rotate),
    .par_i({current_block_pattern[0][0], current_block_pattern[3][0], current_block_pattern[3][3], current_block_pattern[0][3]}), 
    .done(rotation_done[0]), .Q({rotated_pattern[0][0], rotated_pattern[3][0], rotated_pattern[3][3], rotated_pattern[0][3]})
);
shift_reg circle (.clk(clk), .rst(reset), .mode_i(rotate),
    .par_i({current_block_pattern[1][0], current_block_pattern[3][1], current_block_pattern[2][3], current_block_pattern[0][2]}), 
    .done(rotation_done[1]), .Q({rotated_pattern[1][0], rotated_pattern[3][1], rotated_pattern[2][3], rotated_pattern[0][2]})
);
shift_reg bigx (.clk(clk), .rst(reset), .mode_i(rotate),
    .par_i({current_block_pattern[2][0], current_block_pattern[3][2], current_block_pattern[1][3], current_block_pattern[0][1]}), 
    .done(rotation_done[2]), .Q({rotated_pattern[2][0], rotated_pattern[3][2], rotated_pattern[1][3], rotated_pattern[0][1]})
);
shift_reg square (.clk(clk), .rst(reset), .mode_i(rotate),
    .par_i({current_block_pattern[1][1], current_block_pattern[2][1], current_block_pattern[2][2], current_block_pattern[1][2]}), 
    .done(rotation_done[3]), .Q({rotated_pattern[1][1], rotated_pattern[2][1], rotated_pattern[2][2], rotated_pattern[1][2]})
);

    // shift_reg rotation (.clk(clk), .rst(reset), .mode_i(rotate), 
    // .par_i({current_block_pattern[0][0], current_block_pattern[3][0], current_block_pattern[3][3], current_block_pattern[0][3], 
    //     current_block_pattern[1][0], current_block_pattern[3][1], current_block_pattern[2][3], current_block_pattern[0][2], 
    //     current_block_pattern[2][0], current_block_pattern[3][2], current_block_pattern[1][3], current_block_pattern[0][1], 
    //     current_block_pattern[1][1], current_block_pattern[2][1], current_block_pattern[2][2], current_block_pattern[1][2]}), 
    // .done(rotation_done[]), .Q({rotated_pattern[0][0], rotated_pattern[3][0], rotated_pattern[3][3], rotated_pattern[0][3], 
    //     rotated_pattern[1][0], rotated_pattern[3][1], rotated_pattern[2][3], rotated_pattern[0][2], 
    //     rotated_pattern[2][0], rotated_pattern[3][2], rotated_pattern[1][3], rotated_pattern[0][1], 
    //     rotated_pattern[1][1], rotated_pattern[2][1], rotated_pattern[2][2], rotated_pattern[1][2]})
    // ); 

// Line clear logic
logic eval_complete;
logic [4:0] eval_row; 
// Collision detection signals
logic collision_bottom, collision_left, collision_right;

// Block type counter
logic [2:0] current_state_counter;
counter count (.clk(clk), .rst(reset), .button_i(current_state == SPAWN),
.current_state_o(current_state_counter), .counter_o());

// block generation 
blockgen block_generation (.current_block_type(current_state_counter), .current_block_pattern(blockgen_pattern)); 

// State Register
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset)
        current_state <= INIT;
    else 
        current_state <= next_state;
end

// line clear
// always_ff @(posedge clk, posedge reset) begin
//     if (reset) begin
//         eval_row <= 5'd19;
//         eval_complete <= 1'b0;
//         cleared_array  <= '0;
//         score <= 8'd0;
//     end
//     else if (current_state == LANDED) begin
//         eval_row         <= 5'd19;
//         eval_complete    <= 1'b0;
//         cleared_array    <= stored_array;
//     end
//     else if (current_state == EVAL) begin
//         if (&cleared_array[eval_row]) begin
//             // full line → score and flag
//             if (score < 8'd255)
//                 score <= score + 1;

//             // constant 0–19 loop, shift rows ≤ eval_row down by one
//             for (logic [4:0] k = 0; k < 20; k = k + 1) begin
//                 if      (k == 0)         begin cleared_array[0] <= '0; end 
//                 else if (k <= eval_row)  begin cleared_array[k] <= cleared_array[k-1]; end 
//                 else                     begin cleared_array[k] <= cleared_array[k]; end 
//             end
//             // stay on the same eval_row for cascading
//         end
//         else begin
//             if (eval_row == 0)
//                 eval_complete <= 1'b1;
//             else
//                 eval_row <= eval_row - 1;
//         end
//     end
// end


// Block position management
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        blockY <= 5'd0;
        blockX <= 4'd3;  // Center position for 4x4 block
        // current_block_type <= 0;
    end else begin 
    
        if (current_state == SPAWN) begin
            blockY <= 5'd0;
            blockX <= 4'd3;  // Center position for 4x4 block
            // current_block_type <= current_state_counter;
            current_block_pattern <= blockgen_pattern; 
        end else if (current_state == ROTATE) begin 
            current_block_pattern <= rotated_pattern; 
        end else if (current_state == FALLING) begin
            // Handle vertical movement
            if (!collision_bottom) begin
                blockY <= blockY + 5'd1;
            end
        
            // Handle horizontal movement
            if (left_i && !collision_left) begin
                blockX <= blockX - 4'd1;
            end else if (right_i && !collision_right) begin
                blockX <= blockX + 4'd1;
            end
        end
    end
end


// Update stored array after evaluation
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        stored_array <= '0;
    end else if (current_state == LANDED) begin
        stored_array <= stored_array | falling_block_display;
    end else if (current_state == EVAL && eval_complete) begin
        stored_array <= cleared_array;
    end
end

logic [19:0][9:0] falling_block_display;
logic [4:0] row_ext;
logic [3:0] col_ext;
logic [4:0] abs_row;
logic [3:0] abs_col;

logic [15:0] collision_block_pattern = current_block_pattern; 
logic [4:0] row, col; 
logic [4:0] index; 

always_ff @(posedge clk, posedge reset) begin 
    if (reset) begin 
        index <= 0; 
    end else if (current_state == FALLING) begin 
        if (index < 'd15) begin 
            index <= index + 'd1; 
        end else begin 
            index <= 0; 
        end 
    end
end

always_comb begin
    collision_bottom       = 1'b0;
    collision_left         = 1'b0;
    collision_right        = 1'b0;
    falling_block_display  = '0;

    // 4×4 nested loop over the current tetromino pattern
    for (int row = 0; row < 4; row++) begin
        for (int col = 0; col < 4; col++) begin

        // for (int index = 0; index < 5'd16; index++) begin 
            // row = index[4:0] / 'd4; 
            // col = index[4:0] % 'd4; 
            row_ext = {3'b000, row[1:0]}; 
            col_ext = {2'b00, col[1:0]}; 

            abs_row = blockY + row_ext; 
            abs_col = blockX + col_ext;
            if (current_block_pattern[row][col[1:0]]) begin
                // draw the pixel
                if (abs_row < 5'd20 && abs_col < 4'd10) begin 
                    falling_block_display[abs_row][abs_col] = 1'b1;        
                end 
                // bottom collision
                if (abs_row + 1 >= 5'd20 ||
                   ((abs_row + 1) < 5'd20 &&
                    stored_array[abs_row + 1][abs_col])) begin 
                    collision_bottom = 1'b1;
                    end

                // left collision
                if (abs_col == 0 ||
                   (abs_col > 0 && stored_array[abs_row][abs_col - 1]))
                    collision_left = 1'b1;

                // right collision
                if (abs_col + 1 >= 4'd10 ||
                   ((abs_col + 1) < 4'd10 &&
                    stored_array[abs_row][abs_col + 1]))
                    collision_right = 1'b1;
            end

            end
        end

    // end 
end

    // logic [4:0] process_counter;
    // logic [1:0] current_row, current_col;
    // logic processing_complete;

    // Counter for sequential processing
    // always_ff @(posedge clk, posedge reset) begin
    //     if (reset) begin
    //         process_counter <= 'd0;
    //         processing_complete <= 1'b0;
    //     end else if (current_state == FALLING || current_state == SPAWN) begin
    //         if (process_counter < 'd15) begin
    //             process_counter <= process_counter + 1;
    //             processing_complete <= 1'b0;
    //         end else begin
    //             process_counter <= 'd0;
    //             processing_complete <= 1'b1;
    //         end
    //     end else begin
    //         process_counter <= 'd0;
    //         processing_complete <= 1'b0;
    //     end
    // end

    // // Convert counter to row/col
    // assign current_row = process_counter[3:2];
    // assign current_col = process_counter[1:0];

    // // Sequential collision detection and display update
    // always_ff @(posedge clk, posedge reset) begin
    //     if (reset) begin
    //         collision_bottom <= 1'b0;
    //         collision_left <= 1'b0;
    //         collision_right <= 1'b0;
    //         falling_block_display <= '0;
    //     end else if (current_state == FALLING || current_state == SPAWN) begin
    //         if (process_counter == 'd0) begin
    //             // Reset at start of processing
    //             collision_bottom <= 1'b0;
    //             collision_left <= 1'b0;
    //             collision_right <= 1'b0;
    //             falling_block_display <= '0;
    //         end else if (process_counter < 5'd16) begin
    //             // Process current pixel
    //             row_ext = {3'b00, current_row};
    //             col_ext = {2'b00, current_col};
    //             abs_row = blockY + row_ext;
    //             abs_col = blockX + col_ext;
                
    //             if (current_block_pattern[current_row][current_col]) begin
    //                 // Update display
    //                 if (abs_row < 5'd20 && abs_col < 4'd10) begin
    //                     falling_block_display[abs_row][abs_col] <= 1'b1;
    //                 end
                    
    //                 // Check collisions
    //                 if (abs_row + 1 >= 5'd20 || 
    //                 ((abs_row + 1) < 5'd20 && stored_array[abs_row + 1][abs_col])) begin
    //                     collision_bottom <= 1'b1;
    //                 end
                    
    //                 if (abs_col == 0 || 
    //                 (abs_col > 0 && stored_array[abs_row][abs_col - 1])) begin
    //                     collision_left <= 1'b1;
    //                 end
                    
    //                 if (abs_col + 1 >= 4'd10 || 
    //                 ((abs_col + 1) < 4'd10 && stored_array[abs_row][abs_col + 1])) begin
    //                     collision_right <= 1'b1;
    //                 end
    //             end
    //         end
    //     end
    // end
// Tetris FSM logic 
always_comb begin
    next_state = current_state;

    case (current_state)
        INIT: begin
            if (start_i)
                next_state = SPAWN;
            display_array = stored_array;
        end
        SPAWN: begin
            next_state = FALLING;
            display_array = falling_block_display | stored_array;
        end
        FALLING: begin
                if (collision_bottom) begin 
                    next_state = STUCK;
                end else if (current_state_counter != 'd1 && (rotate_r || rotate_l)) begin // square doesn't matter
                    next_state = ROTATE; 
                end 
            display_array = falling_block_display | stored_array;

        end
        STUCK: begin 
            if (|stored_array[0])
                next_state = GAMEOVER;
            else
                next_state = LANDED;
            display_array = falling_block_display | stored_array;
        end
        ROTATE: begin 
            display_array = falling_block_display | stored_array;
            if (collision_bottom) begin 
                next_state = STUCK; 
            end else if (rotation_done == 4'b1111) begin 
                next_state = FALLING; 
            end 
        end
        LANDED: begin
            next_state = EVAL;
            display_array = stored_array;
        end
        EVAL: begin
            if (eval_complete) begin 
                next_state = SPAWN;
            end 
            display_array = cleared_array;
        end
        GAMEOVER: begin
            next_state = GAMEOVER;
            display_array = stored_array;
        end
        default: begin
            next_state = INIT;
            display_array = stored_array;
        end
    endcase
end

endmodule
