`default_nettype none
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

  logic [3:0] d0_w [1:64]; 
  assign left [3:0] = d0_w[1]; 
  assign right [3:0] = d0_w[64]; 
  ai_wb_reader read_wb (.d0_w(d0_w), .d0_b(), .d1_w(), .d1_b(), .d2_w(), .d2_b(), .d3_w(), .d3_b()); 
//   // Color definitions  
//   localparam BLACK   = 3'b000;  // No color
//   localparam RED     = 3'b100;  // Red only
//   localparam GREEN   = 3'b010;  // Green only
//   localparam BLUE    = 3'b001;  // Blue only

//   // Mixed Colors
//   localparam YELLOW  = 3'b110;  // Red + Green
//   localparam MAGENTA = 3'b101;  // Red + Blue (Purple/Pink)
//   localparam CYAN    = 3'b011;  // Green + Blue (Aqua)
//   localparam WHITE   = 3'b111;  // All colors (Red + Green + Blue)

//   // Internal signals
//   logic [9:0] x, y;
//   logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold;  
//   logic onehuzz;
//   logic [7:0] current_score;
//   logic finish, gameover;
//   logic [24:0] scoremod;
//   logic [19:0][9:0] new_block_array;
//   logic speed_mode_o;

// // Color priority logic: starboy and score display take priority over grid
// always_comb begin
//   if (starboy_color != 3'b000) begin  // If starboy display has color (highest priority)
//     final_color = starboy_color;
//   end else if (score_color != 3'b000) begin  // If score display has color
//     final_color = score_color;
//   end else begin
//     final_color = grid_color_movement;
//   end 
// end

// //=================================================================================
// // MODULE INSTANTIATIONS
// //=================================================================================

//     //=============================================================================
//     // tetris game !!!
//     //=============================================================================
    
//     // VGA driver 
//     vgadriver ryangosling (
//       .clk(hz100), 
//       .rst(1'b0),  
//       .color_in(final_color),  
//       .red(left[5]),  
//       .green(left[4]), 
//       .blue(left[3]), 
//       .hsync(left[7]),  
//       .vsync(left[6]),  
//       .x_out(x), 
//       .y_out(y)
//     );
  
//   // Game Logic
//   tetrisFSM plait (
//     .clk(hz100), 
//     .onehuzz(onehuzz), 
//     .reset(reset), 
//     .rotate_l(pb[11]), 
//     .speed_up_i(pb[12]|| pb[15]), 
//     .right_i(pb[0]), 
//     .left_i(pb[3]), 
//     .rotate_r(pb[8]), 
//     .en_newgame(pb[19]), 
//     .speed_mode_o(speed_mode_o),
//     .display_array(new_block_array), 
//     .gameover(gameover), 
//     .score(current_score), 
//     .start_i(pb[19])
//   );
//   //   tetrisFSM plait (
//   //   .clk(hz100), 
//   //   .onehuzz(onehuzz), 
//   //   .reset(reset), 
//   //   .rotate_l(pb[1]), 
//   //   .speed_up_i(pb[2]|| pb[15]), 
//   //   .right_i(pb[6]), 
//   //   .left_i(pb[7]), 
//   //   .rotate_r(pb[0]), 
//   //   .en_newgame(pb[19]), 
//   //   .speed_mode_o(speed_mode_o),
//   //   .display_array(new_block_array), 
//   //   .gameover(gameover), 
//   //   .score(current_score), 
//   //   .start_i(pb[19])
//   // );
  
//   // Tetris Grid Display
//   tetrisGrid durt (
//     .x(x),  
//     .y(y),  
//     .shape_color(grid_color_movement), 
//     .display_array(new_block_array), 
//     .gameover(gameover)
//   );
//     // Clock Divider
//     clkdiv1hz yo (
//       .clk(hz100), 
//       .rst(reset), 
//       .newclk(onehuzz), 
//       .speed_up(speed_mode_o),
//       .scoremod(scoremod)
//     );

//     // Speed Controller
//     speed_controller jorkingtree (
//       .clk(hz100),
//       .reset(reset),
//       .current_score(current_score),
//       .scoremod(scoremod)
//     );

//   // // STARBOY Display
//   starboyDisplay silly (
//     .clk(onehuzz),
//     .rst(reset),
//     .x(x),
//     .y(y),
//     .shape_color(starboy_color)
//   );
//     // Score Display
//     scoredisplay ralsei (
//       .clk(onehuzz),
//       .rst(reset),
//       .score(current_score),
//       .x(x),
//       .y(y),
//       .shape_color(score_color)
//     );

//     //=============================================================================
//     // agentic ai accelerator bsb saas yc startup bay area matcha lababu stussy !!!
//     //=============================================================================

  endmodule