`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : ai_cu_config_csrs  
// Description : Control Unit Layer Configuration CSRS Bank (Configuration Registers)
// 
//
/////////////////////////////////////////////////////////////////

module ai_cu_lconfig_csrs #(
    parameter ADDR_WIDTH = 6, // convers 0x00 - 0x3F 
    parameter DATA_WIDTH = 32
)(
    input logic clk, rst, 

    // simple bus interface 
    input logic cs, // chip-select 
    input logic we, // write-endable 
    input logic [ADDR_WIDTH-1:0] addr, // word-aligned offset 
    input logic [DATA_WIDTH-1:0] wdata, 
    output logic [DATA_WIDTH-1:0] rdata,

    // outputs into the control unit 
    output logic [15:0] in_height, in_width, in_ch, out_ch, 
    output logic [3:0] layer_type, kernel_size, stride,
    output logic relu_en, pool_en, 
    output logic [31:0] addr_ifm_base, addr_wgt_base, addr_ofm_base 
); 
    // field unpacking 
    assign in_height = regs[4'h00][15:0]; 
    assign in_width = regs[4'h01][15:0]; 
    assign in_ch = regs[4'h02][15:0]; 
    assign out_ch = regs[4'h03][15:0]; 

    // word 0x10 
    logic [15:0] cfg1 = regs[4'h04][15:0]; 
    assign layer_type = cfg1[15:12]; 
    assign kernel_size = cfg1[11:8]; 
    assign stride = cfg1[7:4]; 
    assign relu_en = cfg1[3]; 
    assign pool_en = cfg1[2]; 

    // internal register file 
    logic [DATA_WIDTH-1:0] regs [0:(1 << ADDR_WIDTH) / 4 - 1]; 

    // write port 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            // reset all CSRs to zero 
            integer i; 
            for (i = 0; i < (1 << ADDR_WIDTH) / 4; i++) begin 
                regs[i] <= 0; 
            end 
        end else if (cs && we) begin 
            regs[addr[3:0]] <= wdata; 
        end 
    end 

    // Read port 
    always_comb begin 
        if (cs && !we) begin 
            rdata = regs[addr[3:0]]; 
        end else begin 
            rdata = 0; 
        end 
    end
endmodule 

// Offset	Name	Width	Fields / Description
// 0x00	IN_HEIGHT	16 bit	Input feature‐map height (Hₙ)
// 0x04	IN_WIDTH	16 bit	Input feature‐map width (Wₙ)
// 0x08	IN_CH	16 bit	Number of input channels (Cᵢ)
// 0x0C	OUT_CH	16 bit	Number of output channels (Cₒ)
// 0x10	KERNEL_STRIDE_TYPE	16 bit	░[15:12] layer_type (e.g. 0=Conv,1=Pool,2=FC…)