`timescale 1ms/1us

module t01_ai_mc_ci_tb #(
    parameter ADDR_W = 32, 
    parameter LEN_W = 16 
);
    
    logic clk, rst;
    logic read_req, write_req;
    logic [ADDR_W-1:0] read_addr, write_addr;
    logic [LEN_W-1:0] read_len, write_len;
    logic rd_cmd_ready, wr_cmd_ready;
    logic rd_cmd_valid, wr_cmd_valid;
    logic [ADDR_W-1:0] rd_cmd_addr, wr_cmd_addr;
    logic [LEN_W-1:0] rd_cmd_len, wr_cmd_len;
    
    t01_ai_mc_ci pipeline_controller (.clk(clk), .rst(rst), .read_req(read_req), .write_req(write_req), .read_addr(read_addr), .write_addr(write_addr), .read_len(read_len), .write_len(write_len), .rd_cmd_ready(rd_cmd_ready), .wr_cmd_ready(wr_cmd_ready), .rd_cmd_valid(rd_cmd_valid), .wr_cmd_valid(wr_cmd_valid),  .rd_cmd_addr(rd_cmd_addr), .wr_cmd_addr(wr_cmd_addr), .rd_cmd_len(rd_cmd_len), .wr_cmd_len(wr_cmd_len));

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 


    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_mc_ci.vcd"); 
        $dumpvars(0, t01_ai_mc_ci_tb); 

        read_addr = 'd10; write_addr = 'd4;  
        read_len = 'd4; write_len = 'd15; 

        tog_rst(); 

        for (int i = 0; i <= 1; i++) begin 
            for (int j = 0; j <= 1; j++) begin 
                for (int k = 0; k <= 1; k++) begin 
                    for (int m = 0; m <= 1; m++) begin 
                        read_req = i[0];
                        #1;  
                        write_req = j[0];
                        #1;  
                        rd_cmd_ready = k[0];
                        #1;  
                        wr_cmd_ready = m[0];
                        #1;  
                        
                    end
                end
            end
        end 
        #3; 
        $finish; 
    end
endmodule 