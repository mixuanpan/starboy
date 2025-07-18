module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, start_i, rotate_r, rotate_l,  
    output logic [19:0][9:0] display_array,
    output logic gameover,
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

logic [19:0][9:0] stored_array;
logic [19:0][9:0] cleared_array;

logic [4:0] blockY;
logic [3:0] blockX;
logic [4:0] current_block_type;

// Block representation as 4x4 grid for rotation support
logic [3:0][3:0] current_block_pattern;

// Line clear logic
// logic [4:0] eval_row;
// logic line_clear_found;
logic eval_complete;

// Collision detection signals
logic collision_bottom, collision_left, collision_right;

// Block type counter
logic [2:0] current_state_counter;
counter paolowang (.clk(clk), .rst(reset), .button_i(current_state == SPAWN),
.current_state_o(current_state_counter), .counter_o());

logic rotate_pulse, left_pulse, right_pulse; 
synckey alexanderweyerthegreat (.rst(reset) , .clk(clk), .in({19'b0, rotate_r}), .strobe(rotate_pulse)); 
synckey puthputhboy (.rst(reset) , .clk(clk), .in({19'b0, left_i}), .strobe(left_pulse)); 
synckey JohnnyTheKing (.rst(reset) , .clk(clk), .in({19'b0, right_i}), .strobe(right_pulse)); 


blockgen swabey (
    .current_block_type(current_block_type),
    .current_block_pattern(current_block_pattern)
);
// In your main tetrisFSM module, you'd add:

// Line clear module signals
logic start_line_eval;
logic line_eval_complete;
logic [19:0][9:0] line_clear_input;
logic [19:0][9:0] line_clear_output;
logic [7:0] line_clear_score;

// Instantiate the line clear module
lineclear mangomango (
    .clk(clk),
    .reset(reset),
    .start_eval(start_line_eval),
    .input_array(line_clear_input),
    .output_array(line_clear_output),
    .eval_complete(line_eval_complete),
    .score(line_clear_score)
);
// Pulse sync for onehuzz (vertical movement timing)
logic onehuzz_sync0, onehuzz_sync1;
logic drop_tick;
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        onehuzz_sync0 <= 0;
        onehuzz_sync1 <= 0;
    end else begin
        onehuzz_sync0 <= onehuzz;
        onehuzz_sync1 <= onehuzz_sync0;
    end
end

assign drop_tick = onehuzz_sync1 & ~onehuzz_sync0;

// State Register - now on clk for smoother transitions
always_ff @(posedge clk, posedge reset) begin
    if (reset)
        current_state <= INIT;
    else
        current_state <= next_state;
end

// Line clear logic - on clk for smooth operation
//  logic [4:0] next_eval_row;
// logic next_line_clear_found;
// logic next_eval_complete;
// logic [19:0][9:0] next_cleared_array;
// logic [7:0] next_score;

// // Sequential logic for line clear
// always_ff @(posedge clk, posedge reset) begin
//     if (reset) begin
//         eval_row <= 5'd19;
//         line_clear_found <= 1'b0;
//         eval_complete <= 1'b0;
//         cleared_array <= '0;
//         score <= 8'd0;
//     end
//     else begin
//         eval_row <= next_eval_row;
//         line_clear_found <= next_line_clear_found;
//         eval_complete <= next_eval_complete;
//         cleared_array <= next_cleared_array;
//         score <= next_score;
//     end
// end

// // Combinational logic for line clear
// always_comb begin
//     // Default assignments
//     next_eval_row = eval_row;
//     next_line_clear_found = line_clear_found;
//     next_eval_complete = eval_complete;
//     next_cleared_array = cleared_array;
//     next_score = score;

//     if (current_state == LANDED) begin
//         // Initialize evaluation
//         next_eval_row = 5'd19;
//         next_line_clear_found = 1'b0;
//         next_eval_complete = 1'b0;
//         next_cleared_array = stored_array;
//     end
//     else if (current_state == EVAL) begin
//         if (&cleared_array[eval_row]) begin
//             // Full line found - clear it
//             next_line_clear_found = 1'b1;
           
//             // Increment score if not at max
//             if (score < 8'd255)
//                 next_score = score + 1;

//             // Shift rows down
//             for (logic [4:0] k = 0; k < 20; k = k + 1) begin
//                 if (k == 0)
//                     next_cleared_array[0] = '0;
//                 else if (k <= eval_row)
//                     next_cleared_array[k] = cleared_array[k-1];
//                 else
//                     next_cleared_array[k] = cleared_array[k];
//             end
           
//             // Stay on same row for cascading clears
//             next_eval_row = eval_row;
//         end
//         else begin
//             // No full line, move to next row
//             if (eval_row == 0)
//                 next_eval_complete = 1'b1;
//             else
//                 next_eval_row = eval_row - 1;
//         end
//     end
// end


// Block position management 
logic [4:0] next_blockY;
logic [3:0] next_blockX;
logic [4:0] next_current_block_type;


// Sequential logic for block position and type updates
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        blockY <= 5'd0;
        blockX <= 4'd3;  // Center position for 4x4 block
        current_block_type <= 0;
    end else if (current_state == SPAWN) begin
        blockY <= 5'd0;
        blockX <= 4'd3;  // Center position for 4x4 block
        current_block_type <= {2'b0,current_state_counter};
    end else if (current_state == FALLING) begin
        // Handle vertical movement - only on drop_tick (synchronized onehuzz)
        if (drop_tick && !collision_bottom) begin
            blockY <= blockY + 5'd1;
        end
       
        // Handle horizontal movement - on every clk cycle for smooth movement
        if (left_pulse && !collision_left) begin
            blockX <= blockX - 4'd1;
        end else if (right_pulse && !collision_right) begin
            blockX <= blockX + 4'd1;
        end
    end else if (current_state == ROTATE) begin 
        current_block_type <= next_current_block_type;
        
        // Wall kick logic for rotation
        if (collision_left)  blockX <= blockX + 1;   // nudge right
        else if (collision_right) blockX <= blockX - 1; // nudge left
    end 
end


// Combinational logic for rotation type calculation
always_comb begin
    // Default assignment
    next_current_block_type = current_block_type;
    
    if (current_state == ROTATE) begin 
        case (current_block_type)
            // I piece (2 orientations)
            'd0:  next_current_block_type = 'd7;   // I vertical → I horizontal
            'd7:  next_current_block_type = 'd0;   // I horizontal → I vertical

            // O piece (1 orientation, no change)
            'd1:  next_current_block_type = 'd1;

            // S piece (2 orientations)
            'd2:  next_current_block_type = 'd9;   // S horizontal → S vertical
            'd9:  next_current_block_type = 'd2;   // S vertical → S horizontal

            // Z piece (2 orientations)
            'd3:  next_current_block_type = 'd8;   // Z horizontal → Z vertical
            'd8:  next_current_block_type = 'd3;   // Z vertical → Z horizontal

            // L piece (4 orientations)
            'd5:  next_current_block_type = 'd13;  // L 0°  → L 90°
            'd13: next_current_block_type = 'd14;  // L 90° → L 180°
            'd14: next_current_block_type = 'd15;  // L 180°→ L 270°
            'd15: next_current_block_type = 'd5;   // L 270°→ L 0°

            // J piece (4 orientations)
            'd4:  next_current_block_type = 'd10;  // J 0°  → J 90°
            'd10: next_current_block_type = 'd11;  // J 90° → J 180°
            'd11: next_current_block_type = 'd12;  // J 180°→ J 270°
            'd12: next_current_block_type = 'd4;   // J 270°→ J 0°

            // T piece (4 orientations)
            'd6:  next_current_block_type = 'd18;  // T 0°  → T 90°
            'd18: next_current_block_type = 'd17;  // T 90° → T 180°
            'd17: next_current_block_type = 'd16;  // T 180°→ T 270°
            'd16: next_current_block_type = 'd6;   // T 270°→ T 0°

            default: next_current_block_type = current_block_type;
        endcase
    end 
end

// Update stored array after evaluation - on clk
// always_ff @(posedge clk, posedge reset) begin
//     if (reset) begin
//         stored_array <= '0;
//     end else if (current_state == STUCK) begin
//         // Store the block as soon as we detect it's stuck
//         stored_array <= stored_array | falling_block_display;
//     end else if (current_state == EVAL && eval_complete) begin
//         stored_array <= cleared_array;
//     end
// end
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        stored_array <= '0;
    end else if (current_state == STUCK) begin
        // Store the block as soon as we detect it's stuck
        stored_array <= stored_array | falling_block_display;
    end else if (current_state == EVAL && line_eval_complete) begin
        // Update stored_array with cleared result when line clearing is complete
        stored_array <= line_clear_output;
    end
end

logic [19:0][9:0] falling_block_display;
logic [4:0] row_ext;
logic [3:0] col_ext;
logic [4:0] abs_row;
logic [3:0] abs_col;

//collision logic
always_comb begin
    collision_bottom       = 1'b0;
    collision_left         = 1'b0;
    collision_right        = 1'b0;
    falling_block_display  = '0;

    // 4×4 nested loop over the current tetromino pattern
    for (int row = 0; row < 4; row++) begin
        for (int col = 0; col < 4; col++) begin
            row_ext = {3'b000, row[1:0]}; 
            col_ext = {2'b00, col[1:0]}; 

            abs_row = blockY + row_ext; 
            abs_col = blockX + col_ext;

            if (current_block_pattern[row][col]) begin
                // draw the pixel
                if (abs_row < 5'd20 && abs_col < 4'd10) begin 
                    falling_block_display[abs_row][abs_col] = 1'b1;        
                end 
                // bottom collision
                if (abs_row + 1 >= 5'd20 ||
                   ((abs_row + 1) < 5'd20 &&
                    stored_array[abs_row + 1][abs_col]))
                    collision_bottom = 1'b1;

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
end
always_comb begin
    next_state         = current_state;
    gameover           = (current_state == GAMEOVER);
    
    // Default assignments for control signals
    start_line_eval = 1'b0;
    line_clear_input = stored_array;

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
            // Check for bottom collision - can happen any time, but only drop on drop_tick
            if (collision_bottom) begin 
                next_state = STUCK;
            end else if (current_block_type != 'd1 && rotate_pulse) begin // square doesn't matter
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
            next_state = FALLING;   
        end
        LANDED: begin
            next_state = EVAL;
            display_array = stored_array;
            start_line_eval = 1'b1;
            line_clear_input = stored_array;
        end
        EVAL: begin
            // Don't assign stored_array here - it's handled in always_ff
            if (line_eval_complete) begin
                next_state = SPAWN;
            end
            display_array = line_clear_output;
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
// always_comb begin
//     next_state         = current_state;
//     gameover           = (current_state == GAMEOVER);

//     case (current_state)
//         INIT: begin
//             if (start_i)
//                 next_state = SPAWN;
//             display_array = stored_array;
//         end
//         SPAWN: begin
//             next_state = FALLING;
//             display_array = falling_block_display | stored_array;
//         end
//         FALLING: begin
//             // Check for bottom collision - can happen any time, but only drop on drop_tick
//             if (collision_bottom) begin 
//                 next_state = STUCK;
//             end else if (current_block_type != 'd1 && rotate_pulse) begin // square doesn't matter
//                 next_state = ROTATE; 
//             end 
//             display_array = falling_block_display | stored_array;
//         end
//         STUCK: begin 
//             if (|stored_array[0])
//                 next_state = GAMEOVER;
//             else
//                 next_state = LANDED;
//             display_array = falling_block_display | stored_array;
//         end
//         ROTATE: begin 
//             display_array = falling_block_display | stored_array;
//             next_state = FALLING;   
//         end
//         LANDED: begin
//             next_state = EVAL;
//             display_array = stored_array;
//             start_line_eval = 1'b1;
//             line_clear_input = stored_array;
//         end
//         EVAL: begin
//         start_line_eval = 1'b0; // Clear the start signal
//         if (line_eval_complete) begin
//             next_state = SPAWN;
//             // Update stored_array with cleared result
//             stored_array = line_clear_output;
//         end
//         display_array = line_clear_output;
//         end
//         GAMEOVER: begin
//             next_state = GAMEOVER;
//             display_array = stored_array;
//         end
//         default: begin
//             next_state = INIT;
//             display_array = stored_array;
//         end
//     endcase
// end
 assign score = line_clear_score;
 endmodule 
