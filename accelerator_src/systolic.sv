module MAC#(parameter deptch = 4, bit_width = 8, acc_width = 24, size = 4) 
(
    clk,
    control
    data_arr,
    wt_arr, 
    acc_out
);

    input clk;
    input control;
    input [(bit_width * depth) - 1:0] data_arr;
    input [(bit_width * depth) - 1:0] wt_arr;
    output reg [acc_width * size - 1:0] acc_out;

    wire[bit_width - 1:0]data_out[depth - 1:0][depth - 1:0];
    wire [bit_width - 1:0]wt_out[depth - 1:0][depth - 1:0];
    wire [acc_width - 1:0]acc_out_temp[depth - 1:0][depth - 1:0];

    generate
        for (genvar i = 0; i < depth; i++) begin
            for (genvar j = 0; j < depth; j++) begin
                if(i == 0 && j == 0) begin
                    MAC mac_instance(.clk(clk), .control(control), .acc_in(24'b0), .acc_out(acc_out_temp[i][j]), .data_in(data_arr[i * bit_width + :bit_width]), .wt_path_in(wt_arr[bit_width - 1 :0]), .data_out(data_out[i][j]), .wt_path_out(wt_out[i][j]));
                end

                if (i == 0 && j != 0) begin
                    MAC mac_instance(.clk(clk))
    endgenerate