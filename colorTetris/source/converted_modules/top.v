module top (
	clk,
	clk_25m,
	rst,
	switch4,
	J39_b15,
	J39_c15,
	J39_b20,
	J39_e11,
	J39_b10,
	J39_a14,
	J39_d13,
	J39_e12,
	J40_m3,
	J40_a15,
	J40_h2,
	J40_j4,
	J40_j3,
	J40_l4,
	J40_m4,
	J40_n4,
	J40_p5,
	J40_n5,
	J40_l5,
	J40_k3,
	J40_j5,
	tftstate,
	leds,
	test
);
	reg _sv2v_0;
	input wire clk;
	input wire clk_25m;
	input wire rst;
	input wire switch4;
	input wire J39_b15;
	input wire J39_c15;
	input wire J39_b20;
	input wire J39_e11;
	input wire J39_b10;
	input wire J39_a14;
	input wire J39_d13;
	input wire J39_e12;
	input wire J40_m3;
	output wire J40_a15;
	output wire J40_h2;
	output wire J40_j4;
	output wire J40_j3;
	output wire J40_l4;
	output wire J40_m4;
	output wire J40_n4;
	output wire J40_p5;
	output wire J40_n5;
	output wire J40_l5;
	output wire J40_k3;
	output wire J40_j5;
	output wire [2:0] tftstate;
	output wire [2:0] leds;
	output wire test;
	assign J40_a15 = ~switch4;
	assign J40_j5 = rst;
	wire [9:0] x;
	wire [9:0] y;
	wire [2:0] grid_color;
	wire [2:0] score_color;
	wire [2:0] starboy_color;
	reg [2:0] final_color;
	wire [2:0] grid_color_movement;
	wire [2:0] grid_color_hold;
	wire [2:0] credits;
	wire [2:0] next_block_color;
	wire onehuzz;
	wire [9:0] current_score;
	wire finish;
	wire gameover;
	wire [3:0] gamestate;
	wire [24:0] scoremod;
	wire [199:0] new_block_array;
	wire speed_mode_o;
	wire [599:0] final_display_color;
	wire [4:0] next_block_type;
	wire [47:0] next_block_preview;
	always @(*) begin
		if (_sv2v_0)
			;
		if (starboy_color != 3'b000)
			final_color = starboy_color;
		else if (score_color != 3'b000)
			final_color = score_color;
		else if (next_block_color != 3'b000)
			final_color = next_block_color;
		else if (credits != 3'b000)
			final_color = credits;
		else
			final_color = grid_color_movement;
	end
	wire right;
	wire left;
	wire rotate_r;
	wire rotate_l;
	wire start_i;
	t01_debounce NIRAJMENONFANCLUB(
		.clk(clk_25m),
		.pb(J39_e12),
		.button(right)
	);
	t01_debounce BENTANAYAYAYAYAYAY(
		.clk(clk_25m),
		.pb(J39_d13),
		.button(left)
	);
	t01_debounce nandyhu(
		.clk(clk_25m),
		.pb(J39_a14),
		.button(rotate_r)
	);
	t01_debounce benmillerlite(
		.clk(clk_25m),
		.pb(J39_b10),
		.button(rotate_l)
	);
	t01_vgadriver ryangosling(
		.clk(clk_25m),
		.rst(rst),
		.color_in(final_color),
		.red(J40_m4),
		.green(J40_h2),
		.blue(J40_j4),
		.hsync(J40_l4),
		.vsync(J40_j3),
		.x_out(x),
		.y_out(y)
	);
	assign onehuzz = clk_25m;
	t01_speed_controller jorkingtree(
		.clk(clk_25m),
		.reset(rst),
		.current_score(current_score),
		.scoremod(scoremod),
		.gamestate(gamestate)
	);
	t01_tetrisGrid miguelohara(
		.x(x),
		.y(y),
		.shape_color(grid_color_movement),
		.final_display_color(final_display_color),
		.gameover(gameover)
	);
	t01_scoredisplay ralsei(
		.clk(onehuzz),
		.rst(rst),
		.score(current_score),
		.x(x),
		.y(y),
		.shape_color(score_color)
	);
	t01_starboyDisplay silly(
		.clk(onehuzz),
		.rst(rst),
		.x(x),
		.y(y),
		.shape_color(starboy_color)
	);
	t01_tetrisCredits nebulabubu(
		.x(x),
		.y(y),
		.text_color(credits)
	);
	t01_lookahead justinjiang(
		.x(x),
		.y(y),
		.next_block_data(next_block_preview),
		.display_color(next_block_color)
	);
	wire [15:0] lfsr_reg;
	wire clk10k;
	localparam [0:0] sv2v_uu_chchch_ext_enable_1 = 1'sb1;
	t01_counter chchch(
		.clk(clk10k),
		.rst(rst),
		.enable(sv2v_uu_chchch_ext_enable_1),
		.lfsr_reg(lfsr_reg),
		.block_type()
	);
	t01_clkdiv10k thebackofmyfavoritestorespencers(
		.clk(clk_25m),
		.rst(rst),
		.newclk(clk10k)
	);
	t01_musicman piercetheveil(
		.clk(clk_25m),
		.rst(rst),
		.square_out(J40_n4),
		.lfsr(lfsr_reg),
		.gameover(gameover)
	);
	wire [2:0] fe_state;
	assign J40_p5 = fe_state[2];
	assign J40_n5 = fe_state[1];
	assign J40_l5 = fe_state[0];
	wire extract_start;
	assign J40_k3 = extract_start;
	wire [3:0] ofm_blockX;
	assign ofm_blockX = 'd6;
	wire [3:0] ai_blockX;
	wire ai_col_left;
	wire ai_col_right;
	wire ai_left;
	wire ai_new_spawn;
	wire ai_right;
	wire ai_rotate;
	wire [4:0] current_layer_block_type;
	wire extract_ready;
	t01_ai_tetrisFSM ai_tetris(
		.clk(clk_25m),
		.reset(rst),
		.onehuzz(onehuzz),
		.en_newgame(J39_b15),
		.right_i(ai_right),
		.left_i(ai_left),
		.start_i(J39_b15),
		.rotate_r(ai_rotate),
		.rotate_l(),
		.speed_up_i(1'b1),
		.display_array(new_block_array),
		.final_display_color(final_display_color),
		.gameover(gameover),
		.score(current_score),
		.speed_mode_o(speed_mode_o),
		.gamestate(gamestate),
		.ai_done(extract_ready),
		.ai_new_spawn(ai_new_spawn),
		.ai_col_left(ai_col_left),
		.ai_col_right(ai_col_right),
		.ai_blockX(ai_blockX),
		.ofm_blockX(ofm_blockX),
		.current_block_type(current_layer_block_type),
		.test()
	);
	wire new_layer;
	wire mmu_all_done;
	wire [7:0] bumpiness;
	wire [7:0] height_sum;
	wire [7:0] holes;
	wire [9:0] lines_cleared;
	t01_ai_game_engine_new ai_game_engine(
		.clk(clk_25m),
		.rst(rst),
		.gamestate(gamestate),
		.col_right(ai_col_right),
		.col_left(ai_col_left),
		.ai_right(ai_right),
		.ai_left(ai_left),
		.ai_rotation(ai_rotate),
		.blockX(ai_blockX),
		.extract_start(extract_start),
		.extract_ready(extract_ready),
		.current_block_type(current_layer_block_type),
		.ai_new_spawn(ai_new_spawn),
		.tetris_grid(new_block_array),
		.lines_cleared(lines_cleared),
		.holes(holes),
		.bumpiness(bumpiness),
		.height_sum(height_sum),
		.state(fe_state)
	);
	wire [199:0] fe_board;
	wire [99:0] ga_line;
	wire [99:0] ga_hei;
	wire [99:0] ga_hol;
	wire [99:0] ga_bum;
	assign ga_line = (lines_cleared * 100'd38033) / 'd500000;
	assign ga_hei = (height_sum * 100'd255033) / 'd500000;
	assign ga_hol = (holes * 100'd35663) / 'd100000;
	assign ga_bum = (bumpiness * 100'd184483) / 'd1000000;
	wire [7:0] mmu_act_in;
	assign mmu_act_in = ((ga_line[7:0] + ga_hei[7:0]) + ga_hol[7:0]) + ga_bum[7:0];
	wire mmu_start;
	wire mmu_act_valid;
	wire mmu_res_valid;
	wire [17:0] mmu_res_out;
	wire mmu_done;
	wire [1:0] mmu_layer_sel;
	initial _sv2v_0 = 0;
endmodule
