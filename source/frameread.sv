module frameread #(
    parameter DATA_W    = 16,
    parameter GRID_ROWS = 8,
    parameter GRID_COLS = 8
) (
    input  logic [$clog2(GRID_ROWS)-1:0] row_inx,
    input  logic [$clog2(GRID_COLS)-1:0] col_inx,
    input  logic [DATA_W-1:0]            c_grid [0:GRID_ROWS-1][0:GRID_COLS-1],
    output logic [DATA_W-1:0]            c_frame[0:4][0:4]
);
    // Unrolled combinational copy with automatic casting
    always_comb begin
        automatic int r = row_inx;
        automatic int c = col_inx;
        // Row 0
        c_frame[0][0] = c_grid[r+0][c+0];
        c_frame[0][1] = c_grid[r+0][c+1];
        c_frame[0][2] = c_grid[r+0][c+2];
        c_frame[0][3] = c_grid[r+0][c+3];
        c_frame[0][4] = c_grid[r+0][c+4];
        // Row 1
        c_frame[1][0] = c_grid[r+1][c+0];
        c_frame[1][1] = c_grid[r+1][c+1];
        c_frame[1][2] = c_grid[r+1][c+2];
        c_frame[1][3] = c_grid[r+1][c+3];
        c_frame[1][4] = c_grid[r+1][c+4];
        // Row 2
        c_frame[2][0] = c_grid[r+2][c+0];
        c_frame[2][1] = c_grid[r+2][c+1];
        c_frame[2][2] = c_grid[r+2][c+2];
        c_frame[2][3] = c_grid[r+2][c+3];
        c_frame[2][4] = c_grid[r+2][c+4];
        // Row 3
        c_frame[3][0] = c_grid[r+3][c+0];
        c_frame[3][1] = c_grid[r+3][c+1];
        c_frame[3][2] = c_grid[r+3][c+2];
        c_frame[3][3] = c_grid[r+3][c+3];
        c_frame[3][4] = c_grid[r+3][c+4];
        // Row 4
        c_frame[4][0] = c_grid[r+4][c+0];
        c_frame[4][1] = c_grid[r+4][c+1];
        c_frame[4][2] = c_grid[r+4][c+2];
        c_frame[4][3] = c_grid[r+4][c+3];
        c_frame[4][4] = c_grid[r+4][c+4];
    end
endmodule
