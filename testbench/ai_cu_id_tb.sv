`timescale 1ms/10ps
module ai_cu_id_tb #(
  parameter int INST_WIDTH = 32,  // width of the instruction word 
  parameter int K_WIDTH = 4, // kernel_size bits 
  parameter int S_WIDTH = 4, // stride bits 
  parameter int TYPE_WIDTH = 4 // layer_type bits 
);

    logic clk, rst;
    logic start_layer;// strobe from host / FSM to load new inst 
    logic [INST_WIDTH-1:0] inst_word_in;// 32-bit layer descripter 

    logic start_decoded;// one-cycle pulse - params latched 
    logic [K_WIDTH-1:0] kernel_size;
    logic [S_WIDTH-1:0] stride;
    logic relu_en;
    logic pool_en;
    logic [TYPE_WIDTH-1:0] layer_type; 

    ai_cu_id instruction_decoder (.clk(clk), .rst(rst), .start_layer(start_layer), .inst_word_in(inst_word_in), .kernel_size(kernel_size), .stride(stride), .relu_en(relu_en), .pool_en(pool_en), .layer_type(layer_type)); 
    
endmodule 