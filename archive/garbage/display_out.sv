
// Display Output Controller
module display_out (
    input logic [2:0] current_state,
    input logic [19:0][9:0] stored_array,
    input logic [19:0][9:0] falling_block_display,
    input logic [19:0][9:0] cleared_array,
    output logic [19:0][9:0] display_array
);

// No sequential logic needed - purely combinational
always_ff @(*) begin
    // Empty - no flip-flops needed for this module
end

// Display array selection logic
always_comb begin
    case (current_state)
        3'd0: display_array = stored_array; // INIT
        3'd1: display_array = falling_block_display | stored_array; // SPAWN
        3'd2: display_array = falling_block_display | stored_array; // FALLING
        3'd3: display_array = falling_block_display | stored_array; // ROTATE
        3'd4: display_array = falling_block_display | stored_array; // STUCK
        3'd5: display_array = stored_array; // LANDED
        3'd6: display_array = cleared_array; // EVAL
        3'd7: display_array = stored_array; // GAMEOVER
        default: display_array = stored_array;
    endcase
end

endmodule