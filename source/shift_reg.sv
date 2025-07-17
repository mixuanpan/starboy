`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : shift_reg 
// Description : a shift register for the Tetris rotation 
// 
//
/////////////////////////////////////////////////////////////////
module shift_reg (
  input logic clk, rst, en, 
  input logic [1:0] mode_i, 
  input logic [3:0] par_i, 
  output logic [3:0] Q, 
  output logic done 
);
  // logic [3:0] c_P, n_P; 
  // assign Q = c_P; 

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      // c_P <= 0; 
      Q <= 0; 
      done <= 0; 
    // end else begin 
    //   // c_P <= n_P; 
    // end 
    end else if (mode_i == 'b01) begin // rotate right
      Q <= {par_i[0], par_i[2:0]}; 
      done <= 1'b1; 
    end else if (mode_i == 'b10) begin // rotate left 
      Q <= {par_i[2:0], par_i[3]}; 
      done <= 1'b1; 
    end 
  end

  // always_comb begin 
  //   done = 0; 
  //   if (en) begin 
  //     case(mode_i) 
  //       2'b00: begin // no rotations 
  //         n_P = c_P; 
  //       end

  //       2'b01: begin // rotate right  
  //         n_P = {c_P[0], c_P[2:0]}; 
  //         done = 1'b1; 
  //         // n_P[3:0] = {c_P[0], c_P[3:1]}; 
  //         // n_P[7:4] = {c_P[4], c_P[7:5]}; 
  //         // n_P[11:8] = {c_P[8], c_P[11:9]}; 
  //         // n_P[15:12] = {c_P[12], c_P[15:13]}; 

  //       end

  //       2'b10: begin // rotate left 
  //         n_P = {c_P[2:0], c_P[3]}; 
  //         done = 1'b1; 
  //         // n_P[3:0] = {c_P[2:0], c_P[3]}; 
  //         // n_P[7:4] = {c_P[6:4], c_P[7]}; 
  //         // n_P[11:8] = {c_P[10:8], c_P[11]}; 
  //         // n_P[15:12] = {c_P[14:12], c_P[15]}; 
  //       end

  //       2'b11: begin 
  //         n_P = par_i; 
  //       end
  //     endcase
  //   end else begin 
  //     n_P = par_i; 
  //   end 
  // end
endmodule