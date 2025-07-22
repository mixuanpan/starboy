`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_wb_reader 
// Description : weights and biases reader  
// 
//
/////////////////////////////////////////////////////////////////
module ai_wb_reader #(
    parameter int N1 = 1, // first length 
    parameter int N2 = 32, // second length 
    parameter int N3 = 128, // third length 
    parameter int N4 = 1024 // fourth length 
)(
    output logic [3:0] d3_b, 
    output logic [3:0] d0_b [1:N2/2], d1_b [1:N2/2], d2_b [1:N2/2], d3_w [1:N2/2], 
    output logic [3:0] d0_w [1:N3/2], // weight of dense 0 
    output logic [3:0] d1_w [1:N4/2], d2_w [1:N4/2]
); 

    initial begin 
        $readmemh("all_layers.mem", d0_w, 1, N2/2); 
    end


endmodule 
    