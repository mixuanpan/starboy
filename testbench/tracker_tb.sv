`timescale 1ms/10ps

typedef enum logic [2:0] {
  RIGHT, 
  LEFT, 
  ROR, // ROTATE RIGHT
  ROL, // ROTATE LEFT 
  DOWN, 
} MOVE; 

module tracker_tb;
  logic [4:0] state; 
  logic [4:0][4:0][2:0] frame_i, frame_o; 
  logic [2:0] color; 
  tracker track (.state(state), .frame_i(frame_i), .color(color), .frame_o(frame_o));
  
  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/tracker.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, tracker_tb);

    state = A1; 
    frame_i = {4'b0, 4'b0110, 4'b0011, 4'b0}; 
    color = 3'b101; 

    $display("frame_o=/%b", frame_o); 
  // finish the simulation
  #1 $finish;
  end
endmodule