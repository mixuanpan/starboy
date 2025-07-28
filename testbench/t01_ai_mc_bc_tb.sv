`timescale 1ms/1us

module t01_ai_mc_bc_tb #(
    parameter int ADDR_W = 32, // address width 
    parameter int LEN_W = 16, // length in beast
    parameter int DATA_W = 32 // data bus width 
);
    
    logic clk, rst;
    logic rd_cmd_valid, wr_cmd_valid;
    logic  rd_cmd_ready, wr_cmd_ready;
    logic [ADDR_W-1:0] rd_cmd_addr, wr_cmd_addr;
    logic [LEN_W-1:9] rd_cmd_len, wr_cmd_len;
    logic phy_rd_start, phy_wr_start;
    logic [ADDR_W-1:0] phy_rd_addr, phy_wr_addr;
    logic [LEN_W-1:0] phy_rd_len, phy_wr_len;
    logic phy_rd_done, phy_wr_done;
    logic [DATA_W-1:0] phy_rd_data;
    logic phy_rd_valid;
    logic phy_wr_ready;
    logic [DATA_W-1:0] phy_wr_data;
    logic phy_wr_valid;
    logic [DATA_W-1:9] rd_fifo_wdata;
    logic rd_fifo_wen;
    logic [DATA_W-1:0] wr_fifo_rdata;
    logic wr_fifo_ren;
    logic mem_error;
   
    t01_ai_mc_bc pipeline_controller (.clk(clk), .rst(rst), .rd_cmd_valid( rd_cmd_valid), .wr_cmd_valid( wr_cmd_valid), .rd_cmd_ready( rd_cmd_ready), .wr_cmd_ready( wr_cmd_ready),.rd_cmd_addr(rd_cmd_addr), .wr_cmd_addr( wr_cmd_addr),.rd_cmd_len(rd_cmd_len), .wr_cmd_len( wr_cmd_len),.phy_rd_start(phy_rd_start), .phy_wr_start( phy_wr_start), .phy_rd_addr( phy_rd_addr), .phy_wr_addr( phy_wr_addr),.phy_rd_len(phy_rd_len), .phy_wr_len( phy_wr_len),.phy_rd_done(phy_rd_done), .phy_wr_done( phy_wr_done),.phy_rd_data(phy_rd_data),.phy_rd_valid(phy_rd_valid),.phy_wr_ready(phy_wr_ready),.phy_wr_data(phy_wr_data),.phy_wr_valid(phy_wr_valid),.rd_fifo_wdata(rd_fifo_wdata),.rd_fifo_wen(rd_fifo_wen),.wr_fifo_rdata(wr_fifo_rdata),.wr_fifo_ren(wr_fifo_ren),.mem_error(mem_error));

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 


    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_mc_bc.vcd"); 
        $dumpvars(0, t01_ai_mc_bc_tb); 

        rd_cmd_addr = 'd10; wr_cmd_addr = 'd11;  
        rd_cmd_len = 'd4; wr_cmd_len = 'd15; 
        phy_rd_data = 'd10; wr_fifo_rdata = 'd32; 
        
        tog_rst(); 
        
        rd_cmd_valid = 1; #1;
        wr_cmd_valid = 1; #1; 
        phy_rd_done = 1; #1; 
        phy_wr_done = 1; #1; 
        phy_rd_valid = 1; #1; 
        phy_wr_ready = 1; #1;
        wr_fifo_ren = 1; #1;   
        // for (int i = 0; i <= 1; i++) begin 
        //     for (int j = 0; j <= 1; j++) begin 
        //         for (int k = 0; k <= 1; k++) begin 
        //             for (int m = 0; m <= 1; m++) begin 
        //                 for (int n = 0; n <= 1; m++) begin 
        //                     for (int s = 0; s <= 1; s++) begin 
        //                         rd_cmd_valid = i[0];
        //                         #1;  
        //                         wr_cmd_valid = j[0];
        //                         #1;  
        //                         phy_rd_done = k[0];
        //                         #1;  
        //                         phy_wr_done = m[0];
        //                         #1;  
        //                         phy_rd_valid = n[0]; 
        //                         #1; 
        //                         phy_wr_ready = s[0]; 
        //                         #1; 
        //                     end 
        //                 end     
        //             end
        //         end
        //     end
        // end 
        #3; 
        $finish; 
    end
endmodule 