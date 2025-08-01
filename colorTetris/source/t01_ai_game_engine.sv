`default_nettype none
module t01_ai_game_engine (
    input logic clk, onehuzz, rst, en_newgame, 
    // input logic [19:0][9:0] tetris_stored_array,   
    // output logic [19:0][9:0] current_tetris_grid, 
    output logic [19:0][9:0][2:0] display_color, 
    output logic [1:0] mmu_layer_sel, 
    output logic mmu_all_done, 
    input logic mmu_done, 

    // feature extraction 
    input logic extract_ready, // extraction done 
    output logic extract_start, 
    output logic [19:0][9:0][2:0] final_display_color, 
    output logic [199:0] fe_board, 

    // inputs from ofm to stream back to tetris: mamnhattan distance + block type 
    input logic ofm_layer_done, 
    output logic [4:0] current_blockY,
    output logic [3:0] current_blockX,  
    output logic [4:0] current_block_type, ai_block_type, base_block_type, 
    input logic [4:0] ofm_blockY, 
    input logic [3:0] ofm_blockX, 
    input logic [4:0] ofm_block_type, 
    output logic new_layer // a new piece spawned 
);  
    // flatten 2D array 
    assign fe_board[9:0] = new_block_array[0];  
    assign fe_board[19:10] = new_block_array[1]; 
    assign fe_board[29:20] = new_block_array[2]; 
    assign fe_board[39:30] = new_block_array[3];  
    assign fe_board[49:40] = new_block_array[4]; 
    assign fe_board[59:50] = new_block_array[5]; 
    assign fe_board[69:60] = new_block_array[6];  
    assign fe_board[79:70] = new_block_array[7]; 
    assign fe_board[89:80] = new_block_array[8]; 
    assign fe_board[99:90] = new_block_array[9]; 
    assign fe_board[109:100] = new_block_array[10];  
    assign fe_board[119:110] = new_block_array[11]; 
    assign fe_board[129:120] = new_block_array[12]; 
    assign fe_board[139:130] = new_block_array[13];  
    assign fe_board[149:140] = new_block_array[14]; 
    assign fe_board[159:150] = new_block_array[15]; 
    assign fe_board[169:160] = new_block_array[16];  
    assign fe_board[179:170] = new_block_array[17]; 
    assign fe_board[189:180] = new_block_array[18]; 
    assign fe_board[199:190] = new_block_array[19]; 

    logic [3:0] gamestate;
    logic [19:0][9:0] ai_falling_block_display, new_block_array, last_stored_array; 
    // logic [19:0][9:0][2:0] display_color; 
    logic [2:0] current_state_counter; 
    logic ai_new_spawn; 

    // ai movements 
    logic ai_left, ai_rotation, collision_left;
    logic left_en, rot_en, first_move_buffer; // determine if the ai needs to move in the next state  
    assign new_layer = gamestate == 'd1; // spawn 

    // Game Logic
    t01_ai_tetrisFSM ai_plait (
      .gamestate(gamestate),
      .ai_done(ofm_layer_done), // keep moving from landed state 
      .clk(clk), 
      .onehuzz(onehuzz), 
      .reset(rst || extract_ready), 
      .rotate_l(), 
      .ai_state_counter(current_state_counter), 
      .final_display_color(display_color),
      .current_block_type(current_block_type), 
      .speed_up_i(1'b1), // always soft drop speed 
      .en_newgame(en_newgame),
      .right_i(), 
      .left_i(ai_left), 
      .rotate_r(ai_rotation), 
      .speed_mode_o(),
      .display_array(new_block_array), 
      .gameover(), 
      .score(), 
      .start_i(en_newgame), 
      .ai_collision_left(collision_left), 
      .ai_new_spawn(ai_new_spawn)
    );

    logic [4:0] l_blockY, blockY, c_rotation, max_rotation; // maximum rotations count 
    logic [3:0] l_blockX, blockX, c_col, max_col; // maximum possible combinations 

    // typedef enum logic [3:0] {
    //     INIT = 'd0,
    //     SPAWN = 'd1,
    //     FALLING = 'd2,
    //     ROTATE = 'd3,
    //     ROTATE_L = 'd4,
    //     STUCK = 'd5,
    //     LANDED = 'd6,
    //     EVAL = 'd7,    
    //     GAMEOVER = 'd8,
    //     RESTART = 'd9 
    // } game_state_t;
    
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            last_stored_array <= 0; 
            blockX <= 0; 
            blockY <= 0; 
            extract_start <= 0; 
            ai_left <= 0; 
            ai_rotation <= 0;  
            left_en <= 1; 
            rot_en <= 1; 
            first_move_buffer <= 0; // get through the first iteratio first 
            ai_new_spawn <= 0; 
            base_block_type <= 0; 
            mmu_layer_sel <= 0; 
            mmu_all_done <= 0; 
        end else begin
            // convo engine 
            if (mmu_done) begin 
                mmu_layer_sel <= mmu_layer_sel + 1; 
                if (mmu_layer_sel == 2'b11) begin 
                    mmu_all_done <= 1;
                end 
            end 
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