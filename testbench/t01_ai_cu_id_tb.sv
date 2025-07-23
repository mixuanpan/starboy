`timescale 1ms/10ps
module t01_ai_cu_id_tb #(
  parameter int K_WIDTH = 4, // kernel_size bits 
  parameter int S_WIDTH = 4, // stride bits 
  parameter int TYPE_WIDTH = 4, // layer_type bits 
  parameter int INST_WIDTH = K_WIDTH + S_WIDTH + TYPE_WIDTH + 2// width of the instruction word 
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

    t01_ai_cu_id instruction_decoder (.clk(clk), .rst(rst), .start_layer(start_layer), .start_decoded(start_decoded), .inst_word_in(inst_word_in), .kernel_size(kernel_size), .stride(stride), .relu_en(relu_en), .pool_en(pool_en), .layer_type(layer_type)); 
    
    task tog_rst();
      rst = 1; #1; 
      rst = 0; 
    endtask 

    task tog_start();
      start_layer = 1; #1; 
      start_layer = 0; #1; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

    initial begin 
      $dumpfile("waves/t01_ai_cu_id.vcd"); 
      $dumpvars(0, t01_ai_cu_id_tb); 

      inst_word_in = 0; 
      tog_rst(); 

      for (int i = 0; i <= 2**INST_WIDTH; i++) begin 
        inst_word_in = i[13:0]; 
        tog_start(); 
      end

      #1 $finish; 
    end
endmodule 