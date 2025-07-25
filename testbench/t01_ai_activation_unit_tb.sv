`timescale 1ms/1us

module t01_ai_activation_unit_tb #(
    parameter int DATA_WIDTH = 16 // bit width of feature map elements 
);
    logic clk, rst;
    logic [DATA_WIDTH-1:0] in_data, out_data;
    logic in_valid, relu_en, out_valid;

    t01_ai_activation_unit cu_config (.clk(clk), .rst(rst), .in_data(in_data), .out_data(out_data), .in_valid(in_valid), .relu_en(relu_en), .out_valid(out_valid));

    task tog_rst();
      rst = 1; #2; 
      rst = 0; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
        $dumpfile("waves/t01_ai_activation_unit.vcd"); 
        $dumpvars(0, t01_ai_activation_unit_tb); 
        
        in_data = 'd35; 
        tog_rst(); 

    for (int i = 1; i >= 0; i--) begin 
        for (int j = 1; j >= 0; j--) begin 
            in_valid = i[0]; 
            #2;
            relu_en = j[0];
            #2;  
        end
    end 
        #1 $finish; 
    end
endmodule 