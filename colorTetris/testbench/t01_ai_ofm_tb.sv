`timescale 1us/1ps
module t01_ai_ofm_tb; 
    logic clk, rst;
    logic mmu_done; 
    logic [17:0] mmu_result_i; 
    logic [3:0] blockX_i; 
    logic [4:0] block_type_i; 
    logic [3:0] blockX_o; 
    logic [4:0] block_type_o; 
    logic done; 
     
   
    t01_ai_ofm ge (.clk(clk), .rst(rst), .mmu_done(mmu_done), .mmu_result_i(mmu_result_i), .blockX_i(blockX_i), .block_type_i(block_type_i), .blockX_o(blockX_o), .block_type_o(block_type_o), .done(done)); 

    task tog_rst; 
        rst = 1; #1; 
        rst = 0; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

 
    initial begin 
        $dumpfile("waves/t01_ai_ofm.vcd"); 
        $dumpvars(0, t01_ai_ofm_tb);

        blockX_i = 'd7; 
        block_type_i = 'd3; 
        mmu_done = 1'b1; 
        tog_rst(); 
            
                for (int j = 3; j <= 'd7; j++) begin 
                    for (int k = 2; k <= 'd9; k++) begin 
                        for (int i = 0; i <= 'd10; i++) begin 
                        if (i == 'd5) begin 
                            mmu_result_i = 'd0; 
                        end else begin 
                            mmu_result_i = i[17:0];
                        end  
                        block_type_i = j[4:0]; 
                        blockX_i = k[3:0]; 
                        #1; 
                    end
                end
            end

    #1 $finish; 
    end
endmodule 