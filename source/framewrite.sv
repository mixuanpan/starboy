always_ff @(posedge clk. negedge rst_n) begin
  if (!rst_n) begin
    // optional grid reset here
  end else begin
    // ---- row 0 ----
    n_grid[row_inx + 0][col_inx + 0] <= n_frame[0][0];
    n_grid[row_inx + 0][col_inx + 1] <= n_frame[0][1];
    n_grid[row_inx + 0][col_inx + 2] <= n_frame[0][2];
    n_grid[row_inx + 0][col_inx + 3] <= n_frame[0][3];
    n_grid[row_inx + 0][col_inx + 4] <= n_frame[0][4];

    // ---- row 1 ----
    n_grid[row_inx + 1][col_inx + 0] <= n_frame[1][0];
    n_grid[row_inx + 1][col_inx + 1] <= n_frame[1][1];
    n_grid[row_inx + 1][col_inx + 2] <= n_frame[1][2];
    n_grid[row_inx + 1][col_inx + 3] <= n_frame[1][3];
    n_grid[row_inx + 1][col_inx + 4] <= n_frame[1][4];

    // ---- row 2 ----
    n_grid[row_inx + 2][col_inx + 0] <= n_frame[2][0];
    n_grid[row_inx + 2][col_inx + 1] <= n_frame[2][1];
    n_grid[row_inx + 2][col_inx + 2] <= n_frame[2][2];
    n_grid[row_inx + 2][col_inx + 3] <= n_frame[2][3];
    n_grid[row_inx + 2][col_inx + 4] <= n_frame[2][4];

    // ---- row 3 ----
    n_grid[row_inx + 3][col_inx + 0] <= n_frame[3][0];
    n_grid[row_inx + 3][col_inx + 1] <= n_frame[3][1];
    n_grid[row_inx + 3][col_inx + 2] <= n_frame[3][2];
    n_grid[row_inx + 3][col_inx + 3] <= n_frame[3][3];
    n_grid[row_inx + 3][col_inx + 4] <= n_frame[3][4];

    // ---- row 4 ----
    n_grid[row_inx + 4][col_inx + 0] <= n_frame[4][0];
    n_grid[row_inx + 4][col_inx + 1] <= n_frame[4][1];
    n_grid[row_inx + 4][col_inx + 2] <= n_frame[4][2];
    n_grid[row_inx + 4][col_inx + 3] <= n_frame[4][3];
    n_grid[row_inx + 4][col_inx + 4] <= n_frame[4][4];
  end
end