`default_nettype none

// self-defined states for the finite state machine 
typedef enum logic [3:0] {
  IDLE, // reset state 
  READY, // count down to start 
  NEW_BLOCK, // load new block 
  LS0, 
  LS1, 
  LS2, 
  LS3, 
  LS4, 
  LS5, 
  LS6, 
  EVAL, // evaluation 
  GAME_OVER // user run out of space 
} state_t; 

module tetris (
  input logic clk, rst, 
  input logic en, right, left, down, rotate, // user input 
  output logic [7:0] count_down, // count down display during READY state 
  output logic [9:0] grid [21:0], // grid display 
);
  
  state_t c_state, n_state; // current state, next state 

  assign grid [21] = 10'b1111111111; // set the invisible buttom layer to high 

  // a slow clock for the READY state count down 
  logic countdown_clk, ready_en; // slow-down clock for the count down 
  logic [1:0] count_down_in; // output from the countdown function 
  logic [7:0] count_down_out; // temp count down 7-seg output 
  clkdiv_countdown clkdiv (.clk(clk), .rst(rst), .newclk(countdown_clk)); 
  countdown countdown1 (.clk(countdown_clk), .rst(rst), en(ready_en), .count(count_down_in)); 
  ssdec count_down (.in({1'b0, count_down_in}), .enable(1'b1), .out(count_down_out)); 

  // read in a random new block 
  logic [[2:0] nb]; // new block cooridnates 
  new_block nb (.clk(clk), .rst(rst), .block(nb)); 

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
        case(nb)
          3'b001: begin 
            n_state = LS0; 
          end

          3'b010: begin 
            n_state = LS1; 
          end 

          3'b011: begin 
            n_state = LS2; 
          end 

          3'b100: begin 
            n_state = LS3; 
          end 

          3'b101: begin 
            n_state = LS4; 
          end 

          3'b110: begin 
            n_state = LS5; 
          end 

          3'b111: begin 
            n_state = LS6; 
          end 

          default: begin 
            n_state = c_state; 
          end 
        endcase
      end

      LS0: begin 
        
      end
    endcase
  end
endmodule