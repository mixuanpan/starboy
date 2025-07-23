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
  logic [7:0]  current_score, ai_current_score;
  logic finish, gameover;
  logic [24:0] scoremod;
  logic [19:0][9:0] new_block_array;
  logic speed_mode_o, ai_speed_mode_o;

  // AI-specific signals
  logic [4:0] current_piece_type;
  logic ai_placement_start, placement_ready;
  logic [39:0][199:0] next_boards;
  logic [5:0] valid_placements;
  logic [39:0][1:0] rotations;
  logic [39:0][3:0] x_positions;
 
  // Feature extraction signals
  logic [39:0] extract_start_array;
  logic [39:0] extract_ready_array;
  logic [39:0][2:0] lines_cleared_array; 
  logic [39:0][7:0] holes_array;         
  logic [39:0][7:0] bumpiness_array;     
  logic [39:0][7:0] height_sum_array;    
 
  // Neural network signals
  logic nn_start, nn_act_valid, nn_res_valid, nn_done;
  logic [1:0] nn_layer_sel;
  logic [7:0] nn_act_in;  
  logic [17:0] nn_res_out;
  logic [17:0] nn_results [0:31];
  logic [4:0] nn_input_counter, nn_output_counter;
  logic [5:0] feature_idx;
 
  // Argmax signals
  logic argmax_start, argmax_valid, argmax_last, argmax_done;
  logic signed [17:0] q_value;
  logic [5:0] move_id;
  logic [5:0] best_move_id;
  logic signed [17:0] best_q_value;
 
  // AI state machine
  typedef enum logic [3:0] {
    AI_IDLE,
    AI_START_PLACEMENT,
    AI_WAIT_PLACEMENT,
    AI_EXTRACT_FEATURES,
    AI_WAIT_EXTRACT,
    AI_PREPARE_NN,
    AI_STREAM_FEATURES,
    AI_WAIT_NN_RESULT,
    AI_STORE_RESULT,
    AI_ARGMAX,
    AI_WAIT_ARGMAX,
    AI_EXECUTE_MOVE
  } ai_state_t;
 
  ai_state_t ai_state, ai_next_state;
  logic [5:0] feature_counter;
  logic [5:0] current_placement;

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

