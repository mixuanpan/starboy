`timescale 1ms/10ps

// import tetris_pkg::*; 

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


module update_ref_tb;
  logic [3:0] row_i, row_o; 
  logic [4:0] col_i, col_o; 
  logic en; 
  move_t movement; 
  update_ref fulladder (.row_i(row_i), .row_o(row_o), .col_i(col_i), .col_o(col_o), .en(en), .movement(movement));
  initial begin
    $dumpfile("waves/update_ref.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, update_ref_tb);
    
    en = 1'b1; 

    for (integer i = 0; i <= 20; i++) begin
      for (integer j = 0; j <= 9; j++) begin
        for (integer k = 0; k <= 4; k++) begin
        // set our input signals
        row_i = i[3:0]; col_i = j[4:0]; 
        
        if (k == 0) begin 
          #1; 
          movement = RIGHT; 
        end else if (k == 'd1) begin 
          #1; 
          movement = LEFT; 
        end else if (k == 'd2) begin 
          #1; 
          movement = ROR; 
        end else if (k == 'd3) begin 
          #1; 
          movement = ROL; 
        end else begin 
          #1; 
          movement = DOWN; 
        end 
        #1;
        // display inputs and outputs
        $display("row_i=\%b, col_i=\%b, movement=\%b, row_o=\%b, col_o=\%b", row_i, col_i, movement, row_o, col_o);
        end
      end
    end
  // finish the simulation
  #1 $finish;
  end
endmodule