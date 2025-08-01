`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_ai_argmax_unit
// Description : output feature map 
// 
//
/////////////////////////////////////////////////////////////////
module t01_ai_argmax_unit #(
    parameter Q_VALUE_WIDTH = 8, // 200 cells in the grid 
    parameter MOVE_ID_WIDTH = 6
) (
    input logic clk,
    input logic rst,
    input logic start,
    input logic valid,
    input logic signed [Q_VALUE_WIDTH-1:0] q_value,
    input logic [MOVE_ID_WIDTH-1:0] move_id,
    input logic last,
    output logic signed [Q_VALUE_WIDTH-1:0] best_q_value, // distance from the uppper right corner (0, 0) to the first reference point of the current block
    output logic done
);

    logic signed [Q_VALUE_WIDTH-1:0] best_q;
    logic [MOVE_ID_WIDTH-1:0] best_id;
    
    localparam logic signed [Q_VALUE_WIDTH-1:0] MIN_Q_VALUE = {1'b1, {(Q_VALUE_WIDTH-1){1'b0}}};
    
    assign best_q_value = best_q; 
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

logic [Q_VALUE_WIDTH-1:0] c_q_val, n_q_val; 
    // output
    // always_comb begin

        case (move_id) 
            'h1: begin // down 
                n_q_val = c_q_val + 'd10; 
            end

            'h2: begin // left 
                n_q_val = c_q_val + 'd1; 
            end

            'h3: begin // right 
                n_q_val = c_q_val - 'd1; 
            end

            default: begin end
        endcase

    // end

endmodule