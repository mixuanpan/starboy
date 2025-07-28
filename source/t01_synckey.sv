`default_nettype none
module t01_synckey(
    input logic in,
    input logic clk,
    input logic rst,
    output logic strobe
);
    logic synchronizer_ff1;
    logic delayedClock_ff2;
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            synchronizer_ff1 <= 0;
            delayedClock_ff2 <= 0;
        end else begin
            synchronizer_ff1 <= in;
            delayedClock_ff2 <= synchronizer_ff1;
        end
    end
    
    assign strobe = synchronizer_ff1 & ~delayedClock_ff2;
    
endmodule