`timescale 1ms/10ps 

module blockgen_tb;
 
 logic [2:0] current_state;
 logic [2:0] display_array [0:21][0:9];

 blockgen testing(.current_state(current_state), .display_array(display_array));

    task automatic show;
        foreach (display_array[i,j]) begin
            $write("%b ", display_array[i][j]);
            if (j == 9) $write("\n");
        end
        $write("\n");
    endtask
  
  initial begin
    $dumpfile("waves/blockgen.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, blockgen_tb);
    
    $display("=== blockgen quick-check ===");

    for (current_state = 0; current_state < 7; current_state++) begin
        #0;        // delta-cycle: combinational logic inside blockgen runs
        #0;        // another delta: value on the OUT port reaches TB signal
        // #1;     // <-- you could use a real-time delay instead

        $display("--- state %0d ---", current_state);
        show();
    end

    $finish;
end
  
endmodule