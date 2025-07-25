`timescale 1ms/10ps
`define SB_DFF_REG reg Q = 0
// `define SB_DFF_REG reg Q

`define ABC9_ARRIVAL_HX(TIME) `ifdef ICE40_HX (* abc9_arrival=TIME *) `endif
`define ABC9_ARRIVAL_LP(TIME) `ifdef ICE40_LP (* abc9_arrival=TIME *) `endif
`define ABC9_ARRIVAL_U(TIME)  `ifdef ICE40_U (* abc9_arrival=TIME *) `endif

// SiliconBlue IO Cells

module SB_IO (
	inout  PACKAGE_PIN,
	input  LATCH_INPUT_VALUE,
	input  CLOCK_ENABLE,
	input  INPUT_CLK,
	input  OUTPUT_CLK,
	input  OUTPUT_ENABLE,
	input  D_OUT_0,
	input  D_OUT_1,
	output D_IN_0,
	output D_IN_1
);
	parameter [5:0] PIN_TYPE = 6'b000000;
	parameter [0:0] PULLUP = 1'b0;
	parameter [0:0] NEG_TRIGGER = 1'b0;
	parameter IO_STANDARD = "SB_LVCMOS";

`ifndef BLACKBOX
	reg dout, din_0, din_1;
	reg din_q_0, din_q_1;
	reg dout_q_0, dout_q_1;
	reg outena_q;

	// IO tile generates a constant 1'b1 internally if global_cen is not connected
	wire clken_pulled = CLOCK_ENABLE || CLOCK_ENABLE === 1'bz;
	reg  clken_pulled_ri;
	reg  clken_pulled_ro;

	generate if (!NEG_TRIGGER) begin
		always @(posedge INPUT_CLK)                       clken_pulled_ri <= clken_pulled;
		always @(posedge INPUT_CLK)  if (clken_pulled)    din_q_0         <= PACKAGE_PIN;
		always @(negedge INPUT_CLK)  if (clken_pulled_ri) din_q_1         <= PACKAGE_PIN;
		always @(posedge OUTPUT_CLK)                      clken_pulled_ro <= clken_pulled;
		always @(posedge OUTPUT_CLK) if (clken_pulled)    dout_q_0        <= D_OUT_0;
		always @(negedge OUTPUT_CLK) if (clken_pulled_ro) dout_q_1        <= D_OUT_1;
		always @(posedge OUTPUT_CLK) if (clken_pulled)    outena_q        <= OUTPUT_ENABLE;
	end else begin
		always @(negedge INPUT_CLK)                       clken_pulled_ri <= clken_pulled;
		always @(negedge INPUT_CLK)  if (clken_pulled)    din_q_0         <= PACKAGE_PIN;
		always @(posedge INPUT_CLK)  if (clken_pulled_ri) din_q_1         <= PACKAGE_PIN;
		always @(negedge OUTPUT_CLK)                      clken_pulled_ro <= clken_pulled;
		always @(negedge OUTPUT_CLK) if (clken_pulled)    dout_q_0        <= D_OUT_0;
		always @(posedge OUTPUT_CLK) if (clken_pulled_ro) dout_q_1        <= D_OUT_1;
		always @(negedge OUTPUT_CLK) if (clken_pulled)    outena_q        <= OUTPUT_ENABLE;
	end endgenerate

	always @* begin
		if (!PIN_TYPE[1] || !LATCH_INPUT_VALUE)
			din_0 = PIN_TYPE[0] ? PACKAGE_PIN : din_q_0;
		din_1 = din_q_1;
	end

	// work around simulation glitches on dout in DDR mode
	reg outclk_delayed_1;
	reg outclk_delayed_2;
	always @* outclk_delayed_1 <= OUTPUT_CLK;
	always @* outclk_delayed_2 <= outclk_delayed_1;

	always @* begin
		if (PIN_TYPE[3])
			dout = PIN_TYPE[2] ? !dout_q_0 : D_OUT_0;
		else
			dout = (outclk_delayed_2 ^ NEG_TRIGGER) || PIN_TYPE[2] ? dout_q_0 : dout_q_1;
	end

	assign D_IN_0 = din_0, D_IN_1 = din_1;

	generate
		if (PIN_TYPE[5:4] == 2'b01) assign PACKAGE_PIN = dout;
		if (PIN_TYPE[5:4] == 2'b10) assign PACKAGE_PIN = OUTPUT_ENABLE ? dout : 1'bz;
		if (PIN_TYPE[5:4] == 2'b11) assign PACKAGE_PIN = outena_q ? dout : 1'bz;
	endgenerate
`endif
endmodule

module SB_GB_IO (
	inout  PACKAGE_PIN,
	output GLOBAL_BUFFER_OUTPUT,
	input  LATCH_INPUT_VALUE,
	input  CLOCK_ENABLE,
	input  INPUT_CLK,
	input  OUTPUT_CLK,
	input  OUTPUT_ENABLE,
	input  D_OUT_0,
	input  D_OUT_1,
	output D_IN_0,
	output D_IN_1
);
	parameter [5:0] PIN_TYPE = 6'b000000;
	parameter [0:0] PULLUP = 1'b0;
	parameter [0:0] NEG_TRIGGER = 1'b0;
	parameter IO_STANDARD = "SB_LVCMOS";

	assign GLOBAL_BUFFER_OUTPUT = PACKAGE_PIN;

	SB_IO #(
		.PIN_TYPE(PIN_TYPE),
		.PULLUP(PULLUP),
		.NEG_TRIGGER(NEG_TRIGGER),
		.IO_STANDARD(IO_STANDARD)
	) IO (
		.PACKAGE_PIN(PACKAGE_PIN),
		.LATCH_INPUT_VALUE(LATCH_INPUT_VALUE),
		.CLOCK_ENABLE(CLOCK_ENABLE),
		.INPUT_CLK(INPUT_CLK),
		.OUTPUT_CLK(OUTPUT_CLK),
		.OUTPUT_ENABLE(OUTPUT_ENABLE),
		.D_OUT_0(D_OUT_0),
		.D_OUT_1(D_OUT_1),
		.D_IN_0(D_IN_0),
		.D_IN_1(D_IN_1)
	);
endmodule

module SB_GB (
	input  USER_SIGNAL_TO_GLOBAL_BUFFER,
	output GLOBAL_BUFFER_OUTPUT
);
	assign GLOBAL_BUFFER_OUTPUT = USER_SIGNAL_TO_GLOBAL_BUFFER;
endmodule

// SiliconBlue Logic Cells

(* lib_whitebox *)
module SB_LUT4 (output O, input I0, I1, I2, I3);
	parameter [15:0] LUT_INIT = 0;
	wire [7:0] s3 = I3 ? LUT_INIT[15:8] : LUT_INIT[7:0];
	wire [3:0] s2 = I2 ?       s3[ 7:4] :       s3[3:0];
	wire [1:0] s1 = I1 ?       s2[ 3:2] :       s2[1:0];
	assign #0.00000730 O = I0 ? s1[1] : s1[0];
endmodule

(* lib_whitebox *)
module SB_CARRY (output CO, input I0, I1, CI);
	assign CO = (I0 && I1) || ((I0 || I1) && CI);
endmodule

// Max delay from: https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L90
//                 https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L90
//                 https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L102

// Positive Edge SiliconBlue FF Cells

module SB_DFF (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C)
		Q <= #0.00000541 Dd;
endmodule

module SB_DFFE (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C)
		if (E)
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFSR (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C)
		if (R)
			Q <= #0.00000541 0;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFR (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C, posedge R)
		if (R)
			Q <= #0.00000541 0;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFSS (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C)
		if (S)
			Q <= #0.00000541 1;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFS (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C, posedge S)
		if (S)
			Q <= #0.00000541 1;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFESR (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C)
		if (E) begin
			if (R)
				Q <= #0.00000541 0;
			else
				Q <= #0.00000541 Dd;
		end
endmodule

module SB_DFFER (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C, posedge R)
		if (R)
			Q <= #0.00000541 0;
		else if (E)
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFESS (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C)
		if (E) begin
			if (S)
				Q <= #0.00000541 1;
			else
				Q <= #0.00000541 Dd;
		end
endmodule

module SB_DFFES (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(posedge C, posedge S)
		if (S)
			Q <= #0.00000541 1;
		else if (E)
			Q <= #0.00000541 Dd;
endmodule

// Negative Edge SiliconBlue FF Cells

module SB_DFFN (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C)
		Q <= #0.00000541 Dd;
endmodule

module SB_DFFNE (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C)
		if (E)
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFNSR (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C)
		if (R)
			Q <= #0.00000541 0;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFRN (
        output `SB_DFF_REG,
        input C, R, D
);
        always @(posedge C, negedge R)
                if (~R)
                        Q <= #0.00000541 0;
                else
                        Q <= D;
endmodule

module SB_DFFNR (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C, posedge R)
		if (R)
			Q <= #0.00000541 0;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFNSS (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C)
		if (S)
			Q <= #0.00000541 1;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFNS (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C, posedge S)
		if (S)
			Q <= #0.00000541 1;
		else
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFNESR (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C)
		if (E) begin
			if (R)
				Q <= #0.00000541 0;
			else
				Q <= #0.00000541 Dd;
		end
endmodule

module SB_DFFNER (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, R, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C, posedge R)
		if (R)
			Q <= #0.00000541 0;
		else if (E)
			Q <= #0.00000541 Dd;
endmodule

module SB_DFFNESS (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C)
		if (E) begin
			if (S)
				Q <= #0.00000541 1;
			else
				Q <= #0.00000541 Dd;
		end
endmodule

module SB_DFFNES (
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output `SB_DFF_REG,
	input C, E, S, D
);
	wire Dd;
	assign #1.1 Dd = D;
	always @(negedge C, posedge S)
		if (S)
			Q <= #0.00000541 1;
		else if (E)
			Q <= #0.00000541 Dd;
endmodule

// SiliconBlue RAM Cells

module SB_RAM40_4K (
	output [15:0] RDATA,
	input         RCLK, RCLKE, RE,
	input  [10:0] RADDR,
	input         WCLK, WCLKE, WE,
	input  [10:0] WADDR,
	input  [15:0] MASK, WDATA
);
	// MODE 0:  256 x 16
	// MODE 1:  512 x 8
	// MODE 2: 1024 x 4
	// MODE 3: 2048 x 2
	parameter WRITE_MODE = 0;
	parameter READ_MODE = 0;

	parameter INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

	parameter INIT_FILE = "";

`ifndef BLACKBOX
	wire [15:0] WMASK_I;
	wire [15:0] RMASK_I;

	reg  [15:0] RDATA_I;
	wire [15:0] WDATA_I;

	generate
		case (WRITE_MODE)
			0: assign WMASK_I = MASK;

			1: assign WMASK_I = WADDR[   8] == 0 ? 16'b 1010_1010_1010_1010 :
			                    WADDR[   8] == 1 ? 16'b 0101_0101_0101_0101 : 16'bx;

			2: assign WMASK_I = WADDR[ 9:8] == 0 ? 16'b 1110_1110_1110_1110 :
			                    WADDR[ 9:8] == 1 ? 16'b 1101_1101_1101_1101 :
			                    WADDR[ 9:8] == 2 ? 16'b 1011_1011_1011_1011 :
			                    WADDR[ 9:8] == 3 ? 16'b 0111_0111_0111_0111 : 16'bx;

			3: assign WMASK_I = WADDR[10:8] == 0 ? 16'b 1111_1110_1111_1110 :
			                    WADDR[10:8] == 1 ? 16'b 1111_1101_1111_1101 :
			                    WADDR[10:8] == 2 ? 16'b 1111_1011_1111_1011 :
			                    WADDR[10:8] == 3 ? 16'b 1111_0111_1111_0111 :
			                    WADDR[10:8] == 4 ? 16'b 1110_1111_1110_1111 :
			                    WADDR[10:8] == 5 ? 16'b 1101_1111_1101_1111 :
			                    WADDR[10:8] == 6 ? 16'b 1011_1111_1011_1111 :
			                    WADDR[10:8] == 7 ? 16'b 0111_1111_0111_1111 : 16'bx;
		endcase

		case (READ_MODE)
			0: assign RMASK_I = 16'b 0000_0000_0000_0000;

			1: assign RMASK_I = RADDR[   8] == 0 ? 16'b 1010_1010_1010_1010 :
			                    RADDR[   8] == 1 ? 16'b 0101_0101_0101_0101 : 16'bx;

			2: assign RMASK_I = RADDR[ 9:8] == 0 ? 16'b 1110_1110_1110_1110 :
			                    RADDR[ 9:8] == 1 ? 16'b 1101_1101_1101_1101 :
			                    RADDR[ 9:8] == 2 ? 16'b 1011_1011_1011_1011 :
			                    RADDR[ 9:8] == 3 ? 16'b 0111_0111_0111_0111 : 16'bx;

			3: assign RMASK_I = RADDR[10:8] == 0 ? 16'b 1111_1110_1111_1110 :
			                    RADDR[10:8] == 1 ? 16'b 1111_1101_1111_1101 :
			                    RADDR[10:8] == 2 ? 16'b 1111_1011_1111_1011 :
			                    RADDR[10:8] == 3 ? 16'b 1111_0111_1111_0111 :
			                    RADDR[10:8] == 4 ? 16'b 1110_1111_1110_1111 :
			                    RADDR[10:8] == 5 ? 16'b 1101_1111_1101_1111 :
			                    RADDR[10:8] == 6 ? 16'b 1011_1111_1011_1111 :
			                    RADDR[10:8] == 7 ? 16'b 0111_1111_0111_1111 : 16'bx;
		endcase

		case (WRITE_MODE)
			0: assign WDATA_I = WDATA;

			1: assign WDATA_I = {WDATA[14], WDATA[14], WDATA[12], WDATA[12],
			                     WDATA[10], WDATA[10], WDATA[ 8], WDATA[ 8],
			                     WDATA[ 6], WDATA[ 6], WDATA[ 4], WDATA[ 4],
			                     WDATA[ 2], WDATA[ 2], WDATA[ 0], WDATA[ 0]};

			2: assign WDATA_I = {WDATA[13], WDATA[13], WDATA[13], WDATA[13],
			                     WDATA[ 9], WDATA[ 9], WDATA[ 9], WDATA[ 9],
			                     WDATA[ 5], WDATA[ 5], WDATA[ 5], WDATA[ 5],
			                     WDATA[ 1], WDATA[ 1], WDATA[ 1], WDATA[ 1]};

			3: assign WDATA_I = {WDATA[11], WDATA[11], WDATA[11], WDATA[11],
			                     WDATA[11], WDATA[11], WDATA[11], WDATA[11],
			                     WDATA[ 3], WDATA[ 3], WDATA[ 3], WDATA[ 3],
			                     WDATA[ 3], WDATA[ 3], WDATA[ 3], WDATA[ 3]};
		endcase

		case (READ_MODE)
			0: assign RDATA = RDATA_I;
			1: assign RDATA = {1'b0, |RDATA_I[15:14], 1'b0, |RDATA_I[13:12], 1'b0, |RDATA_I[11:10], 1'b0, |RDATA_I[ 9: 8],
			                   1'b0, |RDATA_I[ 7: 6], 1'b0, |RDATA_I[ 5: 4], 1'b0, |RDATA_I[ 3: 2], 1'b0, |RDATA_I[ 1: 0]};
			2: assign RDATA = {2'b0, |RDATA_I[15:12], 3'b0, |RDATA_I[11: 8], 3'b0, |RDATA_I[ 7: 4], 3'b0, |RDATA_I[ 3: 0], 1'b0};
			3: assign RDATA = {4'b0, |RDATA_I[15: 8], 7'b0, |RDATA_I[ 7: 0], 3'b0};
		endcase
	endgenerate

	integer i;
	reg [15:0] memory [0:255];

	initial begin
		if (INIT_FILE != "")
			$readmemh(INIT_FILE, memory);
		else
			for (i=0; i<16; i=i+1) begin
				memory[ 0*16 + i] = INIT_0[16*i +: 16];
				memory[ 1*16 + i] = INIT_1[16*i +: 16];
				memory[ 2*16 + i] = INIT_2[16*i +: 16];
				memory[ 3*16 + i] = INIT_3[16*i +: 16];
				memory[ 4*16 + i] = INIT_4[16*i +: 16];
				memory[ 5*16 + i] = INIT_5[16*i +: 16];
				memory[ 6*16 + i] = INIT_6[16*i +: 16];
				memory[ 7*16 + i] = INIT_7[16*i +: 16];
				memory[ 8*16 + i] = INIT_8[16*i +: 16];
				memory[ 9*16 + i] = INIT_9[16*i +: 16];
				memory[10*16 + i] = INIT_A[16*i +: 16];
				memory[11*16 + i] = INIT_B[16*i +: 16];
				memory[12*16 + i] = INIT_C[16*i +: 16];
				memory[13*16 + i] = INIT_D[16*i +: 16];
				memory[14*16 + i] = INIT_E[16*i +: 16];
				memory[15*16 + i] = INIT_F[16*i +: 16];
			end
	end

	always @(posedge WCLK) begin
		if (WE && WCLKE) begin
			if (!WMASK_I[ 0]) memory[WADDR[7:0]][ 0] <= WDATA_I[ 0];
			if (!WMASK_I[ 1]) memory[WADDR[7:0]][ 1] <= WDATA_I[ 1];
			if (!WMASK_I[ 2]) memory[WADDR[7:0]][ 2] <= WDATA_I[ 2];
			if (!WMASK_I[ 3]) memory[WADDR[7:0]][ 3] <= WDATA_I[ 3];
			if (!WMASK_I[ 4]) memory[WADDR[7:0]][ 4] <= WDATA_I[ 4];
			if (!WMASK_I[ 5]) memory[WADDR[7:0]][ 5] <= WDATA_I[ 5];
			if (!WMASK_I[ 6]) memory[WADDR[7:0]][ 6] <= WDATA_I[ 6];
			if (!WMASK_I[ 7]) memory[WADDR[7:0]][ 7] <= WDATA_I[ 7];
			if (!WMASK_I[ 8]) memory[WADDR[7:0]][ 8] <= WDATA_I[ 8];
			if (!WMASK_I[ 9]) memory[WADDR[7:0]][ 9] <= WDATA_I[ 9];
			if (!WMASK_I[10]) memory[WADDR[7:0]][10] <= WDATA_I[10];
			if (!WMASK_I[11]) memory[WADDR[7:0]][11] <= WDATA_I[11];
			if (!WMASK_I[12]) memory[WADDR[7:0]][12] <= WDATA_I[12];
			if (!WMASK_I[13]) memory[WADDR[7:0]][13] <= WDATA_I[13];
			if (!WMASK_I[14]) memory[WADDR[7:0]][14] <= WDATA_I[14];
			if (!WMASK_I[15]) memory[WADDR[7:0]][15] <= WDATA_I[15];
		end
	end

	always @(posedge RCLK) begin
		if (RE && RCLKE) begin
			RDATA_I <= memory[RADDR[7:0]] & ~RMASK_I;
		end
	end
`endif
`ifdef ICE40_HX
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L343-L358
		$setup(MASK, posedge WCLK &&& WE && WCLKE, 274);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L359-L369
		$setup(RADDR, posedge RCLK &&& RE && RCLKE, 203);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L370
		$setup(RCLKE, posedge RCLK, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L371
		$setup(RE, posedge RCLK, 98);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L372-L382
		$setup(WADDR, posedge WCLK &&& WE && WCLKE, 224);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L383
		$setup(WCLKE, posedge WCLK, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L384-L399
		$setup(WDATA, posedge WCLK &&& WE && WCLKE, 161);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L400
		$setup(WE, posedge WCLK, 133);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L401
		(posedge RCLK => (RDATA : 16'bx)) = 2146;
	endspecify
`endif
`ifdef ICE40_LP
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L343-L358
		$setup(MASK, posedge WCLK &&& WE && WCLKE, 403);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L359-L369
		$setup(RADDR, posedge RCLK &&& RE && RCLKE, 300);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L370
		$setup(RCLKE, posedge RCLK, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L371
		$setup(RE, posedge RCLK, 145);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L372-L382
		$setup(WADDR, posedge WCLK &&& WE && WCLKE, 331);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L383
		$setup(WCLKE, posedge WCLK, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L384-L399
		$setup(WDATA, posedge WCLK &&& WE && WCLKE, 238);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L400
		$setup(WE, posedge WCLK, 196);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L401
		(posedge RCLK => (RDATA : 16'bx)) = 3163;
	endspecify
`endif
`ifdef ICE40_U
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12968-12983
		$setup(MASK, posedge WCLK &&& WE && WCLKE, 517);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12984-12994
		$setup(RADDR, posedge RCLK &&& RE && RCLKE, 384);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12995
		$setup(RCLKE, posedge RCLK, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12996
		$setup(RE, posedge RCLK, 185);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12997-13007
		$setup(WADDR, posedge WCLK &&& WE && WCLKE, 424);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13008
		$setup(WCLKE, posedge WCLK, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13009-13024
		$setup(WDATA, posedge WCLK &&& WE && WCLKE, 305);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13025
		$setup(WE, posedge WCLK, 252);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13026
		(posedge RCLK => (RDATA : 16'bx)) = 1179;
	endspecify
`endif
endmodule

module SB_RAM40_4KNR (
	output [15:0] RDATA,
	input         RCLKN, RCLKE, RE,
	input  [10:0] RADDR,
	input         WCLK, WCLKE, WE,
	input  [10:0] WADDR,
	input  [15:0] MASK, WDATA
);
	parameter WRITE_MODE = 0;
	parameter READ_MODE = 0;

	parameter INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

	parameter INIT_FILE = "";

	SB_RAM40_4K #(
		.WRITE_MODE(WRITE_MODE),
		.READ_MODE (READ_MODE ),
		.INIT_0    (INIT_0    ),
		.INIT_1    (INIT_1    ),
		.INIT_2    (INIT_2    ),
		.INIT_3    (INIT_3    ),
		.INIT_4    (INIT_4    ),
		.INIT_5    (INIT_5    ),
		.INIT_6    (INIT_6    ),
		.INIT_7    (INIT_7    ),
		.INIT_8    (INIT_8    ),
		.INIT_9    (INIT_9    ),
		.INIT_A    (INIT_A    ),
		.INIT_B    (INIT_B    ),
		.INIT_C    (INIT_C    ),
		.INIT_D    (INIT_D    ),
		.INIT_E    (INIT_E    ),
		.INIT_F    (INIT_F    ),
		.INIT_FILE (INIT_FILE )
	) RAM (
		.RDATA(RDATA),
		.RCLK (~RCLKN),
		.RCLKE(RCLKE),
		.RE   (RE   ),
		.RADDR(RADDR),
		.WCLK (WCLK ),
		.WCLKE(WCLKE),
		.WE   (WE   ),
		.WADDR(WADDR),
		.MASK (MASK ),
		.WDATA(WDATA)
	);
`ifdef ICE40_HX
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L343-L358
		$setup(MASK, posedge WCLK &&& WE && WCLKE, 274);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L359-L369
		$setup(RADDR, posedge RCLKN &&& RE && RCLKE, 203);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L370
		$setup(RCLKE, posedge RCLKN, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L371
		$setup(RE, posedge RCLKN, 98);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L372-L382
		$setup(WADDR, posedge WCLK &&& WE && WCLKE, 224);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L383
		$setup(WCLKE, posedge WCLK, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L384-L399
		$setup(WDATA, posedge WCLK &&& WE && WCLKE, 161);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L400
		$setup(WE, posedge WCLK, 133);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L401
		(posedge RCLKN => (RDATA : 16'bx)) = 2146;
	endspecify
`endif
`ifdef ICE40_LP
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L343-L358
		$setup(MASK, posedge WCLK &&& WE && WCLKE, 403);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L359-L369
		$setup(RADDR, posedge RCLKN &&& RE && RCLKE, 300);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L370
		$setup(RCLKE, posedge RCLKN, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L371
		$setup(RE, posedge RCLKN, 145);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L372-L382
		$setup(WADDR, posedge WCLK &&& WE && WCLKE, 331);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L383
		$setup(WCLKE, posedge WCLK, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L384-L399
		$setup(WDATA, posedge WCLK &&& WE && WCLKE, 238);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L400
		$setup(WE, posedge WCLK, 196);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L401
		(posedge RCLKN => (RDATA : 16'bx)) = 3163;
	endspecify
`endif
`ifdef ICE40_U
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12968-12983
		$setup(MASK, posedge WCLK &&& WE && WCLKE, 517);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12984-12994
		$setup(RADDR, posedge RCLKN &&& RE && RCLKE, 384);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12995
		$setup(RCLKE, posedge RCLKN, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12996
		$setup(RE, posedge RCLKN, 185);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12997-13007
		$setup(WADDR, posedge WCLK &&& WE && WCLKE, 424);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13008
		$setup(WCLKE, posedge WCLK, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13009-13024
		$setup(WDATA, posedge WCLK &&& WE && WCLKE, 305);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13025
		$setup(WE, posedge WCLK, 252);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13026
		(posedge RCLKN => (RDATA : 16'bx)) = 1179;
	endspecify
`endif
endmodule

module SB_RAM40_4KNW (
	output [15:0] RDATA,
	input         RCLK, RCLKE, RE,
	input  [10:0] RADDR,
	input         WCLKN, WCLKE, WE,
	input  [10:0] WADDR,
	input  [15:0] MASK, WDATA
);
	parameter WRITE_MODE = 0;
	parameter READ_MODE = 0;

	parameter INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

	parameter INIT_FILE = "";

	SB_RAM40_4K #(
		.WRITE_MODE(WRITE_MODE),
		.READ_MODE (READ_MODE ),
		.INIT_0    (INIT_0    ),
		.INIT_1    (INIT_1    ),
		.INIT_2    (INIT_2    ),
		.INIT_3    (INIT_3    ),
		.INIT_4    (INIT_4    ),
		.INIT_5    (INIT_5    ),
		.INIT_6    (INIT_6    ),
		.INIT_7    (INIT_7    ),
		.INIT_8    (INIT_8    ),
		.INIT_9    (INIT_9    ),
		.INIT_A    (INIT_A    ),
		.INIT_B    (INIT_B    ),
		.INIT_C    (INIT_C    ),
		.INIT_D    (INIT_D    ),
		.INIT_E    (INIT_E    ),
		.INIT_F    (INIT_F    ),
		.INIT_FILE (INIT_FILE )
	) RAM (
		.RDATA(RDATA),
		.RCLK (RCLK ),
		.RCLKE(RCLKE),
		.RE   (RE   ),
		.RADDR(RADDR),
		.WCLK (~WCLKN),
		.WCLKE(WCLKE),
		.WE   (WE   ),
		.WADDR(WADDR),
		.MASK (MASK ),
		.WDATA(WDATA)
	);
`ifdef ICE40_HX
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L343-L358
		$setup(MASK, posedge WCLKN &&& WE && WCLKE, 274);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L359-L369
		$setup(RADDR, posedge RCLK &&& RE && RCLKE, 203);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L370
		$setup(RCLKE, posedge RCLK, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L371
		$setup(RE, posedge RCLK, 98);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L372-L382
		$setup(WADDR, posedge WCLKN &&& WE && WCLKE, 224);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L383
		$setup(WCLKE, posedge WCLKN, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L384-L399
		$setup(WDATA, posedge WCLKN &&& WE && WCLKE, 161);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L400
		$setup(WE, posedge WCLKN, 133);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L401
		(posedge RCLK => (RDATA : 16'bx)) = 2146;
	endspecify
`endif
`ifdef ICE40_LP
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L343-L358
		$setup(MASK, posedge WCLKN &&& WE && WCLKE, 403);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L359-L369
		$setup(RADDR, posedge RCLK &&& RE && RCLKE, 300);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L370
		$setup(RCLKE, posedge RCLK, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L371
		$setup(RE, posedge RCLK, 145);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L372-L382
		$setup(WADDR, posedge WCLKN &&& WE && WCLKE, 331);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L383
		$setup(WCLKE, posedge WCLKN, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L384-L399
		$setup(WDATA, posedge WCLKN &&& WE && WCLKE, 238);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L400
		$setup(WE, posedge WCLKN, 196);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L401
		(posedge RCLK => (RDATA : 16'bx)) = 3163;
	endspecify
`endif
`ifdef ICE40_U
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12968-12983
		$setup(MASK, posedge WCLKN &&& WE && WCLKE, 517);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12984-12994
		$setup(RADDR, posedge RCLK &&& RE && RCLKE, 384);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12995
		$setup(RCLKE, posedge RCLK, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12996
		$setup(RE, posedge RCLK, 185);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12997-13007
		$setup(WADDR, posedge WCLKN &&& WE && WCLKE, 424);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13008
		$setup(WCLKE, posedge WCLKN, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13009-13024
		$setup(WDATA, posedge WCLKN &&& WE && WCLKE, 305);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13025
		$setup(WE, posedge WCLKN, 252);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13026
		(posedge RCLK => (RDATA : 16'bx)) = 1179;
	endspecify
`endif
endmodule

module SB_RAM40_4KNRNW (
	output [15:0] RDATA,
	input         RCLKN, RCLKE, RE,
	input  [10:0] RADDR,
	input         WCLKN, WCLKE, WE,
	input  [10:0] WADDR,
	input  [15:0] MASK, WDATA
);
	parameter WRITE_MODE = 0;
	parameter READ_MODE = 0;

	parameter INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

	parameter INIT_FILE = "";

	SB_RAM40_4K #(
		.WRITE_MODE(WRITE_MODE),
		.READ_MODE (READ_MODE ),
		.INIT_0    (INIT_0    ),
		.INIT_1    (INIT_1    ),
		.INIT_2    (INIT_2    ),
		.INIT_3    (INIT_3    ),
		.INIT_4    (INIT_4    ),
		.INIT_5    (INIT_5    ),
		.INIT_6    (INIT_6    ),
		.INIT_7    (INIT_7    ),
		.INIT_8    (INIT_8    ),
		.INIT_9    (INIT_9    ),
		.INIT_A    (INIT_A    ),
		.INIT_B    (INIT_B    ),
		.INIT_C    (INIT_C    ),
		.INIT_D    (INIT_D    ),
		.INIT_E    (INIT_E    ),
		.INIT_F    (INIT_F    ),
		.INIT_FILE (INIT_FILE )
	) RAM (
		.RDATA(RDATA),
		.RCLK (~RCLKN),
		.RCLKE(RCLKE),
		.RE   (RE   ),
		.RADDR(RADDR),
		.WCLK (~WCLKN),
		.WCLKE(WCLKE),
		.WE   (WE   ),
		.WADDR(WADDR),
		.MASK (MASK ),
		.WDATA(WDATA)
	);
`ifdef ICE40_HX
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L343-L358
		$setup(MASK, posedge WCLKN &&& WE && WCLKE, 274);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L359-L369
		$setup(RADDR, posedge RCLKN &&& RE && RCLKE, 203);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L370
		$setup(RCLKE, posedge RCLKN, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L371
		$setup(RE, posedge RCLKN, 98);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L372-L382
		$setup(WADDR, posedge WCLKN &&& WE && WCLKE, 224);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L383
		$setup(WCLKE, posedge WCLKN, 267);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L384-L399
		$setup(WDATA, posedge WCLKN &&& WE && WCLKE, 161);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L400
		$setup(WE, posedge WCLKN, 133);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_hx1k.txt#L401
		(posedge RCLKN => (RDATA : 16'bx)) = 2146;
	endspecify
`endif
`ifdef ICE40_LP
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L343-L358
		$setup(MASK, posedge WCLKN &&& WE && WCLKE, 403);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L359-L369
		$setup(RADDR, posedge RCLKN &&& RE && RCLKE, 300);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L370
		$setup(RCLKE, posedge RCLKN, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L371
		$setup(RE, posedge RCLKN, 145);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L372-L382
		$setup(WADDR, posedge WCLKN &&& WE && WCLKE, 331);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L383
		$setup(WCLKE, posedge WCLKN, 393);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L384-L399
		$setup(WDATA, posedge WCLKN &&& WE && WCLKE, 238);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L400
		$setup(WE, posedge WCLKN, 196);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_lp1k.txt#L401
		(posedge RCLKN => (RDATA : 16'bx)) = 3163;
	endspecify
`endif
`ifdef ICE40_U
	specify
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12968-12983
		$setup(MASK, posedge WCLKN &&& WE && WCLKE, 517);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12984-12994
		$setup(RADDR, posedge RCLKN &&& RE && RCLKE, 384);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12995
		$setup(RCLKE, posedge RCLKN, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12996
		$setup(RE, posedge RCLKN, 185);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L12997-13007
		$setup(WADDR, posedge WCLKN &&& WE && WCLKE, 424);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13008
		$setup(WCLKE, posedge WCLKN, 503);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13009-13024
		$setup(WDATA, posedge WCLKN &&& WE && WCLKE, 305);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13025
		$setup(WE, posedge WCLKN, 252);
		// https://github.com/cliffordwolf/icestorm/blob/95949315364f8d9b0c693386aefadf44b28e2cf6/icefuzz/timings_up5k.txt#L13026
		(posedge RCLKN => (RDATA : 16'bx)) = 1179;
	endspecify
`endif
endmodule

// Packed IceStorm Logic Cells

module ICESTORM_LC (
	input I0, I1, I2, I3, CIN, CLK, CEN, SR,
	output LO,
	`ABC9_ARRIVAL_HX(540)
	`ABC9_ARRIVAL_LP(796)
	`ABC9_ARRIVAL_U(1391)
	output O,
	output COUT
);
	parameter [15:0] LUT_INIT = 0;

	parameter [0:0] NEG_CLK      = 0;
	parameter [0:0] CARRY_ENABLE = 0;
	parameter [0:0] DFF_ENABLE   = 0;
	parameter [0:0] SET_NORESET  = 0;
	parameter [0:0] ASYNC_SR     = 0;

	parameter [0:0] CIN_CONST    = 0;
	parameter [0:0] CIN_SET      = 0;

	wire mux_cin = CIN_CONST ? CIN_SET : CIN;

	assign COUT = CARRY_ENABLE ? (I1 && I2) || ((I1 || I2) && mux_cin) : 1'bx;

	wire [7:0] lut_s3 = I3 ? LUT_INIT[15:8] : LUT_INIT[7:0];
	wire [3:0] lut_s2 = I2 ?   lut_s3[ 7:4] :   lut_s3[3:0];
	wire [1:0] lut_s1 = I1 ?   lut_s2[ 3:2] :   lut_s2[1:0];
	wire       lut_o  = I0 ?   lut_s1[   1] :   lut_s1[  0];

	assign LO = lut_o;

	wire polarized_clk;
	assign polarized_clk = CLK ^ NEG_CLK;

	reg o_reg;
	always @(posedge polarized_clk)
		if (CEN)
			o_reg <= SR ? SET_NORESET : lut_o;

	reg o_reg_async;
	always @(posedge polarized_clk, posedge SR)
		if (SR)
			o_reg <= SET_NORESET;
		else if (CEN)
			o_reg <= lut_o;

	assign O = DFF_ENABLE ? ASYNC_SR ? o_reg_async : o_reg : lut_o;
endmodule

// SiliconBlue PLL Cells

(* blackbox *)
module SB_PLL40_CORE (
	input   REFERENCECLK,
	output  PLLOUTCORE,
	output  PLLOUTGLOBAL,
	input   EXTFEEDBACK,
	input   [7:0] DYNAMICDELAY,
	output  LOCK,
	input   BYPASS,
	input   RESETB,
	input   LATCHINPUTVALUE,
	output  SDO,
	input   SDI,
	input   SCLK
);
	parameter FEEDBACK_PATH = "SIMPLE";
	parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
	parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
	parameter SHIFTREG_DIV_MODE = 1'b0;
	parameter FDA_FEEDBACK = 4'b0000;
	parameter FDA_RELATIVE = 4'b0000;
	parameter PLLOUT_SELECT = "GENCLK";
	parameter DIVR = 4'b0000;
	parameter DIVF = 7'b0000000;
	parameter DIVQ = 3'b000;
	parameter FILTER_RANGE = 3'b000;
	parameter ENABLE_ICEGATE = 1'b0;
	parameter TEST_MODE = 1'b0;
	parameter EXTERNAL_DIVIDE_FACTOR = 1;
endmodule

(* blackbox *)
module SB_PLL40_PAD (
	input   PACKAGEPIN,
	output  PLLOUTCORE,
	output  PLLOUTGLOBAL,
	input   EXTFEEDBACK,
	input   [7:0] DYNAMICDELAY,
	output  LOCK,
	input   BYPASS,
	input   RESETB,
	input   LATCHINPUTVALUE,
	output  SDO,
	input   SDI,
	input   SCLK
);
	parameter FEEDBACK_PATH = "SIMPLE";
	parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
	parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
	parameter SHIFTREG_DIV_MODE = 1'b0;
	parameter FDA_FEEDBACK = 4'b0000;
	parameter FDA_RELATIVE = 4'b0000;
	parameter PLLOUT_SELECT = "GENCLK";
	parameter DIVR = 4'b0000;
	parameter DIVF = 7'b0000000;
	parameter DIVQ = 3'b000;
	parameter FILTER_RANGE = 3'b000;
	parameter ENABLE_ICEGATE = 1'b0;
	parameter TEST_MODE = 1'b0;
	parameter EXTERNAL_DIVIDE_FACTOR = 1;
endmodule

(* blackbox *)
module SB_PLL40_2_PAD (
	input   PACKAGEPIN,
	output  PLLOUTCOREA,
	output  PLLOUTGLOBALA,
	output  PLLOUTCOREB,
	output  PLLOUTGLOBALB,
	input   EXTFEEDBACK,
	input   [7:0] DYNAMICDELAY,
	output  LOCK,
	input   BYPASS,
	input   RESETB,
	input   LATCHINPUTVALUE,
	output  SDO,
	input   SDI,
	input   SCLK
);
	parameter FEEDBACK_PATH = "SIMPLE";
	parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
	parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
	parameter SHIFTREG_DIV_MODE = 1'b0;
	parameter FDA_FEEDBACK = 4'b0000;
	parameter FDA_RELATIVE = 4'b0000;
	parameter PLLOUT_SELECT_PORTB = "GENCLK";
	parameter DIVR = 4'b0000;
	parameter DIVF = 7'b0000000;
	parameter DIVQ = 3'b000;
	parameter FILTER_RANGE = 3'b000;
	parameter ENABLE_ICEGATE_PORTA = 1'b0;
	parameter ENABLE_ICEGATE_PORTB = 1'b0;
	parameter TEST_MODE = 1'b0;
	parameter EXTERNAL_DIVIDE_FACTOR = 1;
endmodule

(* blackbox *)
module SB_PLL40_2F_CORE (
	input   REFERENCECLK,
	output  PLLOUTCOREA,
	output  PLLOUTGLOBALA,
	output  PLLOUTCOREB,
	output  PLLOUTGLOBALB,
	input   EXTFEEDBACK,
	input   [7:0] DYNAMICDELAY,
	output  LOCK,
	input   BYPASS,
	input   RESETB,
	input   LATCHINPUTVALUE,
	output  SDO,
	input   SDI,
	input   SCLK
);
	parameter FEEDBACK_PATH = "SIMPLE";
	parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
	parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
	parameter SHIFTREG_DIV_MODE = 1'b0;
	parameter FDA_FEEDBACK = 4'b0000;
	parameter FDA_RELATIVE = 4'b0000;
	parameter PLLOUT_SELECT_PORTA = "GENCLK";
	parameter PLLOUT_SELECT_PORTB = "GENCLK";
	parameter DIVR = 4'b0000;
	parameter DIVF = 7'b0000000;
	parameter DIVQ = 3'b000;
	parameter FILTER_RANGE = 3'b000;
	parameter ENABLE_ICEGATE_PORTA = 1'b0;
	parameter ENABLE_ICEGATE_PORTB = 1'b0;
	parameter TEST_MODE = 1'b0;
	parameter EXTERNAL_DIVIDE_FACTOR = 1;
endmodule

(* blackbox *)
module SB_PLL40_2F_PAD (
	input   PACKAGEPIN,
	output  PLLOUTCOREA,
	output  PLLOUTGLOBALA,
	output  PLLOUTCOREB,
	output  PLLOUTGLOBALB,
	input   EXTFEEDBACK,
	input   [7:0] DYNAMICDELAY,
	output  LOCK,
	input   BYPASS,
	input   RESETB,
	input   LATCHINPUTVALUE,
	output  SDO,
	input   SDI,
	input   SCLK
);
	parameter FEEDBACK_PATH = "SIMPLE";
	parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
	parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
	parameter SHIFTREG_DIV_MODE = 2'b00;
	parameter FDA_FEEDBACK = 4'b0000;
	parameter FDA_RELATIVE = 4'b0000;
	parameter PLLOUT_SELECT_PORTA = "GENCLK";
	parameter PLLOUT_SELECT_PORTB = "GENCLK";
	parameter DIVR = 4'b0000;
	parameter DIVF = 7'b0000000;
	parameter DIVQ = 3'b000;
	parameter FILTER_RANGE = 3'b000;
	parameter ENABLE_ICEGATE_PORTA = 1'b0;
	parameter ENABLE_ICEGATE_PORTB = 1'b0;
	parameter TEST_MODE = 1'b0;
	parameter EXTERNAL_DIVIDE_FACTOR = 1;
endmodule

// SiliconBlue Device Configuration Cells

(* blackbox, keep *)
module SB_WARMBOOT (
	input BOOT,
	input S1,
	input S0
);
endmodule

module SB_SPRAM256KA (
	input [13:0] ADDRESS,
	input [15:0] DATAIN,
	input [3:0] MASKWREN,
	input WREN, CHIPSELECT, CLOCK, STANDBY, SLEEP, POWEROFF,
	output reg [15:0] DATAOUT
);
`ifndef BLACKBOX
`ifndef EQUIV
	reg [15:0] mem [0:16383];
	wire off = SLEEP || !POWEROFF;
	integer i;

	always @(negedge POWEROFF) begin
		for (i = 0; i <= 16383; i = i+1)
			mem[i] = 'bx;
	end

	always @(posedge CLOCK, posedge off) begin
		if (off) begin
			DATAOUT <= 0;
		end else
		if (CHIPSELECT && !STANDBY && !WREN) begin
			DATAOUT <= mem[ADDRESS];
		end else begin
			if (CHIPSELECT && !STANDBY && WREN) begin
				if (MASKWREN[0]) mem[ADDRESS][ 3: 0] = DATAIN[ 3: 0];
				if (MASKWREN[1]) mem[ADDRESS][ 7: 4] = DATAIN[ 7: 4];
				if (MASKWREN[2]) mem[ADDRESS][11: 8] = DATAIN[11: 8];
				if (MASKWREN[3]) mem[ADDRESS][15:12] = DATAIN[15:12];
			end
			DATAOUT <= 'bx;
		end
	end
`endif
`endif
endmodule

(* blackbox *)
module SB_HFOSC(
	input TRIM0,
	input TRIM1,
	input TRIM2,
	input TRIM3,
	input TRIM4,
	input TRIM5,
	input TRIM6,
	input TRIM7,
	input TRIM8,
	input TRIM9,
	input CLKHFPU,
	input CLKHFEN,
	output CLKHF
);
parameter TRIM_EN = "0b0";
parameter CLKHF_DIV = "0b00";
endmodule

(* blackbox *)
module SB_LFOSC(
	input CLKLFPU,
	input CLKLFEN,
	output CLKLF
);
endmodule

(* blackbox *)
module SB_RGBA_DRV(
	input CURREN,
	input RGBLEDEN,
	input RGB0PWM,
	input RGB1PWM,
	input RGB2PWM,
	output RGB0,
	output RGB1,
	output RGB2
);
parameter CURRENT_MODE = "0b0";
parameter RGB0_CURRENT = "0b000000";
parameter RGB1_CURRENT = "0b000000";
parameter RGB2_CURRENT = "0b000000";
endmodule

(* blackbox *)
module SB_LED_DRV_CUR(
	input EN,
	output LEDPU
);
endmodule

(* blackbox *)
module SB_RGB_DRV(
	input RGBLEDEN,
	input RGB0PWM,
	input RGB1PWM,
	input RGB2PWM,
	input RGBPU,
	output RGB0,
	output RGB1,
	output RGB2
);
parameter CURRENT_MODE = "0b0";
parameter RGB0_CURRENT = "0b000000";
parameter RGB1_CURRENT = "0b000000";
parameter RGB2_CURRENT = "0b000000";
endmodule

(* blackbox *)
module SB_I2C(
	input  SBCLKI,
	input  SBRWI,
	input  SBSTBI,
	input  SBADRI7,
	input  SBADRI6,
	input  SBADRI5,
	input  SBADRI4,
	input  SBADRI3,
	input  SBADRI2,
	input  SBADRI1,
	input  SBADRI0,
	input  SBDATI7,
	input  SBDATI6,
	input  SBDATI5,
	input  SBDATI4,
	input  SBDATI3,
	input  SBDATI2,
	input  SBDATI1,
	input  SBDATI0,
	input  SCLI,
	input  SDAI,
	output SBDATO7,
	output SBDATO6,
	output SBDATO5,
	output SBDATO4,
	output SBDATO3,
	output SBDATO2,
	output SBDATO1,
	output SBDATO0,
	output SBACKO,
	output I2CIRQ,
	output I2CWKUP,
	output SCLO, //inout in the SB verilog library, but output in the VHDL and PDF libs and seemingly in the HW itself
	output SCLOE,
	output SDAO,
	output SDAOE
);
parameter I2C_SLAVE_INIT_ADDR = "0b1111100001";
parameter BUS_ADDR74 = "0b0001";
endmodule

(* blackbox *)
module SB_SPI (
	input  SBCLKI,
	input  SBRWI,
	input  SBSTBI,
	input  SBADRI7,
	input  SBADRI6,
	input  SBADRI5,
	input  SBADRI4,
	input  SBADRI3,
	input  SBADRI2,
	input  SBADRI1,
	input  SBADRI0,
	input  SBDATI7,
	input  SBDATI6,
	input  SBDATI5,
	input  SBDATI4,
	input  SBDATI3,
	input  SBDATI2,
	input  SBDATI1,
	input  SBDATI0,
	input  MI,
	input  SI,
	input  SCKI,
	input  SCSNI,
	output SBDATO7,
	output SBDATO6,
	output SBDATO5,
	output SBDATO4,
	output SBDATO3,
	output SBDATO2,
	output SBDATO1,
	output SBDATO0,
	output SBACKO,
	output SPIIRQ,
	output SPIWKUP,
	output SO,
	output SOE,
	output MO,
	output MOE,
	output SCKO, //inout in the SB verilog library, but output in the VHDL and PDF libs and seemingly in the HW itself
	output SCKOE,
	output MCSNO3,
	output MCSNO2,
	output MCSNO1,
	output MCSNO0,
	output MCSNOE3,
	output MCSNOE2,
	output MCSNOE1,
	output MCSNOE0
);
parameter BUS_ADDR74 = "0b0000";
endmodule

(* blackbox *)
module SB_LEDDA_IP(
	input LEDDCS,
	input LEDDCLK,
	input LEDDDAT7,
	input LEDDDAT6,
	input LEDDDAT5,
	input LEDDDAT4,
	input LEDDDAT3,
	input LEDDDAT2,
	input LEDDDAT1,
	input LEDDDAT0,
	input LEDDADDR3,
	input LEDDADDR2,
	input LEDDADDR1,
	input LEDDADDR0,
	input LEDDDEN,
	input LEDDEXE,
	input LEDDRST,
	output PWMOUT0,
	output PWMOUT1,
	output PWMOUT2,
	output LEDDON
);
endmodule

(* blackbox *)
module SB_FILTER_50NS(
	input FILTERIN,
	output FILTEROUT
);
endmodule

module SB_IO_I3C (
	inout  PACKAGE_PIN,
	input  LATCH_INPUT_VALUE,
	input  CLOCK_ENABLE,
	input  INPUT_CLK,
	input  OUTPUT_CLK,
	input  OUTPUT_ENABLE,
	input  D_OUT_0,
	input  D_OUT_1,
	output D_IN_0,
	output D_IN_1,
	input  PU_ENB,
	input  WEAK_PU_ENB
);
	parameter [5:0] PIN_TYPE = 6'b000000;
	parameter [0:0] PULLUP = 1'b0;
	parameter [0:0] WEAK_PULLUP = 1'b0;
	parameter [0:0] NEG_TRIGGER = 1'b0;
	parameter IO_STANDARD = "SB_LVCMOS";

`ifndef BLACKBOX
	reg dout, din_0, din_1;
	reg din_q_0, din_q_1;
	reg dout_q_0, dout_q_1;
	reg outena_q;

	generate if (!NEG_TRIGGER) begin
		always @(posedge INPUT_CLK)  if (CLOCK_ENABLE) din_q_0  <= PACKAGE_PIN;
		always @(negedge INPUT_CLK)  if (CLOCK_ENABLE) din_q_1  <= PACKAGE_PIN;
		always @(posedge OUTPUT_CLK) if (CLOCK_ENABLE) dout_q_0 <= D_OUT_0;
		always @(negedge OUTPUT_CLK) if (CLOCK_ENABLE) dout_q_1 <= D_OUT_1;
		always @(posedge OUTPUT_CLK) if (CLOCK_ENABLE) outena_q <= OUTPUT_ENABLE;
	end else begin
		always @(negedge INPUT_CLK)  if (CLOCK_ENABLE) din_q_0  <= PACKAGE_PIN;
		always @(posedge INPUT_CLK)  if (CLOCK_ENABLE) din_q_1  <= PACKAGE_PIN;
		always @(negedge OUTPUT_CLK) if (CLOCK_ENABLE) dout_q_0 <= D_OUT_0;
		always @(posedge OUTPUT_CLK) if (CLOCK_ENABLE) dout_q_1 <= D_OUT_1;
		always @(negedge OUTPUT_CLK) if (CLOCK_ENABLE) outena_q <= OUTPUT_ENABLE;
	end endgenerate

	always @* begin
		if (!PIN_TYPE[1] || !LATCH_INPUT_VALUE)
			din_0 = PIN_TYPE[0] ? PACKAGE_PIN : din_q_0;
		din_1 = din_q_1;
	end

	// work around simulation glitches on dout in DDR mode
	reg outclk_delayed_1;
	reg outclk_delayed_2;
	always @* outclk_delayed_1 <= OUTPUT_CLK;
	always @* outclk_delayed_2 <= outclk_delayed_1;

	always @* begin
		if (PIN_TYPE[3])
			dout = PIN_TYPE[2] ? !dout_q_0 : D_OUT_0;
		else
			dout = (outclk_delayed_2 ^ NEG_TRIGGER) || PIN_TYPE[2] ? dout_q_0 : dout_q_1;
	end

	assign D_IN_0 = din_0, D_IN_1 = din_1;

	generate
		if (PIN_TYPE[5:4] == 2'b01) assign PACKAGE_PIN = dout;
		if (PIN_TYPE[5:4] == 2'b10) assign PACKAGE_PIN = OUTPUT_ENABLE ? dout : 1'bz;
		if (PIN_TYPE[5:4] == 2'b11) assign PACKAGE_PIN = outena_q ? dout : 1'bz;
	endgenerate
`endif
endmodule

module SB_IO_OD (
	inout  PACKAGEPIN,
	input  LATCHINPUTVALUE,
	input  CLOCKENABLE,
	input  INPUTCLK,
	input  OUTPUTCLK,
	input  OUTPUTENABLE,
	input  DOUT1,
	input  DOUT0,
	output DIN1,
	output DIN0
);
	parameter [5:0] PIN_TYPE = 6'b000000;
	parameter [0:0] NEG_TRIGGER = 1'b0;

`ifndef BLACKBOX
	reg dout, din_0, din_1;
	reg din_q_0, din_q_1;
	reg dout_q_0, dout_q_1;
	reg outena_q;

	generate if (!NEG_TRIGGER) begin
		always @(posedge INPUTCLK)  if (CLOCKENABLE) din_q_0  <= PACKAGEPIN;
		always @(negedge INPUTCLK)  if (CLOCKENABLE) din_q_1  <= PACKAGEPIN;
		always @(posedge OUTPUTCLK) if (CLOCKENABLE) dout_q_0 <= DOUT0;
		always @(negedge OUTPUTCLK) if (CLOCKENABLE) dout_q_1 <= DOUT1;
		always @(posedge OUTPUTCLK) if (CLOCKENABLE) outena_q <= OUTPUTENABLE;
	end else begin
		always @(negedge INPUTCLK)  if (CLOCKENABLE) din_q_0  <= PACKAGEPIN;
		always @(posedge INPUTCLK)  if (CLOCKENABLE) din_q_1  <= PACKAGEPIN;
		always @(negedge OUTPUTCLK) if (CLOCKENABLE) dout_q_0 <= DOUT0;
		always @(posedge OUTPUTCLK) if (CLOCKENABLE) dout_q_1 <= DOUT1;
		always @(negedge OUTPUTCLK) if (CLOCKENABLE) outena_q <= OUTPUTENABLE;
	end endgenerate

	always @* begin
		if (!PIN_TYPE[1] || !LATCHINPUTVALUE)
			din_0 = PIN_TYPE[0] ? PACKAGEPIN : din_q_0;
		din_1 = din_q_1;
	end

	// work around simulation glitches on dout in DDR mode
	reg outclk_delayed_1;
	reg outclk_delayed_2;
	always @* outclk_delayed_1 <= OUTPUTCLK;
	always @* outclk_delayed_2 <= outclk_delayed_1;

	always @* begin
		if (PIN_TYPE[3])
			dout = PIN_TYPE[2] ? !dout_q_0 : DOUT0;
		else
			dout = (outclk_delayed_2 ^ NEG_TRIGGER) || PIN_TYPE[2] ? dout_q_0 : dout_q_1;
	end

	assign DIN0 = din_0, DIN1 = din_1;

	generate
		if (PIN_TYPE[5:4] == 2'b01) assign PACKAGEPIN = dout ? 1'bz : 1'b0;
		if (PIN_TYPE[5:4] == 2'b10) assign PACKAGEPIN = OUTPUTENABLE ? (dout ? 1'bz : 1'b0) : 1'bz;
		if (PIN_TYPE[5:4] == 2'b11) assign PACKAGEPIN = outena_q ? (dout ? 1'bz : 1'b0) : 1'bz;
	endgenerate
`endif
endmodule

module SB_MAC16 (
	input CLK, CE,
	input [15:0] C, A, B, D,
	input AHOLD, BHOLD, CHOLD, DHOLD,
	input IRSTTOP, IRSTBOT,
	input ORSTTOP, ORSTBOT,
	input OLOADTOP, OLOADBOT,
	input ADDSUBTOP, ADDSUBBOT,
	input OHOLDTOP, OHOLDBOT,
	input CI, ACCUMCI, SIGNEXTIN,
	output [31:0] O,
	output CO, ACCUMCO, SIGNEXTOUT
);
	parameter [0:0] NEG_TRIGGER = 0;
	parameter [0:0] C_REG = 0;
	parameter [0:0] A_REG = 0;
	parameter [0:0] B_REG = 0;
	parameter [0:0] D_REG = 0;
	parameter [0:0] TOP_8x8_MULT_REG = 0;
	parameter [0:0] BOT_8x8_MULT_REG = 0;
	parameter [0:0] PIPELINE_16x16_MULT_REG1 = 0;
	parameter [0:0] PIPELINE_16x16_MULT_REG2 = 0;
	parameter [1:0] TOPOUTPUT_SELECT = 0;
	parameter [1:0] TOPADDSUB_LOWERINPUT = 0;
	parameter [0:0] TOPADDSUB_UPPERINPUT = 0;
	parameter [1:0] TOPADDSUB_CARRYSELECT = 0;
	parameter [1:0] BOTOUTPUT_SELECT = 0;
	parameter [1:0] BOTADDSUB_LOWERINPUT = 0;
	parameter [0:0] BOTADDSUB_UPPERINPUT = 0;
	parameter [1:0] BOTADDSUB_CARRYSELECT = 0;
	parameter [0:0] MODE_8x8 = 0;
	parameter [0:0] A_SIGNED = 0;
	parameter [0:0] B_SIGNED = 0;

	wire clock = CLK ^ NEG_TRIGGER;

	// internal wires, compare Figure on page 133 of ICE Technology Library 3.0 and Fig 2 on page 2 of Lattice TN1295-DSP
	// http://www.latticesemi.com/~/media/LatticeSemi/Documents/TechnicalBriefs/SBTICETechnologyLibrary201608.pdf
	// https://www.latticesemi.com/-/media/LatticeSemi/Documents/ApplicationNotes/AD/DSPFunctionUsageGuideforICE40Devices.ashx
	wire [15:0] iA, iB, iC, iD;
	wire [15:0] iF, iJ, iK, iG;
	wire [31:0] iL, iH;
	wire [15:0] iW, iX, iP, iQ;
	wire [15:0] iY, iZ, iR, iS;
	wire HCI, LCI, LCO;

	// Regs C and A
	reg [15:0] rC, rA;
	always @(posedge clock, posedge IRSTTOP) begin
		if (IRSTTOP) begin
			rC <= 0;
			rA <= 0;
		end else if (CE) begin
			if (!CHOLD) rC <= C;
			if (!AHOLD) rA <= A;
		end
	end
	assign iC = C_REG ? rC : C;
	assign iA = A_REG ? rA : A;

	// Regs B and D
	reg [15:0] rB, rD;
	always @(posedge clock, posedge IRSTBOT) begin
		if (IRSTBOT) begin
			rB <= 0;
			rD <= 0;
		end else if (CE) begin
			if (!BHOLD) rB <= B;
			if (!DHOLD) rD <= D;
		end
	end
	assign iB = B_REG ? rB : B;
	assign iD = D_REG ? rD : D;

	// Multiplier Stage
	wire [15:0] p_Ah_Bh, p_Al_Bh, p_Ah_Bl, p_Al_Bl;
	wire [15:0] Ah, Al, Bh, Bl;
	assign Ah = {A_SIGNED ? {8{iA[15]}} : 8'b0, iA[15: 8]};
	assign Al = {A_SIGNED && MODE_8x8 ? {8{iA[ 7]}} : 8'b0, iA[ 7: 0]};
	assign Bh = {B_SIGNED ? {8{iB[15]}} : 8'b0, iB[15: 8]};
	assign Bl = {B_SIGNED && MODE_8x8 ? {8{iB[ 7]}} : 8'b0, iB[ 7: 0]};
	assign p_Ah_Bh = Ah * Bh; // F
	assign p_Al_Bh = {8'b0, Al[7:0]} * Bh; // J
	assign p_Ah_Bl = Ah * {8'b0, Bl[7:0]}; // K
	assign p_Al_Bl = Al * Bl; // G

	// Regs F and J
	reg [15:0] rF, rJ;
	always @(posedge clock, posedge IRSTTOP) begin
		if (IRSTTOP) begin
			rF <= 0;
			rJ <= 0;
		end else if (CE) begin
			rF <= p_Ah_Bh;
			if (!MODE_8x8) rJ <= p_Al_Bh;
		end
	end
	assign iF = TOP_8x8_MULT_REG ? rF : p_Ah_Bh;
	assign iJ = PIPELINE_16x16_MULT_REG1 ? rJ : p_Al_Bh;

	// Regs K and G
	reg [15:0] rK, rG;
	always @(posedge clock, posedge IRSTBOT) begin
		if (IRSTBOT) begin
			rK <= 0;
			rG <= 0;
		end else if (CE) begin
			if (!MODE_8x8) rK <= p_Ah_Bl;
			rG <= p_Al_Bl;
		end
	end
	assign iK = PIPELINE_16x16_MULT_REG1 ? rK : p_Ah_Bl;
	assign iG = BOT_8x8_MULT_REG ? rG : p_Al_Bl;

	// Adder Stage
	wire [23:0] iK_e = {A_SIGNED ? {8{iK[15]}} : 8'b0, iK};
	wire [23:0] iJ_e = {B_SIGNED ? {8{iJ[15]}} : 8'b0, iJ};
	assign iL = iG + (iK_e << 8) + (iJ_e << 8) + (iF << 16);

	// Reg H
	reg [31:0] rH;
	always @(posedge clock, posedge IRSTBOT) begin
		if (IRSTBOT) begin
			rH <= 0;
		end else if (CE) begin
			if (!MODE_8x8) rH <= iL;
		end
	end
	assign iH = PIPELINE_16x16_MULT_REG2 ? rH : iL;

	// Hi Output Stage
	wire [15:0] XW, Oh;
	reg [15:0] rQ;
	assign iW = TOPADDSUB_UPPERINPUT ? iC : iQ;
	assign iX = (TOPADDSUB_LOWERINPUT == 0) ? iA : (TOPADDSUB_LOWERINPUT == 1) ? iF : (TOPADDSUB_LOWERINPUT == 2) ? iH[31:16] : {16{iZ[15]}};
	assign {ACCUMCO, XW} = iX + (iW ^ {16{ADDSUBTOP}}) + HCI;
	assign CO = ACCUMCO ^ ADDSUBTOP;
	assign iP = OLOADTOP ? iC : XW ^ {16{ADDSUBTOP}};
	always @(posedge clock, posedge ORSTTOP) begin
		if (ORSTTOP) begin
			rQ <= 0;
		end else if (CE) begin
			if (!OHOLDTOP) rQ <= iP;
		end
	end
	assign iQ = rQ;
	assign Oh = (TOPOUTPUT_SELECT == 0) ? iP : (TOPOUTPUT_SELECT == 1) ? iQ : (TOPOUTPUT_SELECT == 2) ? iF : iH[31:16];
	assign HCI = (TOPADDSUB_CARRYSELECT == 0) ? 1'b0 : (TOPADDSUB_CARRYSELECT == 1) ? 1'b1 : (TOPADDSUB_CARRYSELECT == 2) ? LCO : LCO ^ ADDSUBBOT;
	assign SIGNEXTOUT = iX[15];

	// Lo Output Stage
	wire [15:0] YZ, Ol;
	reg [15:0] rS;
	assign iY = BOTADDSUB_UPPERINPUT ? iD : iS;
	assign iZ = (BOTADDSUB_LOWERINPUT == 0) ? iB : (BOTADDSUB_LOWERINPUT == 1) ? iG : (BOTADDSUB_LOWERINPUT == 2) ? iH[15:0] : {16{SIGNEXTIN}};
	assign {LCO, YZ} = iZ + (iY ^ {16{ADDSUBBOT}}) + LCI;
	assign iR = OLOADBOT ? iD : YZ ^ {16{ADDSUBBOT}};
	always @(posedge clock, posedge ORSTBOT) begin
		if (ORSTBOT) begin
			rS <= 0;
		end else if (CE) begin
			if (!OHOLDBOT) rS <= iR;
		end
	end
	assign iS = rS;
	assign Ol = (BOTOUTPUT_SELECT == 0) ? iR : (BOTOUTPUT_SELECT == 1) ? iS : (BOTOUTPUT_SELECT == 2) ? iG : iH[15:0];
	assign LCI = (BOTADDSUB_CARRYSELECT == 0) ? 1'b0 : (BOTADDSUB_CARRYSELECT == 1) ? 1'b1 : (BOTADDSUB_CARRYSELECT == 2) ? ACCUMCI : CI;
	assign O = {Oh, Ol};
endmodule
