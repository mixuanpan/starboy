module tetrisFSM (
    input logic clk, reset, onehuzz,
    output logic spawn_enable,       // To blockgen module
    output logic [21:0][9:0] display_array, // Final display array
    output logic finish             // Output finish signal to top module
);

// FSM States
typedef enum logic [2:0] {
    SPAWN ,
    SPAWN_WAIT,
    MOVING,
    LEFT,
    RIGHT,
    FALLING,
    ROTATE,
    STUCK,  
    LANDED,
    GAMEOVER

} game_state_t;

game_state_t current_state, next_state;

// Arrays
logic [21:0][9:0] new_block_array;      // From blockgen
logic [21:0][9:0] movement_array;       // From movedown
logic [21:0][9:0] stored_array;         // Permanent grid storage
logic [21:0][9:0] falling_block_array;  // Active falling block

logic check, checked; 

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

// Next State Logic - Use onehuzz for state transitions to sync with block movement
always_ff @(posedge onehuzz, posedge reset) begin
    if (reset) begin
        next_state <= SPAWN;
        check <= 1'b0;
    end else begin
        check <= 1'b0;
        case (current_state)
            SPAWN:   next_state <= SPAWN_WAIT;  // After block spawns, start falling
            SPAWN_WAIT: next_state <= MOVING;
            FALLING: begin
                if(finish_internal && !checked) begin
                    check <= 1'b1;
                    next_state <= FALLING;
                end
                else if (checked) begin
                    next_state <= (collision ? STUCK : LANDED);
                end
                else begin
                    next_state <= FALLING;
                end
            end
                //next_state <= collision ? STUCK : (finish_internal ? LANDED : FALLING);  // Wait for finish signal
            STUCK: next_state <= LANDED; 
            LANDED:  next_state <= SPAWN;   // After merge complete, spawn new block
            default: next_state <= SPAWN;
        endcase
    end
end

// Capture the block when spawned
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        falling_block_array <= '0;
    end else if (current_state == SPAWN_WAIT) begin
        falling_block_array <= new_block_array;  // Capture the spawned block
    end
end

// Output Logic
always_comb begin
    // Control signals
    spawn_enable = (current_state == SPAWN);
    finish = finish_internal;  // Pass through the finish signal
    
    // Display array selection
    case (current_state)
        SPAWN: begin
            display_array = new_block_array | stored_array;  // Show newly spawned block + stored
        end
        SPAWN_WAIT: begin
            display_array = new_block_array | stored_array;  // Show newly spawned block + stored
        end
        FALLING: begin
            display_array = movement_array | stored_array;  // Show falling block + stored blocks
        end
        STUCK: begin 
            display_array = movement_array | stored_array; 
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
        stored_array <= stored_array | movement_array;
    end
end

// Instantiate existing modules
logic [2:0] current_state_counter; // From counter module
counter count (.clk(clk), .rst(reset), .button_i(current_state == SPAWN),
.current_state_o(current_state_counter), .counter_o());

blockgen block_generator (
    .current_state(current_state_counter),
    .rst(reset),
    .clk(clk),
    .enable(spawn_enable),
    .display_array(new_block_array)
);

logic collision; 
logic [4:0] collision_row; 
//assign collision = collision_row == 'd21 ? 0 : display_array[collision_row][4]; 

movedown movement_controller (
    .clk(onehuzz),
    .rst(reset || (current_state == SPAWN) || (current_state == SPAWN_WAIT)),  // Reset movedown when spawning new block
    .en(!collision), 
    .stored_array(stored_array),
    .input_array(falling_block_array),        // Use captured block, not new_block_array
    .output_array(movement_array),
    .check(check),
    .collision(collision),
    .checked(checked),
    .current_state(current_state_counter),
    .collision_row(collision_row), 
    .finish(finish_internal)  // Connect to internal signal
);

endmodule