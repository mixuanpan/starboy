`timescale 1ms/10ps
module blockgen_tb;

  // DUT interface
  logic [2:0] current_state;
  logic [2:0] display_array [0:21][0:9];

  // instantiate the DUT
  blockgen dut ( .current_state(current_state), .display_array(display_array) );

  initial begin
    $dumpfile("waves/blockgen.vcd");
    $dumpvars(0, blockgen_tb);
  end

  initial begin
    for (int s = 0; s < 7; s++) begin

      current_state = s[2:0];
      #1; 

      $display("\n=== STATE %0d ===", s);

      // ---- ROW 0 ----
      $display("r0: %b%b%b%b%b%b%b%b%b%b",
               display_array[0][0], display_array[0][1],
               display_array[0][2], display_array[0][3],
               display_array[0][4], display_array[0][5],
               display_array[0][6], display_array[0][7],
               display_array[0][8], display_array[0][9]);

      // ---- ROW 1 ----
      $display("r1: %b%b%b%b%b%b%b%b%b%b",
               display_array[1][0], display_array[1][1],
               display_array[1][2], display_array[1][3],
               display_array[1][4], display_array[1][5],
               display_array[1][6], display_array[1][7],
               display_array[1][8], display_array[1][9]);

      // ---- ROW 2 ----
      $display("r2: %b%b%b%b%b%b%b%b%b%b",
               display_array[2][0], display_array[2][1],
               display_array[2][2], display_array[2][3],
               display_array[2][4], display_array[2][5],
               display_array[2][6], display_array[2][7],
               display_array[2][8], display_array[2][9]);

      // ---- ROW 3 ----
      $display("r3: %b%b%b%b%b%b%b%b%b%b",
               display_array[3][0], display_array[3][1],
               display_array[3][2], display_array[3][3],
               display_array[3][4], display_array[3][5],
               display_array[3][6], display_array[3][7],
               display_array[3][8], display_array[3][9]);
    end

    $finish;
  end

endmodule
