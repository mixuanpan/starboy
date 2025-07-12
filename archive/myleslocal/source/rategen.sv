`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : rategen
// Description : Manages speed of falling blocks 
// 
//
/////////////////////////////////////////////////////////////////

module rategen
    (
    input clk,
    input reset,
    input drop,
    input [3:0] speed,
    output en
);

parameter logic [25:0]  CLK_DIV_GAMESPEED_1 = 26'd50000000 - 1;  
parameter logic [25:0]  CLK_DIV_GAMESPEED_2 = 26'd4500000 - 1;
parameter logic [25:0]  CLK_DIV_GAMESPEED_3 = 26'd4000000 - 1;
parameter logic [25:0]  CLK_DIV_GAMESPEED_4 = 26'd3500000 - 1;
parameter logic [25:0]  CLK_DIV_GAMESPEED_5 = 26'd3000000 - 1;
parameter logic [25:0]  CLK_DIV_GAMESPEED_6 = 26'd2500000 - 1;
parameter logic [25:0]  CLK_DIV_GAMESPEED_7 = 26'd2000000 - 1;
parameter logic [25:0]  CLK_DIV_GAMESPEED_8 = 26'd15000000 - 1; 
parameter logic [25:0]  CLK_DIV_GAMESPEED_9 = 26'd1000000 - 1;
parameter logic [25:0]  CLK_DIV_DROP =         26'd5000000 - 1;

logic [25:0] compare;

always_comb begin
    case (speed)
    4'd1: compare = CLK_DIV_GAMESPEED_1;
    4'd2: compare = CLK_DIV_GAMESPEED_2;
    4'd3: compare = CLK_DIV_GAMESPEED_3;
    4'd4: compare = CLK_DIV_GAMESPEED_4;
    4'd5: compare = CLK_DIV_GAMESPEED_5;
    4'd6: compare = CLK_DIV_GAMESPEED_6;
    4'd7: compare = CLK_DIV_GAMESPEED_7;
    4'd8: compare = CLK_DIV_GAMESPEED_8;
    4'd9: compare = CLK_DIV_GAMESPEED_9;
    
    default: compare = CLK_DIV_GAMESPEED_1;
    endcase 
end


logic [25:0] cntr;
always_ff @(posedge clk) begin 
    if (reset) begin
        cntr <= '0;
    end else begin
        if (~drop && (cntr >= compare)) begin
        cntr <= '0;
    end else if (drop && (cntr >= CLK_DIV_DROP)) begin
        cntr <= '0; 
    end else begin
        cntr <= cntr + 1'b1;
    end
end
end

assign en = drop ? (cntr == CLK_DIV_DROP) : (cntr == compare);

endmodule