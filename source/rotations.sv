module block_type_rotator (
    input logic [2:0] current_state,
    input logic [4:0] current_block_type,
    output logic [4:0] next_current_block_type
);


// Combinational logic for rotation type calculation
always_comb begin
    next_current_block_type = current_block_type;
    
    if (current_state == 3'd3) begin // ROTATE
        case (current_block_type)
            'd0:  next_current_block_type = 'd7;
            'd7:  next_current_block_type = 'd0;
            'd1:  next_current_block_type = 'd1;
            'd2:  next_current_block_type = 'd9;
            'd9:  next_current_block_type = 'd2;
            'd3:  next_current_block_type = 'd8;
            'd8:  next_current_block_type = 'd3;
            'd5:  next_current_block_type = 'd13;
            'd13: next_current_block_type = 'd14;
            'd14: next_current_block_type = 'd15;
            'd15: next_current_block_type = 'd5;
            'd4:  next_current_block_type = 'd10;
            'd10: next_current_block_type = 'd11;
            'd11: next_current_block_type = 'd12;
            'd12: next_current_block_type = 'd4;
            'd6:  next_current_block_type = 'd18;
            'd18: next_current_block_type = 'd17;
            'd17: next_current_block_type = 'd16;
            'd16: next_current_block_type = 'd6;
            default: next_current_block_type = current_block_type;
        endcase
    end 
end

endmodule