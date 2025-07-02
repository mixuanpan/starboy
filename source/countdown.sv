`default_nettype none

module countdown (
    input logic clk, rst, en, 
    output logic [1:0] count 
); 
    
    logic [1:0] c_count, n_count; // current count, next count 
    assign count = c_count; 
    
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            c_count <= 2'b11; 
        end else begin 
            c_count <= n_count; 
        end 
    end

    always_comb begin
        if (en) begin 
            n_count = c_count - 'd1; 
        end else begin 
            n_count = c_count; 
        end 
    end
endmodule 