// `default_nettype none

// /////////////////////////////////////////////////////////////////
// // HEADER 
// //
// // Module : inputbus
// // Description : converts the pb inputs to moves
// // 
// //
// /////////////////////////////////////////////////////////////////

// module inputbus (
//   input logic clk,
//   input logic rst_n,
//   input logic [4:0] btn_raw,
//   output move_t move,
//   output logic move_valid
// );


// logic [4:0] btn_prev;

// always_ff @(posedge clk, negedge rst_n) begin
//     if (!rstn_n) begin
//         btn_prev <= 5'd0;
//     end else begin
//         btn_prev <= btn_raw;
//     end
// end

// logic [4:0] btn_edge;
// assign btn_edge = btn_raw & ~btn_prev;

// always_comb begin
//     move_valid = 1'b0;
//     move = DOWN; 
//     if (btn_edge[2]) begin
//         move_valid = 1;
//         move = ROR; 
// end else if (btn_edge[3]) begin 
//         move_valid = 1; 
//         move = ROL;
// end else if (btn_edge[0]) begin
//         move_valid = 1;
//         move = RIGHT; 
// end else if (btn_edge[1]) begin
//         move_valid = 1;
//         move = LEFT;
// end else if (btn_edge[1]) begin
//         move_valid = 1;
//         move = DOWN;
//     end
// end


// endmodule