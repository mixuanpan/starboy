`default_nettype none
module t01_ai_game_engine (
    input logic clk, rst, 

    // tetris fsm 
    input logic [3:0] gamestate, 
    input logic collision_left, 
    output logic ai_left, ai_rotation, 

    // feature extraction 
    input logic extract_ready, // extraction done 
    output logic extract_start, 

    // inputs from ofm to stream back to tetris: mamnhattan distance + block type 
    input logic [4:0] current_block_type 

);  

    logic [19:0][9:0] last_stored_array; 
    logic ai_new_spawn; 
    logic [4:0] base_block_type; 
    logic left_en, rot_en, first_move_buffer; // determine if the ai needs to move in the next state  

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            last_stored_array <= 0; 
            extract_start <= 0; 
            ai_left <= 0; 
            ai_rotation <= 0;  
            left_en <= 1; 
            rot_en <= 1; 
            first_move_buffer <= 0; // get through the first iteratio first 
            ai_new_spawn <= 0; 
            base_block_type <= 0; 
        end else begin
            // 
            if (gamestate == 'd1) begin // spawn
                rot_en <= 1; 
                left_en <= 1;  
                first_move_buffer <= 0; 
                base_block_type <= current_block_type; 
            end else if (gamestate == 'd2) begin // falling state 
                // only make one move at a time 
                if (first_move_buffer) begin 
                    if (left_en) begin 
                        ai_left <= 1; 
                    end else if (rot_en) begin 
                        ai_rotation <= 1; 
                    end 
                end 
            end else if (gamestate == 'd10) begin // ai state 
                // set the pulse back for synkey 
                ai_left <= 0; 
                ai_rotation <= 0; 
                
                // feature extraction 
                extract_start <= 1'b1; 
                if (first_move_buffer) begin // not the first iteration 
                    if (extract_ready) begin 
                        if (collision_left && current_block_type == base_block_type) begin 
                            ai_new_spawn <= 1; 
                        end 
                    end
                end else begin 
                    first_move_buffer <= 1; // go to the AI state -> means the first STUCK happened 
                end
            end 
        end 
    end
endmodule 