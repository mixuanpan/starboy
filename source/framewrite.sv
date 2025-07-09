`default_nettype none
module framewrite(
  input logic [4:0][4:0][2:0]
);

parameter int WIN = 5;
localparam int CNT_W = $clog2(WIN);

typedef enum logic [1:0] {
    COLLECT, 
    WAIT, 
    UPDATE} state_t;
state_t state, n_state;

logic [CNT_W-1:0]  row_cnt, col_cnt, n_row, n_col;
logic update_req;
logic last_col, last_item;

assign last_col  = (col_cnt   == WIN-1);
assign last_item = last_col && (row_cnt == WIN-1);

always_comb begin
  n_state = state;
  n_row   = row_cnt;
  n_col   = col_cnt;

  unique case (state)
    COLLECT: begin
      if (last_item)
        n_state = WAIT;
      else
        { n_row, n_col } = next2d(row_cnt, col_cnt);
    end

    WAIT:
      if (update_req)
        n_state = UPDATE;

    UPDATE: begin
      if (last_item)
        n_state = COLLECT;
      else
        { n_row, n_col } = next2d(row_cnt, col_cnt);
    end
  endcase
end

// 2-D counter helper (any WIN ≥ 2)
function automatic logic [2*CNT_W-1:0] next2d(
  input logic [CNT_W-1:0] r,
  input logic [CNT_W-1:0] c
);
  if (c == WIN-1)
    next2d = { r + 1'b1, {CNT_W{1'b0}} };
  else
    next2d = { r, c + 1'b1 };
endfunction

always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    state      <= COLLECT;
    row_cnt    <= '0;
    col_cnt    <= '0;
    update_req <= 1'b0;
  end
  else begin
    state   <= n_state;
    row_cnt <= n_row;
    col_cnt <= n_col;

    if (track_complete)
      update_req <= 1'b1;
    else if (state == UPDATE && n_state == COLLECT)
      update_req <= 1'b0;
  end
end

always_ff @(posedge clk) begin
  if (state == COLLECT) begin
    c_frame[row_cnt][col_cnt] <=
      c_grid[row_inx + row_cnt][col_inx + col_cnt];
  end
  if (state == UPDATE) begin
    n_grid[row_inx + row_cnt][col_inx + col_cnt] <=
      n_frame[row_cnt][col_cnt];
  end
end

endmodule