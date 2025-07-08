`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : update_ref
// Description : Updates Tetris reference number 
// 
//
/////////////////////////////////////////////////////////////////

module update_ref(
  input logic [3:0] row_i, 
  input logic [4:0] col_i, 
  input state_t state, 
  input en, // enable update
  input move_t movement, 
  output logic [3:0] row_o, 
  output logic [4:0] col_o
);

  always_comb begin 
    if (en) begin 
    end 
  end

endmodule