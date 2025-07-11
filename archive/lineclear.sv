`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : lineclear
// Description : Clears filled line 
// 
//
/////////////////////////////////////////////////////////////////


module lineclear (
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  enable,
    input  logic [21:0][9:0][2:0] c_grid,
    output logic [21:0][9:0][2:0] n_grid,
    output logic                  done
);
    typedef enum logic [1:0]{
        IDLE, 
        SCAN, 
        CHECK, 
        COPY
    } clear_state_t; 

    logic [21:0][9:0][2:0] c_grid_tmp, n_grid_tmp; 
    logic [4:0] i_cnt, n_i_cnt, c_update_i, n_update_i; 
    logic [3:0] j_cnt, n_j_cnt, cell_count, n_cell_count; 
    logic row_full, cell_full, copying, cell_empty; 
    clear_state_t c_state, n_state; 

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            i_cnt <= 0; 
            j_cnt <= 0; 
            c_grid_tmp <= 0; 
            c_state <= IDLE; 
            cell_count <= 0; 
            c_update_i <= 'd21; 
        end else begin
            i_cnt <= n_i_cnt; 
            j_cnt <= n_j_cnt;  
            c_grid_tmp <= n_grid_tmp; 
            c_state <= n_state; 
            cell_count <= n_cell_count; 
            c_update_i <= n_update_i; 
        end 
    end

    always_comb begin 
        done = 0; 
        copying = 0; 
        n_grid_tmp = c_grid_tmp; 
        n_state = c_state; 
        n_i_cnt = i_cnt; 
        n_j_cnt = j_cnt; 
        row_full = 0; 
        cell_empty = 0; 
        n_cell_count = cell_count; 
        n_update_i = c_update_i; 
        n_grid = c_grid; 

        if (enable) begin 
            // load the updated grid in only when we're done clearing lines 
            if (done) begin 
                n_grid = c_grid_tmp; 
            end else begin 
                n_grid = c_grid; 
            end 

            case (c_state)
                IDLE: begin 
                    n_i_cnt = 0; 
                    n_j_cnt = 0; 
                    n_cell_count = 0; 
                    if (enable) begin 
                        n_state = SCAN; 
                    end else begin 
                        n_state = c_state; 
                    end 
                end

                SCAN: begin 
                    if (j_cnt == 0) begin 
                        n_cell_count = 0; 
                        n_state = CHECK; 
                    end else begin 
                        if (j_cnt == 'd10) begin 
                            n_state = CHECK; 
                        end else if (c_grid_tmp[i_cnt][j_cnt] != 3'b0) begin 
                            n_cell_count = cell_count + 'd1; 
                            n_state = CHECK; 
                        end else begin 
                            cell_empty = 1'b1; 
                            n_state = CHECK; 
                        end 
                    end 

                end

                CHECK: begin 
                    if (copying) begin 
                        n_state = COPY; 
                    end else if (cell_empty) begin 
                        n_j_cnt = 0; 
                        n_i_cnt = i_cnt + 'd1; 
                        cell_empty = 0; 
                        n_state = SCAN; 
                    end else if (j_cnt == 'd10) begin 
                        if (cell_count == 'd10) begin 
                            copying = 1'b1; 
                            n_update_i = i_cnt; 
                            n_state = COPY; 
                        end else if (i_cnt == 21) begin 
                            done = 1'b1; 
                        end else begin 
                            n_i_cnt = i_cnt + 'd1; 
                            n_j_cnt = 0; 
                            n_state = SCAN; 
                        end 
                    end else begin 
                        // starting from a new 
                        n_j_cnt = j_cnt + 'd1; 
                    end 
                end

                COPY: begin 
                    if (c_update_i == 'd21) begin 
                        n_state = SCAN; 
                    end else begin 
                        if (c_update_i == 0) begin 
                            n_grid[0] = 0; 
                            n_j_cnt = 0; 
                            n_i_cnt = i_cnt + 'd1; 
                            copying = 0; 
                            n_state = SCAN; 
                        end else begin 
                            n_grid_tmp[c_update_i] = c_grid_tmp[c_update_i - 1]; // shift down 
                            n_update_i = c_update_i + 'd1; 
                            n_state = CHECK; 
                        end 
                    end  
                end

                default: begin 
                    n_state = c_state; 
                    n_grid_tmp = c_grid_tmp; 
                end
            endcase
        end
    end
endmodule