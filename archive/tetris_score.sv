module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, start_i, rotate_r, 
    output logic [21:0][9:0] display_array,
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

logic [21:0][9:0] stored_array;
logic [21:0][9:0] cleared_array;

logic [4:0] blockY;
logic [3:0] blockX;
logic [4:0] current_block_type;

// Block representation as 4x4 grid for rotation support
logic [3:0][3:0] current_block_pattern, rotate_block;

// Line clear logic
logic [4:0] eval_row;
logic line_clear_found;
logic eval_complete;

// Collision detection signals
logic collision_bottom, collision_left, collision_right;

// Block type counter
logic [4:0] current_state_counter;
counter count (.clk(clk), .rst(reset), .button_i(current_state == SPAWN),
.current_state_o(current_state_counter[2:0]), .counter_o());


// State Register
always_ff @(posedge onehuzz, posedge reset) begin
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset)
        current_state <= INIT;
    else
        current_state <= next_state;
end

// line clear
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        eval_row <= 5'd19;
        line_clear_found <= 1'b0;
        eval_complete <= 1'b0;
        cleared_array  <= '0;
        score <= 8'd0;
    end
    else if (current_state == LANDED) begin
        eval_row         <= 5'd19;
        line_clear_found <= 1'b0;
        eval_complete    <= 1'b0;
        cleared_array    <= stored_array;
    end
    else if (current_state == EVAL) begin
        if (&cleared_array[eval_row]) begin
            // full line → score and flag
            line_clear_found <= 1'b1;
            if (score < 8'd255)
                score <= score + 1;

            // constant 0–19 loop, shift rows ≤ eval_row down by one
            for (logic [4:0] k = 0; k < 20; k = k + 1) begin
                if      (k == 0)            cleared_array[0] <= '0;
                else if (k <= eval_row)     cleared_array[k] <= cleared_array[k-1];
                else                         cleared_array[k] <= cleared_array[k];
            end
            // stay on the same eval_row for cascading
        end
        else begin
            if (eval_row == 0)
                eval_complete <= 1'b1;
            else
                eval_row <= eval_row - 1;
        end
    end
end

// Block position management
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        blockY <= 5'd0;
        blockX <= 4'd3;  // Center position for 4x4 block
        current_block_type <= 0;
    end else if (current_state == SPAWN) begin
        blockY <= 5'd0;
        blockX <= 4'd3;  // Center position for 4x4 block
        current_block_type <= current_state_counter;
    end else if (current_state == FALLING) begin
        // Handle vertical movement
        if (!collision_bottom) begin
            blockY <= blockY + 5'd1;
        end
       
        // Handle horizontal movement
        if (left_i && !collision_left) begin
        if (left_i && !collision_left) begin
            blockX <= blockX - 4'd1;
        end else if (right_i && !collision_right) begin
        end else if (right_i && !collision_right) begin
            blockX <= blockX + 4'd1;
        end
    end else if (current_state == ROTATE) begin 
        case (current_block_type) 
            'd0: begin // Line
                current_block_type <= 'd7; 
            end
            'd2: begin // Loser
                current_block_type <= 'd8; 
            end
            'd3: begin // reverse loser
               current_block_type <= 'd9; 
            end
            'd4: begin // S
               current_block_type <= 'd10;   
            end
            'd5: begin // Z
               current_block_type <= 'd11;  
            end
            'd6: begin // T
               current_block_type <= 'd12;  
            end
            'd7: begin // reverse line
               current_block_type <= 'd0;   
            end
            'd8: begin // L
               current_block_type <= 'd2;  
            end
            'd9: begin // T
               current_block_type <= 'd3;  
            end
        endcase
        blockY <= 0; 
        blockX <= 0; 
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

logic [21:0][9:0] falling_block_display;
logic [4:0] row_ext;
logic [3:0] col_ext;
logic [4:0] abs_row;
logic [3:0] abs_col;
logic rotate_complete; 

always_comb begin
    collision_bottom       = 1'b0;
    collision_left         = 1'b0;
    collision_right        = 1'b0;
    falling_block_display  = '0;

    rotate_block = 0;
    rotate_complete = 0;  
    // rotated block 
    if (current_block_type != 'd1) begin // square is the same  
        rotate_block[0] = {current_block_pattern[0][0], current_block_pattern[1][0], current_block_pattern[2][0], current_block_pattern[3][0]}; 
        rotate_block[1] = {current_block_pattern[0][1], current_block_pattern[1][1], current_block_pattern[2][1], current_block_pattern[3][1]};
        rotate_block[2] = {current_block_pattern[0][2], current_block_pattern[1][2], current_block_pattern[2][2], current_block_pattern[3][2]};
        rotate_block[3] = {current_block_pattern[0][3], current_block_pattern[1][3], current_block_pattern[2][3], current_block_pattern[3][3]};
        rotate_complete = 1'b1; 
    end

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
    // Default assignment to avoid latches
    next_state = current_state;
    gameover = (current_state == GAMEOVER);
    current_block_pattern = '0;
    case (current_block_type)
        'd0: begin // Line
            current_block_pattern[0][1] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[2][1] = 1'b1;
            current_block_pattern[3][1] = 1'b1;
        end
        'd1: begin //smash boy
            current_block_pattern[0][1] = 1'b1;
            current_block_pattern[0][2] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
        end
        'd2: begin // Loser
            current_block_pattern[0][1] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[2][1] = 1'b1;
            current_block_pattern[2][2] = 1'b1;
        end
        'd3: begin // reverse loser
            current_block_pattern[0][2] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
            current_block_pattern[2][2] = 1'b1;
            current_block_pattern[2][1] = 1'b1;
        end
        'd4: begin // S
            current_block_pattern[0][2] = 1'b1;
            current_block_pattern[0][3] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
        end
        'd5: begin // Z
            current_block_pattern[0][1] = 1'b1;
            current_block_pattern[0][2] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
            current_block_pattern[1][3] = 1'b1;
        end
        'd6: begin // T
            current_block_pattern[0][2] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
            current_block_pattern[1][3] = 1'b1;
        end
        // rotated block types
        'd7: begin // Line
            current_block_pattern[1][0] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
            current_block_pattern[1][3] = 1'b1;
        end
        'd8: begin // Loser
            current_block_pattern[1][0] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
            current_block_pattern[2][2] = 1'b1;
        end
        'd9: begin // reverse loser
            current_block_pattern[2][0] = 1'b1;
            current_block_pattern[2][1] = 1'b1;
            current_block_pattern[2][2] = 1'b1;
            current_block_pattern[1][2] = 1'b1;
        end
        'd10: begin // S
            current_block_pattern[2][0] = 1'b1;
            current_block_pattern[3][0] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[2][1] = 1'b1;
        end
        'd11: begin // Z
            current_block_pattern[1][0] = 1'b1;
            current_block_pattern[2][0] = 1'b1;
            current_block_pattern[2][1] = 1'b1;
            current_block_pattern[3][1] = 1'b1;
        end
        'd12: begin // T
            current_block_pattern[2][0] = 1'b1;
            current_block_pattern[1][1] = 1'b1;
            current_block_pattern[2][1] = 1'b1;
            current_block_pattern[3][1] = 1'b1;
        end
        default: current_block_pattern = '0;
    endcase
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
            end else if (current_block_type != 'd1 && rotate_r) begin // square doesn't matter
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
            if (rotate_complete) begin 
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
