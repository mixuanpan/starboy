`timescale 1ms/1us

module t01_ai_cu_sequencer_tb #(
    parameter int H_WIDTH = 10, // input height bits 
    parameter int W_WIDTH = 10, // input width bits 
    parameter int C_WIDTH = 8, // number of input channels 
    parameter int K_WIDTH = 4, // kernel size bits
    parameter int S_WIDTH = 4, // stride bits

    // derive output dims width at compile time 
    parameter int HOUT_WIDTH = H_WIDTH + 1,
    parameter int WOUT_WIDTH = W_WIDTH + 1 
);
    
    logic clk, rst;
    logic start_decoded;
    logic [H_WIDTH-1:0] in_height;
    logic [W_WIDTH-1:0] in_width;
    logic [C_WIDTH-1:0] in_ch;
    logic [K_WIDTH-1:0] kernel_size;
    logic [S_WIDTH-1:0] stride;
    logic relu_en, pool_en;
    logic [HOUT_WIDTH-1:0] row_cnt;
    logic [WOUT_WIDTH-1:0] col_cnt;
    logic conv_valid, relu_valid, pool_valid;
    logic seq_done;  

    t01_ai_cu_sequencer pipeline_controller (.clk(clk), .rst(rst), .in_height(in_height), .in_width(in_width), .in_ch(in_ch), .kernel_size(kernel_size), .stride(stride), .relu_en(relu_en), .pool_en(pool_en), .row_cnt(row_cnt), .col_cnt(col_cnt), .conv_valid(conv_valid), .relu_valid(relu_valid), .pool_valid(pool_valid), .seq_done(seq_done));

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 

    task tog_start(); 
        start_decoded = 1; #2; 
        start_decoded = 0; 
    endtask

    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_cu_sequencer.vcd"); 
        $dumpvars(0, t01_ai_cu_sequencer_tb); 
        start_decoded = 0; 
        in_height = 'd32; in_width = 'd24;  
        in_ch = 'd4; kernel_size = 'd15; 
        stride = 'd5; 

        tog_rst(); 
        tog_start(); 

        #1; 
        for (int i = 0; i <= 1; i++) begin 
            for (int j = 0; j <= 1; j++) begin 
                relu_en = i[0]; 
                pool_en = j[0];
                #1;  
            end
        end 
        #50; 
        tog_start();
        #3; 
        $finish; 
    end
endmodule 