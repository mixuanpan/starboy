module movement (
    input logic clk, reset, drop_tick,
    input logic [2:0] current_state,
    input logic [2:0] current_state_counter,
    input logic left_pulse, right_pulse,
    input logic collision_bottom, collision_left, collision_right,
    input logic [4:0] next_current_block_type,
    output logic [4:0] blockY,
    output logic [3:0] blockX,
    output logic [4:0] current_block_type
);

// Sequential logic for block position and type updates
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        blockY <= 5'd0;
        blockX <= 4'd3;
        current_block_type <= 0;
    end else if (current_state == 3'd1) begin // SPAWN
        blockY <= 5'd0;
        blockX <= 4'd3;
        current_block_type <= {2'b0,current_state_counter};
    end else if (current_state == 3'd2) begin // FALLING
        if (drop_tick && !collision_bottom) begin
            blockY <= blockY + 5'd1;
        end
       
        if (left_pulse && !collision_left) begin
            blockX <= blockX - 4'd1;
        end else if (right_pulse && !collision_right) begin
            blockX <= blockX + 4'd1;
        end
    end else if (current_state == 3'd3) begin // ROTATE
        current_block_type <= next_current_block_type;
        
        if (collision_left) blockX <= blockX + 1;
        else if (collision_right) blockX <= blockX - 1;
    end 
end



endmodule