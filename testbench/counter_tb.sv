`timescale 1ms/10ps
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : counter_tb 
// Description : Testbench of the counter module 
// 
//
/////////////////////////////////////////////////////////////////

typedef enum logic [2:0] {
    BLOCK_L = 3'd0, // A1 
    BLOCK_T = 3'd1, // B1 
    BLOCK_I = 3'd2, // C1
    BLOCK_DOT = 3'd3, // D0 
    BLOCK_SQUARE = 3'd4, // E1 
    BLOCK_CROSS = 3'd5, // F1 
    BLOCK_STEPS = 3'd6 // G1
    // BLOCK_Z = 3'd7
} block_t;

module counter_tb;
  logic clk, nrst, button; 
  logic [2:0] state, counter; 
  counter count (.clk(clk), .nRst_i(nrst), .button_i(button_i), .current_state_o(state), .counter_o(counter));
  
  initial clk = 0; 
  always clk = #1 ~clk; 

  task tog_nRst(); 
    nrst = 0; #1; 
    nrst = 1; 
  endtask 

  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/counter.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, counter_tb);
    
    tog_nRst(); 
    button = 1; 
    #1; 
    button = 0; 
    #2; 
    tog_nRst(); 
    button = 1; 
    #4; 
    button = 0; 
    #1; 
    button = 1; 
    #2; 
    button = 0; 
    #3; 
    button = 1; 
  // finish the simulation
  #1 $finish;
  end
endmodule