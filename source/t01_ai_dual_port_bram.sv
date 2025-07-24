`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_ai_dual_port_bram  
// Description : A dual port bram for both the input feature 
//               map buffer, weight buffer, and output feature map
// 
//
/////////////////////////////////////////////////////////////////
module t01_ai_dual_port_bram #(
    parameter int DATA_WIDTH = 16, // bits per feature-map element 
    parameter int DEPTH = 1024, // number of words in the buffer 
    parameter int ADDR_W = $clog2(DEPTH) //
)(
    input logic clk, rst, 

    // Write port - A 
    input logic write_en, // gated by buffer selected & read valid 
    input logic [ADDR_W-1:0] write_addr, // drive by BRAM write arbiter 
    input logic [DATA_WIDTH-1:0] write_data, // from mem_read_dta FIFO 

    // Read port - B 
    input logic read_en, 
    input logic [ADDR_W-1:0] read_addr, // flat addresses = row * W_out + col 
    output logic [DATA_WIDTH-1:0] read_data // to Convolution Engine input 
);
    // separate storage array 
    // could be infer vendors as well but idk how to do it 
    logic [DEPTH-1:0][DATA_WIDTH-1:0] mem; 

    // port A write 
    always_ff @(posedge clk) begin 
        if (write_en) begin 
            mem[write_addr] <= write_data; 
        end 
    end 

    // port B synchronous read 
    always_ff @(posedge clk) begin 
        if (read_en) begin 
            read_data <= mem[read_addr]; 
        end 
    end
endmodule 