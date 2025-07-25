module top (
    input  logic clk,
    input  logic clk_48m,
    input  logic clk_10k,
    input  logic rst,
    input  logic up,
    input  logic down,
    input  logic left,
    input  logic right,

    output logic dac_sdi,
    output logic dac_cs,
    output logic dac_sck,
    output logic dac_ld,

    output logic [6:0] sevenSeg,

    input  logic tft_sdo,
    output logic tft_sck,
    output logic tft_sdi,
    output logic tft_dc,
    output logic tft_reset,
    output logic tft_cs,

    output logic [2:0] tftstate,
    output logic [2:0] leds,

    output logic test
);
    // Add your logic here

endmodule
