`default_nettype none
module ai_top #(
    parameter int INST_WIDTH = 32,  // width of the instruction word 
    parameter int K_WIDTH = 4, // kernel_size bits 
    parameter int S_WIDTH = 4, // stride bits 
    parameter int TYPE_WIDTH = 4, // layer_type bits 
    parameter ADDR_W = 32, 
    parameter LEN_W = 16
)(); 
// connections for the ai 
    logic clk, rst; 
    logic start_layer, start_decoded, relu_en, pool_en, mem_read_done, mem_write_done, seq_done; 
    logic [INST_WIDTH-1:0] inst_word_in; // 32-bit layer descripter 
    logic [K_WIDTH-1:0] kernel_size; 
    logic [S_WIDTH-1:0] stride; 
    logic [TYPE_WIDTH-1:0] layer_type; 
    logic [ADDR_W-1:0] ifm_base, ofm_base; 

    // Control Unit 
    ai_cu_id instruction_decoder (
        .clk(clk), .rst(rst), 
        .start_layer(start_layer), 
        .inst_word_in(inst_word_in), 
        .start_decoded(start_decoded), 
        .kernel_size(kernel_size), 
        .stride(stride), 
        .relu_en(relu_en), 
        .pool_en(pool_en), 
        .layer_type(layer_type)
    ); 

    ai_cu_fsm cu_fsm (
        .clk(clk), .rst(rst), 
        .start_decoded(start_decoded), 
        .mem_read_done(mem_read_done), 
        .mem_read_done(mem_write_done), 
        .seq_done(seq_done), 
        .
    );
endmodule 