`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_ai_cu_id
// Description : Instruction Decoder of the Control Unit inside 
//               the AI Accelerator 
// 
//             layer_type code	 
//             4’b0000	Convolutional layer
//             4’b0001	Pooling layer (Max/Average)
//             4’b0010	Activation only (ReLU)
//             4’b0011	Fully-Connected (GEMV)
//             4’b0100	Bypass / Identity
//         pending: 
//             4’b0101	Tetris Grid Preprocessing 
//             4’b0110	Move Generation
//             4’b0111  Sfotmax/ArgMax (final layer)	
//             4’b1000  Grid Feature Extraction 	
//             
//
/////////////////////////////////////////////////////////////////

// Tetris FSM State Definitions
typedef enum logic [3:0] {
    INIT,
    SPAWN,
    FALLING,
    ROTATE,
    ROTATE_L,
    STUCK,
    LANDED,
    EVAL,    
    GAMEOVER  
} game_state_t;

module t01_ai_cu_id #(
  parameter int K_WIDTH = 4, // kernel_size bits 
  parameter int S_WIDTH = 4, // stride bits 
  parameter int TYPE_WIDTH = 4, // layer_type bits 
  parameter int INST_WIDTH = K_WIDTH + S_WIDTH + TYPE_WIDTH + 2// width of the instruction word 
) (
  input logic clk, rst, 
  input logic start_layer, // strobe from host / FSM to load new inst 
  input logic [INST_WIDTH-1:0] inst_word_in, // 32-bit layer descripter from the game engine 

  output logic start_decoded, // one-cycle pulse - params latched 
  output logic [K_WIDTH-1:0] kernel_size, 
  output logic [S_WIDTH-1:0] stride, 
  output logic relu_en, 
  output logic pool_en, 
  output logic [TYPE_WIDTH-1:0] layer_type, 

// game engine
  input game_state_t current_state, // current state 
  input logic [INST_WIDTH-1:0] inst_word, // to control unit instruction decoder 
  input logic [19:0][9:0] stored_array, 
  input logic [3:0][3:0] ai_bp, // block pattern 
  input logic [4:0] next_current_block_type, 
  input logic [2:0] current_state_counter, 
  input logic collision_bottom, collision_left, collision_right, // collision 
  input logic rotation_valid, left_pulse, right_pulse, 

  output logic [4:0] current_block_type, 
  output logic [4:0] blockY,
  output logic [3:0] blockX, 
  output logic right_i, left_i, start_i, rotate_r, rotate_l, 
  output logic ai_movement_done // done with current movement 
);

  // internal registers 
  logic [INST_WIDTH-1:0] inst_reg; 
  logic start_layer_d; 

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      // instruction register: latch the incoming inst_word on start_layer 
      inst_reg <= 0; 

      // start_decoded pulse generation: produce a one-cycle pulse when inst_reg is just loaded 
      start_layer_d <= 1'b0; 
      start_decoded <= 1'b0; 
    end else begin 
      inst_reg <= inst_word_in; 

      start_decoded <= start_layer & ~start_layer_d; 
      start_layer_d <= start_layer; 
    end 
  end

  // field extraction - bit-sliced 
  assign layer_type = inst_reg[INST_WIDTH-1-:TYPE_WIDTH]; 
  assign kernel_size = inst_reg[INST_WIDTH-TYPE_WIDTH-1-:K_WIDTH]; // kernel size bits: [23:20]
  assign stride = inst_reg[INST_WIDTH-TYPE_WIDTH-K_WIDTH-1-:S_WIDTH]; // stride bits: [19:16]
  assign relu_en = inst_reg[INST_WIDTH-TYPE_WIDTH-K_WIDTH-S_WIDTH-1]; 
  assign pool_en = inst_reg[INST_WIDTH-TYPE_WIDTH-K_WIDTH-S_WIDTH-2]; 

    //=============================================================================
    // block positioning and type management !!!
    //=============================================================================

  always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
          blockY <= 5'd0;
          blockX <= 4'd3;
          current_block_type <= 5'd0;
      end 
      else if (current_state == SPAWN) begin
          blockY <= 5'd0;
          blockX <= 4'd3;
          current_block_type <= {2'b0, current_state_counter};
      end 
      else if (current_state == FALLING) begin
          // vertical movement
          if (/*drop_tick && */!collision_bottom) begin 
              blockY <= blockY + 5'd1;
          end
          
          // horizontal movement
          if (left_pulse && !collision_left) begin
              blockX <= blockX - 4'd1;
          end else if (right_pulse && !collision_right) begin
              blockX <= blockX + 4'd1;
          end
      end 
      else if (current_state == ROTATE || current_state == ROTATE_L) begin
          // current_block_type <= next_current_block_type;

          if (rotation_valid) begin
              current_block_type <= next_current_block_type;

          end else begin
              current_block_type <= current_block_type;
          end
          
      end
  end

  // ai movement 
  always_comb begin 
    if (current_state == FALLING) begin 

    end
  end
endmodule