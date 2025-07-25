`default_nettype none 
module tetris_fsm (
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
logic [3:0][3:0] current_block_pattern, n_bp, blockgen_pattern, rotated_pattern;

// Block representation as 4x4 grid for rotation support
// logic [3:0][3:0] current_block_pattern, blockgen_pattern, rotated_pattern;
logic rotation_en; 
logic [1:0] rotate; 
logic [3:0] rotate_complete; 
assign rotate = {rotate_l, rotate_r}; 
shift_reg traingle (.clk(clk), .rst(reset), .en(rotation_en), .mode_i(rotate),
    .par_i({current_block_pattern[0][0], current_block_pattern[3][0], current_block_pattern[3][3], current_block_pattern[0][3]}), 
    .done(rotate_complete[0]), .Q({rotated_pattern[0][0], rotated_pattern[3][0], rotated_pattern[3][3], rotated_pattern[0][3]})
);
shift_reg circle (.clk(clk), .rst(reset), .en(rotation_en), .mode_i(rotate),
    .par_i({current_block_pattern[1][0], current_block_pattern[3][1], current_block_pattern[2][3], current_block_pattern[0][2]}), 
    .done(rotate_complete[1]), .Q({rotated_pattern[1][0], rotated_pattern[3][1], rotated_pattern[2][3], rotated_pattern[0][2]})
);
shift_reg bigx (.clk(clk), .rst(reset), .en(rotation_en), .mode_i(rotate),
    .par_i({current_block_pattern[2][0], current_block_pattern[3][2], current_block_pattern[1][3], current_block_pattern[0][1]}), 
    .done(rotate_complete[2]), .Q({rotated_pattern[2][0], rotated_pattern[3][2], rotated_pattern[1][3], rotated_pattern[0][1]})
);
shift_reg square (.clk(clk), .rst(reset), .en(rotation_en), .mode_i(rotate),
    .par_i({current_block_pattern[1][1], current_block_pattern[2][1], current_block_pattern[2][2], current_block_pattern[1][2]}), 
    .done(rotate_complete[3]), .Q({rotated_pattern[1][1], rotated_pattern[2][1], rotated_pattern[2][2], rotated_pattern[1][2]})
);

// Line clear logic
logic [4:0] eval_row;
logic eval_complete;

// Collision detection signals
logic collision_bottom, collision_left, collision_right;

// Block type counter
logic [2:0] current_state_counter;
counter count (.clk(clk), .rst(reset), .button_i(current_state == SPAWN),
.current_state_o(current_state_counter), .counter_o());

// block generation 
// blockgen block_generation (.current_block_type(current_block_type), .current_block_pattern(blockgen_pattern)); 

    always_comb begin
        blockgen_pattern = 0; 
        case (current_block_type)
            // I piece
            'd0: begin // I vertical
                blockgen_pattern[0][1] = 1;
                blockgen_pattern[1][1] = 1;
                blockgen_pattern[2][1] = 1;
                blockgen_pattern[3][1] = 1;
            end
            // 'd7: begin // I horizontal
            //     blockgen_pattern[1][0] = 1;
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[1][2] = 1;
            //     blockgen_pattern[1][3] = 1;
            // end

            // O piece
            'd1: begin // O
                blockgen_pattern[0][1] = 1;
                blockgen_pattern[0][2] = 1;
                blockgen_pattern[1][1] = 1;
                blockgen_pattern[1][2] = 1;
            end

            // S piece
            'd2: begin // S horizontal
                blockgen_pattern[0][2] = 1;
                blockgen_pattern[0][3] = 1;
                blockgen_pattern[1][1] = 1;
                blockgen_pattern[1][2] = 1;
            end
            // 'd8: begin // S vertical
            //     blockgen_pattern[1][2] = 1;
            //     blockgen_pattern[2][2] = 1;
            //     blockgen_pattern[2][1] = 1;
            //     blockgen_pattern[3][1] = 1;
            // end

            // Z piece
            'd3: begin // Z horizontal
                blockgen_pattern[0][1] = 1;
                blockgen_pattern[0][2] = 1;
                blockgen_pattern[1][2] = 1;
                blockgen_pattern[1][3] = 1;
            end
            // 'd9: begin // Z vertical
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[2][1] = 1;
            //     blockgen_pattern[2][2] = 1;
            //     blockgen_pattern[3][2] = 1;
            // end

            // L piece
            'd4: begin // L 0°
                blockgen_pattern[0][1] = 1;
                blockgen_pattern[1][1] = 1;
                blockgen_pattern[2][1] = 1;
                blockgen_pattern[2][2] = 1;
            end
            // 'd10: begin // L 90°
            //     blockgen_pattern[1][0] = 1;
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[1][2] = 1;
            //     blockgen_pattern[0][0] = 1;
            // end
            // 'd11: begin // L 180°
            //     blockgen_pattern[0][1] = 1;
            //     blockgen_pattern[0][2] = 1;
            //     blockgen_pattern[1][2] = 1;
            //     blockgen_pattern[2][2] = 1;
            // end
            // 'd12: begin // L 270°
            //     blockgen_pattern[1][0] = 1;
            //     blockgen_pattern[2][0] = 1;
            //     blockgen_pattern[2][1] = 1;
            //     blockgen_pattern[2][2] = 1;
            // end

            // J piece
            'd5: begin // J 0°
                blockgen_pattern[0][2] = 1;
                blockgen_pattern[1][2] = 1;
                blockgen_pattern[2][2] = 1;
                blockgen_pattern[2][1] = 1;
            end
            // 'd13: begin // J 90°
            //     blockgen_pattern[1][0] = 1;
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[1][2] = 1;
            //     blockgen_pattern[2][2] = 1;
            // end
            // 'd14: begin // J 180°
            //     blockgen_pattern[0][1] = 1;
            //     blockgen_pattern[0][2] = 1;
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[2][1] = 1;
            // end
            // 'd15: begin // J 270°
            //     blockgen_pattern[0][0] = 1;
            //     blockgen_pattern[1][0] = 1;
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[1][2] = 1;
            // end

            // T piece
            'd6: begin // T 0°
                blockgen_pattern[0][2] = 1;
                blockgen_pattern[1][1] = 1;
                blockgen_pattern[1][2] = 1;
                blockgen_pattern[1][3] = 1;
            end
            // 'd16: begin // T 90°
            //     blockgen_pattern[1][2] = 1;
            //     blockgen_pattern[2][1] = 1;
            //     blockgen_pattern[2][2] = 1;
            //     blockgen_pattern[3][2] = 1;
            // end
            // 'd17: begin // T 180°
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[1][2] = 1;
            //     blockgen_pattern[1][3] = 1;
            //     blockgen_pattern[2][2] = 1;
            // end
            // 'd18: begin // T 270°
            //     blockgen_pattern[1][1] = 1;
            //     blockgen_pattern[2][1] = 1;
            //     blockgen_pattern[2][2] = 1;
            //     blockgen_pattern[3][1] = 1;
            // end
        endcase
    end
logic rotate_pulse, left_pulse, right_pulse; 
synckey yaba (.rst(reset) , .clk(clk), .in({19'b0, rotate_r}), .strobe(rotate_pulse)); 
synckey daba (.rst(reset) , .clk(clk), .in({19'b0, left_i}), .strobe(left_pulse)); 
synckey doo (.rst(reset) , .clk(clk), .in({19'b0, right_i}), .strobe(right_pulse)); 

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
    if (reset) begin 
        current_state <= INIT;
        current_block_pattern <= 0;
    end else begin 
        current_state <= next_state;
        current_block_pattern <= n_bp; 
    end 
end

// Line clear logic - on clk for smooth operation
logic [4:0] next_eval_row;
logic next_eval_complete;
logic [19:0][9:0] next_cleared_array;
logic [7:0] next_score;

// Sequential logic for line clear
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        eval_row <= 5'd19;
        eval_complete <= 1'b0;
        cleared_array <= '0;
        score <= 8'd0;
    end
    else begin
        eval_row <= next_eval_row;
        eval_complete <= next_eval_complete;
        cleared_array <= next_cleared_array;
        score <= next_score;
    end
end

// Combinational logic for line clear
always_comb begin
    // Default assignments
    next_eval_row = eval_row;
    next_eval_complete = eval_complete;
    next_cleared_array = cleared_array;
    next_score = score;

    if (current_state == LANDED) begin
        // Initialize evaluation
        next_eval_row = 5'd19;
        next_eval_complete = 1'b0;
        next_cleared_array = stored_array;
    end
    else if (current_state == EVAL) begin
        if (&cleared_array[eval_row]) begin
            // Full line found - clear it
           
            // Increment score if not at max
            if (score < 8'd255)
                next_score = score + 1;

            // Shift rows down
            for (logic [4:0] k = 0; k < 20; k = k + 1) begin
                if (k == 0)
                    next_cleared_array[0] = '0;
                else if (k <= eval_row)
                    next_cleared_array[k] = cleared_array[k-1];
                else
                    next_cleared_array[k] = cleared_array[k];
            end
           
            // Stay on same row for cascading clears
            next_eval_row = eval_row;
        end
        else begin
            // No full line, move to next row
            if (eval_row == 0)
                next_eval_complete = 1'b1;
            else
                next_eval_row = eval_row - 1;
        end
    end
end

// Block position management - mixed clocking for smooth movement
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        blockY <= 5'd0;
        blockX <= 4'd3;  // Center position for 4x4 block
        // current_block_type <= 0;
        rotation_en <= 0; 
        // current_block_pattern <= 0; 
    end else if (current_state == SPAWN) begin
        blockY <= 5'd0;
        blockX <= 4'd3;  // Center position for 4x4 block
        // current_block_type <= {2'b0,current_state_counter};
        // current_block_pattern <= blockgen_pattern; 
    end else if (current_state == FALLING) begin
        if (next_state == ROTATE) begin rotation_en <= 1'b1; end 
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
        // case (current_block_type)
        //     // I piece (2 orientations)
        //     'd0:  current_block_type <= 'd7;   // I vertical → I horizontal
        //     'd7:  current_block_type <= 'd0;   // I horizontal → I vertical

        //     // O piece (1 orientation, no change)
        //     'd1:  current_block_type <= 'd1;

        //     // S piece (2 orientations)
        //     'd2:  current_block_type <= 'd9;   // S horizontal → S vertical
        //     'd9:  current_block_type <= 'd2;   // S vertical → S horizontal

        //     // Z piece (2 orientations)
        //     'd3:  current_block_type <= 'd8;   // Z horizontal → Z vertical
        //     'd8:  current_block_type <= 'd3;   // Z vertical → Z horizontal

        //     // L piece (4 orientations)
        //     'd4:  current_block_type <= 'd10;  // L 0°  → L 90°
        //     'd10: current_block_type <= 'd11;  // L 90° → L 180°
        //     'd11: current_block_type <= 'd12;  // L 180°→ L 270°
        //     'd12: current_block_type <= 'd4;   // L 270°→ L 0°

        //     // J piece (4 orientations)
        //     'd5:  current_block_type <= 'd13;  // J 0°  → J 90°
        //     'd13: current_block_type <= 'd14;  // J 90° → J 180°
        //     'd14: current_block_type <= 'd15;  // J 180°→ J 270°
        //     'd15: current_block_type <= 'd5;   // J 270°→ J 0°

        //     // T piece (4 orientations)
        //     'd6:  current_block_type <= 'd16;  // T 0°  → T 90°
        //     'd16: current_block_type <= 'd17;  // T 90° → T 180°
        //     'd17: current_block_type <= 'd18;  // T 180°→ T 270°
        //     'd18: current_block_type <= 'd6;   // T 270°→ T 0°

        //     default: current_block_type <= current_block_type;
        // endcase
        if (next_state == FALLING) begin rotation_en <= 0; end 
        // current_block_pattern <= rotated_pattern; 
        // Wall kick logic for rotation
        if (collision_left)  blockX <= blockX + 1;   // nudge right
        else if (collision_right) blockX <= blockX - 1; // nudge left
    end 
end

// Update stored array after evaluation - on clk
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        stored_array <= '0;
    end else if (current_state == STUCK) begin
        // Store the block as soon as we detect it's stuck
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

//block generation
always_comb begin
    // Default assignment to avoid latches
    next_state         = current_state;
    gameover           = (current_state == GAMEOVER);
    n_bp = current_block_pattern; 
    case (current_state)
        INIT: begin
            if (start_i)
                next_state = SPAWN;
            display_array = stored_array;
        end
        SPAWN: begin
            next_state = FALLING;
            display_array = falling_block_display | stored_array;
            n_bp = blockgen_pattern; 
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
            if (rotate_complete == 4'b1111) begin 
                n_bp = rotated_pattern;       
                next_state = FALLING; 
            end else begin 
                next_state = current_state;
            end  
        end
        LANDED: begin
            next_state = EVAL;
            display_array = stored_array;
        end
        EVAL: begin
            if (eval_complete)
                next_state = SPAWN;
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
