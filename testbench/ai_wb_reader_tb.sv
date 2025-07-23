`timescale 1ms/10ps
module ai_wb_reader_tb (); 
    logic [3:0] t1, t2, t3, t4;
    ai_wb_reader read_wb (.t1(t1), .t2(t2), .t3(t3), .t4(t4)); 
    initial begin 
        $dumpfile("waves/ai_wb_reader.vcd"); 
        $dumpvars(0, ai_wb_reader_tb); 
        #1; 
        $display("d0_w\%b", t1); 
    #1 $finish; 
    end
endmodule 