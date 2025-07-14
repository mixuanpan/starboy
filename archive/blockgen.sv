module blockgen (
    input  logic        clk,                // fast pixel clock
    input  logic        rst,
    input  logic        enable,             // 1-cycle pulse from FSM
    input  logic [2:0]  current_state,      // shape ID
    output logic [21:0][9:0] display_array  // stable bitmap
);

    function automatic logic [21:0][9:0] decode (input logic [2:0] id);
        logic [21:0][9:0] m;  m = '0;
        unique case (id)
          3'd0: begin m[0][4]=1; m[1][4]=1; m[2][4]=1; m[3][4]=1; end
          3'd1: begin m[0][4]=1; m[0][5]=1; m[1][4]=1; m[1][5]=1; end
          3'd2: begin m[0][4]=1; m[1][4]=1; m[2][4]=1; m[2][5]=1; end
          3'd3: begin m[0][5]=1; m[1][5]=1; m[2][5]=1; m[2][4]=1; end
          3'd4: begin m[0][6]=1; m[0][5]=1; m[1][5]=1; m[1][4]=1; end
          3'd5: begin m[0][4]=1; m[0][5]=1; m[1][5]=1; m[1][6]=1; end
          3'd6: begin m[0][4]=1; m[1][3]=1; m[1][4]=1; m[1][5]=1; end
        endcase
        return m;
    endfunction

    logic [21:0][9:0] shape_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            shape_reg <= '0;
        else if (enable) 
            shape_reg <= decode(current_state);
    end

    assign display_array = shape_reg; 
endmodule
