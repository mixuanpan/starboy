module blockgen(
    input logic [2:0] current_state,
    output logic [4:0] row, 
    output logic [3:0] col, 
    output logic [21:0][9:0][2:0] display_array   // output state
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
    typedef enum logic [2:0] {
        CL0, // BLACK   
        CL1, 
        CL2, 
        CL3, 
        CL4, 
        CL5, 
        CL6, 
        CL7
    } color_t; 
    color_t color; 

    always_comb begin

        display_array = 0;
        color = CL1; 
        row = 0; 
        col = 0; 

    // shape_color = 3'b000;    
        case(current_state)
            // 3'd0: begin //line
            //     display_array[0][4] = 3'b011;
            //     display_array[1][4] = 3'b011;
            //     display_array[2][4] = 3'b011;
            //     display_array[3][4] = 3'b011;

            // end
            // 3'd1: begin //square
            //     display_array[0][4] = 3'b110;
            //     display_array[0][5] = 3'b110;
            //     display_array[1][4] = 3'b110;
            //     display_array[1][5] = 3'b110;
            // end
            // 3'd2: begin //L
            //     display_array[0][4] = 3'b111;
            //     display_array[1][4] = 3'b111;
            //     display_array[2][4] = 3'b111;
            //     display_array[2][5] = 3'b111;
            // end
            // 3'd3: begin// reverse L
            //     display_array[0][5] = 3'b001;
            //     display_array[1][5] = 3'b001;
            //     display_array[2][5] = 3'b001;
            //     display_array[2][4] = 3'b001;
            // end
            // 3'd4: begin // S
            //     display_array[0][6] = 3'b010;
            //     display_array[0][5] = 3'b010;
            //     display_array[1][5] = 3'b010;
            //     display_array[1][4] = 3'b010;
            // end
            default: begin // Z
                // color = CL1; 
                display_array[0][6] = color;
                display_array[0][5] = color;
                display_array[1][5] = color;
                display_array[1][4] = color;
                row = 0; 
                col = 'd3; 
            end
            // 3'd6: begin // T
            //     display_array[0][4] = 3'b101;
            //     display_array[1][3] = 3'b101;
            //     display_array[1][4] = 3'b101;
            //     display_array[1][5] = 3'b101;
            // end
            // default: ;
        endcase
    end


endmodule