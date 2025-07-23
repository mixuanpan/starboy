`default_nettype none
module ai_wb_reader (
    output logic [3:0] t1, t2, t3, t4
); 
    logic [3:0] d3_b [1];
    logic [3:0] d0_b [1:32];
    logic [3:0] d1_b [1:32];
    logic [3:0] d2_b [1:32];
    logic [3:0] d3_w [1:32];
    logic [3:0] d0_w [1:128];
    logic [3:0] d1_w [1:1024];
    logic [3:0] d2_w [1:1024];

    assign t1 = d3_b[0]; 
    assign t2 = d3_w[15]; 
    assign t3 = d2_b[30]; 
    assign t4 = d1_w[1024]; 

    initial begin 
        $readmemh("dense_0_param0_int4.mem", d0_w, 1, 128); 
        $readmemh("dense_0_param1_int4.mem", d0_b, 1, 32); 
        $readmemh("dense_1_param0_int4.mem", d1_w, 1, 1024); 
        $readmemh("dense_1_param1_int4.mem", d1_b, 1, 32); 
        $readmemh("dense_2_param0_int4.mem", d2_w, 1, 1024); 
        $readmemh("dense_2_param1_int4.mem", d2_b, 1, 32); 
        $readmemh("dense_3_param0_int4.mem", d3_w, 1, 32); 
        $readmemh("dense_3_param1_int4.mem", d3_b); 
    end 
endmodule 