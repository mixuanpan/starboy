`default_nettype none
// Empty top module

module top (
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
  // Your code goes here...
  logic [9:0] x, y;
  logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold;  
  logic onehuzz;
  logic [7:0] current_score, prev_score;
  logic finish, gameover;

    localparam BLACK   = 3'b000;  // No color
    localparam RED     = 3'b100;  // Red only
    localparam GREEN   = 3'b010;  // Green only
    localparam BLUE    = 3'b001;  // Blue only

    // Mixed Colors
    localparam YELLOW  = 3'b110;  // Red + Green
    localparam MAGENTA = 3'b101;  // Red + Blue (Purple/Pink)
    localparam CYAN    = 3'b011;  // Green + Blue (Aqua)
    localparam WHITE   = 3'b111;  // All colors (Red + Green + Blue)

  logic [4:0] increase, newval;
  logic [24:0] scoremod, next_mod;
  logic [19:0][9:0] new_block_array; //, movement_array, current_stored_array, next_stored_array;
  logic speed_increased, next_speed_increased;

  // VGA driver
  vgadriver ryangosling (.clk(hz100), .rst(1'b0),  .color_in(final_color),  .red(left[5]),  
  .green(left[4]), .blue(left[3]), .hsync(left[7]),  .vsync(left[6]),  .x_out(x), .y_out(y) );
 
  // 1Hz clock divider
  clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz), .scoremod(scoremod));


//logic for increased iming as game progresses
always_ff @(posedge hz100, posedge reset) begin
    if (reset) begin
        scoremod <= '0;
        increase <= 1;
        prev_score <= '0;
        speed_increased <= 1'b0;
    end else begin
        scoremod <= next_mod;
        prev_score <= current_score;
        speed_increased <= next_speed_increased;
    end
end

always_comb begin
    next_mod = scoremod;
    newval = increase;
    next_speed_increased = speed_increased;
    
    // Reset flag when score changes but isn't at a multiple of 5
    if (current_score != prev_score && current_score % 5 != 0) begin
        next_speed_increased = 1'b0;
    end
    
    // Increase speed when we hit a multiple of 5 and haven't already increased
    if (current_score != prev_score && current_score % 5 == 0 && 
        current_score != '0 && !speed_increased) begin
        next_mod = scoremod + 25'd1_000_000;
        next_speed_increased = 1'b1;
    end
end
  
  tetrisFSM plait (.clk(hz100), .onehuzz(onehuzz), .reset(reset), .rotate_l(),
  .right_i(pb[8]), .left_i(pb[11]), .rotate_r(pb[7]), .en_newgame(pb[19]), 
  .display_array(new_block_array), .gameover(gameover), .score(current_score), .start_i(pb[19])
);

  tetrisGrid durt (.x(x),  .y(y),  .shape_color(grid_color_movement), .display_array(new_block_array), .gameover(gameover));

  // Score display
  scoredisplay score_disp (.clk(onehuzz),.rst(reset),.score(current_score),.x(x),.y(y),.shape_color(score_color));
  
    // STARBOY display
   starboyDisplay starboy_disp (.clk(onehuzz),.rst(reset),.x(x),.y(y),.shape_color(starboy_color));


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

endmodule
