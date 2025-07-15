// Optimized collision detection and movement logic for Tetris with Line Clear

module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, start_i,
    output logic spawn_enable,
    output logic [21:0][9:0] display_array,
    output logic [2:0] blocktype, 
    output logic finish, gameover,
    output logic [7:0] score
);

// FSM States
typedef enum logic [2:0] {
    INIT,
    SPAWN,
    FALLING,
    STUCK,  
    LANDED,
    EVAL, 
    GAMEOVER
} game_state_t;

game_state_t current_state, next_state;

// Arrays
logic [21:0][9:0] new_block_array;
logic [21:0][9:0] stored_array;
logic [21:0][9:0] cleared_array;

// Block position and movement
logic [4:0] blockY;
logic [3:0] blockX;
logic [2:0] current_block_type;
logic finish_internal;

// Line clear logic
logic [4:0] eval_row;
logic line_clear_found;
logic eval_complete;

// Collision detection signals
logic collision_bottom, collision_left, collision_right;
logic valid_move_left, valid_move_right;

// Movement synchronization


// Block type counter
logic [2:0] current_state_counter;
assign blocktype = current_state_counter;
counter count (.clk(clk), .rst(reset), .button_i(current_state == SPAWN),
.current_state_o(current_state_counter), .counter_o());

// Block generator
blockgen block_generator (
    .current_state(current_state_counter),
    .enable(spawn_enable),
    .display_array(new_block_array)
);

// State Register
always_ff @(posedge clk, posedge reset) begin
    if (reset) 
        current_state <= INIT;
    else 
        current_state <= next_state;
end

// Next State Logic
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        next_state <= INIT;
    end else begin
        case (current_state)
            INIT:  if (start_i) begin next_state <= SPAWN; end
            SPAWN:   next_state <= FALLING;
            FALLING: next_state <= collision_bottom ? STUCK : FALLING;
            STUCK:  begin
                if (|stored_array[0]) begin
                    next_state <= GAMEOVER;
                end else begin
                    next_state <= LANDED;
                end
            end
            LANDED:  next_state <= EVAL;
            EVAL:    next_state <= eval_complete ? SPAWN : EVAL;
            GAMEOVER: next_state <= GAMEOVER;
            default: next_state <= SPAWN;
        endcase
    end
end




// ────────────────────────────────────────────────────────────────────
// Optimized Line‑Clear Evaluation (replace your big case in EVAL)
// ────────────────────────────────────────────────────────────────────
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        eval_row         <= 5'd19;
        line_clear_found <= 1'b0;
        eval_complete    <= 1'b0;
        cleared_array    <= '0;
        score            <= 8'd0;
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
        blockX <= 4'd4;  // Center position
        current_block_type <= 3'd0;
    end else if (current_state == SPAWN) begin
        blockY <= 5'd0;
        blockX <= 4'd4;
        current_block_type <= current_state_counter;
    end else if (current_state == FALLING) begin
        // Handle vertical movement
        if (!collision_bottom) begin
            blockY <= blockY + 5'd1;
        end
        
        // Handle horizontal movement
        if (left_i && valid_move_left) begin
            blockX <= blockX - 4'd1;
        end else if (right_i && valid_move_right) begin
            blockX <= blockX + 4'd1;
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

//myles collision
// localparam BLOCK_H = 4;
// logic checking;
// logic [4:0] abs_cntr;
// logic [2:0] rel_cntr;
// logic check;
// logic collision;
// logic checked;

// always_ff @(posedge clk, posedge reset) begin
//     if (reset) begin
//         checking <= 0;
//         checked <= 0;
//         collision <= 0;
//         rel_cntr <= 0;
//         abs_cntr <= 0;
//     end
//     else if (check) begin 
//         checking <= 1;
//         checked <= 0;
//         collision <= 0;
//         rel_cntr <= 0;
//         abs_cntr <= blockY;
//     end else if (checking) begin
//         if (rel_cntr < 3'd4) begin
//             if ((stored_array[abs_cntr] & falling_block_display[rel_cntr]) != 0)
//             collision <= 1;
//         rel_cntr <= rel_cntr + 1;
//         abs_cntr <= abs_cntr + 1;
//         end else begin
//             checking <= 0; 
//             checked <= 0;
//         end
//     end
// end

// Generate current block display pattern
logic [21:0][9:0] falling_block_display;

