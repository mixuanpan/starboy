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
        IDLE, // reset state 
        READY, // count down to start 
        NEW_BLOCK, // load new block 
        LOAD, 
        A1, // 
        A2, 
        B1, // 
        B2, 
        C1, // 111 
        C2, 
        D0, // 1001
        E1, // 1010 
        E2, 
        E3, 
        E4, 
        F1, // 1110 
        F2, 
        F3, 
        F4, 
        G1, // 10010
        G2, 
        G3, 
        G4, 
        EVAL, // evaluation 
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
  input logic en, right, left, rr, rl, 
  output state_t state_tb, 
  output logic [21:0][9:0][2:0] grid 
);

  assign state_tb = c_state; 

  // next state variable initialization 
  state_t c_state, n_state, l_state; 
  color_t c_color, n_color; // color of the block 
  logic [4:0] row_inx, row_tmp; // reference row index  
  logic [3:0] col_inx, col_tmp; // reference col index

  // grid next state logic 
  logic [21:0][9:0][2:0] c_grid, n_grid; 
  assign grid = c_grid; 

  // load in a new block 
  logic en_nb; // enable new block 
  logic [2:0] nb; // newblock 
  counter newblock (.clk(clk), .nRst_i(!rst), .button_i(en_nb), .current_state_o(nb), .counter_o()); 
  
  // check the validity of a new block 
  // logic load_valid; 
  // state_t load_block; 
  // logic [4:0] load_row; 
  // logic [3:0] load_col; 
  // logic [1:0][9:0][2:0] load_row01; 
  // load_check loadCheck (.block_type(load_block), .row1(c_grid[1]), .color(color), .valid(load_valid), .row_ref(load_row), .col_ref(load_col), .row01(load_row01)); 

  // 5x5 frame tracker 
  logic [4:0][4:0][2:0] c_frame, n_frame; 
  move_t movement; 
  logic track_complete; 
  tracker track (.state(c_state), .frame_i(c_frame), .move(movement), .color(c_color), .check_tb(), .complete(track_complete), .frame_o(n_frame)); 

  // update reference row and tmp 
  logic [4:0] row_movement_update; 
  logic [3:0] col_movement_update; 
  logic en_update; 
  update_ref update (.row_i(row_inx), .col_i(col_inx), .en(en_update), .movement(movement), .row_o(row_movement_update), .col_o(col_movement_update)); 

  // Since slicing doesn't work in SV... 
  // logic [21:0][4:0] row_indices; 
  // logic [9:0][3:0] col_indices; 
  
  // genvar i; 
  // generate
  //   for (i = 0; i < 22; i++) begin 
  //     assign row_indices[i] = i[4:0]; 
  //   end

  //   for (i = 0; i < 10; i++) begin 
  //     assign col_indices[i] = i[3:0]; 
  //   end
  // endgenerate

  // movement type for the tracker module 
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
      c_state <= IDLE; 
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
    // color = CL0; // default color is black, which is the background 
    en_nb = 0; 
    en_update = 0; 
    // load_block = IDLE; 
    n_color = c_color;
    n_grid = c_grid; 
    row_tmp = row_inx; 
    col_tmp = col_inx; 
    c_frame = 0; 
    n_state = c_state; 
    l_state = IDLE; 

    case (c_state) 
      IDLE: begin 
        if (en) begin 
          n_state = READY; 
        end else begin 
          n_state = c_state; 
        end 
      end

      READY: begin 
        // TO IMPLEMENT: count down logic 
        if (en) begin 
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
          3'd0: begin 
            n_color = CL1; 
            n_state = LOAD; 
          end

          3'd1: begin 
             
            n_color = CL2; 
          end

          3'd2: begin 
             
            n_color = CL3; 
          end

          3'd3: begin 
             
            n_color = CL4; 
          end 

          3'd4: begin 
             
            n_color = CL5; 
          end 

          3'd5: begin 
             
            n_color = CL6; 
          end 

          3'd6: begin 
             
            n_color = CL7; 
          end 

          default: begin 
            n_state = c_state; 
          end
        endcase

        // if (load_valid) begin 
        //   n_grid[1:0] = load_row01; 
        //   n_state = load_block; 
        // end else begin 
        //   n_state = GAME_OVER; // unable to load a new block 
        // end 
      end
      LOAD: begin 
        case(c_color) 
          CL1: begin  
            if (c_grid[1][3] != 0 || c_grid[1][4] != 0) begin 
              n_state = GAME_OVER; 
            end else begin 
              n_grid[0][4] = c_color; 
              n_grid[0][5] = c_color; 
              n_grid[1][3] = c_color; 
              n_grid[1][4] = c_color; 
              row_tmp = 0; 
              col_tmp = 'd2; 
              n_state = A1; 
            end 
          end

          default: begin 
            n_state = c_state; 
          end
        endcase
      end
      A1: begin 

        // if (c_grid[row_inx + 3][col_inx + 1] != 0) begin 
        //   n_state = EVAL; 
        // end else begin 
          // tracker 
          // // c_frame = c_grid[row_inx + 'd3:row_inx][col_inx + 'd3:col_inx][2:0]; 
          // c_frame = c_grid[4:0][4:0]; 
        l_state = A1; 
        // frame tracking 
        for (int i = 0; i < 5; i++) begin
          for (int j = 0; j < 5; j++) begin
              c_frame[i][j] = c_grid[row_inx + i[4:0]][col_inx + j[4:0]];
          end
        end
        // frame update 
        if (track_complete) begin 
          for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                n_grid[row_inx + i[4:0]][col_inx + j[4:0]] = n_frame[i][j];
            end
          end
          // update reference numbers 
          en_update = 1'b1; 
          row_tmp = row_movement_update; 
          col_tmp = col_movement_update; 

          n_state = EVAL; 
        end 
      end

      // don't update the reference if C1 LEFT 
      
      EVAL: begin 
        case (l_state) 
          A1: begin 
            if (c_grid[row_inx+3][col_inx+1] != 0 || c_grid[row_inx+3][col_inx+2] != 0 || c_grid[row_inx+2][col_inx+3] != 0) begin 
              if (|c_grid[0]) begin 
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
        // if (|c_grid[0]) begin 
        //   n_state = GAME_OVER; 
        // end else begin 
        //   n_state = NEW_BLOCK; 
        // end 
      end

      GAME_OVER: begin 
        // TO IMPLEMENT: game over display message 
        if (en) begin 
          n_state = IDLE; 
        end 
      end
      default: begin 
        n_grid = c_grid; 
        n_state = c_state; 
        row_tmp = row_inx; 
        col_tmp = col_inx; 
      end
    endcase
  end
endmodule