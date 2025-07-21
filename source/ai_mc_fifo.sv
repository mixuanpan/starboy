`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_cu_fsm 
// Description : Control Unit FSM Controller 
// 
//
/////////////////////////////////////////////////////////////////
module ai_mc_fifo #(
    parameter int DATA_W = 32, // width of each word
    parameter int DEPTH = 16, // number of entries
    parameter int ADDR_W = $clog2(DEPTH) // bits to index DEPTH 
)(
    input logic clk, rst, 

    // write & read interface 
    input logic wr_en, rd_en, // asser to engueue/dequeue when not full/not empty 
    input logic [DATA_W-1:0] wr_data, // data in 
    output logic [DATA_W-1:0] rd_data, // data out 
    output logic full, empty // no more room/no data to read 
); 
    logic [DATA_W-1:0] mem [0:DEPTH-1]; // memory array 
    logic [ADDR_W:0] wr_ptr, rd_ptr; // pointers with extra MSB for full/empty distinction 

    assign rd_data = mem[rd_ptr[ADDR_W-1:0]]; // read operation 
    assign full = (wr_ptr[ADDR_W] != rd_ptr[ADDR_W]) && (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]); // full when pointers match except for the MSB (wrapped once ahead)
    assign empty = (wr_ptr == rd_ptr); // empty when pointers are exactly the same 
    // pointer updates 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            wr_ptr <= 0; 
            rd_ptr <= 0; 
        end else begin 
            if (wr_en && !full) begin 
                mem[wr_ptr[ADDR_W-1:0]] <= wr_data; // write operation 
                wr_ptr <= wr_ptr + 1; 
            end 

            if (rd_en && !empty) begin 
                rd_ptr <= rd_ptr + 1; 
            end 
        end 
    end 
endmodule 