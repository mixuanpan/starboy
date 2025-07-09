`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : frame_extract
// Description : Extract current grid to the current frame
// 
//
/////////////////////////////////////////////////////////////////

module frame_extract (
  input logic clk, rst, start, 
  input logic [4:0] row_inx, 
  input logic [3:0] col_inx, 
  input logic [21:0][9:0][2:0] c_grid, 
  output logic [4:0][4:0][2:0] c_frame, 
  output logic done
);

  logic busy, n_busy; 
  logic [5:0] count, n_count; // 0-24 for 5*5 frame

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      busy <= 0;
      count <= 0; 
      done <= 0; 
    end else begin 
      if (start && !busy) begin 
        busy <= 1;
        count <= 0;
        done <= 0; 
      end else begin 
        busy <=
endmodule