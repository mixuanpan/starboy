`default_nettype none
module t01_ai_tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, 
    input logic right_i, left_i, start_i, rotate_r, rotate_l, speed_up_i,
    output logic [19:0][9:0] display_array,
    output logic gameover,
    output logic [7:0] score,
    output logic speed_mode_o,
    
    // AI interface
    output logic [4:0] current_piece_type,
    input logic ai_enable,
    input logic [5:0] ai_best_move_id,
    input logic ai_done
);

    // FSM State Definitions
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

    // state variables
    game_state_t current_state, next_state;

    // game board arrays
    logic [19:0][9:0] stored_array;
    logic [19:0][9:0] cleared_array;

    // block Position and type
    logic [4:0] blockY;
    logic [3:0] blockX;
    logic [4:0] current_block_type_internal;
    logic [3:0][3:0] current_block_pattern;
    logic [3:0][3:0] next_block_pattern;

    // control signals
    logic eval_complete;
    logic rotate_direction;
    logic [2:0] current_state_counter;
    logic rotation_valid;

    // collision detection
    logic collision_bottom, collision_left, collision_right;

    // delayed sticking logic 
    logic collision_bottom_prev;
    logic stick_delay_active; 

    // input synchronization
    logic rotate_pulse, left_pulse, right_pulse, rotate_pulse_l;
    logic speed_up_sync_level, speed_mode;

    // drop timing control
    logic onehuzz_sync0, onehuzz_sync1, drop_tick;

    // line clear module interface
    logic start_line_eval;
    logic line_eval_complete;
    logic [19:0][9:0] line_clear_input;
    logic [19:0][9:0] line_clear_output;
    logic [7:0] line_clear_score;

    // AI control signals
    logic ai_move_executed;
    logic [5:0] ai_move_cache;
    logic ai_done_prev;
    logic ai_move_trigger;
    
    // AI move decoding
    logic [1:0] ai_rotation;
    logic [3:0] ai_x_position;
    logic ai_rotate_cmd, ai_left_cmd, ai_right_cmd;

    // output Assignments
    assign score = line_clear_score;
    assign speed_mode_o = speed_up_sync_level;
    assign current_piece_type = current_block_type_internal;

    //=============================================================================
    // AI CONTROL LOGIC
    //=============================================================================
    
    // Detect AI done edge and cache the move
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ai_done_prev <= 1'b0;
            ai_move_cache <= 6'b0;
            ai_move_executed <= 1'b0;
        end else begin
            ai_done_prev <= ai_done;
            
            // Cache AI move when it becomes available
            if (ai_done && !ai_done_prev && ai_enable) begin
                ai_move_cache <= ai_best_move_id;
                ai_move_executed <= 1'b0;
            end
            
            // Mark move as executed when we act on it
            if (ai_move_trigger) begin
                ai_move_executed <= 1'b1;
            end
            
            // Reset when spawning new piece
            if (current_state == SPAWN) begin
                ai_move_executed <= 1'b0;
            end
        end
    end

    // Decode AI move (assuming move_id encodes rotation[1:0] and x_position[3:0])
    assign ai_rotation = ai_move_cache[5:4];
    assign ai_x_position = ai_move_cache[3:0];
    
    // Generate AI movement commands
    assign ai_move_trigger = ai_enable && ai_done && !ai_move_executed && (current_state == FALLING);
    
    always_comb begin
        ai_rotate_cmd = 1'b0;
        ai_left_cmd = 1'b0;
        ai_right_cmd = 1'b0;
        
        if (ai_move_trigger) begin
            // Check if rotation is needed (simple example - you may need more complex logic)
            case (current_block_type_internal[4:2]) // Get base piece type
                3'b000: begin // I-piece
                    if ((current_block_type_internal == 5'd0 && ai_rotation[0]) || 
                        (current_block_type_internal == 5'd7 && !ai_rotation[0])) begin
                        ai_rotate_cmd = 1'b1;
                    end
                end
                3'b001: begin // S-piece  
                    if ((current_block_type_internal == 5'd2 && ai_rotation[0]) || 
                        (current_block_type_internal == 5'd9 && !ai_rotation[0])) begin
                        ai_rotate_cmd = 1'b1;
                    end
                end
                3'b010: begin // Z-piece
                    if ((current_block_type_internal == 5'd3 && ai_rotation[0]) || 
                        (current_block_type_internal == 5'd8 && !ai_rotation[0])) begin
                        ai_rotate_cmd = 1'b1;
                    end
                end
                // Add more cases for other pieces as needed
                default: begin
                    // For pieces with 4 rotations, use more complex logic
                    if (ai_rotation != current_block_type_internal[1:0]) begin
                        ai_rotate_cmd = 1'b1;
                    end
                end
            endcase
            
            // Horizontal movement commands
            if (ai_x_position > blockX) begin
                ai_right_cmd = 1'b1;
            end else if (ai_x_position < blockX) begin
                ai_left_cmd = 1'b1;
            end
        end
    end

    //=============================================================================
    // drop timing !!!
    //=============================================================================
    
    // synchronize onehuzz signal to create drop_tick pulse
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            onehuzz_sync0 <= 1'b0;
            onehuzz_sync1 <= 1'b0;
        end else begin
            onehuzz_sync0 <= onehuzz;
            onehuzz_sync1 <= onehuzz_sync0;
        end
    end

    assign drop_tick = onehuzz_sync1 & ~onehuzz_sync0;

    //=============================================================================
    // delayed sticking logic !!!
    //=============================================================================
    
    // allows for last-second movement adjustments
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            collision_bottom_prev <= 1'b0;
            stick_delay_active <= 1'b0;
        end else if (current_state == FALLING) begin
            collision_bottom_prev <= collision_bottom;
            if (collision_bottom && !collision_bottom_prev) begin
                stick_delay_active <= 1'b1;
            end
            else if (!collision_bottom) begin
                stick_delay_active <= 1'b0;
            end
        end else begin
            stick_delay_active <= 1'b0;
            collision_bottom_prev <= 1'b0;
        end
    end

    //=============================================================================
    // state register !!!
    //=============================================================================
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            current_state <= INIT;
        else
            current_state <= next_state;
    end

    //=============================================================================
    // block positioning and type management !!!
    //=============================================================================
    
    logic [4:0] next_current_block_type;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            blockY <= 5'd0;
            blockX <= 4'd3;
            current_block_type_internal <= 5'd0;
        end 
        else if (current_state == SPAWN) begin
            blockY <= 5'd0;
            blockX <= 4'd3;
            current_block_type_internal <= {2'b0, current_state_counter};
        end 
        else if (current_state == FALLING) begin
            // vertical movement
            if (drop_tick && !collision_bottom) begin
                blockY <= blockY + 5'd1;
            end
           
            // horizontal movement - AI takes priority over manual input
            if (ai_enable && ai_left_cmd && !collision_left) begin
                blockX <= blockX - 4'd1;
            end else if (ai_enable && ai_right_cmd && !collision_right) begin
                blockX <= blockX + 4'd1;
            end else if (!ai_enable && left_pulse && !collision_left) begin
                blockX <= blockX - 4'd1;
            end else if (!ai_enable && right_pulse && !collision_right) begin
                blockX <= blockX + 4'd1;
            end
        end 
        else if (current_state == ROTATE) begin
            if (rotation_valid) begin
                current_block_type_internal <= next_current_block_type;
            end else begin
                current_block_type_internal <= current_block_type_internal;
            end
        end
    end

    //=============================================================================
    // rotation logic !!!
    //=============================================================================

    always_comb begin
        next_current_block_type = current_block_type_internal;
        
        if (current_state == ROTATE) begin
            if (rotate_direction == 1'b0) begin // Clockwise rotation
                case (current_block_type_internal)
                    // I-piece: 2 orientations
                    5'd0:  next_current_block_type = 5'd7;   // Vertical → Horizontal
                    5'd7:  next_current_block_type = 5'd0;   // Horizontal → Vertical

                    // O-piece: No rotation needed
                    5'd1:  next_current_block_type = 5'd1;

                    // S-piece: 2 orientations
                    5'd2:  next_current_block_type = 5'd9;   // Horizontal → Vertical
                    5'd9:  next_current_block_type = 5'd2;   // Vertical → Horizontal

                    // Z-piece: 2 orientations
                    5'd3:  next_current_block_type = 5'd8;   // Horizontal → Vertical
                    5'd8:  next_current_block_type = 5'd3;   // Vertical → Horizontal

                    // L-piece: 4 orientations (0° → 90° → 180° → 270°)
                    5'd5:  next_current_block_type = 5'd13;  // 0° → 90°
                    5'd13: next_current_block_type = 5'd14;  // 90° → 180°
                    5'd14: next_current_block_type = 5'd15;  // 180° → 270°
                    5'd15: next_current_block_type = 5'd5;   // 270° → 0°

                    // J-piece: 4 orientations
                    5'd4:  next_current_block_type = 5'd10;  // 0° → 90°
                    5'd10: next_current_block_type = 5'd11;  // 90° → 180°
                    5'd11: next_current_block_type = 5'd12;  // 180° → 270°
                    5'd12: next_current_block_type = 5'd4;   // 270° → 0°

                    // T-piece: 4 orientations
                    5'd6:  next_current_block_type = 5'd18;  // 0° → 90°
                    5'd18: next_current_block_type = 5'd17;  // 90° → 180°
                    5'd17: next_current_block_type = 5'd16;  // 180° → 270°
                    5'd16: next_current_block_type = 5'd6;   // 270° → 0°

                    default: next_current_block_type = current_block_type_internal;
                endcase
            end else begin // Counter-clockwise rotation
                case (current_block_type_internal)
                    // I-piece: Same as clockwise (only 2 states)
                    5'd0:  next_current_block_type = 5'd7;
                    5'd7:  next_current_block_type = 5'd0;

                    // O-piece: No rotation
                    5'd1:  next_current_block_type = 5'd1;

                    // S-piece: Same as clockwise (only 2 states)
                    5'd2:  next_current_block_type = 5'd9;
                    5'd9:  next_current_block_type = 5'd2;

                    // Z-piece: Same as clockwise (only 2 states)
                    5'd3:  next_current_block_type = 5'd8;
                    5'd8:  next_current_block_type = 5'd3;

                    // L-piece: Reverse direction (0° → 270° → 180° → 90°)
                    5'd5:  next_current_block_type = 5'd15;  // 0° → 270°
                    5'd15: next_current_block_type = 5'd14;  // 270° → 180°
                    5'd14: next_current_block_type = 5'd13;  // 180° → 90°
                    5'd13: next_current_block_type = 5'd5;   // 90° → 0°

                    // J-piece: Reverse direction
                    5'd4:  next_current_block_type = 5'd12;  // 0° → 270°
                    5'd12: next_current_block_type = 5'd11;  // 270° → 180°
                    5'd11: next_current_block_type = 5'd10;  // 180° → 90°
                    5'd10: next_current_block_type = 5'd4;   // 90° → 0°

                    // T-piece: Reverse direction
                    5'd6:  next_current_block_type = 5'd16;  // 0° → 270°
                    5'd16: next_current_block_type = 5'd17;  // 270° → 180°
                    5'd17: next_current_block_type = 5'd18;  // 180° → 90°
                    5'd18: next_current_block_type = 5'd6;   // 90° → 0°

                    default: next_current_block_type = current_block_type_internal;
                endcase
            end
        end
    end

    //=============================================================================
    // stored array management !!! 
    //=============================================================================
    
    // Manage the permanently placed blocks
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            stored_array <= '0;
        end 
        else if (current_state == STUCK) begin
            stored_array <= stored_array | falling_block_display;
        end 
        else if (current_state == EVAL && line_eval_complete) begin
            stored_array <= line_clear_output;
        end
    end

    //=============================================================================
    // collision detection logic !!!
    //=============================================================================
    
    logic [19:0][9:0] falling_block_display;
    logic [4:0] row_ext, abs_row;
    logic [3:0] col_ext, abs_col;

    // Generate falling block display and detect collisions
    always_comb begin
        collision_bottom = 1'b0;
        collision_left = 1'b0;
        collision_right = 1'b0;
        falling_block_display = '0;
        rotation_valid = '1; // working

        // check each cell in the 4x4 tetromino pattern
        for (int row = 0; row < 4; row++) begin
            for (int col = 0; col < 4; col++) begin
                row_ext = {3'b000, row[1:0]};
                col_ext = {2'b00, col[1:0]};
                abs_row = blockY + row_ext;
                abs_col = blockX + col_ext;

                // only process cells that contain part of the tetromino
                if (current_block_pattern[row][col]) begin
                    if (abs_row < 5'd20 && abs_col < 4'd10) begin
                        falling_block_display[abs_row][abs_col] = 1'b1;
                    end

                    // bottom collision
                    if (abs_row + 5'd1 >= 5'd20 ||
                       ((abs_row + 5'd1) < 5'd20 && stored_array[abs_row + 5'd1][abs_col])) begin
                        collision_bottom = 1'b1;
                    end

                    // left collision
                    if (abs_col == 4'd0 ||
                       (abs_col > 4'd0 && stored_array[abs_row][abs_col - 4'd1])) begin
                        collision_left = 1'b1;
                    end

                    // right collision
                    if (abs_col + 4'd1 >= 4'd10 ||
                       ((abs_col + 4'd1) < 4'd10 && stored_array[abs_row][abs_col + 4'd1])) begin
                        collision_right = 1'b1;
                    end
                end 
                
                if (next_block_pattern[row][col]) begin
                    if (abs_row > 5'd19 || abs_col > 4'd9) begin
                        rotation_valid = '0;
                    end else if (stored_array[abs_row][abs_col]) begin
                        rotation_valid = '0;
                    end
                end
            end
        end
    end

    //=============================================================================
    // fsm next state logic !!!
    //=============================================================================
    
    always_comb begin
        // Default assignments
        next_state = current_state;
        gameover = (current_state == GAMEOVER);
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
                // Transition to STUCK only after delay period
                if (collision_bottom && stick_delay_active && drop_tick) begin
                    next_state = STUCK;
                end 
                // Handle rotation - AI takes priority, O-piece doesn't rotate
                else if (current_block_type_internal != 5'd1 && 
                        ((ai_enable && ai_rotate_cmd) || 
                         (!ai_enable && (rotate_pulse || rotate_pulse_l)))) begin
                    next_state = ROTATE;
                end
                display_array = falling_block_display | stored_array;
            end

            STUCK: begin
                // Check for game over condition
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

    //=============================================================================
    // module instantiations !!!
    //=============================================================================

    // Block type counter for spawning random pieces
    t01_counter paolowang (
        .clk(clk),
        .rst(reset),
        .enable(1'b1),
        .block_type(current_state_counter)
    );

    // Line clearing logic
    t01_lineclear mangomango (
        .clk(clk),
        .reset(reset),
        .start_eval(start_line_eval),
        .input_array(line_clear_input),
        .output_array(line_clear_output),
        .eval_complete(line_eval_complete),
        .score(line_clear_score)
    );

    // Input synchronizers for button presses
    t01_synckey alexanderweyerthegreat (
        .rst(reset),
        .clk(clk),
        .in({19'b0, rotate_r}),
        .strobe(rotate_pulse)
    );

    t01_synckey lanadelrey (
        .rst(reset),
        .clk(clk),
        .in({19'b0, rotate_l}),
        .strobe(rotate_pulse_l)
    );

    t01_synckey puthputhboy (
        .rst(reset),
        .clk(clk),
        .in({19'b0, left_i}),
        .strobe(left_pulse)
    );

    t01_synckey JohnnyTheKing (
        .rst(reset),
        .clk(clk),
        .in({19'b0, right_i}),
        .strobe(right_pulse)
    );

    // Speed up button synchronizer
    t01_button_sync brawlstars (
        .rst(reset),
        .clk(clk),
        .button_in(speed_up_i),
        .button_sync_out(speed_up_sync_level)
    );

    // Block pattern generator
    t01_blockgen swabey (
        .current_block_type(current_block_type_internal),
        .current_block_pattern(current_block_pattern)
    );

    t01_blockgen yebaws (
        .current_block_type(next_current_block_type),
        .current_block_pattern(next_block_pattern)
    );

endmodule