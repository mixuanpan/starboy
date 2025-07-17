`default_nettype none
// Empty top module

module top #(
    // parameter int INST_WIDTH = 32,  // width of the instruction word 
    // parameter int H_WIDTH = 10, // input height bits 
    // parameter int W_WIDTH = 10, // input width bits 
    // parameter int C_WIDTH = 8, // number of input channels 
    // parameter int K_WIDTH = 4, // kernel_size bits 
    // parameter int S_WIDTH = 4, // stride bits 
    // parameter int TYPE_WIDTH = 4, // layer_type bits 
    // parameter int HOUT_WIDTH = H_WIDTH + 1,
    // parameter int WOUT_WIDTH = W_WIDTH + 1, 
    // parameter ADDR_W = 32, 
    // parameter LEN_W = 16  
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

  logic [9:0] x, y;
  logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold;  
  logic onehuzz;
  logic [7:0] current_score, next_score;
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


  
  logic [19:0][9:0] new_block_array; //, movement_array, current_stored_array, next_stored_array;

  // VGA driver
  vgadriver ryangosling (.clk(hz100), .rst(1'b0),  .color_in(final_color),  .red(left[5]),  
  .green(left[4]), .blue(left[3]), .hsync(left[7]),  .vsync(left[6]),  .x_out(x), .y_out(y) );
 
  // 1Hz clock divider
  clkdiv1hz yo (.clk(hz100), .rst(reset), .newclk(onehuzz));


  
//   tetrisFSM plait (.clk(hz100), .onehuzz(onehuzz), .reset(reset),
//   .right_i(pb[8]), .left_i(pb[11]), .rotate_r(pb[6]), .rotate_l(pb[7]), .en_newgame(pb[19]), 
//   .display_array(new_block_array), .gameover(gameover), .score(current_score), .start_i(pb[19])
// );

  tetris_fsm plait (.clk(hz100), .onehuzz(onehuzz), .reset(reset),
  .right_i(pb[8]), .left_i(pb[11]), .rotate_r(pb[6]), .rotate_l(pb[7]), .en_newgame(pb[19]), 
  .display_array(new_block_array), .gameover(gameover), .score(current_score), .start_i(pb[19])
);

  tetrisGrid durt (.x(x),  .y(y),  .shape_color(grid_color_movement), .display_array(new_block_array), .gameover(gameover));

  // Score display
  // scoredisplay score_disp (.clk(onehuzz),.rst(reset),.score(current_score),.x(x),.y(y),.shape_color(score_color));
  
    // STARBOY display
  // starboyDisplay starboy_disp (.clk(onehuzz),.rst(reset),.x(x),.y(y),.shape_color(starboy_color));



// // Internal signals
// logic [2:0] current_state;
// logic [2:0] current_state_counter;
// logic [4:0] blockY;
// logic [3:0] blockX;
// logic [4:0] current_block_type;
// logic [4:0] next_current_block_type;
// logic [3:0][3:0] current_block_pattern;
// logic [19:0][9:0] stored_array;
// logic [19:0][9:0] falling_block_display;
// logic [19:0][9:0] cleared_array;
// logic [4:0] eval_row;
// logic line_clear_found;
// logic eval_complete;
// logic collision_bottom, collision_left, collision_right;
// logic rotate_pulse, left_pulse, right_pulse;
// logic drop_tick;



       //WIRE UP LATER IN THE FUTURE PLEASE 
// // External modules (keep as in original)
// counter paolowang (.clk(clk), .rst(reset), .button_i(current_state == 3'd1),
// .current_state_o(current_state_counter), .counter_o());

// synckey alexanderweyerthegreat (.rst(reset), .clk(clk), .out(), .in({19'b0, rotate_r}), .strobe(rotate_pulse)); 
// synckey puthputhboy (.rst(reset), .clk(clk), .out(), .in({19'b0, left_i}), .strobe(left_pulse)); 
// synckey JohnnyTheKing (.rst(reset), .clk(clk), .out(), .in({19'b0, right_i}), .strobe(right_pulse)); 

// // Pulse sync for onehuzz
// logic onehuzz_sync0, onehuzz_sync1;
// always_ff @(posedge clk, posedge reset) begin
//     if (reset) begin
//         onehuzz_sync0 <= 0;
//         onehuzz_sync1 <= 0;
//     end else begin
//         onehuzz_sync0 <= onehuzz;
//         onehuzz_sync1 <= onehuzz_sync0;
//     end
// end
// assign drop_tick = onehuzz_sync1 & ~onehuzz_sync0;

// // Internal signals
// logic [2:0] current_state;
// logic [2:0] current_state_counter;
// logic [4:0] blockY;
// logic [3:0] blockX;
// logic [4:0] current_block_type;
// logic [4:0] next_current_block_type;
// logic [3:0][3:0] current_block_pattern;
// logic [19:0][9:0] stored_array;
// logic [19:0][9:0] falling_block_display;
// logic [19:0][9:0] cleared_array;
// logic [4:0] eval_row;
// logic line_clear_found;
// logic eval_complete;
// logic collision_bottom, collision_left, collision_right;
// logic rotate_pulse, left_pulse, right_pulse;
// logic drop_tick;

// // External modules (keep as in original)
// counter paolowang (.clk(clk), .rst(reset), .button_i(current_state == 3'd1),
// .current_state_o(current_state_counter), .counter_o());

// synckey alexanderweyerthegreat (.rst(reset), .clk(clk), .out(), .in({19'b0, rotate_r}), .strobe(rotate_pulse)); 
// synckey puthputhboy (.rst(reset), .clk(clk), .out(), .in({19'b0, left_i}), .strobe(left_pulse)); 
// synckey JohnnyTheKing (.rst(reset), .clk(clk), .out(), .in({19'b0, right_i}), .strobe(right_pulse)); 

// // Pulse sync for onehuzz
// logic onehuzz_sync0, onehuzz_sync1;
// always_ff @(posedge clk, posedge reset) begin
//     if (reset) begin
//         onehuzz_sync0 <= 0;
//         onehuzz_sync1 <= 0;
//     end else begin
//         onehuzz_sync0 <= onehuzz;
//         onehuzz_sync1 <= onehuzz_sync0;
//     end
// end
// assign drop_tick = onehuzz_sync1 & ~onehuzz_sync0;


    
// // Module instantiations
// fsm_state_controller fsm_ctrl (
//     .clk(clk), .reset(reset), .start_i(start_i),
//     .collision_bottom(collision_bottom), .rotate_pulse(rotate_pulse),
//     .current_block_type(current_block_type), .stored_array(stored_array),
//     .eval_complete(eval_complete), .gameover(gameover)
// );

// line_clear_evaluator line_eval (
//     .clk(clk), .reset(reset), .current_state(current_state),
//     .stored_array(stored_array), .eval_row(eval_row),
//     .line_clear_found(line_clear_found), .eval_complete(eval_complete),
//     .cleared_array(cleared_array), .score(score)
// );

// block_position_controller pos_ctrl (
//     .clk(clk), .reset(reset), .drop_tick(drop_tick),
//     .current_state(current_state), .current_state_counter(current_state_counter),
//     .left_pulse(left_pulse), .right_pulse(right_pulse),
//     .collision_bottom(collision_bottom), .collision_left(collision_left), .collision_right(collision_right),
//     .next_current_block_type(next_current_block_type),
//     .blockY(blockY), .blockX(blockX), .current_block_type(current_block_type)
// );

// block_type_rotator type_rot (
//     .current_state(current_state), .current_block_type(current_block_type),
//     .next_current_block_type(next_current_block_type)
// );

// stored_array_manager array_mgr (
//     .clk(clk), .reset(reset), .current_state(current_state),
//     .eval_complete(eval_complete), .falling_block_display(falling_block_display),
//     .cleared_array(cleared_array), .stored_array(stored_array)
// );

// block_pattern_generator pattern_gen (
//     .current_block_type(current_block_type), .current_block_pattern(current_block_pattern)
// );

// collision_display_controller collision_ctrl (
//     .blockY(blockY), .blockX(blockX), .current_block_pattern(current_block_pattern),
//     .stored_array(stored_array), .collision_bottom(collision_bottom),
//     .collision_left(collision_left), .collision_right(collision_right),
//     .falling_block_display(falling_block_display)
// );

// display_output_controller display_ctrl (
//     .current_state(current_state), .stored_array(stored_array),
//     .falling_block_display(falling_block_display), .cleared_array(cleared_array),
//     .display_array(display_array)
// );

    
    

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


// connections for the ai 
    // logic cs, we; 
    // logic start_layer, start_decoded, relu_en, pool_en, seq_start; 
    // logic mem_read_done, mem_write_done, seq_done, layer_done; 
    // logic mem_read_req, mem_write_req, phase_fetch, phase_compute, phase_writeback;
    // logic conv_valid, relu_valid, pool_valid; 

    // logic [INST_WIDTH-1:0] inst_word_in; // 32-bit layer descripter 
    // logic [H_WIDTH-1:0] in_height; 
    // logic [W_WIDTH-1:0] in_width; 
    // logic [C_WIDTH-1:0] in_ch; 
    // logic [K_WIDTH-1:0] kernel_size; 
    // logic [S_WIDTH-1:0] stride; 
    // logic [TYPE_WIDTH-1:0] layer_type; 
    // logic [ADDR_W-1:0] ifm_base, ofm_base, mem_read_addr, mem_write_addr; 
    // logic [LEN_W-1:0] ifm_len, ofm_len, mem_read_len, mem_write_len; 
    // logic [HOUT_WIDTH-1:0] row_cnt;
    // logic [WOUT_WIDTH-1:0] col_cnt;

    // // Control Unit 
    // ai_cu_id instruction_decoder (
    //     .clk(hz100), .rst(reset), 
    //     .start_layer(start_layer), 
    //     .inst_word_in(inst_word_in), 
    //     .start_decoded(start_decoded), 
    //     .kernel_size(kernel_size), 
    //     .stride(stride), 
    //     .relu_en(relu_en), 
    //     .pool_en(pool_en), 
    //     .layer_type(layer_type)
    // ); 

    // ai_cu_fsm cu_fsm (
    //     .clk(hz100), .rst(reset), 
    //     .start_decoded(start_decoded), 
    //     .mem_read_done(mem_read_done), 
    //     .mem_write_done(mem_write_done), 
    //     .seq_done(seq_done), 
    //     .ifm_base(ifm_base), .ofm_base(ofm_base), 
    //     .ifm_len(ifm_len), .ofm_len(ofm_len), 
    //     .mem_read_req(mem_read_req), .mem_write_req(mem_write_req), 
    //     .mem_read_addr(mem_read_addr), .mem_write_addr(mem_write_addr), 
    //     .mem_read_len(mem_read_len), .mem_write_len(mem_write_len), 
    //     .seq_start(seq_start), .phase_fetch(phase_fetch), .phase_compute(phase_compute), 
    //     .phase_writeback(phase_writeback), .layer_done(layer_done)
    // );

    // ai_cu_layer_config_csrs ai_config (
    //     .clk(hz100), .rst(reset), .cs(cs), .we(we), 
    //     .addr(), .wdata(), .rdata(), 
    //     .in_height(), .in_width(), .in_ch(), .out_ch(), // width issues 
    //     .layer_type(), .kernel_size(), .stride(), 
    //     .relu_en(), .pool_en(), 
    //     .addr_ifm_base(ifm_base), .addr_wgt_base(), .addr_ofm_base(ofm_base)
    // ); 

    // ai_cu_sequencer sequencer (
    //     .clk(hz100), .rst(reset), .start_decoded(start_decoded), 
    //     .in_height(), .in_width(), .in_ch(), .kernel_size(kernel_size), .stride(stride), 
    //     .relu_en(relu_en), .pool_en(pool_en), 
    //     .row_cnt(row_cnt), .col_cnt(col_cnt), 
    //     .conv_valid(conv_valid), .relu_valid(relu_valid), .pool_valid(pool_valid), 
    //     .seq_done(seq_done)
    // ); 
endmodule
