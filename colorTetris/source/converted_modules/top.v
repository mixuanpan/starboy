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
	t01_clkdiv1hz yo(
		.clk(clk_25m),
		.rst(rst),
		.newclk(onehuzz),
		.speed_up(speed_mode_o),
		.scoremod(scoremod)
	);
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
	wire [3:0] ai_blockX;
	wire [4:0] ai_block_type;
	wire ai_col_left;
	wire ai_col_right;
	wire ai_left;
	wire ai_need_rotate;
	wire ai_new_spawn;
	wire ai_right;
	wire ai_rotate;
	wire ai_rotated;
	wire [4:0] current_layer_block_type;
	wire [3:0] ofm_blockX;
	wire [4:0] ofm_block_type;
	wire [4:0] ofm_block_type_input;
	wire ofm_layer_done;
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
		.ai_done(ofm_layer_done),
		.ai_new_spawn(ai_new_spawn),
		.ai_col_left(ai_col_left),
		.ai_col_right(ai_col_right),
		.ai_blockX(ai_blockX),
		.ofm_blockX(ofm_blockX),
		.current_block_type(current_layer_block_type),
		.test(),
		.ai_block_type(ai_block_type),
		.ai_need_rotate(ai_need_rotate),
		.ai_rotated(ai_rotated),
		.ofm_block_type_input(ofm_block_type_input),
		.ofm_block_type(ofm_block_type)
	);
	wire c_piece_done;
	wire mmu_all_done;
	wire extract_start;
	t01_ai_game_engine ai_game_engine(
		.clk(clk_25m),
		.rst(rst),
		.gamestate(gamestate),
		.col_right(ai_col_right),
		.col_left(ai_col_left),
		.ai_right(ai_right),
		.ai_left(ai_left),
		.ai_rotate(),
		.blockX(),
		.extract_start(extract_start),
		.ofm_done(ofm_layer_done),
		.current_block_type(current_layer_block_type),
		.ai_new_spawn(ai_new_spawn),
		.c_piece_done(),
		.need_rotate(ai_need_rotate),
		.rotate_block_type(ai_block_type),
		.ai_rotated(ai_rotated)
	);
	wire extract_ready;
	wire [7:0] lines_cleared;
	wire [7:0] holes;
	wire [7:0] bumpiness;
	wire [7:0] height_sum;
	wire [199:0] fe_board;
	wire [2:0] fe_state;
	t01_ai_feature_extract_new fe(
		.clk(clk_25m),
		.rst(rst),
		.extract_start(extract_start),
		.tetris_grid(new_block_array),
		.extract_ready(extract_ready),
		.lines_cleared(lines_cleared),
		.holes(holes),
		.bumpiness(bumpiness),
		.height_sum(height_sum),
		.state(fe_state),
		.ofm_done(ofm_layer_done)
	);
	wire mmu_done;
	wire mmu_res_valid;
	wire [17:0] mmu_res_out;
	reg [2:0] ai_state;
	reg [2:0] next_ai_state;
	reg [1:0] current_layer_sel;
	reg mmu_start;
	reg [7:0] layer0_features [0:3];
	reg [7:0] layer_outputs [0:31];
	reg [4:0] output_counter;
	wire layer_input_ready;
	always @(posedge clk_25m or posedge rst)
		if (rst) begin
			layer0_features[0] <= 8'd0;
			layer0_features[1] <= 8'd0;
			layer0_features[2] <= 8'd0;
			layer0_features[3] <= 8'd0;
		end
		else if (extract_ready) begin
			layer0_features[0] <= lines_cleared;
			layer0_features[1] <= holes;
			layer0_features[2] <= bumpiness;
			layer0_features[3] <= height_sum;
		end
	always @(posedge clk_25m or posedge rst)
		if (rst) begin
			ai_state <= 3'd0;
			current_layer_sel <= 2'b00;
			output_counter <= 5'd0;
		end
		else begin
			ai_state <= next_ai_state;
			case (ai_state)
				3'd1: current_layer_sel <= 2'b00;
				3'd2: current_layer_sel <= 2'b01;
				3'd3: current_layer_sel <= 2'b10;
				3'd4: current_layer_sel <= 2'b11;
				default: current_layer_sel <= 2'b00;
			endcase
			if (mmu_res_valid) begin
				output_counter <= output_counter + 1;
				layer_outputs[output_counter] <= mmu_res_out[7:0];
			end
			else if (mmu_start)
				output_counter <= 5'd0;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_ai_state = ai_state;
		mmu_start = 1'b0;
		case (ai_state)
			3'd0:
				if (extract_ready) begin
					next_ai_state = 3'd1;
					mmu_start = 1'b1;
				end
			3'd1:
				if (mmu_done) begin
					next_ai_state = 3'd2;
					mmu_start = 1'b1;
				end
			3'd2:
				if (mmu_done) begin
					next_ai_state = 3'd3;
					mmu_start = 1'b1;
				end
			3'd3:
				if (mmu_done) begin
					next_ai_state = 3'd4;
					mmu_start = 1'b1;
				end
			3'd4:
				if (mmu_done)
					next_ai_state = 3'd5;
			3'd5: next_ai_state = 3'd0;
			default: next_ai_state = 3'd0;
		endcase
	end
	reg [7:0] mmu_act_value;
	reg [5:0] input_counter;
	wire mmu_act_valid_internal;
	always @(posedge clk_25m or posedge rst)
		if (rst)
			input_counter <= 6'd0;
		else if (mmu_start)
			input_counter <= 6'd0;
		else if (mmu_act_valid_internal)
			input_counter <= input_counter + 1;
	wire [99:0] ga_line;
	wire [99:0] ga_hei;
	wire [99:0] ga_hol;
	wire [99:0] ga_bum;
	wire [99:0] mmu_in_temp;
	assign ga_line = lines_cleared * 100'd76;
	assign ga_hei = height_sum * 100'd50;
	assign ga_hol = holes * 100'd36;
	assign ga_bum = bumpiness * 100'd18;
	assign mmu_in_temp = (((ga_line + ga_hei) + ga_hol) + ga_bum) / 100'd100;
	always @(*) begin
		if (_sv2v_0)
			;
		mmu_act_value = 8'd0;
		case (current_layer_sel)
			2'b00:
				if (input_counter < 6'd4)
					mmu_act_value = mmu_in_temp[7:0];
			2'b01, 2'b10, 2'b11:
				if (input_counter < 6'd32)
					mmu_act_value = layer_outputs[input_counter[4:0]];
		endcase
	end
	assign mmu_act_valid_internal = ((ai_state != 3'd0) && (ai_state != 3'd5)) && !mmu_done;
	t01_ai_MMU mmu(
		.clk(clk_25m),
		.rst_n(!rst),
		.start(mmu_start),
		.layer_sel(current_layer_sel),
		.act_valid(mmu_act_valid_internal),
		.act_in(mmu_act_value),
		.res_valid(mmu_res_valid),
		.res_out(mmu_res_out),
		.done(mmu_done)
	);
	t01_ai_ofm_tmp ofm_tmp(
		.clk(clk_25m),
		.rst(rst || (ai_new_spawn && (gamestate == 'd1))),
		.gamestate(gamestate),
		.mmu_done(mmu_done && (current_layer_sel == 'd2)),
		.mmu_result_i(),
		.blockX_i(ai_blockX),
		.block_type_i(ofm_block_type_input),
		.blockX_o(ofm_blockX),
		.block_type_o(ofm_block_type),
		.done(ofm_layer_done),
		.lines_cleared_i(lines_cleared),
		.bumpiness_i(bumpiness),
		.heights_i(height_sum),
		.holes_i(holes)
	);
	initial _sv2v_0 = 0;
endmodule
