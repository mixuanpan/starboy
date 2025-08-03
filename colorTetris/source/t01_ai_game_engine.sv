`default_nettype none
module t01_ai_game_engine (
    input logic clk, rst, 

    // tetris fsm 
    input logic [3:0] gamestate, 
    input logic col_right, col_left,  
    output logic ai_right, ai_left, ai_rotation, // movement 
    output logic [3:0] blockX, 
    output logic ai_new_spawn, 

    // feature extraction 
    input logic extract_ready, // extraction done 
    output logic extract_start, 

    // inputs from ofm to stream back to tetris: mamnhattan distance + block type 
    input logic [4:0] current_block_type 

);  
    logic [4:0] base_block_type; 
    logic right_en, rot_en, first_move_buffer; // determine if the ai needs to move in the next state  

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            extract_start <= 0; 
            // ai_right <= 0;
            // ai_left <= 0;  
            ai_rotation <= 0;  
            rot_en <= 1; 
            first_move_buffer <= 0; // get through the first iteratio first 
            ai_new_spawn <= 0; 
            base_block_type <= 0; 
            blockX <= 0; 
            move_cnt <= 0; 
        end else begin
            // 
            if (gamestate == 'd1) begin // spawn
                extract_start <= 0; 
                rot_en <= 1; 
                right_en <= 1;  
                first_move_buffer <= 0; 
                base_block_type <= current_block_type; 
                move_cnt <= 0; 
                if (~/*col_left*/collision_left) begin 
                    if (blockX == 0) begin 
                        blockX <= 'd9; 
                    end else begin 
                        blockX <= blockX - 1; 
                    end 
                end 
            end else if (gamestate == 'd2) begin 
                if (right_pulse) begin 
                    move_cnt <= 1; 
                end
            end else if (gamestate == 'd10) begin // ai wait - waiting for feature extract -> mmu -> ofm 
                move_cnt <= 0; 

                ai_rotation <= 0; 
                
                // feature extraction 
                extract_start <= 1'b1; 
                if (first_move_buffer) begin // not the first iteration 
                    if (extract_ready) begin 
                        if (col_right /*&& current_block_type == base_block_type*/) begin 
                            ai_new_spawn <= 1; 
                        end 
                    end
                end 


            end else if (gamestate == 'd11) begin // AI spawn 
                extract_start <= 0; 
                first_move_buffer <= 1'b1; 
                if (~/*col_left*/collision_left) begin 
                    if (blockX == 0) begin 
                        blockX <= 'd9; 
                    end else begin 
                        blockX <= blockX - 1; 
                    end 
                end 
            end 
        end 
    end

// simplified internal collision 
    logic [3:0] col_ext, abs_col;
    logic collision_left, collision_right; 

    always_comb begin 
        collision_left = 1'b0;
        collision_right = 1'b0;
        for (int row = 0; row < 4; row++) begin
            for (int col = 0; col < 4; col++) begin
                col_ext = {2'b00, col[1:0]};
                abs_col = blockX + col_ext;

                    // left collision
                    if (abs_col == 4'd0) begin
                        collision_left = 1'b1;
                    end

                    // right collision
                    if (abs_col + 4'd1 >= 4'd10) begin
                        collision_right = 1'b1;
                    end
                end 
            end
        end

always_comb begin 
    ai_left = 0; 
    // ai_right = 0; 
    if (first_move_buffer) begin  // move it to the right by one column at a time 
        // if (~move_cnt) begin 
        //     ai_right = 1; 
        // end else begin // falling
        //     ai_right = 0; 
        // end 
    end else begin // move it to the very left for the first drop 
        if (left_pulse) begin 
            ai_left = 0; 
        end
        if (!left_pulse) begin 
            ai_left = 1; 
        end
    end
end
    logic left_pulse, right_pulse, rotate_pulse, right_i, move_cnt; 

    t01_synckey alexanderweyerthegreat (
        .rst(rst),
        .clk(clk),
        .in({19'b0, ai_left}),
        .strobe(left_pulse)
    );
    t01_synckey aws (
        .rst(rst),
        .clk(clk),
        .in({19'b0, ai_right}),
        .strobe(right_pulse)
    );
endmodule 