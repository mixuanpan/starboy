`timescale 1ms/10ps
module ai_wb_reader_tb #(
    parameter int N1 = 1, // first length 
    parameter int N2 = 32, // second length 
    parameter int N3 = 128, // third length 
    parameter int N4 = 1024 // fourth length 
); 
    logic [3:0] d3_b; 
    logic [3:0] d0_b, d1_b, d2_b, d3_w [1:N2/2];  
    logic [3:0] d0_w [1:N3/2]; // weight of dense 0 
    logic [3:0] d1_w [1:N4/2], d2_w [1:N4/2]; 

    ai_wb_reader read_wb (.d0_w(d0_w), .d0_b(), .d1_w(), .d1_b(), .d2_w(), .d2_b(), .d3_w(), .d3_b()); 
    initial begin 
        $dumpfile("waves/ai_wb_reader.vcd"); 
        $dumpvars(0, ai_wb_reader_tb); 

        $display("d0_w\%b", d0_w); 
    #1 $finish; 
    end
endmodule 