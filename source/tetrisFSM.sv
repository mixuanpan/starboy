module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, start_i, rotate_r, rotate_l, speed_up_i,
    output logic [19:0][9:0] display_array,
    output logic gameover,
    output logic [7:0] score,
    output logic speed_mode_o
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
logic [3:0][3:0] current_block_pattern;
logic eval_complete;
logic rotate_direction;

// Collision detection signals
logic collision_bottom, collision_left, collision_right;

// NEW: Delayed sticking logic
logic collision_bottom_prev;  // Previous state of collision_bottom
logic stick_delay_active;     // Flag to indicate we're in the delay period

// Block type counter
logic [2:0] current_state_counter;
logic rotate_pulse, left_pulse, right_pulse, rotate_pulse_l; 
logic speed_up_sync_level, speed_mode;

always_comb begin
    speed_mode = speed_up_sync_level;
end
assign speed_mode_o = speed_mode;
                       
// Line clear module signals
logic start_line_eval;
logic line_eval_complete;
logic [19:0][9:0] line_clear_input;
logic [19:0][9:0] line_clear_output;
logic [7:0] line_clear_score;

assign score = line_clear_score;

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

// NEW: Track previous collision state and manage stick delay
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        collision_bottom_prev <= 1'b0;
        stick_delay_active <= 1'b0;
    end else if (current_state == FALLING) begin
        collision_bottom_prev <= collision_bottom;
        
        // Start delay when collision first detected
        if (collision_bottom && !collision_bottom_prev) begin
            stick_delay_active <= 1'b1;
        end
        // Clear delay if collision is resolved (piece moved away)
        else if (!collision_bottom) begin
            stick_delay_active <= 1'b0;
        end
    end else begin
        // Reset delay when not in FALLING state
        stick_delay_active <= 1'b0;
        collision_bottom_prev <= 1'b0;
    end
end

// State Register 
always_ff @(posedge clk, posedge reset) begin
    if (reset)
        current_state <= INIT;
    else
        current_state <= next_state;
end

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
        // Don't drop if we're colliding with bottom
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
        if (collision_left) begin
            if (current_block_type == 'd7) begin
                blockX <= blockX + 2;   // nudge right by 2 for I horizontal
            end else begin
                blockX <= blockX + 1;   // nudge right by 1 for other pieces
            end
        end else if (collision_right) begin
            if (current_block_type == 'd7) begin
                blockX <= blockX - 2;   // nudge left by 2 for I horizontal
            end else begin
                blockX <= blockX - 1;   // nudge left by 1 for other pieces
            end
        end
    end
end

always_comb begin
    // Default assignment
    next_current_block_type = current_block_type;
    if (current_state == ROTATE) begin 
        if (rotate_direction == 0) begin // Clockwise (right rotation)
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
        end else begin // Counter-clockwise (left rotation)
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

                // L piece (4 orientations) - REVERSED
                'd5:  next_current_block_type = 'd15;  // L 0°  → L 270°
                'd15: next_current_block_type = 'd14;  // L 270°→ L 180°
                'd14: next_current_block_type = 'd13;  // L 180°→ L 90°
                'd13: next_current_block_type = 'd5;   // L 90° → L 0°

                // J piece (4 orientations) - REVERSED
                'd4:  next_current_block_type = 'd12;  // J 0°  → J 270°
                'd12: next_current_block_type = 'd11;  // J 270°→ J 180°
                'd11: next_current_block_type = 'd10;  // J 180°→ J 90°
                'd10: next_current_block_type = 'd4;   // J 90° → J 0°

                // T piece (4 orientations) - REVERSED
                'd6:  next_current_block_type = 'd16;  // T 0°  → T 270°
                'd16: next_current_block_type = 'd17;  // T 270°→ T 180°
                'd17: next_current_block_type = 'd18;  // T 180°→ T 90°
                'd18: next_current_block_type = 'd6;   // T 90° → T 0°

                default: next_current_block_type = current_block_type;
            endcase
        end
    end 
end

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
    next_state = current_state;
    gameover = (current_state == GAMEOVER);
    
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
            // MODIFIED: Only transition to STUCK if we've been colliding for one full drop_tick
            if (collision_bottom && stick_delay_active && drop_tick) begin 
                next_state = STUCK;
            end else if (current_block_type != 'd1 && (rotate_pulse || rotate_pulse_l)) begin // square doesn't matter
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

//Module Instantiations

counter paolowang (
    .clk(clk), 
    .rst(reset), 
    .enable('b1),
    .block_type(current_state_counter)
);

lineclear mangomango (
    .clk(clk),
    .reset(reset),
    .start_eval(start_line_eval),
    .input_array(line_clear_input),
    .output_array(line_clear_output),
    .eval_complete(line_eval_complete),
    .score(line_clear_score)
);

synckey alexanderweyerthegreat (
    .rst(reset), 
    .clk(clk), 
    .in({19'b0, rotate_r}), 
    .strobe(rotate_pulse)
); 

synckey lanadelrey (
    .rst(reset), 
    .clk(clk), 
    .in({19'b0, rotate_l}), 
    .strobe(rotate_pulse_l)
); 

synckey puthputhboy (
    .rst(reset), 
    .clk(clk), 
    .in({19'b0, left_i}), 
    .strobe(left_pulse)
); 

synckey JohnnyTheKing (
    .rst(reset), 
    .clk(clk), 
    .in({19'b0, right_i}), 
    .strobe(right_pulse)
); 

button_sync brawlstars(
    .rst(reset), 
    .clk(clk), 
    .button_in(speed_up_i), 
    .button_sync_out(speed_up_sync_level)
);

blockgen swabey (
    .current_block_type(current_block_type),
    .current_block_pattern(current_block_pattern)
);

endmodule
