`default_nettype none
module t01_ai_game_engine (
    input logic clk, rst, 

    // tetris fsm 
    input logic [3:0] gamestate, 
    input logic col_right,  
    output logic ai_right, ai_left, // movement 
    input logic [3:0] falling_blockX, 
    output logic ai_new_spawn, 
    output logic [4:0] rotate_block_type, 
    input logic ai_rotated, 
    output logic need_rotate, force_right, 

    // feature extraction 
    input logic ofm_done, // extraction done 
    output logic extract_start, 

    // inputs from ofm to stream back to tetris: mamnhattan distance + block type 
    input logic [4:0] current_block_type
);      
    logic [4:0] base_block_type; 
    logic [3:0] last_blockX; 
    logic [2:0] blockX_counter; 
    logic right_en, rot_en, first_move_buffer, rotated, ai_col_right; // determine if the ai needs to move in the next state  

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            extract_start <= 0; 
            rot_en <= 1; 
            first_move_buffer <= 0; // get through the first iteratio first 
            ai_new_spawn <= 0; 
            base_block_type <= 0; 
            // rotate_block_type <= 0; 
            last_current_block_type <= 0; 
            rotated <= 0; 
            need_rotate <= 0; 
            rotate_block_type <= 0;
            force_right <= 0; 
            blockX_counter <= 0; 
            ai_col_right <= 0; 
        end else begin
            if (gamestate == 'd1) begin // spawn
                extract_start <= 0; 
                right_en <= 1;  
                first_move_buffer <= 0; 
                ai_new_spawn <= 0; 
                rotated <= 0; 
                blockX_counter <= 0; 
            end else if (gamestate == 'd2) begin
                ai_col_right <= collision_right; // latch if the piece is at the right border 
                // check if we're at the same column  
                if (falling_blockX == last_blockX) begin 
                    blockX_counter <= blockX_counter + 1; 
                end else begin 
                    blockX_counter <= 0; 
                end
                last_current_block_type <= current_block_type; 
                if (!first_move_buffer) begin // first spawn dropping  
                    base_block_type <= current_block_type; 
                end else begin
                    rotate_block_type <= n_rotate_block_type; 
                end 
            end else if (gamestate == 'd3) begin // rotate state 
                rot_en <= 0; 
                rotated <= 1; 
            end else if (gamestate == 'd10) begin // ai wait - waiting for feature extract -> mmu -> ofm 
                last_blockX <= falling_blockX; // latching the fell blockX during ai wait state 
                // feature extraction 
                extract_start <= 1'b1; 
                rot_en <= 0; 
                need_rotate <= 0; 
                if (rotated) begin 
                    last_current_block_type <= rotate_block_type; 
                end
                // not at the right border yet 
                // but encounter a piece on the right that prevents us to go through all possible moves  
                if (blockX_counter >= 3'd7 && col_right && !collision_right) begin 
                    blockX_counter <= 0; // reset the counter after force right 
                    force_right <= 1; 
                end else begin 
                    force_right <= 0; 
                end 
                if (first_move_buffer) begin // not the first iteration 
                    if (ofm_done) begin 
                        if (ai_col_right) begin 
                            if (rotate_block_type == base_block_type) begin 
                                ai_new_spawn <= 1; 
                            end else begin 
                                rot_en <= 1; 
                                if (ai_rotated) begin 
                                    need_rotate <= 0;    
                                end else begin 
                                    need_rotate <= 1; 
                                end
                            end 
                        end else begin 
                            rot_en <= 0; 
                        end 
                    end
                end 
            end else if (gamestate == 'd11) begin // AI spawn 
                blockX_counter <= 0; 
                extract_start <= 0; 
                first_move_buffer <= 1'b1; 
                need_rotate <= 0; 
                if (ai_new_spawn) begin 
                    right_en <= 0; // this is the ai decision delivered by ofm, don't move right 
                end else begin 
                    right_en <= 1; // move right by one column for all possibilities 
                end
            end 
        end 
    end

    // move to the very left for the first spawn 
    always_comb begin 
        ai_left = 0; 
        if ((!first_move_buffer || need_rotate) && gamestate == 'd2) begin // move it to the very left for the first drop 
            if (left_pulse) begin 
                ai_left = 0; 
            end else begin 
                ai_left = 1; 
            end
        end else if (rot_en) begin 
            if (gamestate == 'd2) begin 
                if (left_pulse) begin 
                    ai_left = 0; 
                end else begin 
                    ai_left = 1; 
                end
            end
        end
    end

    // move right by one column for every ai spawn 
    // rotate if possible 
    always_ff @(posedge clk, posedge rst) begin 
        if(rst) begin
            ai_right <= '0;
        end else if (first_move_buffer) begin
            if (gamestate == 'd2) begin 
                if (right_en) begin 
                    ai_right <= 1; 
                end 
            end else begin 
                ai_right <= 0; 
            end 
        end
    end

    // edge detector for movement 
    logic left_pulse; 

    t01_synckey alexanderweyerthegreat (
        .rst(rst),
        .clk(clk),
        .in({19'b0, ai_left}),
        .strobe(left_pulse)
    );

// simplified internal collision 
// only goes high when we're at the left / right border 
    logic [3:0] col_ext, abs_col;
    logic collision_right; 
    logic [3:0][3:0] current_block_pattern;

    always_comb begin 
        collision_right = 1'b0;
        for (int row = 0; row < 4; row++) begin
            for (int col = 0; col < 4; col++) begin
                col_ext = {2'b00, col[1:0]};
                abs_col = falling_blockX + col_ext;
                // only process cells that contain part of the tetromino
                if (current_block_pattern[row][col]) begin
                    // right collision
                    if (abs_col + 4'd1 >= 4'd10) begin
                        collision_right = 1'b1;
                    end
                end
            end 
        end
    end

    // Block pattern generator for current piece
    t01_blockgen swabey (
        .current_block_type(current_block_type),
        .current_block_pattern(current_block_pattern)
    );
// simplified rotation logic 
    logic [4:0] n_rotate_block_type, last_current_block_type; 

    always_comb begin
        case (last_current_block_type)
            // I-piece: 2 orientations
            5'd0:  n_rotate_block_type = 5'd7;   // Vertical → Horizontal
            5'd7:  n_rotate_block_type = 5'd0;   // Horizontal → Vertical

            // O-piece: No rotation needed
            5'd1:  n_rotate_block_type = 5'd1;

            // S-piece: 2 orientations
            5'd2:  n_rotate_block_type = 5'd9;   // Horizontal → Vertical
            5'd9:  n_rotate_block_type = 5'd2;   // Vertical → Horizontal

            // Z-piece: 2 orientations
            5'd3:  n_rotate_block_type = 5'd8;   // Horizontal → Vertical
            5'd8:  n_rotate_block_type = 5'd3;   // Vertical → Horizontal

            // L-piece: 4 orientations (0° → 90° → 180° → 270°)
            5'd5:  n_rotate_block_type = 5'd13;  // 0° → 90°
            5'd13: n_rotate_block_type = 5'd14;  // 90° → 180°
            5'd14: n_rotate_block_type = 5'd15;  // 180° → 270°
            5'd15: n_rotate_block_type = 5'd5;   // 270° → 0°

            // J-piece: 4 orientations
            5'd4:  n_rotate_block_type = 5'd10;  // 0° → 90°
            5'd10: n_rotate_block_type = 5'd11;  // 90° → 180°
            5'd11: n_rotate_block_type = 5'd12;  // 180° → 270°
            5'd12: n_rotate_block_type = 5'd4;   // 270° → 0°

            // T-piece: 4 orientations
            5'd6:  n_rotate_block_type = 5'd18;  // 0° → 90°
            5'd18: n_rotate_block_type = 5'd17;  // 90° → 180°
            5'd17: n_rotate_block_type = 5'd16;  // 180° → 270°
            5'd16: n_rotate_block_type = 5'd6;   // 270° → 0°

            default: n_rotate_block_type = current_block_type;
        endcase

    end 

endmodule 