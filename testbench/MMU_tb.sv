`timescale 1ns/1ps

module MMU_tb;

// clocks & reset
logic clk;
logic rst;

// logic [63:0] result0, result1, result2, result3, result4, result5, result6, result7, result8, result9, result10, result11, result12, result13, result14, result15,
// west‐column inputs (PEs at (0,0), (1,0), (2,0), (3,0))
logic [31:0] inp_west0, inp_west4, inp_west8, inp_west12;
// north‐row inputs (PEs at (0,0), (0,1), (0,2), (0,3))
logic [31:0] inp_north0, inp_north1, inp_north2, inp_north3;

// done flag
wire done;

// cycle & MAC counters
integer cycle_count;
integer mac_count;

// DUT instantiation with named ports
MMU uut (
.inp_west0 (inp_west0),
.inp_west4 (inp_west4),
.inp_west8 (inp_west8),
.inp_west12 (inp_west12),
.inp_north0 (inp_north0),
.inp_north1 (inp_north1),
.inp_north2 (inp_north2),
.inp_north3 (inp_north3),
.clk (clk),
.rst (rst),

.done (done)
);

// drive west0 & north0
initial begin
#3 inp_west0 = 32'd3; inp_north0 = 32'd12;
#10 inp_west0 = 32'd2; inp_north0 = 32'd8;
#10 inp_west0 = 32'd1; inp_north0 = 32'd4;
#10 inp_west0 = 32'd0; inp_north0 = 32'd0;
#10 inp_west0 = 32'd0; inp_north0 = 32'd0;
#10 inp_west0 = 32'd0; inp_north0 = 32'd0;
#10 inp_west0 = 32'd0; inp_north0 = 32'd0;
end

// drive west4 & north1
initial begin
#3 inp_west4 = 32'd0; inp_north1 = 32'd0;
#10 inp_west4 = 32'd7; inp_north1 = 32'd13;
#10 inp_west4 = 32'd6; inp_north1 = 32'd9;
#10 inp_west4 = 32'd5; inp_north1 = 32'd5;
#10 inp_west4 = 32'd4; inp_north1 = 32'd1;
#10 inp_west4 = 32'd0; inp_north1 = 32'd0;
#10 inp_west4 = 32'd0; inp_north1 = 32'd0;
end

// drive west8 & north2
initial begin
#3 inp_west8 = 32'd0; inp_north2 = 32'd0;
#10 inp_west8 = 32'd0; inp_north2 = 32'd0;
#10 inp_west8 = 32'd11; inp_north2 = 32'd14;
#10 inp_west8 = 32'd10; inp_north2 = 32'd10;
#10 inp_west8 = 32'd9; inp_north2 = 32'd6;
#10 inp_west8 = 32'd8; inp_north2 = 32'd2;
#10 inp_west8 = 32'd0; inp_north2 = 32'd0;
end

// drive west12 & north3
initial begin
#3 inp_west12 = 32'd0; inp_north3 = 32'd0;
#10 inp_west12 = 32'd0; inp_north3 = 32'd0;
#10 inp_west12 = 32'd0; inp_north3 = 32'd0;
#10 inp_west12 = 32'd15; inp_north3 = 32'd15;
#10 inp_west12 = 32'd14; inp_north3 = 32'd11;
#10 inp_west12 = 32'd13; inp_north3 = 32'd7;
#10 inp_west12 = 32'd12; inp_north3 = 32'd3;
end

// reset & clock
initial begin
rst = 1;
clk = 0;
#3 rst = 0;
end

// generate ~10 ns period, 21 edges
initial begin
clk = 0;
forever #41.667 clk =  ~clk;
end

// cycle & MAC counting
initial begin
cycle_count = 0;
mac_count = 0;
end

// on every clock, increment cycle and MAC counters
always_ff @(posedge clk) begin
if (!rst) begin
cycle_count <= cycle_count + 1;
mac_count <= mac_count + 16; // 16 PEs → 16 MACs each cycle
end
end

// when done goes high, print out the stats
initial begin
  wait(done);
$display("Systolic Array Performance");
$display("Latency (cycles) : %0d", cycle_count);
$display("Total MAC operations : %0d", mac_count);
$display("Throughput (MACs/cyc): %0f", mac_count*1.0/cycle_count);
$finish;
end

// waveform dump
initial begin
$dumpfile("waves/MMU.vcd");
$dumpvars(0, MMU_tb);
end

endmodule