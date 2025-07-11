`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tetris_to_ai 
// Description : Takes the 3D Tetris input and output a 2D array for AI 
// 
//
/////////////////////////////////////////////////////////////////

module tetris_to_ai (
    input logic [21:0][9:0][2:0] tetris_grid, 
    input clk, rst, en, 
    output logic [19:0][9:0] ai_grid 
);
    
    always_ff @(posedge clk, posedge rst) begin 

    end

    always_comb begin 

    end

endmodule