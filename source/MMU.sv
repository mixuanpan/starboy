/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : MMU
// Description : Generates a systolic array [currently 4x4] uttilizing the given MACs  
// 
//
/////////////////////////////////////////////////////////////////

module MMU (
    input  logic [31:0] inp_west0, inp_west4, inp_west8, inp_west12,
    input  logic [31:0] inp_north0, inp_north1, inp_north2, inp_north3,
    input  logic clk,
    input  logic rst,
    output logic done
);

    logic [3:0] count;
    // inter-PE wires

    logic [31:0]
        outp_south0,  outp_south1,  outp_south2,  outp_south3,
        outp_south4,  outp_south5,  outp_south6,  outp_south7,
        outp_south8,  outp_south9,  outp_south10, outp_south11,
        outp_south12, outp_south13, outp_south14, outp_south15;

    logic [31:0]
        outp_east0,   outp_east1,   outp_east2,   outp_east3,
        outp_east4,   outp_east5,   outp_east6,   outp_east7,
        outp_east8,   outp_east9,   outp_east10,  outp_east11,
        outp_east12,  outp_east13,  outp_east14,  outp_east15;

    logic [63:0]
        result0,  result1,  result2,  result3,
        result4,  result5,  result6,  result7,
        result8,  result9,  result10, result11,
        result12, result13, result14, result15;

    // row 0
    MAC P0  (inp_north0,  inp_west0,  clk, rst, outp_south0,  outp_east0,  result0);
    MAC P1  (inp_north1,  outp_east0, clk, rst, outp_south1,  outp_east1,  result1);
    MAC P2  (inp_north2,  outp_east1, clk, rst, outp_south2,  outp_east2,  result2);
    MAC P3  (inp_north3,  outp_east2, clk, rst, outp_south3,  outp_east3,  result3);

    // column 0
    MAC P4  (outp_south0, inp_west4,  clk, rst, outp_south4,  outp_east4,  result4);
    MAC P8  (outp_south4, inp_west8,  clk, rst, outp_south8,  outp_east8,  result8);
    MAC P12 (outp_south8, inp_west12, clk, rst, outp_south12, outp_east12, result12);

    // interior
    MAC P5  (outp_south1, outp_east4, clk, rst, outp_south5,  outp_east5,  result5);
    MAC P6  (outp_south2, outp_east5, clk, rst, outp_south6,  outp_east6,  result6);
    MAC P7  (outp_south3, outp_east6, clk, rst, outp_south7,  outp_east7,  result7);
    MAC P9  (outp_south5, outp_east8, clk, rst, outp_south9,  outp_east9,  result9);
    MAC P10 (outp_south6, outp_east9, clk, rst, outp_south10, outp_east10, result10);
    MAC P11 (outp_south7, outp_east10,clk, rst, outp_south11, outp_east11, result11);
    MAC P13 (outp_south9, outp_east12,clk, rst, outp_south13, outp_east13, result13);
    MAC P14 (outp_south10,outp_east13,clk, rst, outp_south14, outp_east14, result14);
    MAC P15 (outp_south11,outp_east14,clk, rst, outp_south15, outp_east15, result15);

    // cycle counter & done flag

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            done  <= 1'b0;
            count <= 4'd0;
        end else begin
            if (count == 4'd9) begin
                done  <= 1'b1;
                count <= 4'd0;
            end else begin
                done  <= 1'b0;
                count <= count + 4'd1;
            end
        end
    end
endmodule