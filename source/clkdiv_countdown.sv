`default_nettype none
// the clock for the count down during READY state 

module clkdiv_countdown (
   input logic clk, rst,
   output logic newclk
);

   logic [10:0] count, count_n;
   logic newclk_n;

   always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
           count <= '0;
      end else begin
           count <= count_n;
      end
   end

   always_comb begin
       count_n = count;
       if (count == 11'd200) begin // devided from a 100hz clock 
           count_n = 0;
           newclk = 1; 
       end else begin
            newclk = 0; 
            count_n = count + 1; 
       end
      
   end

endmodule