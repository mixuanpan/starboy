`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : blockgen 
// Description : generate a new block based on the input counter 
// 
//
/////////////////////////////////////////////////////////////////
module blockgen(
    input logic [4:0] current_block_type, 
    output logic [3:0][3:0] current_block_pattern 
);

    always_comb begin
        current_block_pattern = 0; 
        case (current_block_type)
            // I piece
            'd0: begin // I vertical
                current_block_pattern[0][1] = 1;
                current_block_pattern[1][1] = 1;
                current_block_pattern[2][1] = 1;
                current_block_pattern[3][1] = 1;
            end
            // 'd7: begin // I horizontal
            //     current_block_pattern[1][0] = 1;
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[1][2] = 1;
            //     current_block_pattern[1][3] = 1;
            // end

            // O piece
            'd1: begin // O
                current_block_pattern[0][1] = 1;
                current_block_pattern[0][2] = 1;
                current_block_pattern[1][1] = 1;
                current_block_pattern[1][2] = 1;
            end

            // S piece
            'd2: begin // S horizontal
                current_block_pattern[0][2] = 1;
                current_block_pattern[0][3] = 1;
                current_block_pattern[1][1] = 1;
                current_block_pattern[1][2] = 1;
            end
            // 'd8: begin // S vertical
            //     current_block_pattern[1][2] = 1;
            //     current_block_pattern[2][2] = 1;
            //     current_block_pattern[2][1] = 1;
            //     current_block_pattern[3][1] = 1;
            // end

            // Z piece
            'd3: begin // Z horizontal
                current_block_pattern[0][1] = 1;
                current_block_pattern[0][2] = 1;
                current_block_pattern[1][2] = 1;
                current_block_pattern[1][3] = 1;
            end
            // 'd9: begin // Z vertical
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[2][1] = 1;
            //     current_block_pattern[2][2] = 1;
            //     current_block_pattern[3][2] = 1;
            // end

            // L piece
            'd4: begin // L 0°
                current_block_pattern[0][1] = 1;
                current_block_pattern[1][1] = 1;
                current_block_pattern[2][1] = 1;
                current_block_pattern[2][2] = 1;
            end
            // 'd10: begin // L 90°
            //     current_block_pattern[1][0] = 1;
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[1][2] = 1;
            //     current_block_pattern[0][0] = 1;
            // end
            // 'd11: begin // L 180°
            //     current_block_pattern[0][1] = 1;
            //     current_block_pattern[0][2] = 1;
            //     current_block_pattern[1][2] = 1;
            //     current_block_pattern[2][2] = 1;
            // end
            // 'd12: begin // L 270°
            //     current_block_pattern[1][0] = 1;
            //     current_block_pattern[2][0] = 1;
            //     current_block_pattern[2][1] = 1;
            //     current_block_pattern[2][2] = 1;
            // end

            // J piece
            'd5: begin // J 0°
                current_block_pattern[0][2] = 1;
                current_block_pattern[1][2] = 1;
                current_block_pattern[2][2] = 1;
                current_block_pattern[2][1] = 1;
            end
            // 'd13: begin // J 90°
            //     current_block_pattern[1][0] = 1;
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[1][2] = 1;
            //     current_block_pattern[2][2] = 1;
            // end
            // 'd14: begin // J 180°
            //     current_block_pattern[0][1] = 1;
            //     current_block_pattern[0][2] = 1;
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[2][1] = 1;
            // end
            // 'd15: begin // J 270°
            //     current_block_pattern[0][0] = 1;
            //     current_block_pattern[1][0] = 1;
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[1][2] = 1;
            // end

            // T piece
            'd6: begin // T 0°
                current_block_pattern[0][2] = 1;
                current_block_pattern[1][1] = 1;
                current_block_pattern[1][2] = 1;
                current_block_pattern[1][3] = 1;
            end
            // 'd16: begin // T 90°
            //     current_block_pattern[1][2] = 1;
            //     current_block_pattern[2][1] = 1;
            //     current_block_pattern[2][2] = 1;
            //     current_block_pattern[3][2] = 1;
            // end
            // 'd17: begin // T 180°
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[1][2] = 1;
            //     current_block_pattern[1][3] = 1;
            //     current_block_pattern[2][2] = 1;
            // end
            // 'd18: begin // T 270°
            //     current_block_pattern[1][1] = 1;
            //     current_block_pattern[2][1] = 1;
            //     current_block_pattern[2][2] = 1;
            //     current_block_pattern[3][1] = 1;
            // end
        endcase
    end
endmodule