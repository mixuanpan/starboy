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

// Pin assignments
assign J40_a15 = ~switch4;
assign J40_j5 = rst;

  // Internal signals
  logic [9:0] x, y;
  logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold, album;  
  logic onehuzz;
  logic [9:0] current_score;
  logic finish, gameover;
  logic [24:0] scoremod;
  logic [19:0][9:0] new_block_array;
  logic speed_mode_o;
  logic [19:0][9:0][2:0] final_display_color;

  // AI signals
  logic [4:0] current_piece_type;  // From game logic
  logic ai_enable;                 // Enable AI mode
  logic [5:0] ai_best_move_id;     // AI's recommended move
  logic signed [17:0] ai_best_q_value; // AI's confidence score
  logic ai_done;                   // AI inference complete
  logic ai_trigger;                // Trigger AI inference

// Color priority logic: starboy and score display take priority over grid
always_comb begin
  if (starboy_color != 3'b000) begin  // If starboy display has color (highest priority)
    final_color = starboy_color;
  end else if (score_color != 3'b000) begin  // If score display has color
    final_color = score_color;
  end else begin
    final_color = grid_color_movement;
  end
end

// AI control logic
assign ai_enable = J40_j5;  // Use J39_b20 to enable AI mode
assign ai_trigger = ai_enable & onehuzz;  // Trigger AI on clock edge when enabled

// AI status indication on unused outputs
assign J40_n4 = ai_enable;      // LED to show AI mode is active
assign J40_k3 = ai_done;        // LED to show AI has recommendation
assign J40_p5 = ai_enable & ~ai_done;  // LED to show AI is thinking

// Optional: Use remaining outputs for debugging
assign J40_n5 = |ai_best_move_id[2:0];  // Show move ID (low bits)
assign J40_l5 = |ai_best_move_id[5:3];  // Show move ID (high bits)

//=================================================================================
// MODULE INSTANTIATIONS
//=================================================================================

  logic right, left, rotate_r, rotate_l;

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
      .scoremod(scoremod)
    );
    
    // Game Logic - Enhanced with AI interface
    t01_ai_tetrisFSM plait (
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
      .start_i(J39_b15),
      // AI interface
      .current_piece_type(current_piece_type),  // Output current piece type
      .ai_enable(ai_enable ),                    // Input AI enable
      .ai_best_move_id(ai_best_move_id),       // Input AI move recommendation
      .ai_done(ai_done)                        // Input AI inference complete
    );
    
    // Tetris Grid Display
    t01_tetrisGrid durt (
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

    //=============================================================================
    // agentic ai accelerator bsb saas yc startup bay area matcha lababu stussy !!!
    //=============================================================================

    // AI Pipeline Integration
    t01_ai_mylestop ai_brain (
      .clk(clk_25m),                   // Use 25MHz clock for AI processing
      .reset_n(~rst),                  // Active low reset
      .start_ai(ai_trigger),           // Trigger AI inference
      .display_array(new_block_array), // Current board state
      .piece_type(current_piece_type), // Current tetromino type
      .best_move_id(ai_best_move_id),  // AI's recommended move
      .best_q_value(ai_best_q_value),  // AI's confidence score
      .done_ai(ai_done)                // AI inference complete signal
    );

    // Use remaining outputs for AI status/debugging
    assign leds[0] = ai_enable;          // Show AI mode status
    assign leds[1] = ai_done;            // Show AI completion status  
    assign leds[2] = |ai_best_q_value[17:16]; // Show high bits of Q-value
    
    assign tftstate = ai_best_move_id[2:0]; // Show move ID on debug outputs
    assign test = ai_trigger;            // Show AI trigger pulses

endmodule