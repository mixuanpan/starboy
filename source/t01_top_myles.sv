`default_nettype none
module top #(
    parameter ADDR_W = 32, 
    parameter LEN_W = 16
)(
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  // Color definitions  
  localparam BLACK   = 3'b000;  // No color
  localparam RED     = 3'b100;  // Red only
  localparam GREEN   = 3'b010;  // Green only
  localparam BLUE    = 3'b001;  // Blue only

  // Mixed Colors
  localparam YELLOW  = 3'b110;  // Red + Green
  localparam MAGENTA = 3'b101;  // Red + Blue (Purple/Pink)
  localparam CYAN    = 3'b011;  // Green + Blue (Aqua)
  localparam WHITE   = 3'b111;  // All colors (Red + Green + Blue)

  // Internal signals
  logic [9:0] x, y;
  logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold;  
  logic onehuzz;
  logic [7:0] current_score;
  logic finish, gameover;
  logic [24:0] scoremod;
  logic [19:0][9:0] new_block_array;
  logic speed_mode_o;

  // AI signals
  logic [4:0] current_piece_type;  // From game logic
  logic ai_enable;                 // Enable AI mode (pb[18] for example)
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
assign ai_enable = pb[18];  // Use button 18 to enable AI mode
assign ai_trigger = ai_enable & onehuzz;  // Trigger AI on clock edge when enabled

//=================================================================================
// MODULE INSTANTIATIONS
//=================================================================================

    //=============================================================================
    // tetris game !!!
    //=============================================================================
    
    // VGA driver 
    t01_vgadriver ryangosling (
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
  
    // Clock Divider
    t01_clkdiv1hz yo (
      .clk(hz100), 
      .rst(reset), 
      .newclk(onehuzz), 
      .speed_up(speed_mode_o),
      .scoremod(scoremod)
    );

    // Speed Controller
    t01_speed_controller jorkingtree (
      .clk(hz100),
      .reset(reset),
      .current_score(current_score),
      .scoremod(scoremod)
    );
    
    // Game Logic - Modified to include AI interface
    t01_ai_tetrisFSM plait (
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
      .start_i(pb[19]),
      // AI interface (you may need to add these ports to your FSM)
      .current_piece_type(current_piece_type),  // Output current piece type
      .ai_enable(ai_enable),                    // Input AI enable
      .ai_best_move_id(ai_best_move_id),       // Input AI move recommendation
      .ai_done(ai_done)                        // Input AI inference complete
    );
    
    // Tetris Grid Display
    t01_tetrisGrid durt (
      .x(x),  
      .y(y),  
      .shape_color(grid_color_movement), 
      .display_array(new_block_array), 
      .gameover(gameover)
    );

    // Score Display
    t01_scoredisplay ralsei (
      .clk(onehuzz),
      .rst(reset),
      .score(current_score),
      .x(x),
      .y(y),
      .shape_color(score_color)
    );

    // STARBOY Display
    // t01_starboyDisplay silly (
    //   .clk(onehuzz),
    //   .rst(reset),
    //   .x(x),
    //   .y(y),
    //   .shape_color(starboy_color)
    // );

    
    //=============================================================================
    // agentic ai accelerator bsb saas yc startup bay area matcha lababu stussy !!!
    //=============================================================================

    // AI Pipeline Integration
    t01_ai_mylestop ai_brain (
      .clk(hz100),
      .reset_n(~reset),
      .start_ai(ai_trigger),           // Trigger AI inference
      .display_array(new_block_array), // Current board state
      .piece_type(current_piece_type), // Current tetromino type
      .best_move_id(ai_best_move_id),  // AI's recommended move
      .best_q_value(ai_best_q_value),  // AI's confidence score
      .done_ai(ai_done)                // AI inference complete signal
    );

    // Optional: Display AI status on 7-segment displays
    // Show AI move recommendation on ss7-ss6
    always_comb begin
      if (ai_enable) begin
        ss7 = 8'b10001000;  // 'A' for AI mode
        ss6 = ai_best_move_id[3:0] < 10 ? 
              (8'b11000000 | ai_best_move_id[3:0]) :  // Show move ID (0-9)
              8'b10001001;  // 'H' for move ID >= 10
        ss5 = ai_best_move_id[5:4] < 4 ? 
              (8'b11000000 | ai_best_move_id[5:4]) : 
              8'b11111111;  // Blank if high bits not valid
        ss4 = ai_done ? 8'b10000001 : 8'b11111111;  // 'U' when AI done, blank otherwise
      end else begin
        ss7 = 8'b11111111;  // Blank displays when AI disabled
        ss6 = 8'b11111111;
        ss5 = 8'b11111111;
        ss4 = 8'b11111111;
      end
      
      // Keep other displays for score/game info
      ss3 = 8'b11111111;
      ss2 = 8'b11111111;
      ss1 = 8'b11111111;
      ss0 = 8'b11111111;
    end

    // Optional: RGB LED to indicate AI status
    assign red   = ai_enable & ~ai_done;   // Red when AI is thinking
    assign green = ai_enable & ai_done;    // Green when AI has recommendation
    assign blue  = ~ai_enable;             // Blue when in manual mode

  endmodule