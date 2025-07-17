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
    input logic [2:0] current_block_type, 
    output logic [3:0][3:0] current_block_pattern 
);

    always_comb begin
        current_block_pattern = 0; 
        case (current_block_type)
            'd0: begin // Line
                current_block_pattern[0][1] = 1'b1;
                current_block_pattern[1][1] = 1'b1;
                current_block_pattern[2][1] = 1'b1;
                current_block_pattern[3][1] = 1'b1;
            end
            'd1: begin //smash boy
                current_block_pattern[0][1] = 1'b1;
                current_block_pattern[0][2] = 1'b1;
                current_block_pattern[1][1] = 1'b1;
                current_block_pattern[1][2] = 1'b1;
            end
            'd2: begin // Loser
                current_block_pattern[0][1] = 1'b1;
                current_block_pattern[1][1] = 1'b1;
                current_block_pattern[2][1] = 1'b1;
                current_block_pattern[2][2] = 1'b1;
            end
            'd3: begin // reverse loser
                current_block_pattern[0][2] = 1'b1;
                current_block_pattern[1][2] = 1'b1;
                current_block_pattern[2][2] = 1'b1;
                current_block_pattern[2][1] = 1'b1;
            end
            'd4: begin // S
                current_block_pattern[0][2] = 1'b1;
                current_block_pattern[0][3] = 1'b1;
                current_block_pattern[1][1] = 1'b1;
                current_block_pattern[1][2] = 1'b1;
            end
            'd5: begin // Z
                current_block_pattern[0][1] = 1'b1;
                current_block_pattern[0][2] = 1'b1;
                current_block_pattern[1][2] = 1'b1;
                current_block_pattern[1][3] = 1'b1;
            end
            'd6: begin // T
                current_block_pattern[0][2] = 1'b1;
                current_block_pattern[1][1] = 1'b1;
                current_block_pattern[1][2] = 1'b1;
                current_block_pattern[1][3] = 1'b1;
            end
            default: begin 
            end
        endcase
    end
endmodule