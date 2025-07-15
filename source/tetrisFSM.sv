module tetrisFSM (
    input logic clk, reset, onehuzz, en_newgame, right_i, left_i, 
    output logic spawn_enable,       // To blockgen module
    output logic [21:0][9:0] display_array, // Final display array
    output logic [2:0] blocktype, 
    output logic finish, gameover       // Output finish signal to top module
);

// FSM States
typedef enum logic [2:0] {
    SPAWN ,
    FALLING,
    RIGHT,
    LEFT,
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
    end else begin
        case (current_state)
            SPAWN:   next_state <= FALLING;  // After block spawns, start falling
            FALLING: next_state <= collision ? STUCK : (left_sync) ? LEFT : (right_sync) ? RIGHT : (finish_internal ? LANDED : FALLING);  // Wait for finish signal
            LEFT: next_state <= collision ? STUCK : FALLING; 
            RIGHT: next_state <= collision ? STUCK : FALLING; 
            STUCK:  begin  // (|stored_array[0]) ? GAMEOVER : LANDED; next_state <= LANDED; 
                    if (|stored_array[0]) begin
                        next_state <= GAMEOVER;
                    end else begin
                        next_state <= LANDED;
                    end
            end
            GAMEOVER: next_state <= current_state;
            LANDED:  next_state <= SPAWN;   // After merge complete, spawn new block
            default: next_state <= SPAWN;
        endcase
    end
end

// Capture the block when spawned
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        current_col1 <= 0; 
        current_col2 <= 0; 
        current_col3 <= 0; 
        falling_block_array <= '0;
    end else if (current_state == SPAWN) begin
        falling_block_array <= new_block_array;  // Capture the spawned block
        current_col1 <= n_col1; 
        current_col2 <= n_col2;
        current_col3 <= n_col3; 
    end
end

// Output Logic
always_comb begin
    // Control signals
    spawn_enable = (current_state == SPAWN);
    gameover = '0;
    // finish = finish_internal;  // Pass through the finish signal
    // collision = 0; 
    // x_movement_array = movement_array; // Start with vertical movement
    // x_blocked = '0; 

    // Display array selection
    case (current_state)
        SPAWN: begin
            display_array = new_block_array | stored_array;  // Show newly spawned block + stored
        end
        FALLING, RIGHT, LEFT: begin
            display_array = x_movement_array | stored_array;  // Show falling block + stored blocks

        end
        STUCK: begin 
            display_array = x_movement_array | stored_array; 
        end
        GAMEOVER: begin
            gameover = '1;
            display_array = stored_array;
        end
        LANDED: begin
            display_array = stored_array;  // Show only stored blocks after landing
        end
        default: begin
            display_array = stored_array;
        end
    endcase
    // collision detection - HAS TO BE ASSIGNED IN 'ALL' STATES - SPAWN - LANDED 
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
logic [3:0] current_col1, current_col2, current_col3, n_col1, n_col2, n_col3; 


// Instantiate existing modules
logic left_sync, right_sync; 
synckey left (.reset(reset), .hz100(clk), .in({19'b0, left_i}), .out(), .strobe(left_sync)); 
synckey right (.reset(reset), .hz100(clk), .in({19'b0, right_i}), .out(), .strobe(right_sync)); 

logic [2:0] current_state_counter; // From counter module
assign blocktype = current_state_counter; 
counter count (.clk(clk), .rst(reset), .button_i(current_state == SPAWN),
.current_state_o(current_state_counter), .counter_o());

blockgen block_generator (
    .current_state(current_state_counter),
    .enable(spawn_enable),
    .display_array(new_block_array)
);

assign finish = collision; 
logic collision; 
logic [4:0] collision_row1, collision_row2; 
logic [3:0] collision_col1, collision_col2, collision_col3;
// assign collision = collision_row1 == 'd21 ? 0 : display_array[collision_row1][collision_col1];  
assign collision = collision_row1 == 'd21 ? 0 : 
    collision_row2 == 'd21 ? ((current_state_counter == 0) ? display_array[collision_row1][current_col1] : // line 
    (current_state_counter == 'd6) ? display_array[collision_row1][current_col1] || display_array[collision_row1][current_col2] || display_array[collision_row1][current_col3] : // T
    (display_array[collision_row1][current_col1] || display_array[collision_row1][current_col2])) : // smashboy, L, reverseL  
    display_array[collision_row1][current_col3] || display_array[collision_row2][current_col2] || display_array[collision_row2][current_col1]; 


    logic [4:0] blockY, blockYN, maxY;
    logic [21:0][9:0] shifted_array;
    logic rst_movedown; 
    assign rst_movedown = reset || (current_state == SPAWN); 

    // Sequential logic for block position
    always_ff @(posedge onehuzz, posedge rst_movedown) begin
        if (rst_movedown) begin
            blockY <= 5'd0;
            // c_arr <= 0; 
        end else if (!finish) begin
            blockY <= blockYN;
            // c_arr <= n_arr; 
        end
    end



    always_comb begin
        // finish internal logic 
        // if (collision) begin // collision 
        //     finish_internal = '1; 
        // end else begin 
            finish_internal = '0;
        // end 
        blockYN = blockY;
        
        // Move down if not at bottom (leave some space at bottom)
        if (blockY < maxY) begin
            blockYN = blockY + 5'd1;
        end else begin
            blockYN = blockY; 
            finish_internal = '1; 
        end

        if (blockYN == maxY - '1) begin
            finish_internal = '1;
        end
    
        // Initialize output array to all zeros
        // n_arr = c_arr; 
        movement_array = 0; 
        collision_row1 = blockY + 'd4; // out of bounds 
        collision_row2 = 'd21; // last row 
        collision_col1 = 0;
        collision_col2 = 0; 
        collision_col3 = 0;  
        // if (en) begin 
        // Place the block pattern at the current Y position
        if (done_initialize) begin 
            case(current_state_counter)
                3'd0: begin // LINE
                collision_row1 = blockY + 'd4; 
                collision_col1 = 'd4; 
                    if (blockY + 3 < 20) begin
                        movement_array[blockY][current_col1] = 'b1;
                        movement_array[blockY+1][current_col1] = 'b1;
                        movement_array[blockY+2][current_col1] = 'b1;
                        movement_array[blockY+3][current_col1] = 'b1;
                    end
                end
                3'd1: begin // SMASHBOY
                collision_col1 = 'd4; 
                collision_row1 = blockY + 'd2; 
                collision_col2 = 'd5; 
                    if (blockY + 1 < 20) begin
                        movement_array[blockY][current_col1] = 'b1;
                        movement_array[blockY][current_col2] = 'b1;
                        movement_array[blockY+1][current_col1] = 'b1;
                        movement_array[blockY+1][current_col2] = 'b1;
                    end
                end
                3'd2: begin // L
                collision_col1 = 'd4; 
                collision_row1 = blockY + 'd3; 
                collision_col2 = 'd5; 
                    if (blockY + 2 < 20) begin
                        movement_array[blockY][current_col1] = 'b1;
                        movement_array[blockY+1][current_col1] = 'b1;
                        movement_array[blockY+2][current_col1] = 'b1;
                        movement_array[blockY+2][current_col2] = 'b1;
                    end
                end
                3'd3: begin // REVERSE_L
                collision_col1 = 'd4; 
                collision_row1 = blockY + 'd3; 
                collision_col2 = 'd5; 
                    if (blockY + 2 < 20) begin
                        movement_array[blockY][current_col2] = 'b1;
                        movement_array[blockY+1][current_col2] = 'b1;
                        movement_array[blockY+2][current_col2] = 'b1;
                        movement_array[blockY+2][current_col1] = 'b1;
                    end
                end
                3'd4: begin // S
                collision_row1 = blockY + 'd1; 
                collision_col1 = 'd4; 
                collision_row2 = blockY + 'd2; 
                collision_col2 = 'd5; 
                collision_col3 = 'd6; 
                    if (blockY + 1 < 20) begin
                        movement_array[blockY][current_col3] = 'b1;
                        movement_array[blockY][current_col2] = 'b1;
                        movement_array[blockY+1][current_col2] = 'b1;
                        movement_array[blockY+1][current_col1] = 'b1;
                    end
                end
                3'd5: begin // Z
                collision_row1 = blockY + 'd1; 
                collision_col1 = 'd6; 
                collision_row2 = blockY + 'd2; 
                collision_col2 = 'd5; 
                collision_col3 = 'd4; 
                    if (blockY + 1 < 20) begin
                        movement_array[blockY][current_col3] = 'b1;
                        movement_array[blockY][current_col2] = 'b1;
                        movement_array[blockY+1][current_col2] = 'b1;
                        movement_array[blockY+1][current_col1] = 'b1;
                    end
                end
                3'd6: begin // T
                collision_row1 = blockY + 'd2; 
                collision_col1 = 'd4; 
                collision_col2 = 'd5; 
                collision_col3 = 'd3; 
                    if (blockY + 1 < 20) begin
                        movement_array[blockY][current_col1] = 'b1;
                        movement_array[blockY+1][current_col3] = 'b1;
                        movement_array[blockY+1][current_col1] = 'b1;
                        movement_array[blockY+1][current_col2] = 'b1;
                    end
                end
                default: begin
                    // Do nothing for invalid state
                end
            endcase
       end
    end

    logic done_initialize; 
    always_comb begin 
        n_col1 = current_col1; 
        n_col2 = current_col2; 
        n_col3 = current_col3; 
        maxY = 5'd19;
        done_initialize = '0;

        x_blocked = 0;
        // shifted_array = movement_array;
        x_movement_array = movement_array;
        case(current_state_counter)
            3'd0: begin //line
            maxY = 5'd16;
            n_col1 = 'd4; 
            done_initialize = 1'b1; 
            end
            3'd1: begin //square
            maxY = 5'd18;
            n_col1 = 'd4; 
            n_col2 = 'd5; 
            done_initialize = 1'b1; 
            end
            3'd2: begin //L
            maxY = 5'd17;
            n_col1 = 'd4; 
            n_col2 = 'd5; 
            done_initialize = 1'b1; 
            end
            3'd3: begin// reverse L
            maxY = 5'd17;
            n_col1 = 'd4; 
            n_col2 = 'd5; 
            done_initialize = 1'b1; 
            end
            3'd4: begin // S
            maxY = 5'd18;
            done_initialize = 1'b1; 
            n_col1 = 'd4; 
            n_col2 = 'd5; 
            n_col3 = 'd6; 
            end
            3'd5: begin // Z
            maxY = 5'd18;
            done_initialize = 1'b1;
            n_col1 = 'd6; 
            n_col2 = 'd5; 
            n_col3 = 'd4; 
            end
            3'd6: begin // T
            maxY = 5'd18;
            n_col1 = 'd4; 
            n_col2 = 'd5; 
            n_col3 = 'd3; 
            done_initialize = 1'b1; 
            end
            default: begin 
                maxY = 5'd19;
                // n_col1 = 0; 
                // n_col2 = 0; 
            end 
        endcase

    if (left_sync) begin
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
            // for (int row = 0; row <= 19; row++) begin
                x_movement_array = movement_array << 1;
                n_col1 = current_col1 - 'd1; 
            // end
        end
    end
    
    if (right_sync) begin
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
            // for (int row = 0; row <= 19; row++) begin
                x_movement_array = movement_array >> 1;
                n_col1 = current_col1 + 'd1; 
            // end
        end
    end
    end



//PLEASE THERE IS NO REASON THIS SHIT SHOULDN'T WORK TRY IT TONIGHT OR TOMORROW - Cristian :3
// always_comb begin


    // if (left_i) begin
    //     for (int row = 0; row < 22; row++) begin
    //         if (movement_array[row][9] || (|(movement_array[row] << 1) & stored_array[row])) begin
    //             x_blocked = 1;
    //         end
    //     end
    //     if (!x_blocked) begin
    //         for (int row = 0; row < 22; row++) begin
    //             x_movement_array[row] = movement_array[row] << 1;
    //         end
    //     end
    // end

    // if (right_i) begin
    //     x_blocked = 0;
    //     for (int row = 0; row < 22; row++) begin
    //         if (movement_array[row][0] || ((movement_array[row] >> 1) & stored_array[row])) begin
    //             x_blocked = 1;
    //         end
    //     end
    //     if (!x_blocked) begin
    //         for (int row = 0; row < 22; row++) begin
    //             x_movement_array[row] = movement_array[row] >> 1;
    //         end
    //     end
    // end
   
    // x_movement_array = shifted_array;
// end
endmodule
