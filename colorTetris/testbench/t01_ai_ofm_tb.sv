`timescale 1us/1ps
module t01_ai_ofm_tb; 
    logic clk, rst;
    logic mmu_done; 
    logic [17:0] n_mmu_result; 
    logic [3:0] n_blockX; 
    logic [4:0] n_block_type; 
    logic [3:0] blockX; 
    logic [4:0] block_type; 
    logic done; 
     
   
    t01_ai_ofm ge (.clk(clk), .rst(rst), .mmu_done(mmu_done), .n_mmu_result(n_mmu_result), .n_blockX(n_blockX), .n_block_type(n_block_type), .blockX(blockX), .block_type(block_type), .done(done)); 

    task tog_rst; 
        rst = 1; #1; 
        rst = 0; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

 
    initial begin 
        $dumpfile("waves/t01_ai_ofm.vcd"); 
        $dumpvars(0, t01_ai_ofm_tb);

        n_blockX = 'd7; 
        n_block_type = 'd3; 
        mmu_done = 1'b1; 
        tog_rst(); 
            for (int i = 0; i <= 'd10; i++) begin 
                for (int j = 0; j <= 'd7; j++) begin 
                    for (int k = 0; k <= 'd9; k++) begin 
                        if (i == 'd5) begin 
                            n_mmu_result = 'd0; 
                        end else begin 
                            n_mmu_result = i[17:0];
                        end  
                        n_block_type = j[4:0]; 
                        n_blockX = k[3:0]; 
                        #1; 
                    end
                end
            end

    #1 $finish; 
    end
endmodule 