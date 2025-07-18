module stored_arrays (
    input logic clk, reset,
    input logic [2:0] current_state,
    input logic eval_complete,
    input logic [19:0][9:0] falling_block_display,
    input logic [19:0][9:0] cleared_array,
    output logic [19:0][9:0] stored_array
);

// Update stored array after evaluation
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        stored_array <= '0;
    end else if (current_state == 3'd4) begin // STUCK
        stored_array <= stored_array | falling_block_display;
    end else if (current_state == 3'd6 && eval_complete) begin // EVAL
        stored_array <= cleared_array;
    end
end


endmodule