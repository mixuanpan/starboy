`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : clkdiv1hz
// Description : takes 25mhz clock and turns it into 1 hz, subject to change
// 
//
/////////////////////////////////////////////////////////////////
module argmax_unit #(
    parameter Q_VALUE_WIDTH = 16,
    parameter MOVE_ID_WIDTH = 6
) (
    input logic clk,
    input logic rst,
    input logic start,
    input logic valid,
    input logic signed [Q_VALUE_WIDTH-1:0] q_value,
    input logic [MOVE_ID_WIDTH-1:0] move_id,
    input logic last,
    output logic [MOVE_ID_WIDTH-1:0] best_move_id,
    output logic signed [Q_VALUE_WIDTH-1:0] best_q_value,
    output logic done
);

    logic signed [Q_VALUE_WIDTH-1:0] best_q;
    logic [MOVE_ID_WIDTH-1:0] best_id;
    
    localparam logic signed [Q_VALUE_WIDTH-1:0] MIN_Q_VALUE = {1'b1, {(Q_VALUE_WIDTH-1){1'b0}}};
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            best_q <= MIN_Q_VALUE;
            best_id <= '0;
            done <= 1'b0;
        end else begin
            if (start) begin
                best_q <= MIN_Q_VALUE;
                best_id <= '0;
                done <= 1'b0;
            end
            else if (valid) begin
                if (q_value > best_q) begin
                    best_q <= q_value;
                    best_id <= move_id;
                end
                if (last) begin
                    done <= 1'b1;
                end else begin
                    done <= 1'b0;
                end
            end else begin
                done <= 1'b0;
            end
        end
    end

    // output
    always_comb begin
        best_move_id = best_id;
        best_q_value = best_q;
    end

endmodule