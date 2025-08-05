`default_nettype none
module t01_musicman (
	clk,
	rst,
	lfsr,
	gameover,
	square_out
);
	reg _sv2v_0;
	input clk;
	input rst;
	input wire [15:0] lfsr;
	input wire gameover;
	output reg square_out;
	localparam NEWCLK_PER = 4900000;
	reg [23:0] count;
	reg [23:0] count_n;
	wire newclk_n;
	reg newclk;
	always @(posedge clk or posedge rst)
		if (rst)
			count <= 1'sb0;
		else
			count <= count_n;
	always @(*) begin
		if (_sv2v_0)
			;
		count_n = count;
		if (count < 4900000) begin
			count_n = count + 1;
			newclk = 0;
		end
		else begin
			count_n = 1'sb0;
			newclk = 1;
		end
	end
	wire [22:0] current_note;
	wire [22:0] next_note;
	reg [7:0] sample;
	reg [7:0] sample_next;
	always @(posedge clk or posedge rst)
		if (rst)
			sample <= 1'sb0;
		else if (gameover)
			sample <= 1'sb0;
		else if (newclk)
			sample <= sample_next;
	reg [6:0] count_val;
	always @(*) begin
		if (_sv2v_0)
			;
		sample_next = sample + 1;
		if (sample < 64)
			count_val = sample[6:0];
		else
			count_val = sample[6:0] - 64;
		if (sample == 191)
			sample_next = 0;
	end
	reg [22:0] square_count1;
	reg [22:0] square_count_next1;
	always @(posedge clk or posedge rst)
		if (rst)
			square_count1 <= 0;
		else if (gameover)
			square_count1 <= 1'sb0;
		else
			square_count1 <= square_count_next1;
	reg [22:0] square_count2;
	reg [22:0] square_count_next2;
	always @(posedge clk or posedge rst)
		if (rst)
			square_count2 <= 0;
		else if (gameover)
			square_count2 <= 1'sb0;
		else
			square_count2 <= square_count_next2;
	reg [22:0] max_count1;
	reg [22:0] max_count2;
	always @(*) begin
		if (_sv2v_0)
			;
		square_out = 1;
		square_count_next1 = square_count1 + 1;
		square_count_next2 = square_count2 + 1;
		if (gameover)
			square_out = lfsr[0];
		else if (((count >> 7) % 10) < 3) begin
			if ((sample % 16) == 5) begin
				if ((count < 1225000) || ((count > 2450000) && (count < 3675000)))
					square_out = lfsr[0];
			end
			else if ((count < 1225000) && (((sample % 2) == 1) || ((sample % 16) == 14)))
				square_out = lfsr[0];
		end
		else if (((count >> 7) % 10) < 8) begin
			if (square_count1 < (max_count1 >> 2))
				square_out = 0;
			else if (square_count1 > (max_count1 >> 1))
				square_count_next1 = 1'sb0;
		end
		else if (square_count2 < (max_count2 >> 2))
			square_out = 0;
		else if (square_count2 > (max_count2 >> 1))
			square_count_next2 = 1'sb0;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		max_count1 = 23'b00000000000000000000000;
		case (count_val)
			0: {max_count1, max_count2} = 46'h009421800000;
			1: {max_count1, max_count2} = 46'h009421800000;
			2: {max_count1, max_count2} = 46'h00c5bb01d649;
			3: {max_count1, max_count2} = 46'h00baa2000000;
			4: {max_count1, max_count2} = 46'h00a645800000;
			5: {max_count1, max_count2} = 46'h00a645800000;
			6: {max_count1, max_count2} = 46'h00baa201bbe4;
			7: {max_count1, max_count2} = 46'h00c5bb01f23f;
			8: {max_count1, max_count2} = 46'h00ddf2024fdb;
			9: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			10: {max_count1, max_count2} = 46'h00ddf2024fdb;
			11: {max_count1, max_count2} = 46'h00baa2000000;
			12: {max_count1, max_count2} = 46'h009421800000;
			13: {max_count1, max_count2} = 46'h009421800000;
			14: {max_count1, max_count2} = 46'h00a645800000;
			15: {max_count1, max_count2} = 46'h00baa2000000;
			16: {max_count1, max_count2} = 46'h00c5bb01d649;
			17: {max_count1, max_count2} = 46'h00c5bb01d649;
			18: {max_count1, max_count2} = 46'h00c5bb01d649;
			19: {max_count1, max_count2} = 46'h00baa201bbe4;
			20: {max_count1, max_count2} = 46'h00a645818b76;
			21: {max_count1, max_count2} = 46'h00a645818b76;
			22: {max_count1, max_count2} = 46'h009421800000;
			23: {max_count1, max_count2} = 46'h009421800000;
			24: {max_count1, max_count2} = 46'h00baa2000000;
			25: {max_count1, max_count2} = 46'h00baa2000000;
			26: {max_count1, max_count2} = 46'h00ddf2000000;
			27: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			28: {max_count1, max_count2} = 46'h00ddf2000000;
			29: {max_count1, max_count2} = 46'h00ddf2000000;
			30: {max_count1, max_count2} = 46'h00ddf2000000;
			31: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			32: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			33: {max_count1, max_count2} = 46'h00a645822e09;
			34: {max_count1, max_count2} = 46'h00a645822e09;
			35: {max_count1, max_count2} = 46'h008bd101bbe4;
			36: {max_count1, max_count2} = 46'h006ef9017544;
			37: {max_count1, max_count2} = 46'h006ef9017544;
			38: {max_count1, max_count2} = 46'h007c90018b76;
			39: {max_count1, max_count2} = 46'h008bd101bbe4;
			40: {max_count1, max_count2} = 46'h00942181f23f;
			41: {max_count1, max_count2} = 46'h00942181f23f;
			42: {max_count1, max_count2} = 46'h00942181f23f;
			43: {max_count1, max_count2} = 46'h00baa2024fdb;
			44: {max_count1, max_count2} = 46'h00942181f23f;
			45: {max_count1, max_count2} = 46'h00942181f23f;
			46: {max_count1, max_count2} = 46'h00a645822e09;
			47: {max_count1, max_count2} = 46'h00baa2024fdb;
			48: {max_count1, max_count2} = 46'h00c5bb01d649;
			49: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			50: {max_count1, max_count2} = 46'h00c5bb01d649;
			51: {max_count1, max_count2} = 46'h00baa201bbe4;
			52: {max_count1, max_count2} = 46'h00a645818b76;
			53: {max_count1, max_count2} = 46'h00a645818b76;
			54: {max_count1, max_count2} = 46'h009421800000;
			55: {max_count1, max_count2} = 46'h009421800000;
			56: {max_count1, max_count2} = 46'h00baa2000000;
			57: {max_count1, max_count2} = 46'h00baa2000000;
			58: {max_count1, max_count2} = 46'h00ddf2000000;
			59: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			60: {max_count1, max_count2} = 46'h00ddf2000000;
			61: {max_count1, max_count2} = 46'h00ddf2000000;
			62: {max_count1, max_count2} = 46'h00ddf2000000;
			63: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			64: {max_count1, max_count2} = 46'h009421817544;
			65: {max_count1, max_count2} = 46'h009421817544;
			66: {max_count1, max_count2} = 46'h009421817544;
			67: {max_count1, max_count2} = 46'h009421817544;
			68: {max_count1, max_count2} = 46'h00baa201bbe4;
			69: {max_count1, max_count2} = 46'h00baa201bbe4;
			70: {max_count1, max_count2} = 46'h00baa201bbe4;
			71: {max_count1, max_count2} = 46'h00baa201bbe4;
			72: {max_count1, max_count2} = 46'h00a645818b76;
			73: {max_count1, max_count2} = 46'h00a645818b76;
			74: {max_count1, max_count2} = 46'h00a645818b76;
			75: {max_count1, max_count2} = 46'h00a645818b76;
			76: {max_count1, max_count2} = 46'h00c5bb01d649;
			77: {max_count1, max_count2} = 46'h00c5bb01d649;
			78: {max_count1, max_count2} = 46'h00c5bb01d649;
			79: {max_count1, max_count2} = 46'h00c5bb01d649;
			80: {max_count1, max_count2} = 46'h00baa201bbe4;
			81: {max_count1, max_count2} = 46'h00baa201bbe4;
			82: {max_count1, max_count2} = 46'h00baa201bbe4;
			83: {max_count1, max_count2} = 46'h00baa201bbe4;
			84: {max_count1, max_count2} = 46'h00ddf2024fdb;
			85: {max_count1, max_count2} = 46'h00ddf2024fdb;
			86: {max_count1, max_count2} = 46'h00ddf2024fdb;
			87: {max_count1, max_count2} = 46'h00ddf2024fdb;
			88: {max_count1, max_count2} = 46'h00eb24824fdb;
			89: {max_count1, max_count2} = 46'h00eb24824fdb;
			90: {max_count1, max_count2} = 46'h00eb24824fdb;
			91: {max_count1, max_count2} = 46'h00eb24824fdb;
			92: {max_count1, max_count2} = 46'h00c5bb01d649;
			93: {max_count1, max_count2} = 46'h00c5bb01d649;
			94: {max_count1, max_count2} = 46'h00c5bb01d649;
			95: {max_count1, max_count2} = 46'h00c5bb01d649;
			96: {max_count1, max_count2} = 46'h009421817544;
			97: {max_count1, max_count2} = 46'h009421817544;
			98: {max_count1, max_count2} = 46'h009421817544;
			99: {max_count1, max_count2} = 46'h009421817544;
			100: {max_count1, max_count2} = 46'h00baa201bbe4;
			101: {max_count1, max_count2} = 46'h00baa201bbe4;
			102: {max_count1, max_count2} = 46'h00baa201bbe4;
			103: {max_count1, max_count2} = 46'h00baa201bbe4;
			104: {max_count1, max_count2} = 46'h00a645818b76;
			105: {max_count1, max_count2} = 46'h00a645818b76;
			106: {max_count1, max_count2} = 46'h00a645818b76;
			107: {max_count1, max_count2} = 46'h00a645818b76;
			108: {max_count1, max_count2} = 46'h00c5bb01d649;
			109: {max_count1, max_count2} = 46'h00c5bb01d649;
			110: {max_count1, max_count2} = 46'h00c5bb01d649;
			111: {max_count1, max_count2} = 46'h00c5bb01d649;
			112: {max_count1, max_count2} = 46'h00baa201bbe4;
			113: {max_count1, max_count2} = 46'h00baa201bbe4;
			114: {max_count1, max_count2} = 46'h009421817544;
			115: {max_count1, max_count2} = 46'h009421817544;
			116: {max_count1, max_count2} = 46'h006ef9012843;
			117: {max_count1, max_count2} = 46'h006ef9012843;
			118: {max_count1, max_count2} = 46'h006ef9012843;
			119: {max_count1, max_count2} = 46'h006ef9012843;
			120: {max_count1, max_count2} = 46'h007592012843;
			121: {max_count1, max_count2} = 46'h007592012843;
			122: {max_count1, max_count2} = 46'h007592012843;
			123: {max_count1, max_count2} = 46'h007592012843;
			124: {max_count1, max_count2} = 46'h007592012843;
			125: {max_count1, max_count2} = 46'h007592012843;
			126: {max_count1, max_count2} = 46'h007592012843;
			127: {max_count1, max_count2} = 46'b0000000000000000000000000000000000000000000000;
			default: max_count1 = 23'b00000000000000000000000;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
