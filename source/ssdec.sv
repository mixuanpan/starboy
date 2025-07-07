`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ssdec
// Description : 7-segment display 
// 
//
/////////////////////////////////////////////////////////////////

module ssdec (
  input logic [3:0] in, 
  input logic enable, 
  output logic [7:0] out
);

  always_comb begin 
    if(enable) begin
      case(in) 
        4'b0000: begin out = 8'b00111111; end// 0
        4'b0001: begin out = 8'b00000110; end// 1
        4'b0010: begin out = 8'b01011011; end //2 
        4'b0011: begin out = 8'b01001111; end //3
        4'b0100: begin out = 8'b01100110; end //4
        4'b0101: begin out = 8'b01101101; end //5
        4'b0110: begin out = 8'b01111101; end //6
        4'b0111: begin out = 8'b00000111; end //7
        4'b1000: begin out = 8'b01111111; end //8
        4'b1001: begin out = 8'b01100111; end //9
        4'b1010: begin out = 8'b01110111; end //A
        4'b1011: begin out = 8'b01111100; end // b
        4'b1100: begin out = 8'b00111001; end // C
        4'b1101: begin out = 8'b01011110; end // d
        4'b1110: begin out = 8'b01111001; end // E
        4'b1111: begin out = 8'b01110001; end // F
        default: begin out = 8'b00000000; end // Default case
      endcase
    end
    else begin 
      out = 8'b00000000;
    end
  end

endmodule