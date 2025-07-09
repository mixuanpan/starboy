logic [4:0] cnt; 

assign i_idx = cnt / 5;
assign j_idx = cnt % 5; 


always_ff@(posedgec clk, posedge rst) begin
    if (rst) begin
        cnt <= 5'd0;
        done <= 1'b0;
    end else begin 
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



