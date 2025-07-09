`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : frame_extract 
// Description : Extracts grid to c_frame 
// 
//
/////////////////////////////////////////////////////////////////

module frame_extract (
    input logic [21:0][9:0][2:0] c_grid, 
    input logic [4:0] row_inx, 
    input logic [3:0] col_inx, 
    input clk, rst, en, 
    output logic [4:0][4:0][2:0] c_frame, 
    output logic done
); 

logic [4:0] cnt; 
logic [4:0] i_idx; 
logic [4:0] j_idx; 

assign i_idx = cnt / 5;
assign j_idx = cnt % 5; 


always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        cnt <= 5'd0;
        done <= 1'b0;
    end else if (en) begin 
        c_frame[i_idx][j_idx] <= c_grid[row_inx + i_idx][col_inx + j_idx];
        if (cnt == 5'd24) begin
            cnt <= 5'd0;
            done <= 1'b1;
        end else begin
            cnt <= cnt + 5'd1;
            done <= 1'b0;
        end
    end 
end
endmodule 