// Collision detection logic - expanded inline to avoid function issues
always_comb begin
    // collision detection
    collision_bottom = 1'b0;
    collision_left = 1'b0;
    collision_right = 1'b0;
    falling_block_display = '0;
    case (current_block_type)
        3'd0: begin // LINE (vertical)
            collision_bottom = (blockY + 4 >= 20) || stored_array[blockY+1][blockX] || 
                            stored_array[blockY+2][blockX] || 
                            stored_array[blockY+3][blockX] || 
                            stored_array[blockY+4][blockX];
            collision_left = (blockX == 0) || stored_array[blockY][blockX-1] || 
                            stored_array[blockY+1][blockX-1] || 
                            stored_array[blockY+2][blockX-1] || 
                            stored_array[blockY+3][blockX-1];
            collision_right = (blockX + 1 >= 10) || stored_array[blockY][blockX+1] || 
                            stored_array[blockY+1][blockX+1] || 
                            stored_array[blockY+2][blockX+1] || 
                            stored_array[blockY+3][blockX+1];
            if (blockY + 3 < 20) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+2][blockX] = 1'b1;
                falling_block_display[blockY+3][blockX] = 1'b1;
            end
        end
        3'd1: begin // SQUARE
            collision_bottom = (blockY + 2 >= 20) || stored_array[blockY+2][blockX] || 
                            stored_array[blockY+2][blockX+1];
            collision_left = (blockX == 0) || stored_array[blockY][blockX-1] || 
                            stored_array[blockY+1][blockX-1];
            collision_right = (blockX + 2 >= 10) || stored_array[blockY][blockX+2] || 
                            stored_array[blockY+1][blockX+2];
            if (blockY + 1 < 20 && blockX + 1 < 10) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
            end
        end
        3'd2: begin // L
            collision_bottom = (blockY + 3 >= 20) || stored_array[blockY+3][blockX] || 
                            stored_array[blockY+3][blockX+1];
            collision_left = (blockX == 0) || stored_array[blockY][blockX-1] || 
                            stored_array[blockY+1][blockX-1] || 
                            stored_array[blockY+2][blockX-1];
            collision_right = (blockX + 2 >= 10) || stored_array[blockY][blockX+1] || 
                            stored_array[blockY+1][blockX+1] || 
                            stored_array[blockY+2][blockX+2];
            if (blockY + 2 < 20 && blockX + 1 < 10) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+2][blockX] = 1'b1;
                falling_block_display[blockY+2][blockX+1] = 1'b1;
            end
        end
        3'd3: begin // REVERSE_L
            collision_bottom = (blockY + 3 >= 20) || stored_array[blockY+3][blockX+1] || 
                            stored_array[blockY+3][blockX];
            collision_left = (blockX == 0) || stored_array[blockY][blockX] || 
                            stored_array[blockY+1][blockX] || 
                            stored_array[blockY+2][blockX-1];
            collision_right = (blockX + 2 >= 10) || stored_array[blockY][blockX+2] || 
                            stored_array[blockY+1][blockX+2] || 
                            stored_array[blockY+2][blockX+2];
            if (blockY + 2 < 20 && blockX + 1 < 10) begin
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
                falling_block_display[blockY+2][blockX+1] = 1'b1;
                falling_block_display[blockY+2][blockX] = 1'b1;
            end
        end
        3'd4: begin // S
            collision_bottom = (blockY + 2 >= 20) || stored_array[blockY+1][blockX+1] || 
                            stored_array[blockY+1][blockX+2] || 
                            stored_array[blockY+2][blockX] || 
                            stored_array[blockY+2][blockX+1];
            collision_left = (blockX == 0) || stored_array[blockY][blockX] || 
                            stored_array[blockY+1][blockX-1];
            collision_right = (blockX + 3 >= 10) || stored_array[blockY][blockX+3] || 
                            stored_array[blockY+1][blockX+2];
            if (blockY + 1 < 20 && blockX + 2 < 10) begin
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY][blockX+2] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
            end
        end
        3'd5: begin // Z
            collision_bottom = (blockY + 2 >= 20) || stored_array[blockY+1][blockX] || 
                            stored_array[blockY+1][blockX+1] || 
                            stored_array[blockY+2][blockX+1] || 
                            stored_array[blockY+2][blockX+2];
            collision_left = (blockX == 0) || stored_array[blockY][blockX-1] || 
                            stored_array[blockY+1][blockX];
            collision_right = (blockX + 3 >= 10) || stored_array[blockY][blockX+2] || 
                            stored_array[blockY+1][blockX+3];
            if (blockY + 1 < 20 && blockX + 2 < 10) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+2] = 1'b1;
            end
        end
        3'd6: begin // T
            collision_bottom = (blockY + 2 >= 20) || stored_array[blockY+1][blockX+1] || 
                            stored_array[blockY+2][blockX] || 
                            stored_array[blockY+2][blockX+1] || 
                            stored_array[blockY+2][blockX+2];
            collision_left = (blockX == 0) || stored_array[blockY][blockX] || 
                            stored_array[blockY+1][blockX-1];
            collision_right = (blockX + 3 >= 10) || stored_array[blockY][blockX+2] || 
                            stored_array[blockY+1][blockX+3];
            if (blockY + 1 < 20 && blockX + 2 < 10) begin
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+2] = 1'b1;
            end
        end
        default: begin 
            collision_bottom = 1'b0;
            collision_left = 1'b0;
            falling_block_display = '0;
        end
    endcase
    
    valid_move_left = !collision_left;
    valid_move_right = !collision_right;
    finish_internal = collision_bottom;
end

// Output Logic
always_comb begin
    spawn_enable = (current_state == SPAWN);
    gameover = (current_state == GAMEOVER);
    finish = finish_internal;
    
    case (current_state)
        SPAWN: begin
            display_array = new_block_array | stored_array;
        end
        FALLING: begin
            display_array = falling_block_display | stored_array;
        end
        STUCK: begin
            display_array = falling_block_display | stored_array;
        end
        LANDED: begin
            display_array = stored_array;
        end
        EVAL: begin
            display_array = cleared_array;
        end
        GAMEOVER: begin
            display_array = stored_array;
        end
        default: begin
            display_array = stored_array;
        end
    endcase
end

endmodule
