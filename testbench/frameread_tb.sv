`timescale 1ns/1ps

module frameread_tb;
    //--------------------------------------------------------------------------
    // Parameters
    //--------------------------------------------------------------------------
    localparam int DATA_W    = 16;
    localparam int GRID_ROWS = 8;
    localparam int GRID_COLS = 8;

    //--------------------------------------------------------------------------
    // Interface signals
    //--------------------------------------------------------------------------
    logic [$clog2(GRID_ROWS)-1:0] row_inx;
    logic [$clog2(GRID_COLS)-1:0] col_inx;

    logic [DATA_W-1:0] c_grid  [0:GRID_ROWS-1][0:GRID_COLS-1];
    logic [DATA_W-1:0] c_frame [0:4][0:4];
    logic [DATA_W-1:0] exp_frame [0:4][0:4];

    //--------------------------------------------------------------------------
    // DUT instantiation
    //--------------------------------------------------------------------------
    frameread #(
        .DATA_W   (DATA_W),
        .GRID_ROWS(GRID_ROWS),
        .GRID_COLS(GRID_COLS)
    ) dut (
        .row_inx (row_inx),
        .col_inx (col_inx),
        .c_grid  (c_grid),
        .c_frame (c_frame)
    );

    //--------------------------------------------------------------------------
    // Test sequence
    //--------------------------------------------------------------------------
    initial begin
        // 1) Fill the source grid with a known ramp pattern
        foreach (c_grid[r, c])
            c_grid[r][c] = r * GRID_COLS + c;

        // 2) Run 50 random trials
        for (int t = 0; t < 50; t++) begin
            row_inx = $urandom_range(0, GRID_ROWS - 5);
            col_inx = $urandom_range(0, GRID_COLS - 5);
            #0;  // delta-cycle to settle combinational logic

            // Golden model: nested loops
            for (int i = 0; i < 5; i++)
                for (int j = 0; j < 5; j++)
                    exp_frame[i][j] = c_grid[row_inx + i][col_inx + j];

            // Compare DUT output to golden reference
            for (int i = 0; i < 5; i++)
                for (int j = 0; j < 5; j++)
                    if (c_frame[i][j] !== exp_frame[i][j])
                        $fatal(1, "Mismatch at trial %0d window=(%0d,%0d) elt=(%0d,%0d): exp=%0d got=%0d", 
                               t, row_inx, col_inx, i, j,
                               exp_frame[i][j], c_frame[i][j]);
        end

        $display("[TB] All trials passed — DUT matches reference!");
        $finish;
    end
endmodule
