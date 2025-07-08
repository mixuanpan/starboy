`timescale 1ms/10ps
typedef enum logic [4:0] {
  IDLE, // reset state 
  READY, // count down to start 
  NEW_BLOCK, // load new block 
  A1, 
  A2, 
  B1, 
  B2, 
  C1, 
  C2, 
  D, 
  E1, 
  E2, 
  E3, 
  E4, 
  F1, 
  F2, 
  F3, 
  F4, 
  G1, 
  G2, 
  G3, 
  G4, 
  EVAL, // evaluation 
  GAMEOVER // user run out of space 
} state_t; 

module tetris_tb;
  logic clk, rst, en, right, left, rr, rl; 
  logic grid [21:0][9:0]; 
  logic [9:0] row_temp; 
  logic [4:0] state; 
  tetris game (.clk(clk), .rst(rst), .en(en), .right(right), .left(left), .down(), .rr(rr), .rl(rl), .count_down(), .state_o(state));
  
  initial clk = 0; 
  always clk = #1 ~clk; 

  task toggle_rst();
    rst = 1; #2; 
    rst = 0; 
  endtask 

  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/tetris.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, tetris_tb);
    // for loop to test all possible inputs
    for (integer i = 0; i <= 1; i++) begin
      for (integer j = 0; j <= 1; j++) begin
        for (integer k = 0; k <= 1; k++) begin
        // set our input signals
        A = i; B = j; Cin = k;
        #1;
        // display inputs and outputs
        $display("A=\%b, B=\%b, Cin=\%b, Cout=\%b, S=\%b", A, B, Cin, Cout, S);
        end
      end
    end


 
// end
  // finish the simulation
  #1; $finish;
  end
endmodule