//=================================================================================
// MODULE INSTANTIATIONS
//=================================================================================

    //=============================================================================
    // tetris game !!!
    //=============================================================================
   
    // VGA driver
    vgadriver ryangosling (
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
 
  // Game Logic - Human player (commented out in original)
  // tetrisFSM plait (
  //   .clk(hz100),
  //   .onehuzz(onehuzz),
  //   .reset(reset),
  //   .rotate_l(pb[11]),
  //   .speed_up_i(pb[12]|| pb[15]),
  //   .right_i(pb[0]),
  //   .left_i(pb[3]),
  //   .rotate_r(pb[8]),
  //   .en_newgame(pb[19]),
  //   .speed_mode_o(speed_mode_o),
  //   .display_array(new_block_array),
  //   .gameover(gameover),
  //   .score(current_score),
  //   .start_i(pb[19])
  // );

  //Tetris Grid Display
  tetrisGrid durt (
    .x(x),  
    .y(y),  
    .shape_color(grid_color_movement),
    .display_array(new_block_array),
    .gameover(gameover)
  );
 
  // Clock Divider
  clkdiv1hz yo (
    .clk(hz100),
    .rst(reset),
    .newclk(onehuzz),
    .speed_up(speed_mode_o | ai_speed_mode_o),
    .scoremod(scoremod)
  );

  // Speed Controller
  speed_controller jorkingtree (
    .clk(hz100),
    .reset(reset),
    .current_score(current_score | ai_current_score),
    .scoremod(scoremod)
  );

  // STARBOY Display
  starboyDisplay silly (
    .clk(onehuzz),
    .rst(reset),
    .x(x),
    .y(y),
    .shape_color(starboy_color)
  );
 
  // Score Display
  scoredisplay ralsei (
    .clk(onehuzz),
    .rst(reset),
    .score(current_score | ai_current_score),
    .x(x),
    .y(y),
    .shape_color(score_color)
  );

    //=============================================================================
    // agentic ai accelerator bsb saas yc startup bay area matcha lababu stussy !!!
    //=============================================================================
     
  //AI Tetris FSM
  ai_tetrisFSM ecuador (
    .clk(hz100),
    .onehuzz(onehuzz),
    .reset(reset),
    .rotate_l(pb[1]),
    .speed_up_i(pb[2]|| pb[15]),
    .right_i(pb[6]),
    .left_i(pb[7]),
    .rotate_r(pb[0]),
    .en_newgame(pb[19]),
    .speed_mode_o(ai_speed_mode_o),
    .display_array(new_block_array),
    .gameover(gameover),
    .score(ai_current_score),
    .start_i(pb[19]),
    .current_piece_type(current_piece_type),
    .ai_move_ready(argmax_done),
    .best_move_id(best_move_id)
  );

  // Placement Engine - generates all possible placements
  placement_engine anthropic (
    .clk(hz100),
    .reset(reset),
    .start_placement(ai_placement_start),
    .display_array(new_block_array),
    .piece_type(current_piece_type),
    .placement_ready(placement_ready),
    .next_boards(next_boards),
    .valid_placements(valid_placements),
    .rotations(rotations),
    .x_positions(x_positions)
  );

  // Feature Extractors - one for each possible placement
  genvar i;
  generate
    for (i = 0; i < 40; i++) begin : feature_extractors
      feature_extractor matchalatte (
        .clk(hz100),
        .reset(reset),
        .start_extract(extract_start_array[i]),
        .next_board(next_boards[i]),
        .extract_ready(extract_ready_array[i]),
        .lines_cleared(lines_cleared_array[i]),
        .holes(holes_array[i]),
        .bumpiness(bumpiness_array[i]),
        .height_sum(height_sum_array[i])
      );
    end
  endgenerate

  // Neural Network MMU - 32x32 systolic array  
  ai_MMU_32x32 #(
    .IN_DIM(32),
    .OUT_DIM(32),
    .AW(8),      // 8-bit activations
    .WW(4),      // 4-bit weights  
    .ACCW(18)    // 18-bit accumulator
  ) an_dyhu (
    .clk(hz100),
    .rst_n(~reset),
    .start(nn_start),
    .layer_sel(nn_layer_sel),
    .act_valid(nn_act_valid),
    .act_in(nn_act_in),
    .res_valid(nn_res_valid),
    .res_out(nn_res_out),
    .done(nn_done)
  );

  // Argmax Unit - finds best move
  argmax_unit #(
    .Q_VALUE_WIDTH(18),  // Match MMU output width
    .MOVE_ID_WIDTH(6)
  ) brianking (
    .clk(hz100),
    .rst(reset),
    .start(argmax_start),
    .valid(argmax_valid),
    .q_value(q_value),
    .move_id(move_id),
    .last(argmax_last),
    .best_move_id(best_move_id),
    .best_q_value(best_q_value),
    .done(argmax_done)
  );

  //=============================================================================
  // AI Control State Machine
  //=============================================================================
 
  always_ff @(posedge hz100 or posedge reset) begin
    if (reset) begin
      ai_state <= AI_IDLE;
      feature_counter <= 0;
      current_placement <= 0;
      nn_input_counter <= 0;
      nn_output_counter <= 0;
    end else begin
      ai_state <= ai_next_state;
     
      case (ai_state) // sorry integration team
        AI_EXTRACT_FEATURES: begin
          if (feature_counter < valid_placements)
            feature_counter <= feature_counter + 1;
        end
       
        AI_STREAM_FEATURES: begin
          if (nn_act_valid && nn_input_counter < 31) begin
            nn_input_counter <= nn_input_counter + 1;
          end else if (nn_input_counter == 31) begin
            nn_input_counter <= 0;
          end
        end
       
        AI_STORE_RESULT: begin
          if (nn_res_valid) begin
            nn_results[nn_output_counter] <= nn_res_out;
            if (nn_output_counter < 31) begin
              nn_output_counter <= nn_output_counter + 1;
            end else begin
              nn_output_counter <= 0;
              current_placement <= current_placement + 1;
            end
          end
        end
       
        AI_IDLE: begin
          feature_counter <= 0;
          current_placement <= 0;
          nn_input_counter <= 0;
          nn_output_counter <= 0;
        end
      endcase
    end
  end

  // AI state machine logic
  always_comb begin
    ai_next_state = ai_state;
    ai_placement_start = 1'b0;
    extract_start_array = 40'b0;
    nn_start = 1'b0;
    nn_act_valid = 1'b0;
    nn_layer_sel = 2'b00;
    argmax_start = 1'b0;
    argmax_valid = 1'b0;
    argmax_last = 1'b0;
   
    case (ai_state)
      AI_IDLE: begin
        if (onehuzz && !gameover && current_piece_type != 5'b0) begin
          ai_next_state = AI_START_PLACEMENT;
        end
      end
     
      AI_START_PLACEMENT: begin
        ai_placement_start = 1'b1;
        ai_next_state = AI_WAIT_PLACEMENT;
      end
     
      AI_WAIT_PLACEMENT: begin
        if (placement_ready) begin
          ai_next_state = AI_EXTRACT_FEATURES;
        end
      end
     
      AI_EXTRACT_FEATURES: begin
        if (feature_counter < valid_placements) begin
          extract_start_array[feature_counter] = 1'b1;
        end else begin
          ai_next_state = AI_WAIT_EXTRACT;
        end
      end
     
      AI_WAIT_EXTRACT: begin
        if (&extract_ready_array[valid_placements-1:0]) begin
          ai_next_state = AI_PREPARE_NN;
        end
      end
     
      AI_PREPARE_NN: begin
        if (current_placement < valid_placements) begin
          nn_start = 1'b1;
          ai_next_state = AI_STREAM_FEATURES;
        end else begin
          ai_next_state = AI_ARGMAX;
        end
      end
     
      AI_STREAM_FEATURES: begin
        nn_act_valid = 1'b1;
        nn_layer_sel = 2'b00;  // Use layer 0 for evaluation
        if (nn_input_counter == 31) begin
          ai_next_state = AI_WAIT_NN_RESULT;
        end
      end
     
      AI_WAIT_NN_RESULT: begin
        if (nn_res_valid) begin
          ai_next_state = AI_STORE_RESULT;
        end
      end
     
      AI_STORE_RESULT: begin
        if (nn_res_valid && nn_output_counter == 31) begin
          if (current_placement == valid_placements - 1) begin
            ai_next_state = AI_ARGMAX;
          end else begin
            ai_next_state = AI_PREPARE_NN;
          end
        end
      end
     
      AI_ARGMAX: begin
        argmax_start = 1'b1;
        ai_next_state = AI_WAIT_ARGMAX;
      end
     
      AI_WAIT_ARGMAX: begin
        if (current_placement < valid_placements) begin
          argmax_valid = 1'b1;
          if (current_placement == valid_placements - 1) begin
            argmax_last = 1'b1;
          end
        end
        if (argmax_done) begin
          ai_next_state = AI_EXECUTE_MOVE;
        end
      end
     
      AI_EXECUTE_MOVE: begin
        ai_next_state = AI_IDLE;
      end
     
      default: ai_next_state = AI_IDLE;
    endcase
  end

  //feature the streaming to the amazing neural network
  always_comb begin
    feature_idx = current_placement;
   
    // stream 32 feature values (32 cycles of act_valid)
    case (nn_input_counter)
      0:  nn_act_in = {5'b0, lines_cleared_array[feature_idx]};
      1:  nn_act_in = holes_array[feature_idx];
      2:  nn_act_in = bumpiness_array[feature_idx];
      3:  nn_act_in = height_sum_array[feature_idx];
      4:  nn_act_in = rotations[feature_idx][1:0] << 2;
      5:  nn_act_in = x_positions[feature_idx][3:0] << 1;
      6:  nn_act_in = current_piece_type[4:0] << 1;
      7:  nn_act_in = ai_current_score;
      8:  nn_act_in = holes_array[feature_idx] + bumpiness_array[feature_idx][6:0];
      9:  nn_act_in = height_sum_array[feature_idx] >> 1;
      10: nn_act_in = (lines_cleared_array[feature_idx] == 4) ? 8'hFF : 8'h00;
      11: nn_act_in = (holes_array[feature_idx] > 8'd10) ? 8'hFF : 8'h00;
      default: nn_act_in = 8'b0;
    endcase
  end

  // Q-value and move id assignment
  always_comb begin
    if (ai_state == AI_WAIT_ARGMAX && current_placement < valid_placements) begin
      q_value = nn_results[0];
      move_id = current_placement[5:0];
    end else begin
      q_value = 18'b0;
      move_id = 6'b0;
    end
  end

  // seven segment displays for debugging
  assign ss7 = ai_state[7:0];
  assign ss6 = valid_placements[7:0];
  assign ss5 = best_move_id[7:0];
  assign ss4 = current_piece_type[7:0];
  assign ss3 = ai_current_score;
  assign ss2 = feature_counter[7:0];
  assign ss1 = {placement_ready, extract_ready_array[0], nn_done, argmax_done, 4'b0};
  assign ss0 = best_q_value[7:0];

  // right side LEDs for status
  assign right = {
    gameover,
    ai_speed_mode_o,
    placement_ready,
    extract_ready_array[0],
    nn_done,
    argmax_done,
    ai_state[1:0]
  };

  // RGB LED for AI status
  assign red = (ai_state != AI_IDLE);
  assign green = argmax_done;
  assign blue = gameover;
  
endmodule