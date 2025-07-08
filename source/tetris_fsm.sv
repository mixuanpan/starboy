`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris_fsm
// Description : Main file for the Tetris 
// 
//
/////////////////////////////////////////////////////////////////

// self-defined states for the finite state machine 
// block reference: https://docs.google.com/spreadsheets/d/1A7IpiXzjc0Yx8wuKXJpoMbAaJQVSf6PPc_mYC25cqE8/edit?gid=0#gid=0 
typedef enum logic [4:0] {
  IDLE, // reset state 
  READY, // count down to start 
  NEW_BLOCK, // load new block 
  A1, // 011
  A2, 
  B1, // 101
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
  GAME_OVER // user run out of space 10111 
} state_t; 

module tetris_fsm (
  input logic clk, rst, 
  input logic en, right, left, rr, rl, 
  output logic [20:0][9:0][2:0] grid 
);

  // next state variable initialization 
  state_t c_state, n_state; 
  logic [2:0] color; // color of the block 
  logic [4;0] row_inx, row_tmp; // reference row index  
  logic [3:0] col_inx, col_tmp; // reference col index

  logic [20:0][9:0][2:0] c_grid, n_grid; 
  assign grid = c_grid; 

  // load in a new block 
  logic en_nb; // enable new block 
  logic [2:0] nb; // newblock 
  counter newblock (.clk(clk), .nRst_i(!rst), .button_i(en_nb), .current_state_o(nb), .counter_o()); 
  
  // 5x5 frame tracker 
  logic [4:0][4:0][2:0] c_frame, n_frame; 
  logic [2:0] movement; 

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      c_grid <= 0; 
      c_state <= IDLE; 
      row_inx <= 0; 
      col_inx <= 0; 
    end else begin 
      c_grid <= n_grid; 
      c_state <= n_state; 
      row_inx <= row_tmp; 
      col_inx <= col_tmp; 
    end 
  end

  // movement type for the tracker module 
  always_comb begin 
    if (A1 <= c_state <= G4) begin // game state 
      if (right) begin 
        movement = 3'b000; 
        if (complete) begin 
          if (col_inx == 0) begin 
            col_tmp = 'd9; 
          end else begin 
            col_tmp = col_inx - 'd1; 
          end 
        end 
      end else if (left) begin 
        movement = 3'b001; 
      end else if (rr) begin 
        movement = 3'b010; 
      end else if (rl) begin 
        movement = 3'b011; 
      end else begin 
        movement = 3'b100; // default case: DOWN 
      end 
    end else begin 
      movement = 3'b111; // null case 
    end 
  end

  always_comb begin 
    color = 0; // default color is black, which is the background 
    en_nb = 0; 
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
        en_nb = 1'b1; 
        case (nb) 
          3'd0: begin 

          end
        endcase
      end

      A1: begin 

      end
    endcase
  end
endmodule