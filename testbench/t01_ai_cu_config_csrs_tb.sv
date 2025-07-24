`timescale 1ms/1us

module t01_ai_cu_config_csrs_tb #(
    parameter ADDR_WIDTH = 6, // convers 0x00 - 0x3F 
    parameter DATA_WIDTH = 32
);
    logic clk, rst;
    logic cs;
    logic we;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic [15:0] in_height, in_width, in_ch, out_ch;
    logic [3:0] layer_type, kernel_size, stride;
    logic relu_en, pool_en;
    logic [31:0] addr_ifm_base, addr_wgt_base, addr_ofm_base;

    t01_ai_cu_config_csrs cu_config (.clk(clk), .rst(rst), .cs(cs), .we(we), .addr(addr), .wdata(wdata), .rdata(rdata), .in_height(in_height), .in_width(in_width), .in_ch(in_ch), .out_ch(out_ch), .layer_type(layer_type), .kernel_size(kernel_size), .stride(stride), .relu_en(relu_en), .pool_en(pool_en), .addr_ifm_base(addr_ifm_base), .addr_wgt_base(addr_wgt_base), .addr_ofm_base(addr_ofm_base));

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_cu_config_csrs.vcd"); 
        $dumpvars(0, t01_ai_cu_config_csrs_tb); 
        
        start_decoded = 1'b1; 
        in_height = 'd333; in_width = 'd222;  
        in_ch = 'd44; kernel_size = 'd5; 
        stride = 'd6; 

        tog_rst(); 

    for (int i = 0; i <= 1; i++) begin 
        for (int j = 0; j <= 1; j++) begin 
            relu_en = i[0]; 
            pool_en = j[0]; 
        end
    end 
        #1 $finish; 
    end
endmodule 