`timescale 1ms/10ps

    typedef enum logic [4:0] {
        IDLE, // reset state 
        READY, // count down to start 
        NEW_BLOCK, // load new block 
        A1, // 011
        A2, 
        B1, // 101
        B2, 
        C1, // 111 
        C2, 
        D0, // 1001
        E1, // 1010 
        E2, 
        E3, 
        E4, 
        F1, // 1110 
        F2, 
        F3, 
        F4, 
        G1, // 10010
        G2, 
        G3, 
        G4, 
        EVAL, // evaluation 
        GAME_OVER // user run out of space 11000 
    } state_t; 

    typedef enum logic [2:0] {
        RIGHT, 
        LEFT, 
        ROR, // ROTATE RIGHT
        ROL, // ROTATE LEFT 
        DOWN
    } move_t; 

    typedef enum logic [2:0] {
        CL0, // BLACK   
        CL1, 
        CL2, 
        CL3, 
        CL4, 
        CL5, 
        CL6, 
        CL7
    } color_t; 

module tetris_fsm_tb;
  logic clk, rst, en, right, left, rr, rl; 
  logic [20:0][9:0][2:0] grid; 
  state_t state; 
  tetris_fsm game (.clk(clk), .rst(rst), .en(en), .right(right), .left(left), .rr(rr), .rl(rl), .grid(grid), .state_tb(state)); 
  
  logic en_nb; 
  logic [2:0] nb; 
  counter newblock (.clk(clk), .nRst_i(!rst), .button_i(en_nb), .current_state_o(nb), .counter_o()); 
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