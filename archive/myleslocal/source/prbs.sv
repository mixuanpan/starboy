
`timescale 1ns / 1ps

module prbs(
  input logic clk,
  input logic rst,
  output logic [5:0] dout,
  output logic new_sample
);

logic [14:0] prbs_shr;
logic [5:0] prbs_temp;
logic [2:0] cntr;
logic prbs_xor;
assign prbs_xor = prbs_shr[1]^prbs_shr[0];

always_ff @ (posedge clk)
begin
  if(rst || (prbs_shr == 15'b000000000000000)) begin
    prbs_shr   <= 15'b100101010000000;
    dout      <= 0;
    prbs_temp    <= 0;
    cntr      <= 0;
  end else begin
    cntr      <= cntr +1;
    prbs_shr   <= {prbs_xor,prbs_shr[14:1]};
    prbs_temp   <= {prbs_xor,prbs_temp[5:1]};
    if(cntr == 7) begin
      dout <= prbs_temp;
      new_sample  <= 1;
    end else
      new_sample  <= 0;
  end
end

endmodule
