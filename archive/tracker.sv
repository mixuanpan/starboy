`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tracker 
// Description : track and update individual frames of the grid 
// 
//
/////////////////////////////////////////////////////////////////

module tracker (
  // extract frame from grid 
  input logic [21:0][9:0][2:0] c_grid, 
  input logic [4:0] row_inx, 
  input logic [3:0] col_inx, 
  input clk, rst, track_en, 

  // track 
  input state_t state, // current state 
  input move_t move, 
  input logic [2:0] color, // block color 
  input logic right, left, rr, rl, down, 
  input logic [4:0] cell_i1, cell_i2, cell_i3, cell_i4, d_i1, d_i2, d_i3, d_i4,  
  input logic [3:0] cell_j1, cell_j2, cell_j3, cell_j4, d_j1, d_j2, d_j3, d_j4, 

  // writing frame 
  output logic [21:0][9:0][2:0] n_grid,
  output logic complete // indicates the completion of the movement 
);

  logic check; // check if movement is available 
  
  // assign track_en = extract_done;  

  always_comb begin 
    // frame_o = frame_i; 
    check = 0; 
    complete = 0; 
    n_grid = 0; 

    if (track_en && !complete) begin
      // if (right) begin 
        // RIGHT: begin 
          case (state) 
            A1, B1, D0, E1, E3, F1, F3, G1, G3: begin 
              check = c_grid[cell_i1][cell_j1] == 0 && c_grid[cell_i2][cell_j2] == 0; 
              if (check) begin
                n_grid[d_i1][d_j1] = 0; 
                n_grid[d_i2][d_j2] = 0; 
                n_grid[cell_i1][cell_j1] = color; 
                n_grid[cell_i2][cell_j2] = color; 
                complete = 1'b1; 
              end
            end

            default: begin end
          endcase
        // end
      // end 
    end
  end


endmodule