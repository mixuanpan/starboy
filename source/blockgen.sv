module blockgen(
    input logic [2:0] current_state,
    input logic enable,
    // input logic finish,
    // input logic button,
    output logic [21:0][9:0] display_array  // output state
    // output logic [2:0] shape_color
);
    typedef enum logic [2:0] {
        LINE = 3'd0, // BLACK   
        SMASHBOY = 3'd1, 
        L = 3'd2, 
        REVERSE_L = 3'd3, 
        S = 3'd4, 
        Z = 3'd5, 
        T = 3'd6
    } block_t; 

    always_comb begin

        display_array = 0;

    // if (finish || button) begin
    if (enable) begin
    // shape_color = 3'b000;    
        case(current_state)
            3'd0: begin //line
                display_array[0][4] = '1;
                display_array[1][4] = '1;
                display_array[2][4] = '1;
                display_array[3][4] = '1;

            end
            3'd1: begin //square
                display_array[0][4] = '1;
                display_array[0][5] = '1;
                display_array[1][4] = '1;
                display_array[1][5] = '1;
            end
            3'd2: begin //L
                display_array[0][4] = '1;
                display_array[1][4] = '1;
                display_array[2][4] = '1;
                display_array[2][5] = '1;
            end
            3'd3: begin// reverse L
                display_array[0][5] = '1;
                display_array[1][5] = '1;
                display_array[2][5] = '1;
                display_array[2][4] = '1;
            end
            3'd4: begin // S
                display_array[0][6] = '1;
                display_array[0][5] = '1;
                display_array[1][5] = '1;
                display_array[1][4] = '1;
            end
            3'd5: begin // Z
                display_array[0][4] = '1;
                display_array[0][5] = '1;
                display_array[1][5] = '1;
                display_array[1][6] = '1;
            end
            3'd6: begin // T
                display_array[0][4] = '1;
                display_array[1][3] = '1;
                display_array[1][4] = '1;
                display_array[1][5] = '1;
            end
            default: display_array[0][0] = '0;
            
        endcase
    end
    end


endmodule