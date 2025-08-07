`timescale 1ns/100ps

module top_tb ();
    logic clk;
    logic clk_25m;
    logic clk_10k;
    logic rst;
    logic up;
    logic down;
    logic left;
    logic right;
    logic dac_sdi;
    logic dac_cs;
    logic dac_sck;
    logic dac_ld;
    logic [6:0] sevenSeg;
    logic tft_sdo;
    logic tft_sck;
    logic tft_sdi;
    logic tft_dc;
    logic tft_reset;
    logic tft_cs;

    logic [2:0] tftstate;
    logic [2:0] leds;

    logic test;

    logic switch4;

    //mixed j39
    logic J39_b15, J39_c15, J39_b20, J39_e11;

    //right line J39
    logic J39_b10, J39_a14, J39_d13, J39_e12;

    logic J40_m3;

    //right line J40
    logic J40_a15, J40_h2, J40_j4, J40_j3, J40_l4, J40_m4, J40_n4;

    //left line J40
    logic J40_p5, J40_n5, J40_l5, J40_k3, J40_j5;

    // DUT
    top DUT (
        .*
    );

    // Clock Generation
    always begin
        clk_25m = 0;
        #20;
        clk_25m = 1;
        #20;
    end


    integer num_cycles;
    
    // Time-keeping
    initial begin
        num_cycles = 0;
        while (1) begin
            repeat(100000) @(negedge clk_25m);
            num_cycles = num_cycles + 100000;
            $display("%d cycles passed", num_cycles);
        end
        // $display("TIMEOUT!!!!");
        // $finish;
    end


    // Main Testbench process
    initial begin
        $dumpfile("waves/top.vcd"); 
        $dumpvars(0, top_tb);

        // Initialize variables
        rst = 0;
        J39_b15 = 0;
        J39_b20 = 0; 
        // Wait a bit
        #(1);

        // Power-on Reset
        rst = 1;
        repeat (2) @(negedge clk_25m);
        rst = 0;
        repeat (2) @(negedge clk_25m);

        // Start Game
        J39_b20 = 1; @(negedge clk_25m); 
        J39_b20 = 0; #1; 
        J39_b15 = 1;
        repeat (5) @(negedge clk_25m);
        J39_b15 = 0;

        // wait(DUT.extract_start == 1);
        // $display("\nextract_start detected\n");

        // wait(DUT.extract_ready == 1);
        // $display("\nextract_ready detected\n"); 

        // repeat (100) @(negedge clk_25m);
        

        repeat (1300000) @(negedge clk_25m);

        $finish;

    end

endmodule
