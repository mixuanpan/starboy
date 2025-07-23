`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_cu_id
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
module ai_cu_id #(
  parameter int K_WIDTH = 4, // kernel_size bits 
  parameter int S_WIDTH = 4, // stride bits 
  parameter int TYPE_WIDTH = 4, // layer_type bits 
  parameter int INST_WIDTH = K_WIDTH + S_WIDTH + TYPE_WIDTH + 2// width of the instruction word 
) (
  input logic clk, rst, 
  input logic start_layer, // strobe from host / FSM to load new inst 
  input logic [INST_WIDTH-1:0] inst_word_in, // 32-bit layer descripter 

  output logic start_decoded, // one-cycle pulse - params latched 
  output logic [K_WIDTH-1:0] kernel_size, 
  output logic [S_WIDTH-1:0] stride, 
  output logic relu_en, 
  output logic pool_en, 
  output logic [TYPE_WIDTH-1:0] layer_type 
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

endmodule