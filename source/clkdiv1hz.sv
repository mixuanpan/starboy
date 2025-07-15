/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : clkdiv1hz
// Description : takes 25mhz clock and turns it into 1 hz, subject to change
// 
//
/////////////////////////////////////////////////////////////////
module clkdiv1hz (
    input logic clk, rst, //25mhz -> 1hz
    output logic newclk
);

//reduce reuse recycle

    logic [24:0] count, count_n;
    logic newclk_n;

    always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
            count <= '0;
            newclk <= '0;
       end else begin
            count <= count_n;
            newclk <= newclk_n;
       end
    end

    always_comb begin
        count_n = count;
        newclk_n = '1;
        if (count < 25'd12_500_00) begin
            count_n = count + 1;
        end else begin
            count_n = '0;
            newclk_n = '0;
        end
    end

endmodule