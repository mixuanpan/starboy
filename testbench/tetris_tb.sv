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
    rst = 0; 
    en = 1'b0; 
    #2; 
    toggle_rst(); 
    // en = 1'b1; 
    #2; 
    // $display("Grid00=\%b", grid[0][0]);

    for (integer i = 0; i <= 1; i++) begin
      for (integer j = 0; j <= 1; j++) begin
        for (integer k = 0; k <= 1; k++) begin
          for (integer l = 0; l <= 1; l++) begin
            for (integer m = 0; m <= 1; m++) begin
              // set our input signals
              // en = i[0]; 
              right = j[0]; left = k[0]; rr = l[0]; rl = m[0]; 
              #1;
              // display inputs and outputs
              //  right = 1; 
              // left = 1; 
              // rr = 1;
              // rl = 1; 

              // for (int i = 0; i < 22; i++) begin
              // for (int j = 0; j < 10; j++)
              //     row_temp[j] = grid[i][j];
              // $display("Row %0d: %b", i, row_temp);
                $display("Grid after 100ns:");
                for (int i = 0; i < 22; i++) begin
                  for (int j = 0; j < 10; j++) $write("%0d", grid[i][j]);
                  $write("\n");
                end
              $display("en=\%b, right=\%b, left=\%b, rr=\%b, rl=\%b, state=\%b, GRID00=\%b", en, right, left, rr, rl, state, grid[0][0]);
            end
          end
        end
      end
    end


 
// end
  // finish the simulation
  #1; $finish;
  end
endmodule