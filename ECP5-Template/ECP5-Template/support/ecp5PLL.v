module ecp5PLL (
    input in_clk,           // 12 MHz input
    output lcd_clk,         // 48 MHz
    output clk_10kHz,       // 0.01 MHz
    output clk_25MHz,       // 25 MHz
    output locked
);
(* FREQUENCY_PIN_CLKI="12" *)
(* FREQUENCY_PIN_CLKOP="48" *)
(* FREQUENCY_PIN_CLKOS="0.01" *)
(* FREQUENCY_PIN_CLKOS2="25" *)
(* ICP_CURRENT="12" *) 
(* LPF_RESISTOR="8" *) 
(* MFG_ENABLE_FILTEROPAMP="1" *) 
(* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
    .PLLRST_ENA("DISABLED"),
    .INTFB_WAKE("DISABLED"),
    .STDBY_ENABLE("DISABLED"),
    .DPHASE_SOURCE("DISABLED"),
    .OUTDIVIDER_MUXA("DIVA"),
    .OUTDIVIDER_MUXB("DIVB"),
    .OUTDIVIDER_MUXC("DIVC"),
    .OUTDIVIDER_MUXD("DIVD"),
    .CLKI_DIV(1),
    .CLKOP_ENABLE("ENABLED"),
    .CLKOP_DIV(6),
    .CLKOP_CPHASE(2),
    .CLKOP_FPHASE(0),
    .CLKOS_ENABLE("ENABLED"),
    .CLKOS_DIV(30000),
    .CLKOS_CPHASE(5),
    .CLKOS_FPHASE(0),
    .CLKOS2_ENABLE("ENABLED"),
    .CLKOS2_DIV(12),
    .CLKOS2_CPHASE(5),
    .CLKOS2_FPHASE(0),
    .FEEDBK_PATH("CLKOP"),
    .CLKFB_DIV(25)
) pll_i (
    .RST(1'b0),
    .STDBY(1'b0),
    .CLKI(in_clk),
    .CLKOP(lcd_clk),
    .CLKOS(clk_10kHz),
    .CLKOS2(clk_25MHz),
    .CLKFB(lcd_clk),
    .CLKINTFB(),
    .PHASESEL0(1'b0),
    .PHASESEL1(1'b0),
    .PHASEDIR(1'b1),
    .PHASESTEP(1'b1),
    .PHASELOADREG(1'b1),
    .PLLWAKESYNC(1'b0),
    .ENCLKOP(1'b0),
    .LOCK(locked)
);
endmodule
