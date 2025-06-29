`timescale 1ms/10ps
module tb;
  logic A, B, Cin, S, Cout;
  fa fulladder (.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/fa.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, tb);
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
  // finish the simulation
  #1 $finish;
  end
endmodule