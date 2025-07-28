`default_nettype none
// FSM State Definitions
typedef enum logic [3:0] {
    INIT,
    SPAWN,
    FALLING,
    ROTATE,
    ROTATE_L,
    STUCK,
    LANDED,
    EVAL,    
    GAMEOVER  
} game_state_t;

module t01_ai_game_engine #(
    parameter int K_WIDTH = 4, // kernel_size bits 
    parameter int S_WIDTH = 4, // stride bits 
    parameter int TYPE_WIDTH = 4, // layer_type bits 
    parameter int INST_WIDTH = K_WIDTH + S_WIDTH + TYPE_WIDTH + 2// width of the instruction word 
)(
    input logic clk, reset, en_newgame,
    input logic right_i, left_i, start_i, rotate_r, rotate_l,
    output logic [19:0][9:0] display_array,
    output logic [19:0][9:0][2:0] final_display_color,
    output logic gameover,
    output logic [9:0] score,

    // ai - control unit instruction decoder
    input logic [4:0] blockY, 
    input logic [3:0] blockX, // coordinates 
    input logic [4:0] current_block_type, 
    input logic ai_movement_done, 

    output game_state_t ai_state, // current state 
    output logic [INST_WIDTH-1:0] inst_word, // to control unit instruction decoder 
    output logic [19:0][9:0] stored_array, 
    output logic [3:0][3:0] ai_bp, // block pattern 
    output logic [4:0] next_current_block_type, 
    output logic [2:0] current_state_counter, 
    output logic collision_bottom, collision_left, collision_right, // collision detection
    output logic rotation_valid, left_pulse, right_pulse
    
);

    // Color loading for the display only (not ai)
    localparam BLACK   = 3'b000;  // No color
    localparam RED     = 3'b100;  // Red only
    localparam GREEN   = 3'b010;  // Green only
    localparam BLUE    = 3'b001;  // Blue only

    // Mixed Colors
    localparam YELLOW  = 3'b110;  // Red + Green
    localparam MAGENTA = 3'b101;  // Red + Blue (Purple/Pink)
    localparam CYAN    = 3'b011;  // Green + Blue (Aqua)
    localparam WHITE   = 3'b111;  // All colors (Red + Green + Blue)

    logic [2:0] current_piece_color;
    logic [19:0][9:0][2:0] color_array;        // Stores colors of landed pieces
    always_comb begin
        case (current_block_type)
            5'd0, 5'd7:                    current_piece_color = CYAN; //I
            5'd1:                          current_piece_color = YELLOW; //Smashboy
            5'd2, 5'd9:                    current_piece_color = GREEN; //S
            5'd3, 5'd8:                    current_piece_color = RED; //Z
            5'd4, 5'd10, 5'd11, 5'd12:     current_piece_color = WHITE; //J
            5'd5, 5'd13, 5'd14, 5'd15:     current_piece_color = BLUE; //L
            5'd6, 5'd16, 5'd17, 5'd18:     current_piece_color = MAGENTA; //T
            default:                       current_piece_color = BLACK; 
        endcase
    end

    // state variables
    game_state_t current_state, next_state;
    assign ai_state = current_state; 

    // block Position and type
    // logic [4:0] current_block_type;
    logic [3:0][3:0] current_block_pattern;
    logic [3:0][3:0] next_block_pattern;
    assign ai_bp = current_block_pattern; 

    // control signals
    logic eval_complete;

    // delayed sticking logic 
    logic collision_bottom_prev;
    logic stick_delay_active; 

    // input synchronization
    logic rotate_pulse, /*left_pulse, right_pulse, */rotate_pulse_l;

    // line clear module interface
    logic start_line_eval;
    logic line_eval_complete;
    logic [19:0][9:0] line_clear_input;
    logic [19:0][9:0] line_clear_output;
    logic [9:0] line_clear_score;

    // output Assignments
    assign score = line_clear_score;

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
    // rotation logic !!!
    //=============================================================================

    always_comb begin
        next_current_block_type = current_block_type;
        
        if (current_state == ROTATE) begin
            // if (rotate_pulse_l) begin // Clockwise rotation
                case (current_block_type)
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

                    default: next_current_block_type = current_block_type;
                endcase
            end else if (current_state == ROTATE_L) begin // Counter-clockwise rotation
                case (current_block_type)
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

                    default: next_current_block_type = current_block_type;
                endcase
            end
        end

//=============================================================================
// stored array management + color display 
//=============================================================================

// Manage the permanently placed blocks AND their colors
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        stored_array <= '0;
        color_array <= '0;  
    end 
else if (current_state == STUCK) begin
    stored_array <= stored_array | falling_block_display;  // Atomic bitwise OR
    
    // Update colors separately
    for (int row = 0; row < 20; row++) begin
        for (int col = 0; col < 10; col++) begin
            if (falling_block_display[row][col]) begin
                color_array[row][col] <= current_piece_color;
            end
        end
    end
end
    else if (current_state == EVAL && line_eval_complete) begin
        stored_array <= line_clear_output;
    end
end

always_ff @(posedge clk) begin // moved to FF to try to fix that floating issue.
    for (int row = 0; row < 20; row++) begin
        for (int col = 0; col < 10; col++) begin
            if (falling_block_display[row][col]) begin
                // Falling piece gets its current color
                final_display_color[row][col] <= current_piece_color;
            end else if (stored_array[row][col]) begin
                // Landed pieces keep their stored color
                final_display_color[row][col] <= color_array[row][col];
            end else begin
                // Empty space is black
                final_display_color[row][col] <= 3'b000;
            end
        end
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
                display_array = '0;
            end

            SPAWN: begin
                next_state = FALLING;
                display_array = falling_block_display | stored_array;
            end

            FALLING: begin
                // Transition to STUCK only after delay period
                if (collision_bottom && stick_delay_active /*&& drop_tick*/) begin
                    next_state = STUCK;
                end 
                // Handle rotation (O-piece doesn't rotate)
                else if (current_block_type != 5'd1 && rotate_pulse) begin
                    next_state = ROTATE;
                end else if (current_block_type != 5'd1 && rotate_pulse_l) begin
                    next_state = ROTATE_L;
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
            ROTATE_L: begin
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
        .in(rotate_r),
        .strobe(rotate_pulse)
    );

    t01_synckey lanadelrey (
        .rst(reset),
        .clk(clk),
        .in(rotate_l),
        .strobe(rotate_pulse_l)
    );

    t01_synckey puthputhboy (
        .rst(reset),
        .clk(clk),
        .in(left_i),
        .strobe(left_pulse)
    );

    t01_synckey JohnnyTheKing (
        .rst(reset),
        .clk(clk),
        .in(right_i),
        .strobe(right_pulse)
    );

    // Block pattern generator
    t01_blockgen swabey (
        .current_block_type(current_block_type),
        .current_block_pattern(current_block_pattern)
    );

    t01_blockgen yebaws (
        .current_block_type(next_current_block_type),
        .current_block_pattern(next_block_pattern)
    );

endmodule
