// `default_nettype none
// module t01_ai_top #(
//     parameter int H_WIDTH = 10, // input height bits 
//     parameter int W_WIDTH = 10, // input width bits 
//     parameter int C_WIDTH = 8, // number of input channels 
//     parameter int K_WIDTH = 4, // kernel size bits
//     parameter int S_WIDTH = 4, // stride bits
//     parameter int INST_WIDTH = K_WIDTH + S_WIDTH + TYPE_WIDTH + 2, // width of the instruction word 

//     // derive output dims width at compile time 
//     parameter int HOUT_WIDTH = H_WIDTH + 1,
//     parameter int WOUT_WIDTH = W_WIDTH + 1 
// ); 
//     // internal signals 
//     logic hz100, reset; 

//     logic fsm_layer_done; 

//     // control unit 
//     t01_ai_cu_id instruction_decoder (
//         .clk(hz100), .rst(reset), start
//     )
// endmodule 