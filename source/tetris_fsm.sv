`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris_fsm
// Description : Main file for the Tetris 
// 
//
/////////////////////////////////////////////////////////////////

import tetris_pkg::*;

module tetris_fsm (
  input logic clk, rst, 
  input logic en, right, left, rr, rl, 
  output logic [20:0][9:0][2:0] grid 
);

  // next state variable initialization 
  state_t c_state, n_state; 
  logic [2:0] color; // color of the block 
  logic [4:0] row_inx, row_tmp; // reference row index  
  logic [3:0] col_inx, col_tmp; // reference col index

  // grid next state logic 
  logic [20:0][9:0][2:0] c_grid, n_grid; 
  assign grid = c_grid; 

  // load in a new block 
  logic en_nb; // enable new block 
  logic [2:0] nb; // newblock 
  counter newblock (.clk(clk), .nRst_i(!rst), .button_i(en_nb), .current_state_o(nb), .counter_o()); 
  
  // check the validity of a new block 

  // 5x5 frame tracker 
  logic [4:0][4:0][2:0] c_frame, n_frame; 
  move_t movement; 
  logic track_complete; 
  tracker track (.state(c_state), .frame_i(c_frame), .move(movement), .color(color), .check_tb(), .complete(track_complete), .frame_o(n_frame)); 

  // update reference row and tmp 
  logic [4:0] row_movement_update; 
  logic [3:0] col_movement_update; 
  logic en_update; 
  update_ref update (.row_i(row_inx), .col_i(col_inx), .en(en_update), .movement(movement), .row_o(row_movement_update), .col_o(col_movement_update)); 

  // movement type for the tracker module 
  always_comb begin 
    if (A1 <= c_state <= G4) begin // game state 
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
      movement = 3'b111; // null case 
    end 
  end

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
        // assign colors for each game state 
        en_nb = 1'b1; 
        case (nb) 
          3'd0: begin 

          end
        endcase
      end

      A1: begin 

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