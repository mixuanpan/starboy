`default_nettype none 
module t01_ai_ga_kys (
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

    // Fixed GA weights (scaled by 1024 for precision)
    parameter signed [15:0] WEIGHT_HEIGHT = -16'd523;     // -0.510066 * 1024
    parameter signed [15:0] WEIGHT_LINES = 16'd779;       //  0.760666 * 1024  
    parameter signed [15:0] WEIGHT_HOLES = -16'd365;      // -0.35663 * 1024
    parameter signed [15:0] WEIGHT_BUMPINESS = -16'd189;  // -0.184483 * 1024

    // State registers
    logic [4:0] c_block_type, n_block_type;
    logic [3:0] c_blockX, n_blockX;  
    logic signed [31:0] c_best_score, n_best_score;
    
    // Score calculation
    logic signed [31:0] current_score;
    logic signed [31:0] height_term, lines_term, holes_term, bumpiness_term;
    
    // Calculate weighted score: a×height + b×lines + c×holes + d×bumpiness
    always_comb begin
        height_term = $signed({8'b0, heights_i}) * WEIGHT_HEIGHT;
        lines_term = $signed({8'b0, lines_cleared_i}) * WEIGHT_LINES;
        holes_term = $signed({8'b0, holes_i}) * WEIGHT_HOLES;
        bumpiness_term = $signed({8'b0, bumpiness_i}) * WEIGHT_BUMPINESS;
        
        // Sum and scale back down (divide by 1024)
        current_score = (height_term + lines_term + holes_term + bumpiness_term) >>> 10;
    end

    assign blockX_o = c_blockX; 
    assign block_type_o = c_block_type;
    
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_best_score <= 32'sh80000000; // Most negative value (worst score)
            c_block_type <= 0;
            c_blockX <= 0; 
            done <= 0; 
        end else if (mmu_done) begin 
            c_blockX <= n_blockX; 
            c_block_type <= n_block_type; 
            c_best_score <= n_best_score; 
            done <= 1'b1; 
        end else begin 
            done <= 0; 
        end
    end 

    always_comb begin 
        // Default: keep current values
        n_best_score = c_best_score; 
        n_blockX = c_blockX; 
        n_block_type = c_block_type; 
        
        // If current move has better score, update best move
        if (current_score > c_best_score) begin
            n_best_score = current_score;
            n_blockX = blockX_i; 
            n_block_type = block_type_i; 
        end
    end
    
endmodule