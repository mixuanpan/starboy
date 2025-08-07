`default_nettype none 
module t01_ai_ofm (
    input logic clk, rst, mmu_done,
    input logic [17:0] mmu_result_i,
    input logic [3:0] blockX_i, 
    input logic [4:0] block_type_i, 
    input logic [3:0] gamestate, 
    output logic [3:0] blockX_o, 
    output logic [4:0] block_type_o,  
    output logic done
); 
    logic [4:0] c_block_type, n_block_type;
    logic [3:0] c_blockX, n_blockX;  
    logic [17:0] c_mmu_result, n_mmu_result; 
    logic testing; 
    assign testing = mmu_result_i > c_mmu_result; 

    assign blockX_o = c_blockX; 
    assign block_type_o = c_block_type; 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            // ai without mmu 
            // c_mmu_result <= 18'd262143; // the highest it gets 
            // ai with mmu 
            c_mmu_result <= 0; 
            c_block_type <= 0;
            c_blockX <= 0; 
            done <= 0; 
        end else if (mmu_done) begin 
            c_blockX <= n_blockX; 
            c_block_type <= n_block_type; 
            c_mmu_result <= n_mmu_result; 
            done <= 1'b1; 
        end else begin 
            done <= 0; 
        end
    end 

    always_comb begin 
        n_mmu_result = c_mmu_result; 
        n_blockX = c_blockX; 
        n_block_type = c_block_type; 
        // ai without mmu 
        // if (mmu_result_i < c_mmu_result) begin 
        // ai with mmu 
        if (mmu_result_i > c_mmu_result) begin 
            n_blockX = blockX_i; 
            n_block_type = block_type_i; 
            n_mmu_result = mmu_result_i; 
        end
    end
endmodule 