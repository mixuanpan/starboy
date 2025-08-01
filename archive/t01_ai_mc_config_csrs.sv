`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_mc_config_csrs 
// Description : CSR Bank for the memory controller 
// 
//
/////////////////////////////////////////////////////////////////
module ai_mc_config_csrs #(
    parameter CSR_ADDR_W = 4, // coer 0x00 - 0x3F
    parameter CSR_DATA_W = 32
)(
    input logic clk, rst, 

    // simple bus interface 
    input logic cs, we, 
    input logic [CSR_ADDR_W-1:0] addr,
    input logic [CSR_DATA_W-1:0] wdata, 
    output logic [CSR_DATA_W] rdata, 

    // ouputs into memory controller 
    output logic [1:0] spi_mode, // CPOL/CPHA
    output logic [7:0] clk_div, // SCK clk div
    output logic [15:0] default_len, // beats per burst 
    output logic ecc_en, // ECC enable 
    output logic [15:0] timeout // cmd timeout 
); 
    logic [CSR_DATA_W-1:0] regs [0:(1<<CSR_ADDR_W)/4-1]; // internal CSR storgage

    // unpack fileds - i want to eliminate this 
    assign spi_mode = regs[2'h0][1:0]; 
    assign clk_div = regs[2'h1][7:0];
    assign default_len = regs[2'h2][15:0]; 
    assign ecc_en = regs[2'h3][0];
    assign timeout = regs[2'h4][15:0]; 
    
    // write & read ports 
    always_ff @(posedge rst, posedge clk) begin 
        if (rst) begin 
            regs <= 0; 
            rdata <= 0; 
        end else if (cs && we) begin 
            regs[addr] <= wdata; 
        end else if (cs && !we) begin 
            rdata = regs[addr]; 
        end 
    end
endmodule 