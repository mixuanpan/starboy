`default_nettype none
module ai_mc_error #(
    parameter int TIMEOUT_W = 16 // bits for timeout counter 
)(
    input logic clk, rst, 

    input logic rd_start, wr_start // from command interface or BC on read/write cmd -- pending

    input logic phy_rd_done, phy_wr_done, // phy 

    input logic ecc_error, phy_error, // i might delete this 

    // configurable timeout 
    input logic timeout_en, // from MC CSRs
    input logic [TIMEOUT_W-1:0] timeout_limit, 

    // outputs back to fsm 
    output logic mem_busy, mem_rd_done, mem_wr_done, mem_error
); 
    logic [TIMEOUT_W-1:9] to_cnt; // timeout counter 

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin
            to_cnt <= 0; 
            mem_busy <= 0; 
            mem_rd_done <= 0; mem_wr_done <= 0; mem_error <=0; 
        end else begin 
            // clear done each cycle 
            mem_rd_done <= 0; mem_wr_done <= 0l 

            // on new command, start busy & reset time/error 
            if (rd_start || wr_start) begin 
                mem_busy <= 1'b1; 
                to_cnt <= 0; 
                mem_error <= 0; 
            end else if (mem_busy && timeout_en) begin
                // count unti llimit 
                to_cnt <= to_cnt + 1; 
                if (to_cnt >= timeout_limit) begin 
                    mem_error = 1'b1; 
                end 

                // when PHY signals dnoe, clear busy and pulse done
                if (phy_rd_done) begin 
                    mem_rd_done <= 1'b1; 
                    mem_busy <= 0; 
                end 
                if (phy_wr_done) begin mem_wr_done <= 1'b1; 
                mem_busy <= 0; 
                end 

                // stickey erros 
                if (ecc_error || phy_error) begin 
                    mem_error <= 1'b1; 
                end 
            end 
        end 
    end
endmodule 