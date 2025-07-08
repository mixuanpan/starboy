`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : update_ref
// Description : Updates Tetris reference number 
// 
//
/////////////////////////////////////////////////////////////////

import tetris_pkg::*;

module update_ref(
  input logic [3:0] row_i, 
  input logic [4:0] col_i, 
  input logic en, // enable update
  input move_t movement, 
  output logic [3:0] row_o, 
  output logic [4:0] col_o
);

  always_comb begin 
    row_o = row_i; 
    col_o = col_i; 

    if (en) begin 
      case (movement) 
        LEFT: begin 
          if (col_i == 'd9) begin 
            col_o = 0; 
          end else begin 
            col_o = col_i + 'd1; 
          end 
        end

        RIGHT: begin 
          if (col_i == 'd9) begin 
            col_o = 0; 
          end else begin 
            col_o = col_i - 'd1; 
          end 
        end

        DOWN: begin 
          row_o = row_i + 'd1; 
        end
      endcase
    end 
  end

endmodule