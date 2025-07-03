`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris
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
  A1, 
  A2, 
  B1, 
  B2, 
  C1, 
  C2, 
  D, 
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
  GAME_OVER // user run out of space 
} state_t; 

module tetris (
  input logic clk, rst, 
  input logic en, right, left, down, rr, rl, // user input 
  output logic [7:0] count_down, // count down display during READY state 
  output logic [9:0] grid [21:0], // grid display 
);
  
  logic check; // 1 bit loop variable 
  logic [4:0] i, loop_counter; 
  state_t c_state, n_state; // current state, next state 

  assign grid [21] = 10'b1111111111; // set the invisible buttom layer to high 

  // a slow clock for the READY state count down 
  logic countdown_clk, ready_en; // slow-down clock for the count down 
  logic [1:0] count_down_in; // output from the countdown function 
  logic [7:0] count_down_out; // temp count down 7-seg output 
  clkdiv_countdown clkdiv (.clk(clk), .rst(rst), .newclk(countdown_clk)); 
  countdown countdown1 (.clk(countdown_clk), .rst(rst), .en(ready_en), .count(count_down_in)); 
  ssdec countdown2 (.in({2'b0, count_down_in}), .enable(1'b1), .out(count_down_out)); 

  // read in a random new block 
  logic en_nb; // enable reading new block 
  logic [2:0] nb; // new block cooridnates 
  logic [3:0] nb_arr [3:0]; // new block array 
  logic [4:0] row_inx, col_inx; // current row and column starting index 
  new_block nb1 (.clk(clk), .rst(rst), .en(en_nb), .block_o(nb), .coordinate_o(nb_arr)); 

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      c_state <= IDLE; 
    end else begin 
      c_state <= n_state; 
    end
  end

  always_comb begin 

    // initialization 
    ready_en = 0; 
    count_down = 0; 
    en_nb = 0; 
    // map c_arr = 0  
    row_inx = 0; 
    col_inx = 0; 
    check = 0; 
    i = 0; 
    loop_counter = 0; 

    case (c_state) 
      IDLE: begin 
        if (en) begin 
          n_state = READY; 
        end else begin 
          n_state = c_state; 
        end 
      end

      READY: begin 
        ready_en = 1'b1; // start counting down 
        count_down = count_down_out; 
        if (count_down_in == 0) begin 
          n_state = NEW_BLOCK; 
        end else begin 
          n_state = c_state; 
        end
      end

      NEW_BLOCK: begin 
        en_nb = 1'b1; 
        check = 0; 
        loop_counter = 0; 
         
        case(nb)
          3'b001: begin 
            i = 'd5;
            while (loop_counter < 'd8) begin 
              loop_counter = loop_counter + 'd1; 
              if (~ (grid[1][i] || grid[1][i+'d1])) begin 
                grid[0][i-'d1] = 1'b1; 
                grid[0][i] = 1'b1; 
                grid[1][i] = 1'b1; 
                grid[1][i+'d1] = 1'b1; 
                row_inx = 'd0; 
                col_inx = i - 'd2; 
                n_state = A1; 
              end 
              if (i == 'd8) begin 
                i = 0; 
              end else begin 
                i = i + 'd1; 
              end
            end
            if (loop_counter >= 'd8) begin 
              n_state = GAME_OVER; 
            end
          end

          3'b010: begin 
            i = 'd4;
            while (loop_counter < 'd8) begin 
              loop_counter = loop_counter + 'd1; 
              if (~ (grid[1][i] || grid[1][i+'d1])) begin 
                grid[0][i-'d1] = 1'b1; 
                grid[0][i] = 1'b1; 
                grid[1][i] = 1'b1; 
                grid[1][i+'d1] = 1'b1; 
                row_inx = 'd0; 
                col_inx = i - 'd2; 
                n_state = A1; 
              end 
              if (i == 'd8) begin 
                i = 0; 
              end else begin 
                i = i + 'd1; 
              end
            end
            if (loop_counter >= 'd8) begin 
              n_state = GAME_OVER; 
            end 
          end 

          3'b011: begin 
            n_state = C1; 
          end 

          3'b100: begin 
            n_state = D; 
          end 

          3'b101: begin 
            n_state = E1; 
          end 

          3'b110: begin 
            n_state = F1; 
          end 

          3'b111: begin 
            n_state = G1; 
          end 

          default: begin 
            n_state = c_state; 
          end 
        endcase
      end

      A1: begin 
        if (~ (grid[row_inx+'d2][col_inx+'d2] || grid[row_inx+'d3][col_inx+'d3] || grid[row_inx+'d3][col_inx+'d3])) begin 
          grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
          grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
          grid[row_inx+'d3][col_inx+'d3] = 1'b1; 
          row_inx = row_inx + 'd1;  
        end else begin 
          n_state = EVAL; // the block is stuck 
        end

        if (right && (col_inx != 'd6)) begin 
          if (~(grid[row_inx+'d1][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d4])) begin 
            grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d1][col_inx+'d3] = 1'b1; 
            grid[row_inx+'d2][col_inx+'d4] = 1'b1; 
          
            if (col_inx == 'd9) begin 
              col_inx = 0; 
            end else begin 
              col_inx = col_inx + 'd1;  
            end
          end 
        end 

        if (left && (col_inx != 'd9)) begin 
          if (~(grid[row_inx+'d1][col_inx-'d1] || grid[row_inx+'d2][col_inx-'d1])) begin 
            grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d3] = 1'b0; 
            grid[row_inx+'d1][col_inx] = 1'b1; 
            grid[row_inx+'d2][col_inx+'d4] = 1'b1; 
          
            if (col_inx == 0) begin 
              col_inx = 'd9; 
            end else begin 
              col_inx = col_inx - 'd1;  
            end
          end 
        end    

        if ((rr || rl) && (~(grid[row_inx+'d2][col_inx+'d1] || grid[row_inx][col_inx+'d2]))) begin 
          grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d1] = 1'b1; 
          grid[row_inx][col_inx+'d2] = 1'b1; 
          n_state = A2; 
        end         
      end

      A2: begin 
        if (~ (grid[row_inx+'d3][col_inx+'d1] || grid[row_inx+'d2][col_inx+'d2])) begin 
          grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
          grid[row_inx][col_inx+'d2] = 1'b0; 
          grid[row_inx+'d3][col_inx+'d1] = 1'b1; 
          grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
          row_inx = row_inx + 'd1;  
        end else begin 
          n_state = EVAL; // the block is stuck 
        end

        if (right && (col_inx != 'd7)) begin 
          if (~(grid[row_inx][col_inx+'d3] || grid[row_inx+'d1][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d2])) begin 
            grid[row_inx][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
            grid[row_inx][col_inx+'d3] = 1'b1; 
            grid[row_inx+'d1][col_inx+'d3] = 1'b1; 
            grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
          
            if (col_inx == 'd9) begin 
              col_inx = 0; 
            end else begin 
              col_inx = col_inx + 'd1;  
            end
          end 
        end 

        if (left && (col_inx != 'd9)) begin 
          if (~(grid[row_inx][col_inx+'d1] || grid[row_inx+'d1][col_inx] || grid[row_inx+'d2][col_inx])) begin 
            grid[row_inx][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
            grid[row_inx][col_inx+'d1] = 1'b1; 
            grid[row_inx+'d1][col_inx] = 1'b1; 
            grid[row_inx+'d2][col_inx] = 1'b1; 
          
            if (col_inx == 0) begin 
              col_inx = 'd9; 
            end else begin 
              col_inx = col_inx - 'd1;  
            end
          end 
        end    

        if ((rr || rl) && (~(grid[row_inx+'d2][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d2]))) begin 
          grid[row_inx][col_inx+'d2] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
          grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
          n_state = A1; 
        end    
      end

      B1: begin 
        if (~ (grid[row_inx+'d3][col_inx+'d1] || grid[row_inx+'d3][col_inx+'d2] || grid[row_inx+'d2][col_inx+'d3])) begin 
          grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
          grid[row_inx+'d1][col_inx+'d3] = 1'b0; 
          grid[row_inx+'d3][col_inx+'d1] = 1'b0; 
          grid[row_inx+'d3][col_inx+'d1] = 1'b1; 
          grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
          grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
          row_inx = row_inx + 'd1;  
        end else begin 
          n_state = EVAL; // the block is stuck 
        end

        if (right && (col_inx != 'd6)) begin 
          if (~(grid[row_inx+'d1][col_inx+'d4] || grid[row_inx+'d2][col_inx+'d3])) begin 
            grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
            grid[row_inx+'d1][col_inx+'d4] = 1'b1; 
            grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
          
            if (col_inx == 'd9) begin 
              col_inx = 0; 
            end else begin 
              col_inx = col_inx + 'd1;  
            end
          end 
        end 

        if (left && (col_inx != 'd9)) begin 
          if (~(grid[row_inx+'d1][col_inx+'d1] || grid[row_inx+'d2][col_inx])) begin 
            grid[row_inx+'d1][col_inx+'d3] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d1][col_inx+'d1] = 1'b1; 
            grid[row_inx+'d2][col_inx] = 1'b1; 
          
            if (col_inx == 0) begin 
              col_inx = 'd9; 
            end else begin 
              col_inx = col_inx - 'd1;  
            end
          end 
        end    

        if ((rr || rl) && (~(grid[row_inx][col_inx+'d1] || grid[row_inx+'d1][col_inx+'d1]))) begin 
          grid[row_inx+'d1][col_inx+'d3] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
          grid[row_inx][col_inx+'d1] = 1'b1; 
          grid[row_inx+'d1][col_inx+'d1] = 1'b1; 
          n_state = B2; 
        end         
      end

      B2: begin 
        if (~ (grid[row_inx+'d2][col_inx+'d1] || grid[row_inx+'d3][col_inx+'d2])) begin 
          grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
          grid[row_inx][col_inx+'d1] = 1'b0; 
          grid[row_inx+'d2][col_inx+'d1] = 1'b1; 
          grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
          row_inx = row_inx + 'd1;  
        end else begin 
          n_state = EVAL; // the block is stuck 
        end

        if (right && (col_inx != 'd7)) begin 
          if (~(grid[row_inx][col_inx+'d2] || grid[row_inx+'d1][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d3])) begin 
            grid[row_inx][col_inx+'d1] = 1'b0; 
            grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
            grid[row_inx][col_inx+'d2] = 1'b1; 
            grid[row_inx+'d1][col_inx+'d3] = 1'b1; 
            grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
          
            if (col_inx == 'd9) begin 
              col_inx = 0; 
            end else begin 
              col_inx = col_inx + 'd1;  
            end
          end 
        end 

        if (left && (col_inx != 'd9)) begin 
          if (~(grid[row_inx][col_inx] || grid[row_inx+'d1][col_inx] || grid[row_inx+'d2][col_inx+'d1])) begin 
            grid[row_inx][col_inx+'d1] = 1'b0; 
            grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
            grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
            grid[row_inx][col_inx] = 1'b1; 
            grid[row_inx+'d1][col_inx] = 1'b1; 
            grid[row_inx+'d2][col_inx+'d1] = 1'b1; 
          
            if (col_inx == 0) begin 
              col_inx = 'd9; 
            end else begin 
              col_inx = col_inx - 'd1;  
            end
          end 
        end    

        if ((rr || rl) && (~(grid[row_inx][col_inx+'d3] || grid[row_inx][col_inx+'d2]))) begin 
          grid[row_inx][col_inx+'d1] = 1'b0; 
          grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
          grid[row_inx][col_inx+'d3] = 1'b1; 
          grid[row_inx][col_inx+'d2] = 1'b1; 
          n_state = B1; 
        end    
      end

      EVAL: begin 
        // check if any blocks are out of the display (first row)
        if (|[9:0] grid) begin 
          n_state = GAME_OVER; 
        end else begin 
          for (i = 0; i < 20; i++) begin 
            if (& [9:0] grid[i]) begin 
              [9:0] grid [1:i] = [9:0] grid [0:i - 'd1]; 
            end
          end
          n_state = NEW_BLOCK; 
        end
      end
    endcase
  end
endmodule