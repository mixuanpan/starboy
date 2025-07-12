`default_nettype none

module lineclear_tb();

    // Clock and reset
    logic clk;
    logic rst;
    logic enable;
    
    // Grid signals
    logic [21:0][9:0][2:0] c_grid;
    logic [21:0][9:0][2:0] n_grid;
    logic done;
    
    // Instantiate DUT
    lineclear dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .c_grid(c_grid),
        .n_grid(n_grid),
        .done(done)
    );
    
    // Clock generation
  // 25 MHz clock → 40 ns period
  always #20 clk = ~clk;

  initial begin
    // dump waveform
    $dumpfile("waves/vgadriver.vcd"); 
    $dumpvars(0, vgadriver_tb);

    //reset pulse
    rst = 1;
    #100;
    rst = 0;



  end



  // finish after a few full frames
  initial begin
    // wait 800 µs ≈ 3 full 25 MHz/640×480@60Hz frames
    #800_000_00;
    $finish;
  end
endmodule