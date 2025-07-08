`timescale 1ms/10ps
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tracker_tb 
// Description : Testbench of the tracker module 
// 
//
/////////////////////////////////////////////////////////////////


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

module tracker_tb;
  state_t state; 
  logic [4:0][4:0][2:0] frame_i, frame_o; 
  logic [2:0] color; 
  move_t move; 
  logic check, clk, rst, complete; 
  logic [4:0] display_frame; 
  tracker track (.state(state), .frame_i(frame_i), .color(color), .frame_o(frame_o), .move(move), .check_tb(check), .complete(complete));

  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/tracker.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, tracker_tb);
     
    color = 3'b111; 
    frame_i = 0; 

    // A1 
    // state = A1;
    // frame_i[1][3] = color;
    // frame_i[1][2] = color;
    // frame_i[2][2] = color;
    // frame_i[2][1] = color;

    // state = A2; 
    // frame_i[1][1] = color;
    // frame_i[2][1] = color;
    // frame_i[3][2] = color;
    // frame_i[2][2] = color;
 
    // state = B1; 
    // frame_i[1][1] = color;
    // frame_i[1][2] = color;
    // frame_i[2][2] = color;
    // frame_i[2][3] = color;

    // B2
    state = B2; 
    frame_i[2][1] = color;
    frame_i[3][1] = color;
    frame_i[1][2] = color;
    frame_i[2][2] = color;
    
    
    // display the input frame 
      $display("frame_i, movement: \%b", move); 
      $write("row\%0d: ", 0); 
        display_frame[0] = frame_i[0][0][2]; 
        display_frame[1] = frame_i[0][1][2]; 
        display_frame[2] = frame_i[0][2][2]; 
        display_frame[3] = frame_i[0][3][2]; 
        display_frame[4] = frame_i[0][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 1); 
        display_frame[0] = frame_i[1][0][2]; 
        display_frame[1] = frame_i[1][1][2]; 
        display_frame[2] = frame_i[1][2][2]; 
        display_frame[3] = frame_i[1][3][2]; 
        display_frame[4] = frame_i[1][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 2); 
        display_frame[0] = frame_i[2][0][2]; 
        display_frame[1] = frame_i[2][1][2]; 
        display_frame[2] = frame_i[2][2][2]; 
        display_frame[3] = frame_i[2][3][2]; 
        display_frame[4] = frame_i[2][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 3); 
        display_frame[0] = frame_i[3][0][2]; 
        display_frame[1] = frame_i[3][1][2]; 
        display_frame[2] = frame_i[3][2][2]; 
        display_frame[3] = frame_i[3][3][2]; 
        display_frame[4] = frame_i[3][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 4); 
        display_frame[0] = frame_i[4][0][2]; 
        display_frame[1] = frame_i[4][1][2]; 
        display_frame[2] = frame_i[4][2][2]; 
        display_frame[3] = frame_i[4][3][2]; 
        display_frame[4] = frame_i[4][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

    for (int i = 0; i < 5; i++) begin 

      if (i == 0) begin 
        #1; 
        move = RIGHT; 
      end else if (i == 'd1) begin 
        #1; 
        move = LEFT; 
      end else if (i == 'd2) begin 
        #1; 
        move = ROR; 
      end else if (i == 'd3) begin 
        #1; 
        move = ROL; 
      end else begin 
        #1; 
        move = DOWN; 
      end 

      #5; 

      // display the frame 
      $display("frame_o, movement: \%b", move); 
      $write("row\%0d: ", 0); 
        display_frame[0] = frame_o[0][0][2]; 
        display_frame[1] = frame_o[0][1][2]; 
        display_frame[2] = frame_o[0][2][2]; 
        display_frame[3] = frame_o[0][3][2]; 
        display_frame[4] = frame_o[0][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 1); 
        display_frame[0] = frame_o[1][0][2]; 
        display_frame[1] = frame_o[1][1][2]; 
        display_frame[2] = frame_o[1][2][2]; 
        display_frame[3] = frame_o[1][3][2]; 
        display_frame[4] = frame_o[1][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 2); 
        display_frame[0] = frame_o[2][0][2]; 
        display_frame[1] = frame_o[2][1][2]; 
        display_frame[2] = frame_o[2][2][2]; 
        display_frame[3] = frame_o[2][3][2]; 
        display_frame[4] = frame_o[2][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 3); 
        display_frame[0] = frame_o[3][0][2]; 
        display_frame[1] = frame_o[3][1][2]; 
        display_frame[2] = frame_o[3][2][2]; 
        display_frame[3] = frame_o[3][3][2]; 
        display_frame[4] = frame_o[3][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

      $write("row\%0d: ", 4); 
        display_frame[0] = frame_o[4][0][2]; 
        display_frame[1] = frame_o[4][1][2]; 
        display_frame[2] = frame_o[4][2][2]; 
        display_frame[3] = frame_o[4][3][2]; 
        display_frame[4] = frame_o[4][4][2]; 
      $write("\%b", display_frame); 
      $write("\n"); 

    end
  // finish the simulation
  #1 $finish;
  end
endmodule