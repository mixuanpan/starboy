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
// typedef enum logic [4:0] {
//   IDLE, // reset state 
//   READY, // count down to start 
//   NEW_BLOCK, // load new block 
//   A1, 
//   A2, 
//   B1, 
//   B2, 
//   C1, 
//   C2, 
//   D0, 
//   E1, 
//   E2, 
//   E3, 
//   E4, 
//   F1, 
//   F2, 
//   F3, 
//   F4, 
//   G1, 
//   G2, 
//   G3, 
//   G4, 
//   EVAL, // evaluation 
//   GAMEOVER // user run out of space 
// } state_t; 

module tetris (
  input logic clk, rst, 
  input logic en, right, left, down, rr, rl, // user input 
  output logic [7:0] count_down, // count down display during READY state 
  // output logic [21:0][9:0]grid, // grid display
  output logic [4:0] state_o
);
  logic [4:0] i; 
  logic [21:0][9:0] grid, n_grid; // next state grid 
  logic check; // 1 bit loop variable 
  logic [4:0] loop_counter; 
  state_t c_state, n_state; // current state, next state 
  assign state_o = c_state; 
  // a slow clock for the READY state count down 
  logic countdown_clk, ready_en; // slow-down clock for the count down 
  logic [1:0] count_down_in; // output from the countdown function 
  logic [7:0] count_down_out; // temp count down 7-seg output 
  // clkdiv_countdown clkdiv (.clk(clk), .rst(rst), .newclk(countdown_clk)); 
  // countdown countdown1 (.clk(countdown_clk), .rst(rst), .en(ready_en), .count(count_down_in)); 
  ssdec countdown2 (.in({2'b0, count_down_in}), .enable(1'b1), .out(count_down_out)); 

  logic [3:0] col_inx, col_tmp; 
  logic [4:0] row_inx, row_tmp; // current row and column starting index 

  logic [9:0] row_vec; 

  logic en_nb; // enable new block 
  logic [2:0] nb; // new block 
  counter newblock (.clk(clk), .nRst_i(!rst), .button_i(en_nb), .current_state_o(nb), .counter_o()); 
  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      grid <= '0;
      c_state <= IDLE; 
    end else begin 
      grid <= n_grid; 
      c_state <= n_state; 
    end
  end

  always_comb begin 
    n_state = c_state; 
    n_grid = grid; 
    // initialization 

    en_nb = 0; 
    ready_en = 0; 
    count_down = 0; 
    row_inx = 0; 
    col_inx = 0; 
    row_tmp = row_inx; 
    col_tmp = col_inx; 
    check = 0; 
    i = 0; 
    loop_counter = 0; 
    row_vec = 0; 

    for(int i = 0; i < 10; i++) begin 
      n_grid[21][i[3:0]] = 1'b1; // set the last row to all 1 
    end

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
        // if (count_down_in == 0) begin 
        if (en) begin 
          n_state = NEW_BLOCK; 
        end else begin 
          n_state = c_state; 
        end
      end

      NEW_BLOCK: begin 
        check = 0; 
        loop_counter = 0; 
        en_nb = 1'b1; 
        case(nb)
          3'b001: begin 
            i = 'd5;

            if (loop_counter >= 'd8) begin 
              n_state = GAMEOVER; 
            end else begin 
              loop_counter++; 
              if (~ (grid[1][i[3:0]] || grid[1][i+'d1])) begin 
                n_grid[0][i-'d1] = 1'b1; 
                n_grid[0][i[3:0]] = 1'b1; 
                n_grid[1][i[3:0]] = 1'b1; 
                n_grid[1][i+'d1] = 1'b1; 
                row_inx = 'd0; 
                col_inx = i[3:0] - 'd2; 
                n_state = A1; 
              end 
              if (i == 'd8) begin 
                i = 0; 
              end else begin 
                i = i + 'd1; 
              end
            end
          end

          // 3'b010: begin 
          //   i = 'd4;
          //   if (loop_counter >= 'd8) begin 
          //     n_state = GAMEOVER; 
          //   end else begin 
          //     loop_counter = loop_counter + 'd1; 
          //     if (~ (grid[1][i[3:0]] || grid[1][i[3:0]+'d1])) begin 
          //       n_grid[0][i-'d1] = 1'b1; 
          //       n_grid[0][i[3:0]] = 1'b1; 
          //       n_grid[1][i[3:0]] = 1'b1; 
          //       n_grid[1][i+'d1] = 1'b1; 
          //       row_inx = 'd0; 
          //       col_inx = i[3:0] - 'd2; 
          //       n_state = B1; 
          //     end 
          //     if (i == 'd8) begin 
          //       i = 0; 
          //     end else begin 
          //       i = i + 'd1; 
          //     end
          //   end
          // end 

          // 3'b011: begin 
          //   for (int i = 0; i < 7; i++) begin 
          //     if (~(grid[i][1]|grid[i+1][1]|grid[i+2][1]|grid[i+3][1])) begin 
          //       n_grid[i[3:0]][1] = 1'b1; 
          //       n_grid[i+1][1] = 1'b1; 
          //       n_grid[i+2][1] = 1'b1; 
          //       n_grid[i+3][1] = 1'b1; 
          //       row_inx = 0; 
          //       col_inx = i[3:0]; 
          //       n_state = C1; 
          //     end
          //   end
          //   n_state = GAMEOVER; 
          // end 

          // 3'b100: begin 
          //   i = 'd4;
          //   if (loop_counter >= 'd8) begin 
          //     n_state = GAMEOVER; 
          //   end else begin 
          //     loop_counter = loop_counter + 'd1; 
          //     if (~ (grid[1][i[3:0]] || grid[1][i[3:0]+'d1])) begin 
          //       n_grid[0][i+'d1] = 1'b1; 
          //       n_grid[0][i[3:0]] = 1'b1; 
          //       n_grid[1][i[3:0]] = 1'b1; 
          //       n_grid[1][i+'d1] = 1'b1; 
          //       row_inx = 'd0; 
          //       col_inx = i[3:0] - 'd2; 
          //       n_state = D0; 
          //     end 
          //     if (i == 'd8) begin 
          //       i = 0; 
          //     end else begin 
          //       i = i + 'd1; 
          //     end
          //   end
          // end 

          // 3'b101: begin 
          //   i = 'd5;
          //   if (loop_counter >= 'd8) begin 
          //     n_state = GAMEOVER; 
          //   end else begin 
          //     loop_counter = loop_counter + 'd1; 
          //     if (~ (grid[1][i[3:0]] || grid[1][i+'d1])) begin 
          //       n_grid[0][i-'d1] = 1'b1; 
          //       n_grid[0][i[3:0]] = 1'b1; 
          //       n_grid[1][i[3:0]] = 1'b1; 
          //       n_grid[1][i+'d1] = 1'b1; 
          //       row_inx = 'd0; 
          //       col_inx = i[3:0] - 'd2; 
          //       n_state = E1; 
          //     end 
          //     if (i == 'd8) begin 
          //       i = 0; 
          //     end else begin 
          //       i = i + 'd1; 
          //     end
          //   end
          // end 

          // // 3'b110: begin 
          // //   n_state = F1; 
          // // end 

          // // 3'b111: begin 
          // //   n_state = G1; 
          // // end 

          default: begin 
            n_state = c_state; 
          end 
        endcase
      end

      A1: begin 
        check = grid[row_inx+'d2][col_inx+'d2] || grid[row_inx+'d3][col_inx+'d3] || grid[row_inx+'d3][col_inx+'d3]; 
        if (!check) begin 
          n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
          n_grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
          n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
          n_grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
          n_grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
          n_grid[row_inx+'d3][col_inx+'d3] = 1'b1; 
          row_tmp = row_inx + 'd1;  
        end else begin 
          n_state = EVAL; // the block is stuck 
        end

        if (right && (col_inx != 'd6)) begin 
          if (~(grid[row_inx+'d1][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d4])) begin 
            n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
            n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
            n_grid[row_inx+'d1][col_inx+'d3] = 1'b1; 
            n_grid[row_inx+'d2][col_inx+'d4] = 1'b1; 
          
            if (col_inx == 'd9) begin 
              col_inx = 0; 
            end else begin 
              col_inx = col_inx + 'd1;  
            end
          end 
        end 

        if (left && (col_inx != 'd9)) begin 
          if (~(grid[row_inx+'d1][col_inx-'d1] || grid[row_inx+'d2][col_inx-'d1])) begin 
            n_grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
            n_grid[row_inx+'d2][col_inx+'d3] = 1'b0; 
            n_grid[row_inx+'d1][col_inx] = 1'b1; 
            n_grid[row_inx+'d2][col_inx+'d4] = 1'b1; 
          
            if (col_inx == 0) begin 
              col_inx = 'd9; 
            end else begin 
              col_inx = col_inx - 'd1;  
            end
          end 
        end    

        if ((rr || rl) && (~(grid[row_inx+'d2][col_inx+'d1] || grid[row_inx][col_inx+'d2]))) begin 
          n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
          n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
          n_grid[row_inx+'d2][col_inx+'d1] = 1'b1; 
          n_grid[row_inx][col_inx+'d2] = 1'b1; 
          n_state = A2; 
        end         
      end

      // A2: begin 
      //   if (~ (grid[row_inx+'d3][col_inx+'d1] || grid[row_inx+'d2][col_inx+'d2])) begin 
      //     n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx][col_inx+'d2] = 1'b0; 
      //     n_grid[row_inx+'d3][col_inx+'d1] = 1'b1; 
      //     n_grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
      //     row_inx = row_inx + 'd1;  
      //   end else begin 
      //     n_state = EVAL; // the block is stuck 
      //   end

      //   if (right && (col_inx != 'd7)) begin 
      //     if (~(grid[row_inx][col_inx+'d3] || grid[row_inx+'d1][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d2])) begin 
      //       n_grid[row_inx][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx][col_inx+'d3] = 1'b1; 
      //       n_grid[row_inx+'d1][col_inx+'d3] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
          
      //       if (col_inx == 'd9) begin 
      //         col_inx = 0; 
      //       end else begin 
      //         col_inx = col_inx + 'd1;  
      //       end
      //     end 
      //   end 

      //   if (left && (col_inx != 'd9)) begin 
      //     if (~(grid[row_inx][col_inx+'d1] || grid[row_inx+'d1][col_inx] || grid[row_inx+'d2][col_inx])) begin 
      //       n_grid[row_inx][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx][col_inx+'d1] = 1'b1; 
      //       n_grid[row_inx+'d1][col_inx] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx] = 1'b1; 
          
      //       if (col_inx == 0) begin 
      //         col_inx = 'd9; 
      //       end else begin 
      //         col_inx = col_inx - 'd1;  
      //       end
      //     end 
      //   end    

      //   if ((rr || rl) && (~(grid[row_inx+'d2][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d2]))) begin 
      //     n_grid[row_inx][col_inx+'d2] = 1'b0; 
      //     n_grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
      //     n_grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
      //     n_state = A1; 
      //   end    
      // end

      // B1: begin 
      //   if (~ (grid[row_inx+'d3][col_inx+'d1] || grid[row_inx+'d3][col_inx+'d2] || grid[row_inx+'d2][col_inx+'d3])) begin 
      //     n_grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
      //     n_grid[row_inx+'d1][col_inx+'d3] = 1'b0; 
      //     n_grid[row_inx+'d3][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx+'d3][col_inx+'d1] = 1'b1; 
      //     n_grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
      //     n_grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
      //     row_inx = row_inx + 'd1;  
      //   end else begin 
      //     n_state = EVAL; // the block is stuck 
      //   end

      //   if (right && (col_inx != 'd6)) begin 
      //     if (~(grid[row_inx+'d1][col_inx+'d4] || grid[row_inx+'d2][col_inx+'d3])) begin 
      //       n_grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d4] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
          
      //       if (col_inx == 'd9) begin 
      //         col_inx = 0; 
      //       end else begin 
      //         col_inx = col_inx + 'd1;  
      //       end
      //     end 
      //   end 

      //   if (left && (col_inx != 'd9)) begin 
      //     if (~(grid[row_inx+'d1][col_inx+'d1] || grid[row_inx+'d2][col_inx])) begin 
      //       n_grid[row_inx+'d1][col_inx+'d3] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d1] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx] = 1'b1; 
          
      //       if (col_inx == 0) begin 
      //         col_inx = 'd9; 
      //       end else begin 
      //         col_inx = col_inx - 'd1;  
      //       end
      //     end 
      //   end    

      //   if ((rr || rl) && (~(grid[row_inx][col_inx+'d1] || grid[row_inx+'d1][col_inx+'d1]))) begin 
      //     n_grid[row_inx+'d1][col_inx+'d3] = 1'b0; 
      //     n_grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx][col_inx+'d1] = 1'b1; 
      //     n_grid[row_inx+'d1][col_inx+'d1] = 1'b1; 
      //     n_state = B2; 
      //   end         
      // end

      // B2: begin 
      //   if (~ (grid[row_inx+'d2][col_inx+'d1] || grid[row_inx+'d3][col_inx+'d2])) begin 
      //     n_grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
      //     n_grid[row_inx][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx+'d2][col_inx+'d1] = 1'b1; 
      //     n_grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
      //     row_inx = row_inx + 'd1;  
      //   end else begin 
      //     n_state = EVAL; // the block is stuck 
      //   end

      //   if (right && (col_inx != 'd7)) begin 
      //     if (~(grid[row_inx][col_inx+'d2] || grid[row_inx+'d1][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d3])) begin 
      //       n_grid[row_inx][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx][col_inx+'d2] = 1'b1; 
      //       n_grid[row_inx+'d1][col_inx+'d3] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
          
      //       if (col_inx == 'd9) begin 
      //         col_inx = 0; 
      //       end else begin 
      //         col_inx = col_inx + 'd1;  
      //       end
      //     end 
      //   end 

      //   if (left && (col_inx != 'd9)) begin 
      //     if (~(grid[row_inx][col_inx] || grid[row_inx+'d1][col_inx] || grid[row_inx+'d2][col_inx+'d1])) begin 
      //       n_grid[row_inx][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx][col_inx] = 1'b1; 
      //       n_grid[row_inx+'d1][col_inx] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx+'d1] = 1'b1; 
          
      //       if (col_inx == 0) begin 
      //         col_inx = 'd9; 
      //       end else begin 
      //         col_inx = col_inx - 'd1;  
      //       end
      //     end 
      //   end    

      //   if ((rr || rl) && (~(grid[row_inx][col_inx+'d3] || grid[row_inx][col_inx+'d2]))) begin 
      //     n_grid[row_inx][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx][col_inx+'d3] = 1'b1; 
      //     n_grid[row_inx][col_inx+'d2] = 1'b1; 
      //     n_state = B1; 
      //   end    
      // end

      // C1: begin 
      //   if (~ (|grid[row_inx][col_inx+'d2]|grid[row_inx+'d1][col_inx+'d2]|grid[row_inx+'d2][col_inx+'d2]|grid[row_inx+'d3][col_inx+'d2])) begin 
      //     n_grid[row_inx][col_inx+'d1] = 1'b0;  
      //     n_grid[row_inx+1][col_inx+'d1] = 1'b0;  
      //     n_grid[row_inx+2][col_inx+'d1] = 1'b0;  
      //     n_grid[row_inx+3][col_inx+'d1] = 1'b0;  
      //     n_grid[row_inx][col_inx+'d2] = 1'b1;  
      //     n_grid[row_inx+1][col_inx+'d2] = 1'b1;  
      //     n_grid[row_inx+2][col_inx+'d2] = 1'b1;  
      //     n_grid[row_inx+3][col_inx+'d2] = 1'b1; 
      //     row_inx = row_inx + 'd1;  
      //   end else begin 
      //     n_state = EVAL; // the block is stuck 
      //   end

      //   if (right && (col_inx < 'd6)) begin 
      //     if (~grid[row_inx+'d1][col_inx+'d4]) begin 
      //       n_grid[row_inx+'d1][col_inx] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d4] = 1'b1; 
      //       col_inx = col_inx + 'd1; 
      //     end 
      //   end 

      //   if (left && (col_inx > 'd3)) begin 
      //     if (~grid[row_inx+'d1][col_inx-'d1]) begin 
      //       n_grid[row_inx+'d1][col_inx+'d3] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx-'d1] = 1'b1; 
      //       col_inx = col_inx - 'd1; 
      //     end 
      //   end    

      //   if ((rr || rl) && (~(grid[row_inx][col_inx+'d2] || grid[row_inx+'d3][col_inx+'d2] || grid[row_inx+'d2][col_inx+'d2]))) begin 
      //       n_grid[row_inx + 1][col_inx] = 1'b0; 
      //       n_grid[row_inx + 1][col_inx + 1] = 1'b0; 
      //       n_grid[row_inx + 1][col_inx + 3] = 1'b0; 
      //       n_grid[row_inx][col_inx+'d2] = 1'b1; 
      //       n_grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx+'d2] = 1'b1; 
      //       n_state = C2; 
      //   end    
      // end

      // C2: begin 
      //   if (~ (grid[row_inx+'d4][col_inx+'d2])) begin 
      //     n_grid[row_inx][col_inx+'d2] = 1'b0;  
      //     n_grid[row_inx+'d4][col_inx+'d2] = 1'b1; 
      //     row_inx = row_inx + 'd1;  
      //   end else begin 
      //     n_state = EVAL; // the block is stuck 
      //   end

      //   if (right && (col_inx != 'd7)) begin 
      //     if (~(grid[row_inx][col_inx + 3] || grid[row_inx + 1][col_inx + 3] || grid[row_inx + 2][col_inx + 3] || grid[row_inx + 3][col_inx + 3])) begin 
      //       n_grid[row_inx][col_inx + 3] = 1'b1; 
      //       n_grid[row_inx + 1][col_inx + 3] = 1'b1; 
      //       n_grid[row_inx + 2][col_inx + 3] = 1'b1; 
      //       n_grid[row_inx + 3][col_inx + 3] = 1'b1; 
            
      //       n_grid[row_inx][col_inx + 2] = 1'b0; 
      //       n_grid[row_inx + 1][col_inx + 2] = 1'b0; 
      //       n_grid[row_inx + 2][col_inx + 2] = 1'b0; 
      //       n_grid[row_inx + 3][col_inx + 2] = 1'b0; 
            
      //       col_inx = col_inx + 'd1; 
      //     end 
      //   end 

      //   if (left && (col_inx != 'd8)) begin 
      //     if (~(grid[row_inx][col_inx + 1] || grid[row_inx + 1][col_inx + 1] || grid[row_inx + 2][col_inx + 1] || grid[row_inx + 3][col_inx + 1])) begin 
      //       n_grid[row_inx][col_inx + 1] = 1'b1; 
      //       n_grid[row_inx + 1][col_inx + 1] = 1'b1; 
      //       n_grid[row_inx + 2][col_inx + 1] = 1'b1; 
      //       n_grid[row_inx + 3][col_inx + 1] = 1'b1; 
            
      //       n_grid[row_inx][col_inx + 2] = 1'b0; 
      //       n_grid[row_inx + 1][col_inx + 2] = 1'b0; 
      //       n_grid[row_inx + 2][col_inx + 2] = 1'b0; 
      //       n_grid[row_inx + 3][col_inx + 2] = 1'b0; 
            
      //       col_inx = col_inx - 'd1; 
      //     end 
      //   end    

      //   if ((rr || rl) && (~(grid[row_inx + 1][col_inx] || grid[row_inx + 1][col_inx + 1] || grid[row_inx + 1][col_inx + 3]))) begin 
      //       n_grid[row_inx + 1][col_inx] = 1'b1; 
      //       n_grid[row_inx + 1][col_inx + 1] = 1'b1; 
      //       n_grid[row_inx + 1][col_inx + 3] = 1'b1; 
      //       n_grid[row_inx][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d3][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
      //       n_state = C2; 
      //   end    
      // end

      // D0: begin 
      //   if (~ (grid[row_inx+'d3][col_inx+'d1] || grid[row_inx+'d3][col_inx+'d2])) begin 
      //     n_grid[row_inx][col_inx+'d2] = 1'b0; 
      //     n_grid[row_inx][col_inx+'d1] = 1'b0; 
      //     n_grid[row_inx+'d3][col_inx+'d1] = 1'b1; 
      //     n_grid[row_inx+'d3][col_inx+'d2] = 1'b1; 
      //     row_inx = row_inx + 'd1;  
      //   end else begin 
      //     n_state = EVAL; // the block is stuck 
      //   end

      //   if (right && (col_inx != 'd7)) begin 
      //     if (~(grid[row_inx+'d1][col_inx+'d3] || grid[row_inx+'d2][col_inx+'d3])) begin 
      //       n_grid[row_inx+'d1][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d1] = 1'b0; 
      //       n_grid[row_inx+'d1][col_inx+'d3] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx+'d3] = 1'b1; 
          
      //       if (col_inx == 'd9) begin 
      //         col_inx = 0; 
      //       end else begin 
      //         col_inx = col_inx + 'd1;  
      //       end
      //     end 
      //   end 

      //   if (left && (col_inx != 'd9)) begin 
      //     if (~(grid[row_inx+'d1][col_inx] || grid[row_inx+'d2][col_inx])) begin 
      //       n_grid[row_inx+'d1][col_inx] = 1'b1; 
      //       n_grid[row_inx+'d2][col_inx] = 1'b1; 
      //       n_grid[row_inx+'d1][col_inx+'d2] = 1'b0; 
      //       n_grid[row_inx+'d2][col_inx+'d2] = 1'b0; 
          
      //       if (col_inx == 'd9) begin 
      //         col_inx = 0; 
      //       end else begin 
      //         col_inx = col_inx + 'd1;  
      //       end
      //     end 
      //   end    
      // end

      // EVAL: begin 
      //   // check if any blocks are out of the display (first row)
      //   for (int i = 0; i< 10; i++) begin 
      //     if (grid[0][i[3:0]]) begin 
      //       n_state = GAMEOVER; 
      //     end
      //   end
      //     // eliminate full rows
      //     for (int i = 0; i < 'd22; i++) begin 
      //       // assign the entire row to a vector for looping 
            
      //       for (int j = 0; j < 10; j++) begin 
      //         row_vec[j] = grid[i][j];
      //       end

      //       if (row_vec == 10'h3FF) begin 
      //         for (int j = {27'b0, i}; j > 0; j--) begin 
      //           for (int k = 0; k < 10; k++) begin 
      //             n_grid[j][k] = grid[j-1][k]; 
      //           end
      //         end
      //       end
      //     end
      //     n_state = NEW_BLOCK; 
      // end
      // // end
      
      // GAMEOVER: begin 
      //   // TO IMPLEMENT: scoring system update 
      //   if (en) begin 
      //     n_state = IDLE; 
      //   end else begin 
      //     n_state = c_state; 
      //   end
      // end

      default: begin 
        for (int i = 0; i < 10; i++) begin 
          for (int j = 0; j < 22; j++) begin 
            n_grid[j][i] = 1'b1; 
          end
        end
      end
    endcase
  end
endmodule