module ecp5wrapper (
    input logic clk,
    input logic rst,

    input logic switch4,

    input logic J39_b15, J39_c15, J39_b20, J39_e11,


    input logic J39_b10, J39_a14, J39_d13, J39_e12,
    
    input logic J40_m3,
    output logic J40_a15, J40_h2, J40_j4, J40_j3, J40_l4, J40_m4, J40_n4,
    output logic J40_p5, J40_n5, J40_l5, J40_k3, J40_j5,

    output logic [2:0] tftstate,
    output logic [2:0] leds,
    
    output logic test
);

    logic hz100;
    logic reset;


    // PLL-generated clocks
    logic clk2;
    logic clk_25m;

    // logic clk_25mHz;
    logic pll_locked;

    ecp5PLL pll_inst (
        .in_clk(clk),
        .VGA_clk(clk_25m),     
        .clk2(clk2),   
        .locked(pll_locked)
    );

    logic [23:0] div;

    always_ff @(posedge clk2)
        div <= div + 1;
    assign hz100 = div[17];

    reset_on_start ros (
        .reset(reset),
        .clk(hz100),
        .manual(rst)
    );

    top top_inst (
        .clk(clk),
        .clk_25m(clk_25m),
        .switch4(switch4),
        .rst(reset), 

        .J39_b15(J39_b15),
        .J39_c15(J39_c15),
        .J39_b20(J39_b20),
        .J39_e11(J39_e11),


        .J39_b10(J39_b10),
        .J39_a14(J39_a14),
        .J39_d13(J39_d13),
        .J39_e12(J39_e12),


        .J40_a15(J40_a15),
        .J40_h2(J40_h2),
        .J40_j4(J40_j4),
        .J40_j3(J40_j3),
        .J40_l4(J40_l4),
        .J40_m4(J40_m4),
        .J40_n4(J40_n4),



        .J40_p5(J40_p5),
        .J40_m3(J40_m3),
        .J40_n5(J40_n5),
        .J40_j5(J40_j5),
        .J40_k3(J40_k3),
        .J40_l5(J40_l5),
        .tftstate(tftstate),
        .leds(leds),
        .test(test)
    );

endmodule

module reset_on_start(
    output logic reset,
    input logic clk,
    input logic manual
);
  logic [2:0] startup = 4;
  assign reset = startup[2] | manual;    // MSB drives the reset signal
  always @ (posedge clk, posedge manual)
    if (manual == 1)
      startup <= 4;             // start with reset low to get a rising edge
    else begin
        case(startup)
            4: startup <= 5;
            5: startup <= 6;
            6: startup <= 7;
            7: startup <= 0;    // pull reset low here
        endcase
    end
endmodule
