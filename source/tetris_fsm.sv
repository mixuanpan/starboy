`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris_fsm
// Description : Main file for the Tetris 
// 
//
/////////////////////////////////////////////////////////////////

// import tetrispkg::*;

    typedef enum logic [4:0] {
        IDLE, // reset state 00000 
        // READY, // count down to start 
        NEW_BLOCK, // load new block 00001
        LOAD, // 00010
        A1, // 00011 
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
        UPDATE, 
        WRITE, 
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


module tetris_fsm (
  input logic clk, rst, 
  input logic en, right, left, rr, rl, down, 
  output state_t state_tb, 
  output logic [21:0][9:0][2:0] grid, 

  // for testing 
  output logic done_extracting, 
  output move_t move_state, 
  output logic last_state
);

  assign state_tb = c_state; 
  assign done_extracting = track_en; 
  assign move_state = movement; 
  assign last_state = l_state == A1; 

  // next state variable initialization 
  state_t c_state, n_state, l_state, n_l_state; 
  color_t c_color, n_color; // color of the block 
  logic [4:0] row_inx, row_tmp; // reference row index  
  logic [3:0] col_inx, col_tmp; // reference col index

  // grid next state logic 
  logic [21:0][9:0][2:0] c_grid, n_grid; 
  assign grid = c_grid; 

  // load in a new block 
  logic en_nb; // enable new block 
  logic [2:0] nb; // newblock 
  logic [21:0][9:0][2:0] nbgen_arr; 
  logic [4:0] row_gen; 
  logic [3:0] col_gen; 
  counter newblock (.clk(clk), .rst(rst), .button_i(en_nb), .current_state_o(nb), .counter_o()); 
  blockgen newblockgen (.current_state(nb), .display_array(nbgen_arr), .row(row_gen), .col(col_gen)); 

  // 5x5 frame tracker 
  logic check; 
  // logic [4:0][4:0][2:0] c_frame, n_frame; 
  move_t movement; 
  logic track_complete, track_en; 
  logic [4:0] cell_i1, cell_i2, cell_i3, cell_i4, d_i1, d_i2, d_i3, d_i4;   
  logic [3:0] cell_j1, cell_j2, cell_j3, cell_j4, d_j1, d_j2, d_j3, d_j4; 
  // tracker track (.state(c_state), .track_en(track_en), .move(movement), .color(c_color), .complete(track_complete), .n_grid(grid_write_o), 
  // .cell_i1(cell_i1), .cell_i2(cell_i2), .cell_i3(cell_i3), .cell_i4(cell_i4), .d_i1(d_i1), .d_i2(d_i2), .d_i3(d_i3), .d_i4(d_i4),  
  // .cell_j1(cell_j1), .cell_j2(cell_j2), .cell_j3(cell_j3), .cell_j4(cell_j4), .d_j1(d_j1), .d_j2(d_j2), .d_j3(d_j3), .d_j4(d_j4), 
  // .right(right), .left(left), .down(down), .rr(rr), .rl(rl), 
  // .c_grid(c_grid), .row_inx(row_inx), .col_inx(col_inx), .clk(clk), .rst(rst)
  // ); 
  // assign done_extracting = track_complete; 
  // extract & write frames 
  // logic [4:0][4:0][2:0] frame_extract_o; 
  logic [21:0][9:0][2:0] grid_write_o; 
  // logic extract_en, write_en, extract_done, write_done; 
  // frame_extract extraction (.clk(clk), .rst(rst), .en(extract_en), .c_grid(c_grid), .row_inx(row_inx), .col_inx(col_inx), .c_frame(frame_extract_o), .done(extract_done));
  // frame_write write_out (.clk(clk), .rst(rst), .en(write_en), .n_frame(n_frame), .n_grid(grid_write_o), .row_inx(row_inx), .col_inx(col_inx), .done(write_done)); 

  // update reference row and tmp 
  logic [4:0] row_movement_update; 
  logic [3:0] col_movement_update; 
  logic en_update, update_done; 
  update_ref update (.row_i(row_inx), .col_i(col_inx), .en(en_update), .movement(movement), .row_o(row_movement_update), .col_o(col_movement_update), .done(update_done)); 

  // clear lines when it's full 
  logic clear_en, clear_done; 
  logic [21:0][9:0][2:0] cleared_grid; 
  lineclear clearline (.clk(clk), .rst(rst), .enable(clear_en), .c_grid(c_grid), .n_grid(cleared_grid), .done(clear_done)); 
  
  always_comb begin 
    // if (A1 <= c_state && c_state <= G4) begin // game state 
      if (right) begin 
        movement = RIGHT; 
      end else if (left) begin 
        movement = LEFT; 
      end else if (rr) begin 
        movement = ROR; 
      end else if (rl) begin 
        movement = ROL; 
      end else if (down) begin 
        movement = DOWN; // default case: DOWN 
      end else begin 
        movement = NONE; 
      end 
    // end else begin 
    //   movement = NONE; // null case 
    // end 
  end

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      c_grid <= 0; 
      c_color <= CL0; 
      c_state <= IDLE; 
      row_inx <= 0; 
      col_inx <= 0; 
      l_state <= IDLE; 
    end else begin 
      c_grid <= n_grid; 
      c_color <= n_color; 
      c_state <= n_state; 
      row_inx <= row_tmp; 
      col_inx <= col_tmp; 
      l_state <= n_l_state; 
    end 
  end

  always_comb begin 
    en_nb = 0; 
    clear_en = 0; 
    en_update = 0; 
    // extract_en = 0; 
    // write_en = 0; 

    track_en = 0; cell_i1 = 0; cell_i2 = 0; cell_i3 = 0; cell_i4 = 0; d_i1 = 0; d_i2 = 0; d_i3 = 0; d_i4 = 0;    cell_j1 = 0; cell_j2 = 0; cell_j3 = 0; cell_j4 = 0; d_j1 = 0; d_j2 = 0; d_j3 = 0; d_j4 = 0; 
    check = 0; 
    
    n_color = c_color;
    n_grid = c_grid; 
    row_tmp = row_inx; 
    col_tmp = col_inx; 
    // c_frame = 0; 
    n_state = c_state; 
    n_l_state = l_state; 

    case (c_state) 
      IDLE: begin 
        n_grid[21] = 30'h3FFFFFFF; // all one
        if (en) begin 
          // n_state = READY; 
          n_state = NEW_BLOCK; 
        end else begin 
          n_state = c_state; 
        end 
      end

      NEW_BLOCK: begin 
        // TO IMPLEMENT: new block loading checker 
        // assign colors for each game state 
        en_nb = 1'b1; 
        case (nb) 
          default: begin 
            n_grid = nbgen_arr; 
            // n_color = CL1; 
            // n_state = LOAD; 
            row_tmp = row_gen; 
            col_tmp = col_gen; 
            n_color = CL4; 
            n_state = A1; 
          end

        endcase

      end

      A1: begin 
        n_l_state = A1; 
        if (right) begin 
          cell_i1 = row_inx + 'd1; 
          cell_j1 = col_inx + 'd1; 
          d_i1 = row_inx + 'd1; 
          d_j1 = col_inx + 'd3; 
          cell_i2 = row_inx + 'd2; 
          d_i2 = row_inx + 'd2; 
          d_j2 = col_inx + 'd2;
          
          track_en = 1'b1; 
          n_state = UPDATE; 
        end
        // track_en = 1'b1; 
        // // frame tracking 
        // if (track_complete) begin 
        //   // c_frame = frame_extract_o; 
        //   // track_en = 1'b1; 
          
          
        // end 
        // frame update 
        // if (track_complete) begin 
        //   // write_en = 1'b1; 
        //   // track_en = 0; 
        //   n_grid = grid_write_o; 
        //   n_state = WRITE; 
        //   // update reference numbers 
        // end else begin 
        //   n_state = c_state; 
        // end 
      end

      // don't update the reference if C1 LEFT 
      UPDATE: begin // replace tracker module 
        if (track_en) begin
        // if (right) begin 
          // RIGHT: begin 
            case (l_state) 
              A1, B1, D0, E1, E3, F1, F3, G1, G3: begin 
                check = c_grid[cell_i1][cell_j1] == 0 && c_grid[cell_i2][cell_j2] == 0; 
                if (check) begin
                  n_grid[d_i1][d_j1] = 0; 
                  n_grid[d_i2][d_j2] = 0; 
                  n_grid[cell_i1][cell_j1] = c_color; 
                  n_grid[cell_i2][cell_j2] = c_color; 
                  // track_complete = 1'b1; 
                  if (en) begin 
                    n_state = l_state; 
                  end
                end
              end

              default: begin end
            endcase
          // end
        // end 
      end
    end

      WRITE: begin 
        // if (write_done) begin 
        //     n_grid = grid_write_o; 
        //     n_state = UPDATE; 
        // end 

        if (en) begin 
          n_state = l_state; 
        end 
      end
      EVAL: begin 
        case (l_state) 
          A1: begin 
            if (c_grid[row_inx+3][col_inx+1] != 0 || c_grid[row_inx+3][col_inx+2] != 0 || c_grid[row_inx+2][col_inx+3] != 0) begin 
              if (clear_done == 0) begin 
                n_state = LINECLEAR; 
              end else if (clear_done && (|c_grid[0])) begin 
                n_state = GAME_OVER; 
              end else begin 
                n_state = NEW_BLOCK; 
              end 
            end else begin 
              n_state = l_state; 
            end 
          end

          default: begin 
            n_state = c_state; 
          end
        endcase 

      end

      LINECLEAR: begin 
        clear_en = 1'b1; 
        if (clear_done) begin 
          n_grid = cleared_grid; 
          n_state = EVAL; 
        end else begin 
          n_state = c_state; 
        end 
      end
      
      GAME_OVER: begin 
        // TO IMPLEMENT: game over display message 
        if (en) begin 
          n_state = IDLE; 
        end 
      end
      default: begin 
        n_grid = c_grid; 
        n_color = c_color; 
        n_state = c_state; 
        row_tmp = row_inx; 
        col_tmp = col_inx; 
      end
    endcase
  end
endmodule