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
  logic [7:0] current_score, next_score;
  logic finish;

    localparam BLACK   = 3'b000;  // No color
    localparam RED     = 3'b100;  // Red only
    localparam GREEN   = 3'b010;  // Green only
    localparam BLUE    = 3'b001;  // Blue only

    // Mixed Colors
    localparam YELLOW  = 3'b110;  // Red + Green
    localparam MAGENTA = 3'b101;  // Red + Blue (Purple/Pink)
    localparam CYAN    = 3'b011;  // Green + Blue (Aqua)
    localparam WHITE   = 3'b111;  // All colors (Red + Green + Blue)


  // logic move_valid;
  // // // For testing, increment score every second
  // always_ff @(posedge onehuzz, posedge reset) begin
  //   if (reset) begin
  //     current_score <= 8'd0;
  //   end else begin
  //     current_score <= next_score;
  //   end
  // end
  // always_comb begin
  //   next_score = 'd0;

  //   if (next_score < 8'd255) begin
  //     next_score = current_score + 'b1;
  //   end else begin
  //     next_score = current_score;
  //   end
  // end
  
  logic [21:0][9:0] new_block_array; //, movement_array, current_stored_array, next_stored_array;

  // VGA driver
  vgadriver ryangosling (.clk(hz100), .rst(1'b0),  .color_in(final_color),  .red(left[5]),  
  .green(left[4]), .blue(left[3]), .hsync(left[7]),  .vsync(left[6]),  .x_out(x), .y_out(y) );
 
  // 1Hz clock divider
  clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz));



  //  blockgen dawg (.current_state(current_state_o), .enable(pb[0]),
  // .display_array(new_block_array));

  // movedown lion (.clk(onehuzz), .rst(reset), 
  // .input_array(new_block_array), .output_array(movement_array), 
  // .current_state(current_state_o), .finish(finish));

  // gridstore grid (.finish(finish), .current_stored_array(current_stored_array), 
  // .movement_array(movement_array), .next_stored_array(next_stored_array) );
  //tetrisGrid gurt (.x(x),  .y(y),  .shape_color(grid_color_hold), .display_array(next_stored_array));
  
  
  tetrisFSM plait (.clk(hz100), .onehuzz(onehuzz), .reset(reset), 
  .finish(red), 
  .spawn_enable(), .en_newgame(pb[19]), .blocktype(right[2:0]), 
  .display_array(new_block_array)
);

  tetrisGrid durt (.x(x),  .y(y),  .shape_color(grid_color_movement), .display_array(new_block_array));

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
  end else if (grid_color_movement != 3'b000) begin
    final_color = grid_color_movement;
  end else begin
    final_color = grid_color_hold;  // Default to grid color
  end
end

endmodule