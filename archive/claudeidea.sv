// Enhanced Tetris FSM with Rotation Support
module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, rotate_i,
    output logic spawn_enable,
    output logic [21:0][9:0] display_array,
    output logic [2:0] blocktype, 
    output logic finish, gameover,
    output logic [7:0] score
);

// Enhanced FSM States - added ROTATE state
typedef enum logic [2:0] {
    SPAWN,
    FALLING,
    ROTATE,
    STUCK,  
    LANDED,
    EVAL, 
    GAMEOVER
} game_state_t;

game_state_t current_state, next_state;

// Arrays
logic [21:0][9:0] new_block_array;
logic [21:0][9:0] stored_array;
logic [21:0][9:0] current_block_array;
logic [21:0][9:0] cleared_array;

// Block position and movement
logic [4:0] blockY;
logic [3:0] blockX;
logic [2:0] current_block_type;
logic [1:0] rotation_state;  // 0=0°, 1=90°, 2=180°, 3=270°
logic finish_internal;

// Rotation logic variables
logic rotation_complete;            // Flag for rotation completion

// Line clear logic
logic [4:0] eval_row;
logic line_clear_found;
logic eval_complete;

// Collision detection signals
logic collision_bottom, collision_left, collision_right, collision_rotate;
logic valid_move_left, valid_move_right;

