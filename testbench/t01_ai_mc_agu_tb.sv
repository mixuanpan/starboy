`timescale 1ms/1us

module t01_ai_mc_agu_tb #(
    parameter int ADDR_W = 32, // width of the address bus 
    parameter int LEN_W = 16, // width of the length (in beats)
    parameter int BEAT_BYTES = 4 // bytes per burst beat 
);
    
    logic clk, rst;
    logic gen_last;
    logic [ADDR_W-1:0] cmd_addr, gen_addr;
    logic [LEN_W-1:0] cmd_len;
    logic cmd_ready, gen_ready;
    logic cmd_valid, gen_valid;
    
    t01_ai_mc_agu pipeline_controller (.clk(clk), .rst(rst), .cmd_valid(cmd_valid), .cmd_ready(cmd_ready), .cmd_addr(cmd_addr), .cmd_len(cmd_len), .gen_valid(gen_valid), .gen_addr(gen_addr), .gen_last);

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 


    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_mc_agu.vcd"); 
        $dumpvars(0, t01_ai_mc_agu_tb); 

        cmd_addr = 'd444; cmd_len = 'd4; 
        tog_rst(); 

        for (int i = 0; i <= 1; i++) begin 
            for (int j = 0; j <= 1; j++) begin 
                        cmd_valid = i[0];
                        #1;  
                        cmd_ready = j[0];
                        #1;  
            end
        end 
        #6; 
        $finish; 
    end
endmodule 