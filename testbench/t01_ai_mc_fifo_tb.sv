`timescale 1ms/1us

module t01_ai_mc_fifo_tb #(
    parameter int DATA_W = 32, // width of each word
    parameter int DEPTH = 16, // number of entries
    parameter int ADDR_W = $clog2(DEPTH) // bits to index DEPTH 
);
    
    logic clk, rst;
    logic wr_en, rd_en; // asser to engueue/dequeue when not full/not empty 
    logic [DATA_W-1:0] wr_data; // data in 
    logic [DATA_W-1:0] rd_data; // data out 
    logic full, empty; // no more room/no data to read 
    
    t01_ai_mc_fifo fifo (.clk(clk), .rst(rst), .wr_en(wr_en), .rd_en(rd_en), .wr_data(wr_data), .rd_data(rd_data), .full(full), .empty(empty));

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 


    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_mc_fifo.vcd"); 
        $dumpvars(0, t01_ai_mc_fifo_tb); 

        wr_data = 'd444; 
        tog_rst(); 

        for (int i = 0; i <= 1; i++) begin 
            for (int j = 0; j <= 1; j++) begin 
                        wr_en = i[0];
                        #1;  
                        rd_en = j[0];
                        #1;  
            end
        end 
        #6; 
        $finish; 
    end
endmodule 