`default_nettype none 
module t01_ai_ofm (
    input clk, rst, mmu_done,
    input [17:0] n_mmu_result,
    input [3:0] n_blockX, 
    input [4:0] n_blockY, n_block_type, 
    output [3:0] blockX, 
    output [4:0] blockY, block_type,  
    output logic done
); 
    logic [4:0] c_block_type, c_blockY;
    logic [3:0] c_blockX;  
    logic [17:0] c_mmu_result; 

    assign block_type = c_block_type; 
    assign blockX = c_blockX; 
    assign blockY = c_blockY; 

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_mmu_result <= 0; 
            c_block_type <= 0;
            c_blockX <= 0;
            c_blockY <= 0;
            done <= 0;  
        end else if (mmu_done) begin 
            if (n_mmu_result > c_mmu_result) begin 
                c_mmu_result <= n_mmu_result; 
                c_blockX <= n_blockX; 
                c_blockY <= n_blockY; 
                c_block_type <= n_block_type; 
            end
            done <= 0; 
        end
    end 
endmodule 