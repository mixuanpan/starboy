`default_nettype none 
module tetris_ga_kys_ai (
    input logic clk, rst, mmu_done,
    input logic [17:0] mmu_result_i,
    input logic [3:0] blockX_i, 
    input logic [4:0] block_type_i, 
    input logic [3:0] gamestate, 
    input logic [7:0] lines_cleared_i, bumpiness_i, heights_i, holes_i,
    output logic [3:0] blockX_o, 
    output logic [4:0] block_type_o,  
    output logic done
); 

    // GA weights (scaled by 1024)
    parameter signed [15:0] W_LINES     =  16'd1024;
    parameter signed [15:0] W_HEIGHT    = -16'd512;
    parameter signed [15:0] W_BUMPINESS = -16'd256;
    parameter signed [15:0] W_HOLES     = -16'd1536;

    // State registers
    logic [4:0] c_block_type, n_block_type;
    logic [3:0] c_blockX, n_blockX;  
    logic signed [31:0] c_best_score, n_best_score;
    logic [7:0] c_lines_cleared, c_bumpiness, c_heights, c_holes;
    logic [7:0] n_lines_cleared, n_bumpiness, n_heights, n_holes;
    
    // Score calculation
    logic signed [31:0] score_lines, score_height, score_bump, score_holes;
    logic signed [31:0] score;
    
    // Calculate weighted score
    always_comb begin
        // extend inputs to signed and multiply by weights
        score_lines  = $signed({8'b0, lines_cleared_i}) * W_LINES;
        score_height = $signed({8'b0, heights_i})      * W_HEIGHT;
        score_bump   = $signed({8'b0, bumpiness_i})    * W_BUMPINESS;
        score_holes  = $signed({8'b0, holes_i})        * W_HOLES;
        
        // sum & down-scale by 1024
        score = (score_lines + score_height + score_bump + score_holes) >>> 10;
    end

    assign blockX_o = c_blockX; 
    assign block_type_o = c_block_type;
    
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_best_score <= 32'sh80000000; // Most negative value (worst score)
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
            c_best_score <= n_best_score; 
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
        // Default: keep current values
        n_best_score = c_best_score; 
        n_blockX = c_blockX; 
        n_block_type = c_block_type; 
        n_lines_cleared = c_lines_cleared;
        n_bumpiness = c_bumpiness;
        n_heights = c_heights;
        n_holes = c_holes;
        
        // compare against best so far
        if (score > c_best_score) begin
            n_best_score = score;
            n_blockX = blockX_i;
            n_block_type = block_type_i;
            n_lines_cleared = lines_cleared_i;
            n_bumpiness = bumpiness_i;
            n_heights = heights_i;
            n_holes = holes_i;
        end
    end
    
endmodule