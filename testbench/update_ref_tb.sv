`timescale 1ms/10ps

import tetris_pkg::*; 

module update_reftb;
  logic [3:0] row_i, row_o; 
  logic [4:0] col_i, col_o; 
  logic en; 
  move_t movement; 
  update_ref fulladder (.row_i(row_i), .row_o(row_o), .col_i(col_i), .col_o(col_o), .en(en), .movement(movement));
  initial begin
    $dumpfile("waves/update_ref.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, update_reftb);
    
    en = 1'b1; 

    for (integer i = 0; i <= 20; i++) begin
      for (integer j = 0; j <= 9; j++) begin
        for (integer k = 0; k <= 4; k++) begin
        // set our input signals
        row_i = i; col_i = j; movement = k;
        #1;
        // display inputs and outputs
        $display("row_i=\%b, col_i=\%b, movement=\%b, row_o=\%b, col_o=\%b", row_i, col_i, movement, row_o, col_o);
        end
      end
    end
  // finish the simulation
  #1 $finish;
  end
endmodule