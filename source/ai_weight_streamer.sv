// module ai_weight_streamer #(
//   parameter int BYTES  = 1153,
//   parameter int ADDR_W = $clog2(BYTES)
// ) (
//   input  logic               clk,
//   input  logic               rst,
//   input  logic               start,
//   output logic [ADDR_W-1:0]  addr_a,
//   output logic [ADDR_W-1:0]  addr_b,
//   input  logic [7:0]         dout_a,
//   input  logic [7:0]         dout_b,
//   output logic signed [7:0]  w_west [0:3],
//   output logic               valid,
//   output logic               done
// );

//   // raw byte‐counts per layer
//   localparam int BYTES_L0  =  80;
//   localparam int BYTES_L1  = 528;
//   localparam int BYTES_L2  = 528;
//   localparam int BYTES_L3  =  17;

//   // half‐byte cycles
//   localparam int CYCLES_L0 = (BYTES_L0 + 1) / 2;
//   localparam int CYCLES_L1 = (BYTES_L1 + 1) / 2;
//   localparam int CYCLES_L2 = (BYTES_L2 + 1) / 2;
//   localparam int CYCLES_L3 = (BYTES_L3 + 1) / 2;

//   // total across all layers
//   localparam int TOTAL_CYCLES = CYCLES_L0 + CYCLES_L1 + CYCLES_L2 + CYCLES_L3;

//   // SIZE‐MATCHED layer base addresses
//   localparam logic [ADDR_W-1:0] BASE [0:3] = '{
//     0,
//     BYTES_L0,
//     BYTES_L0 + BYTES_L1,
//     BYTES_L0 + BYTES_L1 + BYTES_L2
//   };

//   // SIZE‐MATCHED cycle counts
//   localparam logic [$clog2(TOTAL_CYCLES+1)-1:0] CYC [0:3] = '{
//     CYCLES_L0,
//     CYCLES_L1,
//     CYCLES_L2,
//     CYCLES_L3
//   };

//   // counters
//   logic [1:0]        layer;       // which layer 0..3
//   logic [8:0]        cyc_cnt;     // up to TOTAL_CYCLES=577 so 9 bits
//   logic [ADDR_W-1:0] byte_addr;   // 0..(BYTES_Lx-1)
  
//   // unpack and sign-extend 4 weights from two bytes
//   always_ff @(posedge clk) begin
//     if (rst) begin
//       { w_west[0], w_west[1], w_west[2], w_west[3] } <= '0;
//     end else if (valid) begin
//       // high nibble of dout_a → row 0
//       w_west[0] <= { {4{dout_a[7]}}, dout_a[7:4] };
//       // low  nibble of dout_a → row 1
//       w_west[1] <= { {4{dout_a[3]}}, dout_a[3:0] };
//       // same for port B
//       w_west[2] <= { {4{dout_b[7]}}, dout_b[7:4] };
//       w_west[3] <= { {4{dout_b[3]}}, dout_b[3:0] };
//     end
//   end

//   // address generator + FSM
//   always_ff @(posedge clk or posedge rst) begin
//     if (rst) begin
//       layer     <= 0;
//       cyc_cnt   <= 0;
//       byte_addr <= 0;
//       valid     <= 1'b0;
//       done      <= 1'b0;
//     end else begin
//       done  <= 1'b0;  // default
//       if (start) begin
//         // kick off new stream
//         layer     <= 0;
//         cyc_cnt   <= 0;
//         byte_addr <= 0;
//         valid     <= 1'b1;
//       end else if (valid) begin
//         // generate ROM addresses
//         addr_a <= BASE[layer] + byte_addr;
//         addr_b <= BASE[layer] + byte_addr + 1;
        
//         // advance our byte pointer by 2 every cycle
//         byte_addr <= byte_addr + 2;
//         cyc_cnt   <= cyc_cnt + 1;
        
//         // layer‐done?
//         if (cyc_cnt + 1 == CYC[layer]) begin
//           if (layer == 3) begin
//             // all 4 layers done
//             valid <= 1'b0;
//             done  <= 1'b1;
//           end else begin
//             // next layer
//             layer     <= layer + 1;
//             byte_addr <= 0;
//             cyc_cnt   <= 0;
//           end
//         end
//       end
//     end
//   end

// endmodule
