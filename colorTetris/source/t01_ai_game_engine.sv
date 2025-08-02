`default_nettype none
module t01_ai_game_engine (
    input logic clk, rst, 

    // tetris fsm 
    input logic [3:0] gamestate, 
    input logic col_right, col_left,  
    output logic ai_right, ai_left, ai_rotation, // movement 
    output logic [4:0] blockY, 
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
            ai_right <= 0;
            ai_left <= 0;  
            ai_rotation <= 0;  
            rot_en <= 1; 
            first_move_buffer <= 0; // get through the first iteratio first 
            ai_new_spawn <= 0; 
            base_block_type <= 0; 
            blockY <= 0; 
            blockX <= 0; 
        end else begin
            // 
            if (gamestate == 'd1) begin // spawn
                extract_start <= 0; 
                rot_en <= 1; 
                right_en <= 1;  
                first_move_buffer <= 0; 
                base_block_type <= current_block_type; 
            end else if (gamestate == 'd11) begin // AI spawn 
                extract_start <= 0; 
                first_move_buffer <= 1'b1; 
                // if (~col_right) begin 
                //     blockX <= blockX + 'd1;
                // end else begin 
                //     blockX <= 0; 
                // end 
            end else if (gamestate == 'd2) begin // falling state 
                if (first_move_buffer) begin 
                    if (~col_right) begin 
                        blockX <= blockX + 'd1;
                    end else begin 
                        blockX <= 0; 
                    end 
                end
                // only make one move at a time 
                // if (first_move_buffer) begin 
                //     if (right_en) begin 
                //         ai_left <= 1; 
                //     end else if (rot_en) begin 
                //         ai_rotation <= 1; 
                //     end 
                // end else begin 
                //     // the first iteration 
                //     if (!col_left) begin // move the piece to the leftmost 

                //     end
                // end
            end else if (gamestate == 'd10) begin // ai wait - waiting for feature extract -> mmu -> ofm 
                // set the pulse back for synkey 
                ai_left <= 0; 
                ai_rotation <= 0; 
                
                // feature extraction 
                extract_start <= 1'b1; 
                if (first_move_buffer) begin // not the first iteration 
                    if (extract_ready) begin 
                        if (col_right && current_block_type == base_block_type) begin 
                            ai_new_spawn <= 1; 
                        end 
                    end
                end 
            end 
        end 
    end

// ai movement pulses 
    // always_comb begin 
    //     if ()
    // end
    logic left_pulse, right_pulse, rotate_pulse; 

    t01_synckey alexanderweyerthegreat (
        .rst(rst),
        .clk(clk),
        .in({19'b0, ai_left}),
        .strobe(left_pulse)
    );
endmodule 