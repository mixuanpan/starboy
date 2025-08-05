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
#1000; // 1000ns = 1us (fast simulation)
onehuzz = 1;
#10; // Short pulse
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
// Main test: reset, start, then play strategically to get line clear
initial begin
 integer piece_num;
 reg [7:0] prev_score;
 
reset = 1;
#50; // Hold reset
reset = 0;
// Pulse start to get into SPAWN state
#20 start_i = 1;
#10 start_i = 0;
$display("=== TETRIS FSM TEST - LINE CLEAR STRATEGY ===\n");
// Print initial state
#10;
 print_display();

prev_score = score;

// Strategic piece placement to fill bottom row
// Piece 1: Place on far left (column 0-1)
$display("=== PIECE 1: Far Left ===");
repeat (10) begin
@(posedge onehuzz);
#50;
 print_display();
end
$display("Moving LEFT multiple times...");
repeat (4) begin
left_i = 1;
#10 left_i = 0;
#100;
end
repeat (10) begin
@(posedge onehuzz);
#50;
 print_display();
end

// Piece 2: Place on far right (column 8-9)
$display("=== PIECE 2: Far Right ===");
repeat (3) begin
@(posedge onehuzz);
#50;
 print_display();
end
$display("Moving RIGHT multiple times...");
repeat (5) begin
right_i = 1;
#10 right_i = 0;
#100;
end
repeat (10) begin
@(posedge onehuzz);
#50;
 print_display();
end

// Piece 3: Place in middle-left (column 2-3)
$display("=== PIECE 3: Middle Left ===");
repeat (3) begin
@(posedge onehuzz);
#50;
 print_display();
end
$display("Moving LEFT...");
repeat (2) begin
left_i = 1;
#10 left_i = 0;
#100;
end
repeat (10) begin
@(posedge onehuzz);
#50;
 print_display();
end

// Piece 4: Place in middle-right (column 6-7)
$display("=== PIECE 4: Middle Right ===");
repeat (3) begin
@(posedge onehuzz);
#50;
 print_display();
end
$display("Moving RIGHT...");
repeat (2) begin
right_i = 1;
#10 right_i = 0;
#100;
end
repeat (10) begin
@(posedge onehuzz);
#50;
 print_display();
end

// Piece 5: Place in center (column 4-5)
$display("=== PIECE 5: Center ===");
repeat (3) begin
@(posedge onehuzz);
#50;
 print_display();
end
// No movement needed for center
repeat (10) begin
@(posedge onehuzz);
#50;
 print_display();
end

// Continue with more pieces to fill gaps and create line clears
for (piece_num = 6; piece_num <= 15; piece_num = piece_num + 1) begin
$display("=== PIECE %0d ===", piece_num);
repeat (3) begin
@(posedge onehuzz);
#50;
 print_display();
end

// Alternate placement strategy
case (piece_num % 4)
0: begin // Far left
$display("Moving to far LEFT...");
repeat (4) begin
left_i = 1;
#10 left_i = 0;
#100;
end
end
1: begin // Far right
$display("Moving to far RIGHT...");
repeat (4) begin
right_i = 1;
#10 right_i = 0;
#100;
end
end
2: begin // Left of center
$display("Moving LEFT of center...");
repeat (1) begin
left_i = 1;
#10 left_i = 0;
#100;
end
end
3: begin // Right of center
$display("Moving RIGHT of center...");
repeat (1) begin
right_i = 1;
#10 right_i = 0;
#100;
end
end
endcase

// Let piece fall and land
repeat (12) begin
@(posedge onehuzz);
#50;
 print_display();
end

// Check for score increase (line clear)
if (score > prev_score) begin
$display("*** LINE CLEAR! Score: %0d -> %0d ***", prev_score, score);
prev_score = score;
end

// Test some rotations occasionally
if (piece_num % 5 == 0) begin
$display("Testing rotation...");
rotate_r = 1;
#10 rotate_r = 0;
#100;
 print_display();
end

// Check for game over
if (gameover) begin
$display("*** GAME OVER ***");
end
end

// Final summary
$display("\n=== FINAL RESULTS ===");
 print_display();
$display("Final Score: %0d", score);
if (score > 0) begin
$display("SUCCESS: Line clear(s) detected!");
end else begin
$display("No line clears detected - may need more pieces or different strategy");
end

$finish;
end

// Monitor state changes by watching key signals
always @(posedge clk) begin
if (gameover) begin
$display("*** GAME OVER at time %0t ***", $time);
end
end

// Monitor score changes
always @(posedge clk) begin
static reg [7:0] last_score = 0;
if (score != last_score && score > 0) begin
$display("*** SCORE CHANGE: %0d -> %0d at time %0t ***", last_score, score, $time);
last_score = score;
end
end

// Print when onehuzz pulses occur
always @(posedge onehuzz) begin
$display("--- DROP TICK at time %0t ---", $time);
end
endmodule
