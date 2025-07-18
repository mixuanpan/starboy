module button_sync(
    input logic clk, 
    input logic rst,
    input logic button_in,
    output logic button_sync_out
);

logic sync_ff1, sync_ff2;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        sync_ff1 <= 1'b0;
        sync_ff2 <= 1'b0;
    end else begin
        sync_ff1 <= button_in;
        sync_ff2 <= sync_ff1;
    end
end

assign button_sync_out = sync_ff2;

endmodule
