`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : inputbus
// Description : converts the pb inputs to moves
// 
//
/////////////////////////////////////////////////////////////////

module inputbus (
  input logic [3:0] in, 
  input logic enable, 
  output logic [7:0] out
);


logic [4:0] btn_prev;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rstn_n) begin
        btn_prev <= 5'd0;
    end else begin
        btn_prev <= btn_raw;
    end
end

logic [4:0] btn_edge;
assign btn_edge = btn_raw & ~btn_prev;

always_comb begin
    move_valid = 1'b0;
    move = DOWN; 
    if 

endmodule