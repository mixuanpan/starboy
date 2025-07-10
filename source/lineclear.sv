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

  localparam int ROW_W = $clog2(22);
  localparam int COL_W = $clog2(10);

  typedef enum logic [1:0] { SCAN, COPY, DONE } lineclear_state_t;
  lineclear_state_t state, n_state;

  logic [ROW_W-1:0] row_in, row_out, n_row_in, n_row_out;
  logic [COL_W-1:0] col, n_col;
  logic row_full, n_row_full;
  logic [ROW_W-1:0] output_row_idx, n_output_row_idx;

  assign done = (state == DONE);
  // --- Sequential ---
  always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
          state          <= SCAN;
          row_in         <= 0;
          row_out        <= 0;
          col            <= 0;
          row_full       <= 1'b1;
          output_row_idx <= 0;
          // Optional: clear n_grid here
      end else if (enable) begin
          state          <= n_state;
          row_in         <= n_row_in;
          row_out        <= n_row_out;
          col            <= n_col;
          row_full       <= n_row_full;
          output_row_idx <= n_output_row_idx;
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

          // COPY row if not full; if full, insert empty row in output
          COPY: begin
              if (row_full) begin
                  // Insert zero row in output
                  n_grid[output_row_idx][col] = 3'b0;
              end else begin
                  // Copy input row to output row
                  n_grid[output_row_idx][col] = c_grid[row_in][col];
              end
              if (col == 9) begin
                  n_row_in  = row_in + 1'b1;
                  if (row_full)
                      n_output_row_idx = output_row_idx + 1'b1; // Only increment output if row was full
                  else
                      n_output_row_idx = output_row_idx + 1'b1;
                  n_col     = 0;
                  n_row_full = 1'b1; // Assume next row is full until proven otherwise
                  if (row_in == 21)
                      n_state = DONE;
                  else
                      n_state = SCAN;
              end else begin
                  n_col = col + 1'b1;
              end
          end

          DONE: begin
              // Wait for rst
              // Or if you want to re-enable, you can add:
              if (!enable)
                  n_state = SCAN;
          end

          default: n_state = SCAN;
      endcase
  end

endmodule