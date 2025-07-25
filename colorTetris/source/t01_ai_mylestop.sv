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
  // 2) Feature Extractors (one per possible placement)
  //------------------------------------------------------------------------
  logic [39:0]          extract_start;
  logic [39:0]          extract_ready;
  logic [2:0]           lines_cleared  [0:39];
  logic [7:0]           holes          [0:39];
  logic [7:0]           bumpiness      [0:39];
  logic [7:0]           height_sum     [0:39];

  genvar i;
  generate
    for (i = 0; i < 40; i++) begin : FEAT     
      t01_ai_feature_extract fe (
        .clk           (clk),
        .reset         (~reset_n),
        .start_extract (extract_start[i]),
        .next_board    (next_boards[i]),
        .extract_ready (extract_ready[i]),
        .lines_cleared (lines_cleared[i]),
        .holes         (holes[i]),
        .bumpiness     (bumpiness[i]),
        .height_sum    (height_sum[i])
      );
    end
  endgenerate

  //------------------------------------------------------------------------
  // 3) MMU (32×32 Broadcast‑MAC)
  //------------------------------------------------------------------------
  logic        mmu_start;
  logic        mmu_act_valid;
  logic [7:0]  mmu_act_in;
  logic        mmu_res_valid;
  logic [17:0] mmu_res_out;
  logic        mmu_done;
  logic [1:0]  mmu_layer_sel;

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
  // 4) Argmax
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
  // 5) Control FSM
  //------------------------------------------------------------------------
  
  // FSM States
  typedef enum logic [3:0] {
    IDLE,
    PLACEMENT,
    EXTRACT,
    EXTRACT_WAIT,
    MMU_PREP,
    MMU_STREAM,
    MMU_WAIT,
    ARGMAX_FEED,
    DONE
  } state_t;

  state_t current_state, next_state;

  // FSM Control Registers
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
      
      // Counter management
      case (current_state)
        EXTRACT: begin
          if (extract_counter < valid_placements)
            extract_counter <= extract_counter + 1;
        end
        
        EXTRACT_WAIT: begin
          if (&extract_ready[valid_placements-1:0])
            extract_counter <= 6'b0;
        end
        
        MMU_STREAM: begin
          if (mmu_cycle_counter == 31) begin
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
          next_state = EXTRACT;
      end
      
      EXTRACT: begin
        if (extract_counter >= valid_placements)
          next_state = EXTRACT_WAIT;
      end
      
      EXTRACT_WAIT: begin
        if (&extract_ready[valid_placements-1:0])
          next_state = MMU_PREP;
      end
      
      MMU_PREP: begin
        next_state = MMU_STREAM;
      end
      
      MMU_STREAM: begin
        if (mmu_counter >= valid_placements && mmu_cycle_counter == 31)
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
    extract_start = 40'b0;
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
      
      EXTRACT: begin
        if (extract_counter < valid_placements)
          extract_start[extract_counter] = 1'b1;
      end
      
      MMU_PREP: begin
        mmu_start = 1'b1;
        arg_start = 1'b1;
      end
      
      MMU_STREAM: begin
        mmu_act_valid = 1'b1;
        
        // Stream features for current placement
        case (mmu_cycle_counter[4:2])  // Divide by 4 to get feature index
          3'b000: mmu_act_in = lines_cleared[mmu_counter];   // Lines cleared
          3'b001: mmu_act_in = holes[mmu_counter];           // Holes
          3'b010: mmu_act_in = bumpiness[mmu_counter];       // Bumpiness  
          3'b011: mmu_act_in = height_sum[mmu_counter];      // Height sum
          default: mmu_act_in = 8'b0;                        // Zeros for remaining cycles
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