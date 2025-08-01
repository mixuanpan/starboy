`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_counter 
// Description : counter for reading in a new block 
// 
//
/////////////////////////////////////////////////////////////////

module t01_counter(
    input logic clk, rst,
    input logic enable,      // generate new random number
    output logic [2:0] block_type  // 0-6 for tetris blocks
);

    logic [15:0] lfsr_reg;
    logic feedback;
    
    // LFSR polynomial: x^16 + x^14 + x^13 + x^11 + 1
    assign feedback = lfsr_reg[15] ^ lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[10];
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            lfsr_reg <= 16'd332; 
        end else if (enable) begin
            lfsr_reg <= {lfsr_reg[14:0], feedback};
        end
    end
        
    // map to tetris block types (0-6)
    assign block_type = lfsr_reg[2:0] == 3'd7 ? (lfsr_reg[5:3] == 3'd7 ? 3'd0 : lfsr_reg[5:3]) : lfsr_reg[2:0]; // added extra redundancy
endmodule
