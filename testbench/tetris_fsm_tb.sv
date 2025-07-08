`timescale 1ms/10ps
import tetris_pkg::*; 

module tetris_fsm_tb;
  logic clk, rst, en, right, left, rr, rl; 
  logic [20:0][9:0][2:0] grid; 
  state_t state; 
  tetris_fsm game (.clk(clk), .rst(rst), .en(en), .right(right), .left(left), .rr(rr), .rl(rl), .grid(grid), .state_tb(state)); 
  
  initial clk = 0; 
  always clk = #1 ~clk; 

  task tog_rst(); 
    rst = 1; #1; 
    rst = 0; 
  endtask 

  task tog_en(); 
    en = 1; #1; 
    en = 0; 
  endtask 

  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/tetris_fsm.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, tetris_fsm_tb);
    
    tog_rst(); 

    if (state == IDLE || state == READY) begin 
      tog_en(); 
    end
    
    for (integer i = 0; i <= 1; i++) begin
      for (integer j = 0; j <= 1; j++) begin
        for (integer k = 0; k <= 1; k++) begin
          for (integer l = 0; l <= 1; l++) begin 
        
            right = i; 
            #1;
            
            left = j; 
            #1; 

            rr = k;
            #1; 

            rl = l; 
            #1; 

            $display("state=\%b, grid=\%b", state, grid);
          end 
        end
      end
    end
  // finish the simulation
  #1 $finish;
  end
endmodule