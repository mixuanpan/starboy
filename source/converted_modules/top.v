`default_nettype none
module top (
	hz100,
	reset,
	pb,
	left,
	right,
	ss7,
	ss6,
	ss5,
	ss4,
	ss3,
	ss2,
	ss1,
	ss0,
	red,
	green,
	blue,
	txdata,
	rxdata,
	txclk,
	rxclk,
	txready,
	rxready
);
	reg _sv2v_0;
	parameter ADDR_W = 32;
	parameter LEN_W = 16;
	input wire hz100;
	input wire reset;
	input wire [20:0] pb;
	output wire [7:0] left;
	output wire [7:0] right;
	output wire [7:0] ss7;
	output wire [7:0] ss6;
	output wire [7:0] ss5;
	output wire [7:0] ss4;
	output wire [7:0] ss3;
	output wire [7:0] ss2;
	output wire [7:0] ss1;
	output wire [7:0] ss0;
	output wire red;
	output wire green;
	output wire blue;
	output wire [7:0] txdata;
	input wire [7:0] rxdata;
	output wire txclk;
	output wire rxclk;
	input wire txready;
	input wire rxready;
	localparam BLACK = 3'b000;
	localparam RED = 3'b100;
	localparam GREEN = 3'b010;
	localparam BLUE = 3'b001;
	localparam YELLOW = 3'b110;
	localparam MAGENTA = 3'b101;
	localparam CYAN = 3'b011;
	localparam WHITE = 3'b111;
	wire [9:0] x;
	wire [9:0] y;
	wire [2:0] grid_color;
	wire [2:0] score_color;
	wire [2:0] starboy_color;
	reg [2:0] final_color;
	wire [2:0] grid_color_movement;
	wire [2:0] grid_color_hold;
	wire onehuzz;
	wire [7:0] current_score;
	wire finish;
	wire gameover;
	wire [24:0] scoremod;
	wire [199:0] new_block_array;
	wire speed_mode_o;
	always @(*) begin
		if (_sv2v_0)
			;
		if (starboy_color != 3'b000)
			final_color = starboy_color;
		else if (score_color != 3'b000)
			final_color = score_color;
		else
			final_color = grid_color_movement;
	end
	t01_vgadriver ryangosling(
		.clk(hz100),
		.rst(1'b0),
		.color_in(final_color),
		.red(left[5]),
		.green(left[4]),
		.blue(left[3]),
		.hsync(left[7]),
		.vsync(left[6]),
		.x_out(x),
		.y_out(y)
	);
	t01_clkdiv1hz yo(
		.clk(hz100),
		.rst(reset),
		.newclk(onehuzz),
		.speed_up(speed_mode_o),
		.scoremod(scoremod)
	);
	t01_speed_controller jorkingtree(
		.clk(hz100),
		.reset(reset),
		.current_score(current_score),
		.scoremod(scoremod)
	);
	t01_tetrisFSM plait(
		.clk(hz100),
		.onehuzz(onehuzz),
		.reset(reset),
		.rotate_l(pb[11]),
		.speed_up_i(pb[12] | pb[15]),
		.right_i(pb[0]),
		.left_i(pb[3]),
		.rotate_r(pb[8]),
		.en_newgame(pb[19]),
		.speed_mode_o(speed_mode_o),
		.display_array(new_block_array),
		.gameover(gameover),
		.score(current_score),
		.start_i(pb[19])
	);
	t01_tetrisGrid durt(
		.x(x),
		.y(y),
		.shape_color(grid_color_movement),
		.display_array(new_block_array),
		.gameover(gameover)
	);
	t01_scoredisplay ralsei(
		.clk(onehuzz),
		.rst(reset),
		.score(current_score),
		.x(x),
		.y(y),
		.shape_color(score_color)
	);
	initial _sv2v_0 = 0;
endmodule
