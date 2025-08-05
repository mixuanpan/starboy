`default_nettype none
module t01_vgadriver (
	clk,
	rst,
	color_in,
	x_out,
	y_out,
	hsync,
	vsync,
	red,
	green,
	blue
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [2:0] color_in;
	output reg [9:0] x_out;
	output reg [9:0] y_out;
	output wire hsync;
	output wire vsync;
	output reg red;
	output reg green;
	output reg blue;
	reg [9:0] H_ACTIVE = 10'd639;
	reg [9:0] H_FRONT = 10'd15;
	reg [9:0] H_PULSE = 10'd95;
	reg [9:0] H_BACK = 10'd47;
	reg [9:0] V_ACTIVE = 10'd479;
	reg [9:0] V_FRONT = 10'd9;
	reg [9:0] V_PULSE = 10'd1;
	reg [9:0] V_BACK = 10'd32;
	reg LOW = 1'b0;
	reg HIGH = 1'b1;
	reg [1:0] current_hstate;
	reg [1:0] next_hstate;
	reg [1:0] current_vstate;
	reg [1:0] next_vstate;
	reg hsync_r;
	reg vsync_r;
	reg line_done;
	reg [9:0] h_current_count;
	reg [9:0] h_next_count;
	reg [9:0] v_current_count;
	reg [9:0] v_next_count;
	always @(posedge clk or posedge rst)
		if (rst) begin
			h_current_count <= 0;
			current_hstate <= 2'b00;
			v_current_count <= 0;
			current_vstate <= 2'b00;
		end
		else begin
			h_current_count <= h_next_count;
			v_current_count <= v_next_count;
			current_hstate <= next_hstate;
			current_vstate <= next_vstate;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_hstate = 2'b00;
		h_next_count = 'b0;
		case (current_hstate)
			2'b00: begin
				hsync_r = HIGH;
				line_done = LOW;
				if (h_current_count == H_ACTIVE) begin
					h_next_count = 10'd0;
					next_hstate = 2'b01;
				end
				else begin
					h_next_count = h_current_count + 10'd1;
					next_hstate = current_hstate;
				end
			end
			2'b01: begin
				hsync_r = HIGH;
				line_done = LOW;
				if (h_current_count == H_FRONT) begin
					h_next_count = 10'd0;
					next_hstate = 2'b10;
				end
				else begin
					h_next_count = h_current_count + 10'd1;
					next_hstate = current_hstate;
				end
			end
			2'b10: begin
				hsync_r = LOW;
				line_done = LOW;
				if (h_current_count == H_PULSE) begin
					h_next_count = 10'd0;
					next_hstate = 2'b11;
				end
				else begin
					h_next_count = h_current_count + 10'd1;
					next_hstate = current_hstate;
				end
			end
			2'b11: begin
				hsync_r = HIGH;
				if (h_current_count == (H_BACK - 1))
					line_done = HIGH;
				else
					line_done = LOW;
				if (h_current_count == H_BACK) begin
					h_next_count = 10'd0;
					next_hstate = 2'b00;
				end
				else begin
					h_next_count = h_current_count + 10'd1;
					next_hstate = current_hstate;
				end
			end
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		next_vstate = 2'b00;
		v_next_count = 'b0;
		case (current_vstate)
			2'b00: begin
				vsync_r = HIGH;
				if (line_done == HIGH) begin
					if (v_current_count == V_ACTIVE) begin
						v_next_count = 10'd0;
						next_vstate = 2'b01;
					end
					else begin
						v_next_count = v_current_count + 10'd1;
						next_vstate = 2'b00;
					end
				end
				else begin
					v_next_count = v_current_count;
					next_vstate = current_vstate;
				end
			end
			2'b01: begin
				vsync_r = HIGH;
				if (line_done == HIGH) begin
					if (v_current_count == V_FRONT) begin
						v_next_count = 10'd0;
						next_vstate = 2'b10;
					end
					else begin
						v_next_count = v_current_count + 10'd1;
						next_vstate = 2'b01;
					end
				end
				else begin
					v_next_count = v_current_count;
					next_vstate = current_vstate;
				end
			end
			2'b10: begin
				vsync_r = LOW;
				if (line_done == HIGH) begin
					if (v_current_count == V_PULSE) begin
						v_next_count = 10'd0;
						next_vstate = 2'b11;
					end
					else begin
						v_next_count = v_current_count + 10'd1;
						next_vstate = 2'b10;
					end
				end
				else begin
					v_next_count = v_current_count;
					next_vstate = current_vstate;
				end
			end
			2'b11: begin
				vsync_r = HIGH;
				if (line_done == HIGH) begin
					if (v_current_count == V_BACK) begin
						v_next_count = 10'd0;
						next_vstate = 2'b00;
					end
					else begin
						v_next_count = v_current_count + 10'd1;
						next_vstate = current_vstate;
					end
				end
				else begin
					v_next_count = v_current_count;
					next_vstate = current_vstate;
				end
			end
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (current_hstate == 2'b00) begin
			if (current_vstate == 2'b00) begin
				red = color_in[2];
				green = color_in[1];
				blue = color_in[0];
			end
			else begin
				red = 'd0;
				green = 'd0;
				blue = 'd0;
			end
		end
		else begin
			red = 'd0;
			green = 'd0;
			blue = 'd0;
		end
	end
	assign vsync = vsync_r;
	assign hsync = hsync_r;
	always @(*) begin
		if (_sv2v_0)
			;
		if (current_hstate == 2'b00)
			x_out = h_current_count;
		else
			x_out = 10'd0;
		if (current_vstate == 2'b00)
			y_out = v_current_count;
		else
			y_out = 10'd0;
	end
	initial _sv2v_0 = 0;
endmodule