// Movement synchronization
logic left_sync, right_sync, rotate_sync;
synckey left (.reset(reset), .hz100(clk), .in({19'b0, left_i}), .out(), .strobe(left_sync)); 
synckey right (.reset(reset), .hz100(clk), .in({19'b0, right_i}), .out(), .strobe(right_sync)); 
synckey rotate (.reset(reset), .hz100(clk), .in({19'b0, rotate_i}), .out(), .strobe(rotate_sync)); 

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

// Next State Logic - Enhanced with rotation support
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        next_state <= SPAWN;
    end else begin
        case (current_state)
            SPAWN:   next_state <= FALLING;
            FALLING: begin
                if (rotate_sync && current_block_type != 3'd1) begin // No rotation for square
                    next_state <= ROTATE;
                end else if (collision_bottom) begin
                    next_state <= STUCK;
                end else begin
                    next_state <= FALLING;
                end
            end
            ROTATE:  next_state <= rotation_complete ? FALLING : ROTATE;
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

// Rotation Logic - Simple collision check approach
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        rotation_complete <= 1'b0;
        rotation_state <= 2'd0;
    end else if (current_state == FALLING && rotate_sync && current_block_type != 3'd1) begin
        // Initialize rotation check
        rotation_complete <= 1'b0;
    end else if (current_state == ROTATE) begin
        // Check if rotation would cause collision
        logic [1:0] next_rotation;
        logic [3:0][11:0] test_matrix;
        
        next_rotation = (rotation_state + 1) % 4;
        test_matrix = generate_block_matrix(current_block_type, next_rotation);
        
        if (check_rotation_collision(test_matrix, blockX, blockY)) begin
            // Collision detected - don't rotate, just complete
            rotation_complete <= 1'b1;
        end else begin
            // No collision - apply rotation
            rotation_state <= next_rotation;
            rotation_complete <= 1'b1;
        end
    end
end

// Function to generate block matrix based on type and rotation
function logic [3:0][11:0] generate_block_matrix(input logic [2:0] block_type, input logic [1:0] rotation);
    logic [3:0][11:0] matrix;
    matrix = '0;
    
    case (block_type)
        3'd0: begin // LINE
            case (rotation)
                2'd0: begin // Vertical
                    matrix[0] = 12'b0001_0000_0000;
                    matrix[1] = 12'b0001_0000_0000;
                    matrix[2] = 12'b0001_0000_0000;
                    matrix[3] = 12'b0001_0000_0000;
                end
                2'd1: begin // Horizontal
                    matrix[0] = 12'b0000_0000_0000;
                    matrix[1] = 12'b1111_0000_0000;
                    matrix[2] = 12'b0000_0000_0000;
                    matrix[3] = 12'b0000_0000_0000;
                end
                default: matrix = generate_block_matrix(block_type, 2'd0);
            endcase
        end
        3'd2: begin // L
            case (rotation)
                2'd0: begin
                    matrix[0] = 12'b0001_0000_0000;
                    matrix[1] = 12'b0001_0000_0000;
                    matrix[2] = 12'b0011_0000_0000;
                    matrix[3] = 12'b0000_0000_0000;
                end
                2'd1: begin
                    matrix[0] = 12'b0000_0000_0000;
                    matrix[1] = 12'b0100_0000_0000;
                    matrix[2] = 12'b0111_0000_0000;
                    matrix[3] = 12'b0000_0000_0000;
                end
                2'd2: begin
                    matrix[0] = 12'b0110_0000_0000;
                    matrix[1] = 12'b0010_0000_0000;
                    matrix[2] = 12'b0010_0000_0000;
                    matrix[3] = 12'b0000_0000_0000;
                end
                2'd3: begin
                    matrix[0] = 12'b0000_0000_0000;
                    matrix[1] = 12'b0111_0000_0000;
                    matrix[2] = 12'b0001_0000_0000;
                    matrix[3] = 12'b0000_0000_0000;
                end
            endcase
        end
        // Add other block types (T, S, Z, Reverse L) with their rotations
        default: matrix = '0;
    endcase
    
    return matrix;
endfunction

// Function to perform 90-degree clockwise rotation
function logic [3:0][11:0] perform_90_rotation(input logic [3:0][11:0] input_matrix);
    logic [3:0][11:0] rotated;
    integer i, j;
    
    rotated = '0;
    
    // Transpose and reverse rows for 90° clockwise rotation
    for (i = 0; i < 4; i++) begin
        for (j = 0; j < 4; j++) begin
            rotated[j][11-(3-i)] = input_matrix[i][11-j];
        end
    end
    
    return rotated;
endfunction

// Function to check rotation collision
function logic check_rotation_collision(input logic [3:0][11:0] matrix, input logic [3:0] x, input logic [4:0] y);
    logic collision;
    integer i, j;
    
    collision = 1'b0;
    
    for (i = 0; i < 4; i++) begin
        for (j = 0; j < 4; j++) begin
            if (matrix[i][11-j] && (y + i < 22) && (x + j < 10)) begin
                if ((y + i >= 20) || (x + j >= 10) || (x + j < 0) || stored_array[y + i][x + j]) begin
                    collision = 1'b1;
                end
            end
        end
    end
    
    return collision;
endfunction

// Line Clear Evaluation Logic (unchanged from original)
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        eval_row <= 5'd19;
        line_clear_found <= 1'b0;
        eval_complete <= 1'b0;
        cleared_array <= '0;
        score <= '0;
    end else if (current_state == LANDED) begin
        eval_row <= 5'd19;
        line_clear_found <= 1'b0;
        eval_complete <= 1'b0;
        cleared_array <= stored_array;
    end else if (current_state == EVAL) begin
        if (&cleared_array[eval_row]) begin
            line_clear_found <= 1'b1;
            if (score < 8'd255) begin
                score <= score + 1;
            end
            // Line clearing logic (same as original)
            // ... (include the full case statement from original)
        end else begin
            if (eval_row == 0) begin
                eval_complete <= 1'b1;
            end else begin
                eval_row <= eval_row - 1;
            end
        end
    end
end

// Block position management - Enhanced with rotation support
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        blockY <= 5'd0;
        blockX <= 4'd4;
        current_block_type <= 3'd0;
        current_block_array <= '0;
        rotation_state <= 2'd0;
    end else if (current_state == SPAWN) begin
        blockY <= 5'd0;
        blockX <= 4'd4;
        current_block_type <= current_state_counter;
        current_block_array <= new_block_array;
        rotation_state <= 2'd0;
    end else if (current_state == FALLING) begin
        if (!collision_bottom) begin
            blockY <= blockY + 5'd1;
        end
        
        if (left_sync && valid_move_left) begin
            blockX <= blockX - 4'd1;
        end else if (right_sync && valid_move_right) begin
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

// Generate current block display pattern - Enhanced with rotation
logic [21:0][9:0] falling_block_display;

always_comb begin
    falling_block_display = '0;
    collision_bottom = 1'b0;
    collision_left = 1'b0;
    collision_right = 1'b0;
    
    // Generate display based on current rotation state
    logic [3:0][11:0] current_matrix;
    current_matrix = generate_block_matrix(current_block_type, rotation_state);
    
    for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < 4; j++) begin
            if (current_matrix[i][11-j] && (blockY + i < 22) && (blockX + j < 10)) begin
                if (blockY + i < 20) begin
                    falling_block_display[blockY + i][blockX + j] = 1'b1;
                end
                
                // Check collisions
                if (blockY + i + 1 >= 20 || stored_array[blockY + i + 1][blockX + j]) begin
                    collision_bottom = 1'b1;
                end
                if (blockX + j == 0 || stored_array[blockY + i][blockX + j - 1]) begin
                    collision_left = 1'b1;
                end
                if (blockX + j + 1 >= 10 || stored_array[blockY + i][blockX + j + 1]) begin
                    collision_right = 1'b1;
                end
            end
        end
    end
    
    valid_move_left = !collision_left;
    valid_move_right = !collision_right;
    finish_internal = collision_bottom;
end

// Output Logic - Enhanced for rotation state
always_comb begin
    spawn_enable = (current_state == SPAWN);
    gameover = (current_state == GAMEOVER);
    finish = finish_internal;
    
    case (current_state)
        SPAWN: begin
            display_array = new_block_array | stored_array;
        end
        FALLING, ROTATE: begin
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
