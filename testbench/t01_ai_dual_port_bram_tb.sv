`timescale 1ms/1us

module t01_ai_dual_port_bram_tb #(
    parameter int DATA_WIDTH = 16, // bits per feature-map element 
    parameter int DEPTH = 1024, // number of words in the buffer 
    parameter int ADDR_W = $clog2(DEPTH) //
);
    
    logic clk, rst;
    logic [ADDR_W-1:0] read_addr, write_addr;
    logic read_en, write_en;
    logic [DATA_WIDTH-1:0] read_data, write_data; 
    
    t01_ai_dual_port_bram dual_port_bram (.clk(clk), .rst(rst), .read_addr(read_addr), .write_addr(write_addr), .read_en(read_en), .write_en(write_en), .read_data(read_data), .write_data(write_data));

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 


    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_dual_port_bram.vcd"); 
        $dumpvars(0, t01_ai_dual_port_bram_tb); 

        read_addr = 'd101; write_addr = 'd101;  
        write_data = 'd50; 

        tog_rst(); 

        for (int i = 0; i <= 1; i++) begin 
            for (int j = 0; j <= 1; j++) begin 
                write_en = i[0]; #2; 
                read_en = j[0]; #2; 
            end
        end 
        #3; 
        $finish; 
    end
endmodule 