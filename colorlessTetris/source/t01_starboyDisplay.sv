`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_starboyDisplay
// Description : generates the starboy display
// 
//
/////////////////////////////////////////////////////////////////
module t01_starboyDisplay(
    input logic clk, rst,
    input logic [9:0] x, y,
    output logic [2:0] shape_color
);

    // colors 
    localparam BLACK   = 3'b000;
    localparam WHITE   = 3'b111;
    localparam RED    = 3'b100;  
    
    // font parameters
    localparam CHAR_WIDTH = 8;
    localparam CHAR_HEIGHT = 12;
    localparam CHAR_SCALE = 2;  
    
    // display area parameters
    localparam STARBOY_START_X = 10'd245;
    localparam STARBOY_START_Y = 10'd50;

    logic [7:0] font_rom [0:6][0:11];

    initial begin
        // char 'S' (index 0)
        font_rom[0][0]  = 8'b00111100;
        font_rom[0][1]  = 8'b01100110;
        font_rom[0][2]  = 8'b01100000;
        font_rom[0][3]  = 8'b01100000;
        font_rom[0][4]  = 8'b00110000;
        font_rom[0][5]  = 8'b00011000;
        font_rom[0][6]  = 8'b00001100;
        font_rom[0][7]  = 8'b00000110;
        font_rom[0][8]  = 8'b00000110;
        font_rom[0][9]  = 8'b00000110;
        font_rom[0][10] = 8'b01100110;
        font_rom[0][11] = 8'b00111100;
        
        // char 'T' (index 1)
        font_rom[1][0]  = 8'b01111110;
        font_rom[1][1]  = 8'b01111110;
        font_rom[1][2]  = 8'b00011000;
        font_rom[1][3]  = 8'b00011000;
        font_rom[1][4]  = 8'b00011000;
        font_rom[1][5]  = 8'b00011000;
        font_rom[1][6]  = 8'b00011000;
        font_rom[1][7]  = 8'b00011000;
        font_rom[1][8]  = 8'b00011000;
        font_rom[1][9]  = 8'b00011000;
        font_rom[1][10] = 8'b00011000;
        font_rom[1][11] = 8'b00011000;
        
        // char 'A' (index 2)
        font_rom[2][0]  = 8'b00111100;
        font_rom[2][1]  = 8'b01100110;
        font_rom[2][2]  = 8'b01100110;
        font_rom[2][3]  = 8'b01100110;
        font_rom[2][4]  = 8'b01100110;
        font_rom[2][5]  = 8'b01111110;
        font_rom[2][6]  = 8'b01100110;
        font_rom[2][7]  = 8'b01100110;
        font_rom[2][8]  = 8'b01100110;
        font_rom[2][9]  = 8'b01100110;
        font_rom[2][10] = 8'b01100110;
        font_rom[2][11] = 8'b01100110;
        
        // char 'R' (index 3)
        font_rom[3][0]  = 8'b01111100;
        font_rom[3][1]  = 8'b01100110;
        font_rom[3][2]  = 8'b01100110;
        font_rom[3][3]  = 8'b01100110;
        font_rom[3][4]  = 8'b01100110;
        font_rom[3][5]  = 8'b01111100;
        font_rom[3][6]  = 8'b01111000;
        font_rom[3][7]  = 8'b01101100;
        font_rom[3][8]  = 8'b01100110;
        font_rom[3][9]  = 8'b01100110;
        font_rom[3][10] = 8'b01100110;
        font_rom[3][11] = 8'b01100110;
        
        // char 'B' (index 4)
        font_rom[4][0]  = 8'b01111100;
        font_rom[4][1]  = 8'b01100110;
        font_rom[4][2]  = 8'b01100110;
        font_rom[4][3]  = 8'b01100110;
        font_rom[4][4]  = 8'b01111100;
        font_rom[4][5]  = 8'b01111100;
        font_rom[4][6]  = 8'b01100110;
        font_rom[4][7]  = 8'b01100110;
        font_rom[4][8]  = 8'b01100110;
        font_rom[4][9]  = 8'b01100110;
        font_rom[4][10] = 8'b01100110;
        font_rom[4][11] = 8'b01111100;
        
        // char 'O' (index 5)
        font_rom[5][0]  = 8'b00111100;
        font_rom[5][1]  = 8'b01100110;
        font_rom[5][2]  = 8'b01100110;
        font_rom[5][3]  = 8'b01100110;
        font_rom[5][4]  = 8'b01100110;
        font_rom[5][5]  = 8'b01100110;
        font_rom[5][6]  = 8'b01100110;
        font_rom[5][7]  = 8'b01100110;
        font_rom[5][8]  = 8'b01100110;
        font_rom[5][9]  = 8'b01100110;
        font_rom[5][10] = 8'b01100110;
        font_rom[5][11] = 8'b00111100;
        
        // char 'Y' (index 6)
        font_rom[6][0]  = 8'b01100110;
        font_rom[6][1]  = 8'b01100110;
        font_rom[6][2]  = 8'b01100110;
        font_rom[6][3]  = 8'b01100110;
        font_rom[6][4]  = 8'b01100110;
        font_rom[6][5]  = 8'b00111100;
        font_rom[6][6]  = 8'b00011000;
        font_rom[6][7]  = 8'b00011000;
        font_rom[6][8]  = 8'b00011000;
        font_rom[6][9]  = 8'b00011000;
        font_rom[6][10] = 8'b00011000;
        font_rom[6][11] = 8'b00011000;
    end
    
    logic in_starboy_text;
    logic [2:0] char_index;
    logic [2:0] font_index;
    logic [9:0] char_x, char_y;
    logic [2:0] pixel_x;
    logic [3:0] pixel_y;
    logic pixel_on;
    
    always_comb begin
        shape_color = BLACK;
        char_index = 3'd0;
        font_index = 3'd0;
        char_x = 10'd0;
        char_y = 10'd0;
        pixel_x = 3'd0;
        pixel_y = 4'd0;
        pixel_on = 1'b0;
        
        in_starboy_text = (x >= STARBOY_START_X) && 
                         (x < STARBOY_START_X + (7 * CHAR_WIDTH * CHAR_SCALE)) &&
                         (y >= STARBOY_START_Y) && 
                         (y < STARBOY_START_Y + (CHAR_HEIGHT * CHAR_SCALE));
        
        if (in_starboy_text) begin
            char_x = (x - STARBOY_START_X) / CHAR_SCALE;
            char_y = (y - STARBOY_START_Y) / CHAR_SCALE;
            char_index = 3'({22'd0, char_x} / CHAR_WIDTH);
            pixel_x = 3'({22'd0, char_x} % CHAR_WIDTH);
            pixel_y = 4'({22'd0, char_y} % CHAR_HEIGHT);
  
            case (char_index)
                3'd0: font_index = 3'd0; // s
                3'd1: font_index = 3'd1; // t
                3'd2: font_index = 3'd2; // a
                3'd3: font_index = 3'd3; // r
                3'd4: font_index = 3'd4; // b
                3'd5: font_index = 3'd5; // o
                3'd6: font_index = 3'd6; // y
                default: font_index = 3'd0;
            endcase
        
            pixel_on = font_rom[font_index][pixel_y][7-pixel_x];
            
            if (pixel_on) begin
                shape_color = RED;
            end
        end
    end

endmodule