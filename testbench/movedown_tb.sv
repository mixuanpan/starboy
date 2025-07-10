`timescale 1ms/10ps
module movedown_tb; 
    logic clk, rst; 
    logic [21:0][9:0][2:0] in_arr, out_arr; 
    logic [2:0] state; 
    logic [9:0] display_frame;  
    movedown mdown (.clk(clk), .rst(rst), .input_array(in_arr), .output_array(out_arr), .current_state(state)); 

    logic [659:0] display_arr; 
    assign display_arr = out_arr; 

    initial clk = 0; 
    always clk = #1 ~clk; 

    task tog_rst(); 
        rst = 1; #1; 
        rst = 0; 
    endtask 

    initial begin 
        $dumpfile("waves/movedown.vcd"); 
        $dumpvars(0, movedown_tb); 

        in_arr = 0; 

        // change state 
        for (integer i = 0; i <= 'd6; i++) begin 
            state = i[2:0]; 
            tog_rst();
            #5; 


 
        end


    end
endmodule 