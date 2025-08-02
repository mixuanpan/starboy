`default_nettype none 
module t01_ai_ofm (
    input logic clk, rst, mmu_done,
    input logic [17:0] n_mmu_result,
    input logic [3:0] n_blockX, 
    input logic [4:0] n_block_type, 
    output logic [3:0] blockX, 
    output logic [4:0] block_type,  
    output logic done
); 
    logic [4:0] c_block_type;
    logic [3:0] c_blockX;  
    logic [17:0] c_mmu_result; 
    logic testing; 
    assign testing = n_mmu_result > c_mmu_result; 

    // assign block_type = c_block_type; 
    // assign blockX = c_blockX; 

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_mmu_result <= 0; 
            block_type <= 0;
            blockX <= 0;
            done <= 0;  
        end else if (mmu_done) begin 
            if (n_mmu_result > c_mmu_result) begin 
                c_mmu_result <= n_mmu_result; 
                blockX <= n_blockX; 
                block_type <= n_block_type; 
            end
            done <= 1'b1; 
        end
    end 
endmodule 