`default_nettype none
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
    input logic [24:0] scoremod,
    input logic speed_up,
    output logic newclk
);

//reduce reuse recycle

    logic [25:0] count, count_n;
    logic newclk_n;
    logic [25:0] threshold;

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
        threshold = speed_up ? 26'd1_250_000 : 26'd12_500_000 - scoremod; // Fixed: smaller threshold = faster clock
        if (count < threshold) begin //updated to half a huzz
            count_n = count + 1;
        end else begin
            count_n = '0;
            newclk_n = '0;
        end
    end

endmodule
