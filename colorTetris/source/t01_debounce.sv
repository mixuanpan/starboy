module t01_debounce(
    input logic clk, pb,
    output logic button
);

logic Q0, Q1, Q2;
logic slow_clk_en;

logic [26:0] count, nextcount;
always_ff @(posedge clk) begin
    count <= nextcount;
end

always_comb begin
    if (count >=27'd249_999) begin
        nextcount = 0;
    end else begin
        nextcount = count + 1;
    end

    if (count == 27'd249_999) begin
        slow_clk_en = '1;
    end else begin
        slow_clk_en = '0;
    end
end

always_ff @(posedge clk) begin
    if (slow_clk_en == '1) begin
        Q0 <= pb;
        Q1 <= Q0;
        Q2 <= Q1;
    end else begin
        Q0 <= Q0;
        Q1 <= Q1;
        Q2 <= Q2;
    end
end


assign button = Q1 & !Q2;

endmodule