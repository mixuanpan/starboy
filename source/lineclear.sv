`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : lineclear
// Description : Clears filled line 
// 
//
/////////////////////////////////////////////////////////////////

module lineclear (
  input logic clk, rst, start, 
  input logic [4:0] row_inx, 
  input logic [3:0] col_inx, 
  output logic [4:0][4:0][2:0] n_frame, 
  output logic [21:0][9:0][2:0] n_grid
);

  logic busy; 
  logic [5:0] count; // 0-24 for 5*5 frame
  logic done; 

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
      end else if (busy) begin 
        int i = {26'b0, count} / 5;
        int j = {26'b0, count} % 5; 

        c_frame[i][j] = c_grid[row_inx + i[4:0]][col_inx + j[4:0]]; 

        if (count == 24) begin 
          busy <= 0; 
          done <= 1; 
        end else begin 
          count <= count + 1; 
        end 
      end else begin 
        done <= 0; 
      end 
    end 
  end
 
endmodule