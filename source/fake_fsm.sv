`default_nettype none
    typedef enum logic [4:0] {
        IDLE, // reset state 
        READY, // count down to start 
        NEW_BLOCK, // load new block 
        LOAD, 
        A1, 
        A2, 
        B1, 
        B2, 
        C1,  
        C2, 
        D0,
        E1, 
        E2, 
        E3, 
        E4, 
        F1, 
        F2, 
        F3, 
        F4, 
        G1, 
        G2, 
        G3, 
        G4, 
        EVAL, // evaluation 
        LINECLEAR, 
        GAME_OVER // user run out of space 11000 
    } state_t; 

    typedef enum logic [2:0] {
        RIGHT, 
        LEFT, 
        ROR, // ROTATE RIGHT
        ROL, // ROTATE LEFT 
        DOWN, 
        NONE
    } move_t; 

    typedef enum logic [2:0] {
        CL0, // BLACK   
        CL1, 
        CL2, 
        CL3, 
        CL4, 
        CL5, 
        CL6, 
        CL7
    } color_t; 

module fake_fsm(
    input logic clk, rst, 
    input logic en, right, left, rr, rl, 
    output logic [21:0][9:0][2:0] grid 
); 
      // next state variable initialization 
    state_t c_state, n_state, l_state; 
    color_t c_color, n_color; // color of the block 
    logic [4:0] row_inx, row_tmp; // reference row index  
    logic [3:0] col_inx, col_tmp; // reference col index

    // grid next state logic 
    logic [21:0][9:0][2:0] c_grid, n_grid; 
    assign grid = c_grid; 

    // extract & write frames 
    logic [4:0][4:0][2:0] frame_extract_o; 
    logic [21:0][9:0][2:0] grid_write_o; 
    logic extract_en, write_en, extract_done, write_done; 
    frame_extract extraction (.clk(clk), .rst(rst), .en(extract_en), .c_grid(c_grid), .row_inx(row_inx), .col_inx(col_inx), .c_frame(frame_extract_o), .done(extract_done));
    frame_write write_out (.clk(clk), .rst(rst), .en(write_en), .n_frame(n_frame), .n_grid(grid_write_o), .row_inx(row_inx), .col_inx(col_inx), .done(write_done)); 

    // 5x5 frame tracker 
    logic [4:0][4:0][2:0] c_frame, n_frame; 
    move_t movement; 
    logic track_complete, track_en; 
    tracker track (.state(c_state), .en(track_en), .frame_i(c_frame), .move(movement), .color(c_color), .check_tb(), .complete(track_complete), .frame_o(n_frame)); 

    always_comb begin 
        if (A1 <= c_state && c_state <= G4) begin // game state 
        if (right) begin 
            movement = RIGHT; 
        end else if (left) begin 
            movement = LEFT; 
        end else if (rr) begin 
            movement = ROR; 
        end else if (rl) begin 
            movement = ROL; 
        end else begin 
            movement = DOWN; // default case: DOWN 
        end 
        end else begin 
        movement = NONE; // null case 
        end 
    end

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
        c_grid <= 0; 
        c_color <= CL0; 
        c_state <= A1; 
        row_inx <= 0; 
        col_inx <= 0; 
        end else begin 
        c_grid <= n_grid; 
        c_color <= n_color; 
        c_state <= n_state; 
        row_inx <= row_tmp; 
        col_inx <= col_tmp; 
        end 
    end

    always_comb begin 
        en_nb = 0; 
        clear_en = 0; 
        en_update = 0; 
        extract_en = 0; 
        write_en = 0; 
        track_en = 0; 
        n_color = c_color;
        n_grid = c_grid; 
        row_tmp = row_inx; 
        col_tmp = col_inx; 
        c_frame = 0; 
        n_state = c_state; 
        l_state = c_state; 
        
        case (c_state)
            A1: begin 
                l_state = A1; 
                track_en = 1'b1; 

                extract_en = 1'b1; 
                c_frame = frame_extract_o; 
                // frame update 
                if (track_complete && extract_done) begin 
                write_en = 1'b1; 

                if (write_done) begin 
                    n_grid = grid_write_o; 
                    en_update = 1'b1; 
                    row_tmp = row_movement_update; 
                    col_tmp = col_movement_update; 
                    if (update_done) begin 
                    n_state = EVAL;
                    end 
                end 
                // update reference numbers 
                end else begin 
                n_state = c_state; 
                end 
            end

            default: begin 
                n_state = c_state; 
            end
        endcase
    end
endmodule 