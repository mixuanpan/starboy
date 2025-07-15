// Optimized collision detection and movement logic for Tetris

module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, 
    output logic spawn_enable,
    output logic [21:0][9:0] display_array,
    output logic [2:0] blocktype, 
    output logic finish, gameover
);

// FSM States
typedef enum logic [2:0] {
    SPAWN,
    FALLING,
    STUCK,  
    LANDED, 
    GAMEOVER
} game_state_t;

game_state_t current_state, next_state;

// Arrays
logic [21:0][9:0] new_block_array;
logic [21:0][9:0] stored_array;
logic [21:0][9:0] current_block_array;

// Block position and movement
logic [4:0] blockY;
logic [3:0] blockX;
logic [2:0] current_block_type;
logic finish_internal;

// Collision detection signals
logic collision_bottom, collision_left, collision_right;
logic valid_move_left, valid_move_right;

// Movement synchronization
logic left_sync, right_sync;
synckey left (.reset(reset), .hz100(clk), .in({19'b0, left_i}), .out(), .strobe(left_sync)); 
synckey right (.reset(reset), .hz100(clk), .in({19'b0, right_i}), .out(), .strobe(right_sync)); 

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
        current_state <= SPAWN;
    else 
        current_state <= next_state;
end

// Next State Logic
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        next_state <= SPAWN;
    end else begin
        case (current_state)
            SPAWN:   next_state <= FALLING;
            FALLING: next_state <= collision_bottom ? STUCK : FALLING;
            STUCK:  begin
                if (|stored_array[0]) begin
                    next_state <= GAMEOVER;
                end else begin
                    next_state <= LANDED;
                end
            end
            LANDED:  next_state <= SPAWN;
            GAMEOVER: next_state <= GAMEOVER;
            default: next_state <= SPAWN;
        endcase
    end
end

// Block position management
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        blockY <= 5'd0;
        blockX <= 4'd4;  // Center position
        current_block_type <= 3'd0;
        current_block_array <= '0;
    end else if (current_state == SPAWN) begin
        blockY <= 5'd0;
        blockX <= 4'd4;
        current_block_type <= current_state_counter;
        current_block_array <= new_block_array;
    end else if (current_state == FALLING) begin
        // Handle vertical movement
        if (!collision_bottom) begin
            blockY <= blockY + 5'd1;
        end
        
        // Handle horizontal movement
        if (left_sync && valid_move_left) begin
            blockX <= blockX - 4'd1;
        end else if (right_sync && valid_move_right) begin
            blockX <= blockX + 4'd1;
        end
    end
end

// Collision detection logic - expanded inline to avoid function issues
always_comb begin
    // Bottom collision detection
    collision_bottom = 1'b0;
    case (current_block_type)
        3'd0: begin // LINE (vertical)
            if (blockY + 4 >= 20) collision_bottom = 1'b1;
            else begin
                collision_bottom = stored_array[blockY+1][blockX] || 
                                 stored_array[blockY+2][blockX] || 
                                 stored_array[blockY+3][blockX] || 
                                 stored_array[blockY+4][blockX];
            end
        end
        3'd1: begin // SQUARE
            if (blockY + 2 >= 20) collision_bottom = 1'b1;
            else begin
                collision_bottom = stored_array[blockY+2][blockX] || 
                                 stored_array[blockY+2][blockX+1];
            end
        end
        3'd2: begin // L
            if (blockY + 3 >= 20) collision_bottom = 1'b1;
            else begin
                collision_bottom = stored_array[blockY+3][blockX] || 
                                 stored_array[blockY+3][blockX+1];
            end
        end
        3'd3: begin // REVERSE_L
            if (blockY + 3 >= 20) collision_bottom = 1'b1;
            else begin
                collision_bottom = stored_array[blockY+3][blockX+1] || 
                                 stored_array[blockY+3][blockX];
            end
        end
        3'd4: begin // S
            if (blockY + 2 >= 20) collision_bottom = 1'b1;
            else begin
                collision_bottom = stored_array[blockY+1][blockX+1] || 
                                 stored_array[blockY+1][blockX+2] || 
                                 stored_array[blockY+2][blockX] || 
                                 stored_array[blockY+2][blockX+1];
            end
        end
        3'd5: begin // Z
            if (blockY + 2 >= 20) collision_bottom = 1'b1;
            else begin
                collision_bottom = stored_array[blockY+1][blockX] || 
                                 stored_array[blockY+1][blockX+1] || 
                                 stored_array[blockY+2][blockX+1] || 
                                 stored_array[blockY+2][blockX+2];
            end
        end
        3'd6: begin // T
            if (blockY + 2 >= 20) collision_bottom = 1'b1;
            else begin
                collision_bottom = stored_array[blockY+1][blockX+1] || 
                                 stored_array[blockY+2][blockX] || 
                                 stored_array[blockY+2][blockX+1] || 
                                 stored_array[blockY+2][blockX+2];
            end
        end
        default: collision_bottom = 1'b0;
    endcase
    
    // Left collision detection
    collision_left = 1'b0;
    if (blockX == 0) begin
        collision_left = 1'b1;
    end else begin
        case (current_block_type)
            3'd0: begin // LINE
                collision_left = stored_array[blockY][blockX-1] || 
                               stored_array[blockY+1][blockX-1] || 
                               stored_array[blockY+2][blockX-1] || 
                               stored_array[blockY+3][blockX-1];
            end
            3'd1: begin // SQUARE
                if (blockX == 0) collision_left = 1'b1;
                else begin
                    collision_left = stored_array[blockY][blockX-1] || 
                                   stored_array[blockY+1][blockX-1];
                end
            end
            3'd2: begin // L
                if (blockX == 0) collision_left = 1'b1;
                else begin
                    collision_left = stored_array[blockY][blockX-1] || 
                                   stored_array[blockY+1][blockX-1] || 
                                   stored_array[blockY+2][blockX-1];
                end
            end
            3'd3: begin // REVERSE_L
                if (blockX == 0) collision_left = 1'b1;
                else begin
                    collision_left = stored_array[blockY][blockX] || 
                                   stored_array[blockY+1][blockX] || 
                                   stored_array[blockY+2][blockX-1];
                end
            end
            3'd4: begin // S
                if (blockX == 0) collision_left = 1'b1;
                else begin
                    collision_left = stored_array[blockY][blockX] || 
                                   stored_array[blockY+1][blockX-1];
                end
            end
            3'd5: begin // Z
                if (blockX == 0) collision_left = 1'b1;
                else begin
                    collision_left = stored_array[blockY][blockX-1] || 
                                   stored_array[blockY+1][blockX];
                end
            end
            3'd6: begin // T
                if (blockX == 0) collision_left = 1'b1;
                else begin
                    collision_left = stored_array[blockY][blockX] || 
                                   stored_array[blockY+1][blockX-1];
                end
            end
            default: collision_left = 1'b0;
        endcase
    end
    
    // Right collision detection
    collision_right = 1'b0;
    case (current_block_type)
        3'd0: begin // LINE
            if (blockX + 1 >= 10) collision_right = 1'b1;
            else begin
                collision_right = stored_array[blockY][blockX+1] || 
                                stored_array[blockY+1][blockX+1] || 
                                stored_array[blockY+2][blockX+1] || 
                                stored_array[blockY+3][blockX+1];
            end
        end
        3'd1: begin // SQUARE
            if (blockX + 2 >= 10) collision_right = 1'b1;
            else begin
                collision_right = stored_array[blockY][blockX+2] || 
                                stored_array[blockY+1][blockX+2];
            end
        end
        3'd2: begin // L
            if (blockX + 2 >= 10) collision_right = 1'b1;
            else begin
                collision_right = stored_array[blockY][blockX+1] || 
                                stored_array[blockY+1][blockX+1] || 
                                stored_array[blockY+2][blockX+2];
            end
        end
        3'd3: begin // REVERSE_L
            if (blockX + 2 >= 10) collision_right = 1'b1;
            else begin
                collision_right = stored_array[blockY][blockX+2] || 
                                stored_array[blockY+1][blockX+2] || 
                                stored_array[blockY+2][blockX+2];
            end
        end
        3'd4: begin // S
            if (blockX + 3 >= 10) collision_right = 1'b1;
            else begin
                collision_right = stored_array[blockY][blockX+3] || 
                                stored_array[blockY+1][blockX+2];
            end
        end
        3'd5: begin // Z
            if (blockX + 3 >= 10) collision_right = 1'b1;
            else begin
                collision_right = stored_array[blockY][blockX+2] || 
                                stored_array[blockY+1][blockX+3];
            end
        end
        3'd6: begin // T
            if (blockX + 3 >= 10) collision_right = 1'b1;
            else begin
                collision_right = stored_array[blockY][blockX+2] || 
                                stored_array[blockY+1][blockX+3];
            end
        end
        default: collision_right = 1'b0;
    endcase
    
    valid_move_left = !collision_left;
    valid_move_right = !collision_right;
    finish_internal = collision_bottom;
end

// Generate current block display pattern
logic [21:0][9:0] falling_block_display;
always_comb begin
    falling_block_display = '0;
    
    case (current_block_type)
        3'd0: begin // LINE
            if (blockY + 3 < 20) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+2][blockX] = 1'b1;
                falling_block_display[blockY+3][blockX] = 1'b1;
            end
        end
        3'd1: begin // SQUARE
            if (blockY + 1 < 20 && blockX + 1 < 10) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
            end
        end
        3'd2: begin // L
            if (blockY + 2 < 20 && blockX + 1 < 10) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+2][blockX] = 1'b1;
                falling_block_display[blockY+2][blockX+1] = 1'b1;
            end
        end
        3'd3: begin // REVERSE_L
            if (blockY + 2 < 20 && blockX + 1 < 10) begin
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
                falling_block_display[blockY+2][blockX+1] = 1'b1;
                falling_block_display[blockY+2][blockX] = 1'b1;
            end
        end
        3'd4: begin // S
            if (blockY + 1 < 20 && blockX + 2 < 10) begin
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY][blockX+2] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
            end
        end
        3'd5: begin // Z
            if (blockY + 1 < 20 && blockX + 2 < 10) begin
                falling_block_display[blockY][blockX] = 1'b1;
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+2] = 1'b1;
            end
        end
        3'd6: begin // T
            if (blockY + 1 < 20 && blockX + 2 < 10) begin
                falling_block_display[blockY][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX] = 1'b1;
                falling_block_display[blockY+1][blockX+1] = 1'b1;
                falling_block_display[blockY+1][blockX+2] = 1'b1;
            end
        end
        default: falling_block_display = '0;
    endcase
end

// Stored Array Management
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        stored_array <= '0;
    end else if (current_state == LANDED) begin
        stored_array <= stored_array | falling_block_display;
    end
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
        GAMEOVER: begin
            display_array = stored_array;
        end
        default: begin
            display_array = stored_array;
        end
    endcase
end

endmodule