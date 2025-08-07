`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_ai_ofm 
// Description : makes final ai decision based on inputs & weights
// 
//
/////////////////////////////////////////////////////////////////
module t01_ai_ofm (
    input logic clk, rst, mmu_done,
    input logic [3:0] blockX_i, 
    input logic [4:0] block_type_i, 
    input logic [3:0] gamestate, 
    input logic [7:0] lines_cleared_i, bumpiness_i, heights_i, holes_i, 
    output logic [3:0] blockX_o, 
    output logic [4:0] block_type_o,  
    output logic done
); 
    logic [4:0] c_block_type, n_block_type;
    logic [3:0] c_blockX, n_blockX;  
    logic [17:0] c_mmu_result, n_mmu_result, value_i; 
    logic [7:0] c_lines_cleared, c_bumpiness, c_heights, c_holes, n_lines_cleared, n_bumpiness, n_heights, n_holes; 

    // generic algorithm 
    assign value_i = {10'b0, heights_i} * 'd6 + {10'b0, holes_i} * 'd4 + {10'b0, bumpiness_i} * 'd2 + {10'b0, lines_cleared_i} * 'd12; // from reference model - best one so far 

    assign blockX_o = c_blockX; 
    assign block_type_o = c_block_type; 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_mmu_result <= 18'd262143; // the highest it gets 
            c_block_type <= 0;
            c_blockX <= 0; 
            done <= 0; 
            c_lines_cleared <= 0; 
            c_bumpiness <= 8'd255; 
            c_heights <= 8'd255; 
            c_holes <= 8'd255; 
        end else if (mmu_done) begin 
            c_blockX <= n_blockX; 
            c_block_type <= n_block_type; 
            c_mmu_result <= n_mmu_result; 
            done <= 1'b1; 
            c_lines_cleared <= n_lines_cleared; 
            c_bumpiness <= n_bumpiness; 
            c_heights <= n_heights; 
            c_holes <= n_holes;
        end else begin 
            done <= 0; 
        end
    end 

    always_comb begin 
        n_mmu_result = c_mmu_result; 
        n_blockX = c_blockX; 
        n_block_type = c_block_type; 
        n_lines_cleared = c_lines_cleared;
        n_bumpiness = c_bumpiness;
        n_heights = c_heights;
        n_holes = c_holes;
        if (value_i < c_mmu_result) begin 
            n_mmu_result = value_i;
            n_lines_cleared = lines_cleared_i; 
            n_bumpiness = bumpiness_i; 
            n_heights = heights_i; 
            n_holes = holes_i; 
            n_blockX = blockX_i; 
            n_block_type = block_type_i; 
        end 
    end
endmodule 