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
            c_grid_tmp <= c_grid; 
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

  // --- Next-state/combinational logic ---
  always_comb begin
      // Default assignments to prevent latches
      n_state          = state;
      n_row_in         = row_in;
      n_row_out        = row_out;
      n_col            = col;
      n_row_full       = row_full;
      n_output_row_idx = output_row_idx;
      n_grid           = c_grid;  // Default: pass through input grid

      case (state)
          // SCAN a row for fullness, one cell per clk
          SCAN: begin
              if (c_grid[row_in][col] == 0)
                  n_row_full = 0;
              if (col == 9) begin
                  n_state = COPY;
                  n_col  = 0;
              end else begin
                  n_col = col + 1'b1;
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
