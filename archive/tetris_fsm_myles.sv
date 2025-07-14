module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, 
    output logic spawn_enable,       // To blockgen module
    output logic [21:0][9:0] display_array, // Final display array
    output logic [2:0] blocktype, 
    output logic finish             // Output finish signal to top module
);

// FSM States
typedef enum logic [2:0] {
    SPAWN ,
    FALLING,
    STUCK,  
    LANDED, 
    GAMEOVER 

} game_state_t;

//block states
typedef enum logic [2:0] {
    LINE, 
    SMASHBOY, 
    L, 
    REVERSE_L, 
    S, 
    Z, 
    T
    } block_t;

game_state_t current_state, next_state;

// Arrays
logic [21:0][9:0] movement_array;       // From movedown
logic [21:0][9:0] stored_array;         // Permanent grid storage
logic [21:0][9:0] falling_block_array;  // Active falling block

// Internal finish signal from movedown
logic finish_internal;
logic spawn_new_block;

// State Register
always_ff @(posedge clk, posedge reset) begin
    if (reset) 
        current_state <= SPAWN;
    else 
        current_state <= next_state;
end

//block generation 
function automatic logic [21:0][9:0] make_shape (input block_t t);
    logic [21:0][9:0] m;   // default cleared
    m = '0;
    unique case (t)
        LINE :       begin m[0][4]=1; m[1][4]=1; m[2][4]=1; m[3][4]=1; end
        SMASHBOY :   begin m[0][4]=1; m[0][5]=1; m[1][4]=1; m[1][5]=1; end
        L :          begin m[0][4]=1; m[1][4]=1; m[2][4]=1; m[2][5]=1; end
        REVERSE_L :  begin m[0][5]=1; m[1][5]=1; m[2][5]=1; m[2][4]=1; end
        S :          begin m[0][6]=1; m[0][5]=1; m[1][5]=1; m[1][4]=1; end
        Z :          begin m[0][4]=1; m[0][5]=1; m[1][5]=1; m[1][6]=1; end
        T :          begin m[0][4]=1; m[1][3]=1; m[1][4]=1; m[1][5]=1; end
    endcase
    return m;
endfunction


// Next State Logic - Use onehuzz for state transitions to sync with block movement
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        next_state <= SPAWN;
    end else begin
        case (current_state)
            SPAWN:   next_state <= FALLING;  // After block spawns, start falling
            FALLING: next_state <= collision ? STUCK : (finish_internal ? LANDED : FALLING);  // Wait for finish signal
            STUCK: next_state <= LANDED; // (|stored_array[0]) ? GAMEOVER : LANDED; 
            // GAMEOVER: next_state <= en_newgame ? SPAWN : GAMEOVER; 
            LANDED:  next_state <= SPAWN;   // After merge complete, spawn new block
            default: next_state <= SPAWN;
        endcase
    end
end

// Capture the block when spawned
always_ff @(posedge clk or posedge reset) begin
    if (reset)
        falling_block_array <= '0;
    else if (current_state == SPAWN)
        falling_block_array <= make_shape(block_t'(blocktype));   // <- one-cycle load
end

// Output Logic
always_comb begin
    // Control signals
    spawn_enable = (current_state == SPAWN);
    // finish = finish_internal;  // Pass through the finish signal
    // collision = 0; 
    
    // Display array selection
    case (current_state)
        SPAWN: begin
            display_array = falling_block_array | stored_array;  // Show newly spawned block + stored
        end
        FALLING: begin
            display_array = x_movement_array | stored_array;  // Show falling block + stored blocks
        end
        STUCK: begin 
            display_array = x_movement_array | stored_array; 
        end
        LANDED: begin
            display_array = stored_array;  // Show only stored blocks after landing
        end
        default: begin
            display_array = stored_array;
        end
    endcase
end 

// Stored Array Management (permanent grid)
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        stored_array <= '0;  // Clear the grid
    end else if ((current_state == LANDED && finish_internal)) begin
        // Merge the landed block into permanent storage only once
        stored_array <= stored_array | x_movement_array;
    end
end

//Left and Right movement
logic x_blocked;
logic [21:0][9:0] x_movement_array; 
logic [3:0] current_col1; 

always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        x_movement_array <= '0;
        current_col1 <= 'd4; 
    end else if (current_state == FALLING) begin
        x_movement_array <= movement_array; // Start with vertical movement
        
        if (left_i) begin
            x_blocked = '0; // Reset blocking flag
            // Check if left movement is blocked
            for (int row = 0; row <= 19; row++) begin
                if ((movement_array[row] & 10'b1000000000) != 0 || 
                    ((movement_array[row] << 1) & stored_array[row]) != 0) begin
                    x_blocked = '1;
                end
            end
            // Apply left movement if not blocked
            if (!x_blocked) begin
                for (int row = 0; row <= 19; row++) begin
                    x_movement_array[row] <= movement_array[row] << 1;
                    current_col1 <= current_col1 - 'd1; 
                end
            end
        end
        
        if (right_i) begin
            x_blocked = '0; // Reset blocking flag
            // Check if right movement is blocked
            for (int row = 0; row <= 19; row++) begin
                if ((movement_array[row] & 10'b0000000001) != 0 || 
                    ((movement_array[row] >> 1) & stored_array[row]) != 0) begin
                    x_blocked = '1;
                end
            end
            // Apply right movement if not blocked
            if (!x_blocked) begin
                for (int row = 0; row <= 19; row++) begin
                    x_movement_array[row] <= movement_array[row] >> 1;
                    current_col1 <= current_col1 + 'd1; 
                end
            end
        end
    end
end


logic spawn_pulse = (current_state == SPAWN) & (prev_state != SPAWN);
always_ff @(posedge clk) prev_state <= current_state;

// Instantiate existing modules
logic [2:0] current_state_counter; // From counter module
assign blocktype = current_state_counter; 
counter count (.clk(clk), .rst(reset), .button_i(spawn_pulse),
.current_state_o(current_state_counter), .counter_o());

assign finish = collision; 
logic collision; 
logic [4:0] collision_row1, collision_row2; 
logic [3:0] collision_col1, collision_col2, collision_col3;
// assign collision = collision_row1 == 'd21 ? 0 : display_array[collision_row1][collision_col1];  
assign collision = collision_row1 == 'd21 ? 0 : 
    collision_row2 == 'd21 ? ((current_state_counter == 0) ? display_array[collision_row1][collision_col1] : // line 
    (current_state_counter == 'd6) ? display_array[collision_row1][collision_col1] || display_array[collision_row1][collision_col2] || display_array[collision_row1][collision_col3] : // T
    (display_array[collision_row1][collision_col1] || display_array[collision_row1][collision_col2])) : // smashboy, L, reverseL  
    display_array[collision_row1][collision_col3] || display_array[collision_row2][collision_col2] || display_array[collision_row2][collision_col1]; 

movedown movement_controller (
    .clk(onehuzz),
    .rst(reset || (current_state == SPAWN)),  // Reset movedown when spawning new block
    .en(!collision), 
    .input_array(falling_block_array),        // Use captured block, not new_block_array
    .output_array(movement_array),
    .current_col1(current_col1), 
    .current_state(current_state_counter),
    .collision_row1(collision_row1), .collision_row2(collision_row2), 
    .collision_col1(collision_col1), .collision_col2(collision_col2), .collision_col3(collision_col3), 
    .finish(finish_internal)  // Connect to internal signal
);

endmodule