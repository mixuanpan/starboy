`default_nettype none

module ai_activation_unit #(
    parameter int DATA_WIDTH = 16 // bit width of feature map elements 
)(
    input logic clk, rst, 
    input logic [DATA_WIDTH-1:0] in_data, // from convolution engine 
    input logic in_valid, // conv_valid 
    input logic 
);

endmodule 