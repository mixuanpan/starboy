`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_activation_unit  
// Description : Activation Unit in the AI Accelerator 
// 
//
/////////////////////////////////////////////////////////////////
module ai_activation_unit #(
    parameter int DATA_WIDTH = 16 // bit width of feature map elements 
)(
    input logic clk, rst, 
    input logic [DATA_WIDTH-1:0] in_data, // from convolution engine 
    input logic in_valid, // conv_valid 
    input logic relu_en, // static per-layer flag 

    output logic [DATA_WIDTH-1:0] out_data, // to pooling unit / ofm buffer
    output logic out_valid // relu_valid 
);

    // pipeline register 
    logic [DATA_WIDTH-1:0] data_reg; 
    logic valid_reg; 
    
    // drive outputs 
    assign out_data = data_reg; 
    assign out_valid = valid_reg; 
    
    always_ff @(posedge rst, posedge clk) begin 
        if (rst) begin 
            data_reg <= 0; 
            valid_reg <= 1'b0; 
        end else begin 
            valid_reg <= in_valid; 
            // sequntial 
            if (in_valid) begin 
                if (relu_en) begin 
                    // if MSB = 1 output 0 else pass 
                    data_reg <= (in_data[DATA_WIDTH-1] == 1'b1) ? '0 : in_data;
                end else begin 
                    // relu disabled 
                    data_reg <= in_data; 
                end 
            end  
        end 
    end

endmodule 