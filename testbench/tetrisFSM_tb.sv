`timescale 1ns/1ps
module tetrisFSM_tb;
// Clock & reset
 reg clk;
 reg reset;
// Drop timing - 1Hz signal
 reg onehuzz = 0;
 reg en_newgame = 0;
 reg right_i = 0;
 reg left_i = 0;
 reg start_i = 0;
 reg rotate_r = 0;
 reg rotate_l = 0;
 reg speed_up_i = 0;
// DUT outputs
 wire [19:0][9:0] display_array;
 wire gameover;
 wire [7:0] score;
 wire speed_mode_o;

// Instantiate your FSM
tetrisFSM dut (
 .clk (clk),
 .reset (reset),
 .onehuzz (onehuzz),
 .en_newgame (en_newgame),
 .right_i (right_i),
 .left_i (left_i),
 .start_i (start_i),
 .rotate_r (rotate_r),
 .rotate_l (rotate_l),
 .speed_up_i (speed_up_i),
 .display_array (display_array),
 .gameover (gameover),
 .score (score),
 .speed_mode_o (speed_mode_o)
 );

// Clock: 10 ns period (25MHz would be 40ns, but faster for simulation)
initial clk = 0;
always #5 clk = ~clk;

// Generate 1Hz drop signal (every 1000ns for fast simulation)
// In real hardware this would be every 25M cycles
initial begin
    forever begin
        #1000;  // 1000ns = 1us (fast simulation)
        onehuzz = 1;
        #10;    // Short pulse
        onehuzz = 0;
    end
end

// Waveform dump
initial begin
$dumpfile("waves/tetrisFSM.vcd");
$dumpvars(0, tetrisFSM_tb);
end

// Flatten the packed 20×10 display_array into a 200‑bit vector
 wire [199:0] display_flat;
 genvar gi, gj;
generate
for (gi = 0; gi < 20; gi = gi + 1) begin: ROW
for (gj = 0; gj < 10; gj = gj + 1) begin: COL
// index = gi*10 + gj
assign display_flat[gi*10 + gj] = display_array[gi][gj];
end
end
endgenerate

// Task to print display_flat as a 20×10 grid
task print_display;
 integer row, col, idx;
begin
$display("Time = %0t ns", $time);
for (row = 0; row < 20; row = row + 1) begin
    $write("Row %2d: ", row);
    for (col = 0; col < 10; col = col + 1) begin
        idx = row * 10 + col;
        if (display_flat[idx])
            $write("█");
        else
            $write("·");
    end
    $write("\n");
end
$display("Score: %0d, GameOver: %b", score, gameover);
$display("====================================\n");
end
endtask

// Main test: reset, start, then print periodically to see falling
initial begin
    reset = 1;
    #50;  // Hold reset
    reset = 0;
    
    // Pulse start to get into SPAWN state
    #20 start_i = 1;
    #10 start_i = 0;
    
    $display("=== TETRIS FSM TEST - FALLING PIECE ===\n");
    
    // Print initial state
    #10;
    print_display();
    
    // Wait and print every drop cycle to see piece falling
    repeat (25) begin
        @(posedge onehuzz);  // Wait for drop signal
        #50;  // Give FSM time to process
        print_display();
    end
    
    $display("=== TESTING MOVEMENT ===\n");
    
    // Test left movement
    $display("Moving LEFT...");
    left_i = 1;
    #10 left_i = 0;
    #50 print_display();
    
    // Test right movement  
    $display("Moving RIGHT...");
    right_i = 1;
    #10 right_i = 0;
    #50 print_display();
    
    // Test rotation
    $display("ROTATING...");
    rotate_r = 1;
    #10 rotate_r = 0;
    #50 print_display();
    
    // Wait for piece to land and next to spawn
    repeat (5) begin
        @(posedge onehuzz);
        #50;
        print_display();
    end
    
    $finish;
end

// Monitor state changes by watching key signals
always @(posedge clk) begin
    if (gameover) begin
        $display("*** GAME OVER at time %0t ***", $time);
    end
end

// Print when onehuzz pulses occur
always @(posedge onehuzz) begin
    $display("--- DROP TICK at time %0t ---", $time);
end

endmodule
