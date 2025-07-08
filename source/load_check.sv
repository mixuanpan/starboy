`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : load_check
// Description : Checks the validity of a new block 
// 
//
/////////////////////////////////////////////////////////////////

import tetris_pkg::*;

module load_check(
  input state_t block_type, 
  input logic [9:0][2:0] row1, // check row 0
  input color_t color, 
  output logic valid, 
  output logic [4:0] row_ref, 
  output logic [3:0] col_ref, 
  output logic [1:0][9:0][2:0] row01 // the first two rows of the grid 
);
  logic check; 

  always_comb begin 
    row01[0] = 0; 
    row01[1] = row1; 
    valid = 0; 
    row_ref = 0; 
    col_ref = 0; 
    
    if (block_type == E1 || block_type == F1 || block_type == G1) begin 
      for (int i = 0; i <= 7; i++) begin 
        check = (row1[i] == 3'b0) && (row1[i + 1] == 3'b0) && (row1[i + 2] == 3'b0); 
        if (check) begin 
          row01[1][i] = color; 
          row01[1][i + 1] = color; 
          row01[1][i + 2] = color; 
          break; 
        end
      end

    end 

    // output reference row & col number 
    if (valid) begin 

      if (block_type == E1) begin 
        row01[0][i + 1] = color; 
        valid = 1'b1; 
      end
    
      row_ref = 'd21;
      if (i == 0) begin 
        col_ref = 'd9; 
      end else begin 
        col_ref = i - 'd1; 
      end  
    end
  end
endmodule