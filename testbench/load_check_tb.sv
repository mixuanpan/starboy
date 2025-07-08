`timescale 1ms/10ps

import tetris_pkg::*; 

module load_check_tb;
  state_t block_type;
  color_t color; 
  logic [9:0] row1; 
  logic valid; 
  logic [4:0] row_ref; 
  logic [3:0] col_ref; 
  logic [1:0][9:0][2:0] row01; 

  load_check fulladder (.row_i(row_i), .row_o(row_o), .col_i(col_i), .col_o(col_o), .en(en), .movement(movement));
  initial begin
    $dumpfile("waves/load_check.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, load_check_tb);
    
    block_type = E1;
    color = CL1; 
    row1 = 0;  
    #1; 
    $display("valid=\%b, row_ref=\%b, col_ref=\%b", valid, row_ref, col_ref);

    
  // finish the simulation
  #1 $finish;
  end
endmodule