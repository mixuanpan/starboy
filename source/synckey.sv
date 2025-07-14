`default_nettype none

module synckey(
    input logic reset, hz100, 
    input logic [19:0] in,
    output logic [4:0] out,
    output logic strobe
);
logic Q, nextQ, nextStrobe;
logic keyclk;
assign keyclk = |in[19:0];
//assign strobe = Q1;

always_ff @(posedge hz100, posedge reset) begin
    if(reset) begin
        strobe <= 1'b0;
        Q <= 1'b0;
    end else begin
        strobe <= nextStrobe;
        Q <= nextQ;
    end

end

always_comb begin

    nextStrobe = Q;
    nextQ = keyclk;

    out = 5'd0;
    for (int i = 0; i < 20; i++) begin
        if (in[i]) begin
            out = i[4:0];
        end
    end
 //  strobe = |in[19:0];


end





endmodule


