module top (
    input  logic clk, //12mhz
    input  logic clk_25m,

    input  logic rst, //switch 2


    input logic switch4,

    //mixed j39
    input logic J39_b15, J39_c15, J39_b20, J39_e11,

    //right line J39
    input logic J39_b10, J39_a14, J39_d13, J39_e12,

    input logic J40_m3,

    //right line J40
    output logic J40_a15, J40_h2, J40_j4, J40_j3, J40_l4, J40_m4, J40_n4,

    //left line J40
    output logic J40_p5, J40_n5, J40_l5, J40_k3, J40_j5,

    output logic [2:0] tftstate, //ignore
    output logic [2:0] leds, //ignore

    output logic test //ignore
);
    // Add your logic here

// assign J40_a15 = clk_25m;


assign J40_a15 = ~switch4;

assign J40_j5 = rst;



  // Internal signals
  logic [9:0] x, y;
  logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold, credits;  
  logic onehuzz;
  logic [9:0] current_score;
  logic finish, gameover;
  logic [3:0] gamestate;

  logic [24:0] scoremod;
  logic [19:0][9:0] new_block_array;
  logic speed_mode_o;
logic [19:0][9:0][2:0] final_display_color;
// Color priority logic: starboy and score display take priority over grid
always_comb begin
  if (starboy_color != 3'b000) begin  // If starboy display has color (highest priority)
    final_color = starboy_color;
  end else if (score_color != 3'b000) begin  // If score display has color
    final_color = score_color;
  end else if (credits != 3'b000) begin
    final_color = credits;
  end else begin
    final_color = grid_color_movement;
    end
end


//=================================================================================
// MODULE INSTANTIATIONS
//=================================================================================

  logic right, left, rotate_r, rotate_l, start_i;

  t01_debounce NIRAJMENONFANCLUB (.clk(clk_25m), .pb(J39_e12), .button(right));
  t01_debounce BENTANAYAYAYAYAYAY (.clk(clk_25m), .pb(J39_d13), .button(left));
  t01_debounce nandyhu (.clk(clk_25m), .pb(J39_a14), .button(rotate_r));
  t01_debounce benmillerlite (.clk(clk_25m), .pb(J39_b10), .button(rotate_l));


    //=============================================================================
    // tetris game !!!
    //=============================================================================
    
    // VGA driver 
    t01_vgadriver ryangosling (
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
  
    // Clock Divider (gurt)
    t01_clkdiv1hz yo (
      .clk(clk_25m), 
      .rst(rst), 
      .newclk(onehuzz), 
      .speed_up(speed_mode_o),
      .scoremod(scoremod)
    );

    // Speed Controller
    t01_speed_controller jorkingtree (
      .clk(clk_25m),
      .reset(rst),
      .current_score(current_score),
      .scoremod(scoremod),
      .gamestate(gamestate)
    );
    
    // Game Logic
    t01_tetrisFSM plait (
      .gamestate(gamestate),
      .clk(clk_25m), 
      .onehuzz(onehuzz), 
      .reset(rst), 
      .rotate_l(rotate_l), 
      .final_display_color(final_display_color),
      .speed_up_i(J39_c15), 
      .en_newgame(J39_b15),
      .right_i(right), 
      .left_i(left), 
      .rotate_r(rotate_r), 
      .speed_mode_o(speed_mode_o),
      .display_array(new_block_array), 
      .gameover(gameover), 
      .score(current_score), 
      .start_i(J39_b15)
    );
    
    // Tetris Grid Display
    t01_tetrisGrid miguelohara (
      .x(x),  
      .y(y),  
      .shape_color(grid_color_movement), 
      .final_display_color(final_display_color),
      .gameover(gameover)
    );

    // Score Display
    t01_scoredisplay ralsei (
      .clk(onehuzz),
      .rst(rst),
      .score(current_score),
      .x(x),
      .y(y),
      .shape_color(score_color)
    );

    // STARBOY Display
    t01_starboyDisplay silly (
      .clk(onehuzz),
      .rst(rst),
      .x(x),
      .y(y),
      .shape_color(starboy_color)
    );

    t01_tetrisCredits nebulabubu (
        .x(x),
        .y(y),
        .text_color(credits)
    );

  logic [15:0] lfsr_reg;

    t01_counter chchch (
      .clk(clk10k),
      .rst(rst),
      .enable('1),
      .lfsr_reg(lfsr_reg),
      .block_type()
    );

  logic clk10k;

    t01_clkdiv10k thebackofmyfavoritestorespencers(
      .clk(clk_25m),
      .rst(rst),
      .newclk(clk10k)
    );

    // assign J40_n4 = lfsr_reg[0];

    t01_musicman piercetheveil (
      .clk(clk_25m),
      .rst(rst || gameover),
      .square_out(J40_n4),
      .lfsr(lfsr_reg)
    );

    //=============================================================================
    // agentic ai accelerator bsb saas yc startup bay area matcha lababu stussy !!!
    //=============================================================================
    logic [19:0][9:0] current_tetris_grid; // stream for feature extract 
    logic [199:0] fe_board; 
    logic [4:0] current_blockY, current_layer_block_type; 
    logic [3:0] current_blockX; 
    logic new_layer; 

    t01_game_engine ai_game_engine (
      .clk(clk_25m), 
      .rst(rst), 
      .final_display_color(), 
      .current_tetris_grid(current_tetris_grid), 
      .extract_start(extract_start), 
      .extract_ready(extract_ready), 
      .fe_board(fe_board), 
      .current_blockX(current_blockX), 
      .current_blockY(current_blockY), 
      .current_block_type(current_layer_block_type), 
      .ofm_layer_done(ofm_layer_done), 
      .ofm_blockX(ofm_blockX), 
      .ofm_blockY(ofm_blockY), 
      .ofm_block_type(ofm_block_type), 
      .new_layer(new_layer)
    );

    logic [39:0]          extract_start;
    logic [39:0]          extract_ready;
    logic [2:0]           lines_cleared;
    logic [7:0]           holes;
    logic [7:0]           bumpiness;
    logic [7:0]           height_sum;
  
    t01_ai_feature_extract fe (
    .clk           (clk_25m),
    .reset         (rst || new_layer),
    .start_extract (extract_start),
    .next_board    (fe_board),
    .extract_ready (extract_ready),
    .lines_cleared (lines_cleared),
    .holes         (holes),
    .bumpiness     (bumpiness),
    .height_sum    (height_sum)
    );

  logic        mmu_start;
  logic        mmu_act_valid;
  logic [7:0]  mmu_act_in;
  logic        mmu_res_valid;
  logic [17:0] mmu_res_out;
  logic        mmu_done;
  logic [1:0]  mmu_layer_sel;

  t01_ai_MMU mmu (
    .clk       (clk_25m),
    .rst_n     (!rst || !new_layer),
    .start     (mmu_start),
    .layer_sel (mmu_layer_sel),
    .act_valid (mmu_act_valid),
    .act_in    (mmu_act_in),
    .res_valid (mmu_res_valid),
    .res_out   (mmu_res_out),
    .done      (mmu_done)
  );

    logic [4:0] ofm_blockY, ofm_block_type; 
    logic [3:0] ofm_blockX; 
    logic ofm_layer_done; 

  t01_ai_ofm ofm (
    .clk(clk_25m), 
    .rst(rst || new_layer), 
    .mmu_done(mmu_done), 
    .n_mmu_result(mmu_res_out), 
    .n_blockX(current_blockX), 
    .n_blockY(current_blockY), 
    .n_block_type(current_layer_block_type), 
    .blockX(ofm_blockX), 
    .blockY(ofm_blockY), 
    .block_type(ofm_block_type), 
    .done(ofm_layer_done) 
  );
  endmodule
