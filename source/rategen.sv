// `timescale 1ns / 1ps

// /////////////////////////////////////////////////////////////////
// // HEADER 
// //
// // Module : rategen
// // Description : Manages speed of falling blocks 
// // 
// //
// /////////////////////////////////////////////////////////////////

// module rategen#( 
// parameter int unsigned CLK_DIV_GAMESPEED_1 = 50000000 - 1;   
// parameter int unsigned CLK_DIV_GAMESPEED_2 = 4500000 - 1; 
// parameter int unsigned CLK_DIV_GAMESPEED_3 = 4000000 - 1; 
// parameter int unsigned CLK_DIV_GAMESPEED_4 = 3500000 - 1; 
// parameter int unsigned CLK_DIV_GAMESPEED_5 = 3000000 - 1; 
// parameter int unsigned CLK_DIV_GAMESPEED_6 = 2500000 - 1; 
// parameter int unsigned CLK_DIV_GAMESPEED_7 = 2000000 - 1; 
// parameter int unsigned CLK_DIV_GAMESPEED_8 = 15000000 - 1;  
// parameter int unsigned CLK_DIV_GAMESPEED_9 = 1000000 - 1; 
// parameter int unsigned CLK_DIV_DROP = 5000000 - 1
// )
//     (
//     input clk,
//     input reset,
//     input drop,
//     input [3:0] speed,
//     output en
// );

// logic [25:0] compare;

// always_comb begin
//     case (speed)
//     4'd1: compare = CLK_DIV_GAMESPEED_1;
//     4'd2: compare = CLK_DIV_GAMESPEED_2;
//     4'd3: compare = CLK_DIV_GAMESPEED_3;
//     4'd4: compare = CLK_DIV_GAMESPEED_4;
//     4'd5: compare = CLK_DIV_GAMESPEED_5;
//     4'd6: compare = CLK_DIV_GAMESPEED_6;
//     4'd7: compare = CLK_DIV_GAMESPEED_7;
//     4'd8: compare = CLK_DIV_GAMESPEED_8;
//     4'd9: compare = CLK_DIV_GAMESPEED_9;
    
//     default: compare = CLK_DIV_GAMESPEED_1;
//     endcase 
// end


// logic [25:0] cntr;
// always @ (posedge clk) begin 
//     if (rst) begin
//         cntr <= '0;
//     end else ((!drop && cntr >= compare) || (drop && cntr >= CLK_DIV_DROP)) begin
//         cntr <= '0;
//     end
//     else begin
//         cntr <= cntr + 1'b1'
//     end
// end

// assign en = drop ? (cntr == CLK_DIV_DROP) : (cntr == compare);

// endmodule