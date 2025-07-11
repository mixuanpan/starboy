// `default_nettype none

// /////////////////////////////////////////////////////////////////
// // HEADER 
// //
// // Module : lineclear
// // Description : Clears filled line 
// // 
// //
// /////////////////////////////////////////////////////////////////

// typedef enum logic [1:0] {
//     IDLE,
//     SCAN,
//     CLEAR,
//     DONE
// } clear_state_t;

// module lineclear (
//     input  logic                  clk,
//     input  logic                  rst,
//     input  logic                  enable,
//     input  logic [21:0][9:0][2:0] c_grid,
//     output logic [21:0][9:0][2:0] n_grid,
//     output logic                  done
// );

//     clear_state_t c_state, n_state;
//     logic [4:0] scan_row, n_scan_row;
//     logic [4:0] shift_row, n_shift_row;
//     logic [9:0] filled;  // filled cells in current row
//     logic [21:0][9:0][2:0] grid_tmp, n_grid_tmp;

//     assign n_grid = grid_tmp;
//     assign done = (c_state == DONE);

//     // Sequential
//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             c_state   <= IDLE;
//             scan_row  <= 0;
//             shift_row <= 0;
//             grid_tmp  <= c_grid;
//         end else if (enable) begin
//             c_state   <= n_state;
//             scan_row  <= n_scan_row;
//             shift_row <= n_shift_row;
//             grid_tmp  <= n_grid_tmp;
//         end
//     end

//     // Combinational FSM
//     always_comb begin
//         n_state     = c_state;
//         n_scan_row  = scan_row;
//         n_shift_row = shift_row;
//         n_grid_tmp  = grid_tmp;
//         n_grid = c_grid; 

//         case (c_state)
//             IDLE: begin
//                 n_grid_tmp = c_grid;
//                 n_scan_row = 0;
//                 n_state    = enable ? SCAN : IDLE;
//             end

//             SCAN: begin
//                 // Check if current row is full
//                 filled = 0;
//                 for (int j = 0; j < 10; j++)
//                     if (grid_tmp[scan_row][j] != 0) filled++;
//                 if (filled == 10) begin
//                     // Row is full, clear it
//                     n_shift_row = scan_row;
//                     n_state = CLEAR;
//                 end else if (scan_row == 21) begin
//                     n_state = DONE;
//                 end else begin
//                     n_scan_row = scan_row + 1;
//                 end
//             end

//             CLEAR: begin
//                 if (shift_row > 0) begin
//                     // Shift all rows above down
//                     n_grid_tmp[shift_row] = grid_tmp[shift_row - 1];
//                     n_shift_row = shift_row - 1;
//                 end else begin
//                     // Zero the top row
//                     n_grid_tmp[0] = 0;
//                     n_scan_row = 0; // After a clear, recheck from row 0
//                     n_state = SCAN;
//                 end
//             end

//             DONE: begin
//                 // Stay done until reset or enable is lowered
//                 if (!enable) n_state = IDLE;
//             end

//             default: n_state = IDLE;
//         endcase
//     end

// endmodule