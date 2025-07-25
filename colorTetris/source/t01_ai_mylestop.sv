`default_nettype none
module t01_ai_mylestop (
  input  logic            clk,
  input  logic            reset_n,
  input  logic            start_ai,           // pulse to kick off a new AI inference
  input  logic [19:0][9:0] display_array,     // current board
  input  logic [4:0]      piece_type,         // current tetromino type

  output logic [5:0]      best_move_id,       // argmax result
  output logic signed [17:0] best_q_value,    // argmax score
  output logic            done_ai             // pulses when result is valid
);

  //------------------------------------------------------------------------
  // 1) Placement Engine
  //------------------------------------------------------------------------
  logic                  placement_start;
  logic                  placement_ready;
  logic [199:0]          next_boards   [0:39];
  logic [5:0]            valid_placements;
  logic [1:0]            rotations      [0:39];
  logic [3:0]            x_positions    [0:39];

  t01_ai_placement_engine pe (
    .clk             (clk),
    .reset           (~reset_n),
    .start_placement (placement_start),
    .display_array   (display_array),
    .piece_type      (piece_type),
    .placement_ready (placement_ready),
    .next_boards     (next_boards),
    .valid_placements(valid_placements),
    .rotations       (rotations),
    .x_positions     (x_positions)
  );

  //------------------------------------------------------------------------
  // 2) SINGLE Sequential Feature Extractor (HUGE SAVINGS!)
  //------------------------------------------------------------------------
  logic                  extract_start;
  logic                  extract_ready;
  logic [2:0]            lines_cleared;
  logic [7:0]            holes;
  logic [7:0]            bumpiness;
  logic [7:0]            height_sum;
  logic [199:0]          current_board_to_extract;

  // Feature storage for all placements
  logic [2:0]            stored_lines_cleared  [0:39];
  logic [7:0]            stored_holes          [0:39];
  logic [7:0]            stored_bumpiness      [0:39];
  logic [7:0]            stored_height_sum     [0:39];

  t01_ai_feature_extract fe (
    .clk           (clk),
    .reset         (~reset_n),
    .start_extract (extract_start),
    .next_board    (current_board_to_extract),
    .extract_ready (extract_ready),
    .lines_cleared (lines_cleared),
    .holes         (holes),
    .bumpiness     (bumpiness),
    .height_sum    (height_sum)
  );

  //------------------------------------------------------------------------
  // 3) Simplified MMU (Reduce from 32x32 to smaller)
  //------------------------------------------------------------------------
  logic         mmu_start;
  logic         mmu_act_valid;
  logic [7:0]   mmu_act_in;
  logic         mmu_res_valid;
  logic [17:0]  mmu_res_out;
  logic         mmu_done; 
  logic [1:0]   mmu_layer_sel;

  t01_ai_MMU mmu (
    .clk       (clk),
    .rst_n     (reset_n),
    .start     (mmu_start),
    .layer_sel (mmu_layer_sel),
    .act_valid (mmu_act_valid),
    .act_in    (mmu_act_in),
    .res_valid (mmu_res_valid),
    .res_out   (mmu_res_out),
    .done      (mmu_done)
  );

  //------------------------------------------------------------------------
  // 4) Argmax (Keep as-is)
  //------------------------------------------------------------------------
  logic        arg_start;
  logic        arg_valid;
  logic signed [17:0] arg_q_value;
  logic [5:0]  arg_move_id;
  logic        arg_last;
  logic        arg_done;

  t01_ai_argmax_unit #(
    .Q_VALUE_WIDTH (18),
    .MOVE_ID_WIDTH (6)
  ) amx (
    .clk         (clk),
    .rst         (~reset_n),
    .start       (arg_start),
    .valid       (arg_valid),
    .q_value     (arg_q_value),
    .move_id     (arg_move_id),
    .last        (arg_last),
    .best_move_id(best_move_id),
    .best_q_value(best_q_value),
    .done        (arg_done)
  );

  //------------------------------------------------------------------------
  // 5) Optimized Control FSM
  //------------------------------------------------------------------------
  
  typedef enum logic [3:0] {
    IDLE,
    PLACEMENT,
    EXTRACT_SETUP,
    EXTRACT_WAIT,
    EXTRACT_STORE,
    MMU_PREP,
    MMU_STREAM,
    MMU_WAIT,
    ARGMAX_FEED,
    DONE
  } state_t;

  state_t current_state, next_state;

  logic [5:0] extract_counter;
  logic [5:0] mmu_counter;
  logic [4:0] mmu_cycle_counter;
  logic [5:0] current_move_id;

  // State register
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      current_state <= IDLE;
      extract_counter <= 6'b0;
      mmu_counter <= 6'b0;
      mmu_cycle_counter <= 5'b0;
      current_move_id <= 6'b0;
    end else begin
      current_state <= next_state;
      
      case (current_state)
        EXTRACT_SETUP: begin
          if (extract_counter < valid_placements)
            extract_counter <= extract_counter + 1;
        end
        
        EXTRACT_STORE: begin
          // Store current features and reset counter if done
          if (extract_counter >= valid_placements)
            extract_counter <= 6'b0;
        end
        
        MMU_STREAM: begin
          if (mmu_cycle_counter == 7) begin  // Only 8 cycles: 4 features + 4 zeros
            mmu_cycle_counter <= 5'b0;
            if (mmu_counter < valid_placements)
              mmu_counter <= mmu_counter + 1;
          end else begin
            mmu_cycle_counter <= mmu_cycle_counter + 1;
          end
        end
        
        ARGMAX_FEED: begin
          if (mmu_res_valid)
            current_move_id <= current_move_id + 1;
        end
        
        IDLE: begin
          extract_counter <= 6'b0;
          mmu_counter <= 6'b0;
          mmu_cycle_counter <= 5'b0;
          current_move_id <= 6'b0;
        end
        
        default: begin
          // Maintain current values
        end
      endcase
    end
  end

  // Store features as they're computed
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      for (int i = 0; i < 40; i++) begin
        stored_lines_cleared[i] <= 3'b0;
        stored_holes[i] <= 8'b0;
        stored_bumpiness[i] <= 8'b0;
        stored_height_sum[i] <= 8'b0;
      end
    end else if (current_state == EXTRACT_STORE && extract_ready) begin
      stored_lines_cleared[extract_counter-1] <= lines_cleared;
      stored_holes[extract_counter-1] <= holes;
      stored_bumpiness[extract_counter-1] <= bumpiness;
      stored_height_sum[extract_counter-1] <= height_sum;
    end
  end

  // Next state logic
  always_comb begin
    next_state = current_state;
    
    case (current_state)
      IDLE: begin
        if (start_ai)
          next_state = PLACEMENT;
      end
      
      PLACEMENT: begin
        if (placement_ready)
          next_state = EXTRACT_SETUP;
      end
      
      EXTRACT_SETUP: begin
        next_state = EXTRACT_WAIT;
      end
      
      EXTRACT_WAIT: begin
        if (extract_ready)
          next_state = EXTRACT_STORE;
      end
      
      EXTRACT_STORE: begin
        if (extract_counter >= valid_placements)
          next_state = MMU_PREP;
        else
          next_state = EXTRACT_SETUP;
      end
      
      MMU_PREP: begin
        next_state = MMU_STREAM;
      end
      
      MMU_STREAM: begin
        if (mmu_counter >= valid_placements && mmu_cycle_counter == 7)
          next_state = MMU_WAIT;
      end
      
      MMU_WAIT: begin
        if (mmu_done)
          next_state = ARGMAX_FEED;
      end
      
      ARGMAX_FEED: begin
        if (current_move_id >= valid_placements)
          next_state = DONE;
      end
      
      DONE: begin
        if (arg_done)
          next_state = IDLE;
      end
      
      default: next_state = IDLE;
    endcase
  end

  // Output control logic
  always_comb begin
    // Default values
    placement_start = 1'b0;
    extract_start = 1'b0;
    current_board_to_extract = 200'b0;
    mmu_start = 1'b0;
    mmu_act_valid = 1'b0;
    mmu_act_in = 8'b0;
    mmu_layer_sel = 2'b0;
    arg_start = 1'b0;
    arg_valid = 1'b0;
    arg_q_value = 18'b0;
    arg_move_id = 6'b0;
    arg_last = 1'b0;
    done_ai = 1'b0;
    
    case (current_state)
      PLACEMENT: begin
        placement_start = 1'b1;
      end
      
      EXTRACT_SETUP: begin
        extract_start = 1'b1;
        current_board_to_extract = next_boards[extract_counter];
      end
      
      MMU_PREP: begin
        mmu_start = 1'b1;
        arg_start = 1'b1;
      end
      
      MMU_STREAM: begin
        mmu_act_valid = 1'b1;
        
        // Simplified 8-cycle feature streaming 
        case (mmu_cycle_counter[2:1])  // Divide by 2 to get feature index
          2'b00: mmu_act_in = stored_lines_cleared[mmu_counter];   // Lines cleared
          2'b01: mmu_act_in = stored_holes[mmu_counter];           // Holes
          2'b10: mmu_act_in = stored_bumpiness[mmu_counter];       // Bumpiness  
          2'b11: mmu_act_in = stored_height_sum[mmu_counter];      // Height sum
        endcase
      end
      
      ARGMAX_FEED: begin
        if (mmu_res_valid) begin
          arg_valid = 1'b1;
          arg_q_value = mmu_res_out;
          arg_move_id = current_move_id;
          arg_last = (current_move_id == valid_placements - 1);
        end
      end
      
      DONE: begin
        done_ai = arg_done;
      end
      
      default: begin
        // All outputs remain at default values
      end
    endcase
  end

endmodule