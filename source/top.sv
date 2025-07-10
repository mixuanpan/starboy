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
  logic [2:0] grid_color, score_color, starboy_color, final_color;  
  logic onehuzz;
  logic [7:0] current_score, next_score;
  

//     localparam BLACK   = 3'b000;  // No color
//     localparam RED     = 3'b100;  // Red only
//     localparam GREEN   = 3'b010;  // Green only
//     localparam BLUE    = 3'b001;  // Blue only

//     // Mixed Colors
//     localparam YELLOW  = 3'b110;  // Red + Green
//     localparam MAGENTA = 3'b101;  // Red + Blue (Purple/Pink)
//     localparam CYAN    = 3'b011;  // Green + Blue (Aqua)
//     localparam WHITE   = 3'b111;  // All colors (Red + Green + Blue)

//   logic [4:0] blockY, blockYN; 

//     typedef enum logic [2:0] {
//         RIGHT = 3'b0, 
//         LEFT = 3'b1, 
//         ROR = 3'b10, // ROTATE RIGHT
//         ROL = 3'b11, // ROTATE LEFT 
//         DOWN = 3'b100, 
//         NONE = 3'b111
//     } move_t; 

//     move_t move, current_move;
//   logic move_valid;
//   // // For testing, increment score every second
//   always_ff @(posedge onehuzz, posedge reset) begin
//     if (reset) begin
//       current_score <= 8'd0;
//     end else begin
//       current_score <= next_score;
//     end
//   end
//   always_comb begin
//     next_score = 'd0;

//     if (next_score < 8'd255) begin
//       next_score = current_score + 'b1;
//     end else begin
//       next_score = current_score;
//     end
//   end
  
  logic [21:0][9:0][2:0] new_block_array, stored_array;

  // VGA driver
  vgadriver ryangosling (.clk(hz100), .rst(1'b0),  .color_in(final_color),  .red(left[5]),  
  .green(left[4]), .blue(left[3]), .hsync(left[7]),  .vsync(left[6]),  .x_out(x), .y_out(y) );
 
//   // 1Hz clock divider
//   clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz));

//   // Tetris grid

//     logic [2:0] current_state_o;
//     logic [2:0] counter_o;


//   counter blockcount(.clk(hz100), .rst(reset), .button_i(pb[19]),
//    .current_state_o(current_state_o), .counter_o(counter_o));
   
//   blockgen dawg (.current_state(current_state_o), 
//   .display_array(new_block_array));

  tetris_fsm game (.clk(hz100), .rst(reset), .en(pb[19]), .right(pb[3]), .left(pb[14]), .rr(pb[13]), .rl(pb[12]), .down(pb[11]), .state_tb(right[4:0]), .grid(stored_array), 
  .done_extracting(blue), .move_state(left[2:0]), .last_state(red));


//   inputbus smalldog (.clk(hz100), .rst_n(~reset), .btn_raw(pb[4:0]), 
//   .move(move), .move_valid(move_valid));
  
//   movedown lion (.clk(onehuzz), .rst(reset), 
//   .input_array(new_block_array), .output_array(stored_array), 
//   .current_state(current_state_o));
 
//   moveleftright adrian (.clk(hz100), .rst(reset), 
//   .input_array(stored_array), .current_state(current_state_o), 
//   .move_left(move_valid&& (current_move ==LEFT)),
//   .move_right(move_valid&&current_move==RIGHT),
//   .output_array(leftright_array));

  tetris_grid gurt ( .x(x),  .y(y),  .shape_color(grid_color), .display_array(stored_array));

  
  // Score display
  // scoredisplay score_disp (.clk(onehuzz),.rst(reset),.score(current_score),.x(x),.y(y),.shape_color(score_color));
  
    // STARBOY display
  // starboydisplay starboy_disp (.clk(onehuzz),.rst(reset),.x(x),.y(y),.shape_color(starboy_color));


// Color priority logic: starboy and score display take priority over grid
always_comb begin
  // if (starboy_color != 3'b000) begin  // If starboy display has color (highest priority)
  //   final_color = starboy_color;
  // end else if (score_color != 3'b000) begin  // If score display has color
  //   final_color = score_color;
  // end else begin
    final_color = grid_color;  // Default to grid color
  // end
end

endmodule