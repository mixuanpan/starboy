// `default_nettype none 
// /////////////////////////////////////////////////////////////////
// // HEADER 
// //
// // Module : t01_ai_cu_config_csrs  
// // Description : Control Unit Layer Configuration CSRS Bank (Configuration Registers)
// // 
// //
// /////////////////////////////////////////////////////////////////

// module t01_ai_cu_config_csrs #(
//     parameter ADDR_WIDTH = 6, // convers 0x00 - 0x3F 
//     parameter DATA_WIDTH = 32
// )(
//     input logic clk, rst, 

//     // simple bus interface 
//     input logic cs, // chip-select 
//     input logic we, // write-endable 
//     input logic [ADDR_WIDTH-1:0] addr, // word-aligned offset 
//     input logic [DATA_WIDTH-1:0] wdata, 
//     output logic [DATA_WIDTH-1:0] rdata,

//     // tb
//     output logic valid, 
//     // outputs into the control unit 
//     output logic [15:0] in_height, in_width, in_ch, out_ch, 
//     output logic [3:0] layer_type, kernel_size, stride,
//     output logic relu_en, pool_en, 
//     output logic [31:0] addr_ifm_base, addr_wgt_base, addr_ofm_base 
// ); 

//     assign valid = cs && we; 

//     // calculate number of 32-bit words 
//     localparam int REG_COUNT = (1 << (ADDR_WIDTH - 2)); // 6-bi addr ==> 16 words 

//     // internal register file 
//     logic [REG_COUNT-1:0][DATA_WIDTH-1:0] regs; 

//     // field unpacking 
//     assign in_height = regs[0][15:0]; // 0x00
//     assign in_width = regs[1][15:0]; //0x04
//     assign in_ch = regs[2][15:0]; // 0x08
//     assign out_ch = regs[3][15:0]; // 0x0C 

//     // word 0x00 holds packed config fields 
//     assign layer_type = regs[4][15:12]; 
//     assign kernel_size = regs[4][11:8]; 
//     assign stride = regs[4][7:4]; 
//     assign relu_en = regs[4][3]; 
//     assign pool_en = regs[4][2]; 

//     // base addresses for buffers 
//     assign addr_ifm_base = regs[5]; // 0x14
//     assign addr_wgt_base = regs[6]; // 0x18
//     assign addr_ofm_base = regs[7]; // 0x1C 

 

// endmodule 

// // Offset	Name	Width	Fields / Description
// // 0x00	IN_HEIGHT	16 bit	Input feature‐map height (Hₙ)
// // 0x04	IN_WIDTH	16 bit	Input feature‐map width (Wₙ)
// // 0x08	IN_CH	16 bit	Number of input channels (Cᵢ)
// // 0x0C	OUT_CH	16 bit	Number of output channels (Cₒ)
// // 0x10	KERNEL_STRIDE_TYPE	16 bit	░[15:12] layer_type (e.g. 0=Conv,1=Pool,2=FC…)