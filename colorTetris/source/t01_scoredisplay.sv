`default_nettype none 
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_scoredisplay
// Description : generates the score display
// 
//
/////////////////////////////////////////////////////////////////
module t01_scoredisplay(
    input logic clk, rst,
    input logic [9:0] score,
    input logic [9:0] x, y,
    output logic [2:0] shape_color
);

    // colors 
    localparam BLACK   = 3'b000;
    localparam WHITE   = 3'b111;
    localparam YELLOW  = 3'b110;
    
    // font parameters
    localparam CHAR_WIDTH = 8;
    localparam CHAR_HEIGHT = 12;
    localparam CHAR_SCALE = 2; 
    
    // display area parameters 
    localparam SCORE_START_X = 10'd245; 
    localparam SCORE_START_Y = 10'd400;  
    
    // char positions
    localparam SCORE_TEXT_X = SCORE_START_X;
    localparam SCORE_VALUE_X = SCORE_START_X + (5 * CHAR_WIDTH * CHAR_SCALE) + 10;
    
    // font ROM for digits 0-9 and "score"
    logic [7:0] font_rom [0:14][0:11];
    
    // init font ROM
    initial begin
        // char '0' (index 0)
        font_rom[0][0]  = 8'b00111100;
        font_rom[0][1]  = 8'b01100110;
        font_rom[0][2]  = 8'b01100110;
        font_rom[0][3]  = 8'b01100110;
        font_rom[0][4]  = 8'b01100110;
        font_rom[0][5]  = 8'b01100110;
        font_rom[0][6]  = 8'b01100110;
        font_rom[0][7]  = 8'b01100110;
        font_rom[0][8]  = 8'b01100110;
        font_rom[0][9]  = 8'b01100110;
        font_rom[0][10] = 8'b01100110;
        font_rom[0][11] = 8'b00111100;
        
        // char '1' (index 1)
        font_rom[1][0]  = 8'b00011000;
        font_rom[1][1]  = 8'b00111000;
        font_rom[1][2]  = 8'b00011000;
        font_rom[1][3]  = 8'b00011000;
        font_rom[1][4]  = 8'b00011000;
        font_rom[1][5]  = 8'b00011000;
        font_rom[1][6]  = 8'b00011000;
        font_rom[1][7]  = 8'b00011000;
        font_rom[1][8]  = 8'b00011000;
        font_rom[1][9]  = 8'b00011000;
        font_rom[1][10] = 8'b00011000;
        font_rom[1][11] = 8'b01111110;
        
        // char '2' (index 2)
        font_rom[2][0]  = 8'b00111100;
        font_rom[2][1]  = 8'b01100110;
        font_rom[2][2]  = 8'b00000110;
        font_rom[2][3]  = 8'b00000110;
        font_rom[2][4]  = 8'b00001100;
        font_rom[2][5]  = 8'b00011000;
        font_rom[2][6]  = 8'b00110000;
        font_rom[2][7]  = 8'b01100000;
        font_rom[2][8]  = 8'b01100000;
        font_rom[2][9]  = 8'b01100000;
        font_rom[2][10] = 8'b01100110;
        font_rom[2][11] = 8'b01111110;
        
        // char '3' (index 3)
        font_rom[3][0]  = 8'b00111100;
        font_rom[3][1]  = 8'b01100110;
        font_rom[3][2]  = 8'b00000110;
        font_rom[3][3]  = 8'b00000110;
        font_rom[3][4]  = 8'b00001100;
        font_rom[3][5]  = 8'b00111000;
        font_rom[3][6]  = 8'b00001100;
        font_rom[3][7]  = 8'b00000110;
        font_rom[3][8]  = 8'b00000110;
        font_rom[3][9]  = 8'b00000110;
        font_rom[3][10] = 8'b01100110;
        font_rom[3][11] = 8'b00111100;
        
        // char '4' (index 4)
        font_rom[4][0]  = 8'b00001100;
        font_rom[4][1]  = 8'b00011100;
        font_rom[4][2]  = 8'b00101100;
        font_rom[4][3]  = 8'b01001100;
        font_rom[4][4]  = 8'b01001100;
        font_rom[4][5]  = 8'b01001100;
        font_rom[4][6]  = 8'b01111110;
        font_rom[4][7]  = 8'b00001100;
        font_rom[4][8]  = 8'b00001100;
        font_rom[4][9]  = 8'b00001100;
        font_rom[4][10] = 8'b00001100;
        font_rom[4][11] = 8'b00001100;
        
        // char '5' (index 5)
        font_rom[5][0]  = 8'b01111110;
        font_rom[5][1]  = 8'b01100000;
        font_rom[5][2]  = 8'b01100000;
        font_rom[5][3]  = 8'b01100000;
        font_rom[5][4]  = 8'b01111100;
        font_rom[5][5]  = 8'b01100110;
        font_rom[5][6]  = 8'b00000110;
        font_rom[5][7]  = 8'b00000110;
        font_rom[5][8]  = 8'b00000110;
        font_rom[5][9]  = 8'b00000110;
        font_rom[5][10] = 8'b01100110;
        font_rom[5][11] = 8'b00111100;
        
        // char '6' (index 6)
        font_rom[6][0]  = 8'b00111100;
        font_rom[6][1]  = 8'b01100110;
        font_rom[6][2]  = 8'b01100000;
        font_rom[6][3]  = 8'b01100000;
        font_rom[6][4]  = 8'b01111100;
        font_rom[6][5]  = 8'b01100110;
        font_rom[6][6]  = 8'b01100110;
        font_rom[6][7]  = 8'b01100110;
        font_rom[6][8]  = 8'b01100110;
        font_rom[6][9]  = 8'b01100110;
        font_rom[6][10] = 8'b01100110;
        font_rom[6][11] = 8'b00111100;
        
        // char '7' (index 7)
        font_rom[7][0]  = 8'b01111110;
        font_rom[7][1]  = 8'b01100110;
        font_rom[7][2]  = 8'b00000110;
        font_rom[7][3]  = 8'b00000110;
        font_rom[7][4]  = 8'b00001100;
        font_rom[7][5]  = 8'b00001100;
        font_rom[7][6]  = 8'b00011000;
        font_rom[7][7]  = 8'b00011000;
        font_rom[7][8]  = 8'b00110000;
        font_rom[7][9]  = 8'b00110000;
        font_rom[7][10] = 8'b00110000;
        font_rom[7][11] = 8'b00110000;
        
        // char '8' (index 8)
        font_rom[8][0]  = 8'b00111100;
        font_rom[8][1]  = 8'b01100110;
        font_rom[8][2]  = 8'b01100110;
        font_rom[8][3]  = 8'b01100110;
        font_rom[8][4]  = 8'b00111100;
        font_rom[8][5]  = 8'b01100110;
        font_rom[8][6]  = 8'b01100110;
        font_rom[8][7]  = 8'b01100110;
        font_rom[8][8]  = 8'b01100110;
        font_rom[8][9]  = 8'b01100110;
        font_rom[8][10] = 8'b01100110;
        font_rom[8][11] = 8'b00111100;
        
        // char '9' (index 9)
        font_rom[9][0]  = 8'b00111100;
        font_rom[9][1]  = 8'b01100110;
        font_rom[9][2]  = 8'b01100110;
        font_rom[9][3]  = 8'b01100110;
        font_rom[9][4]  = 8'b01100110;
        font_rom[9][5]  = 8'b01100110;
        font_rom[9][6]  = 8'b00111110;
        font_rom[9][7]  = 8'b00000110;
        font_rom[9][8]  = 8'b00000110;
        font_rom[9][9]  = 8'b00000110;
        font_rom[9][10] = 8'b01100110;
        font_rom[9][11] = 8'b00111100;
        
        // char 'S' (index 10)
        font_rom[10][0]  = 8'b00111100;
        font_rom[10][1]  = 8'b01100110;
        font_rom[10][2]  = 8'b01100000;
        font_rom[10][3]  = 8'b01100000;
        font_rom[10][4]  = 8'b00110000;
        font_rom[10][5]  = 8'b00011000;
        font_rom[10][6]  = 8'b00001100;
        font_rom[10][7]  = 8'b00000110;
        font_rom[10][8]  = 8'b00000110;
        font_rom[10][9]  = 8'b00000110;
        font_rom[10][10] = 8'b01100110;
        font_rom[10][11] = 8'b00111100;
        
        // char 'C' (index 11)
        font_rom[11][0]  = 8'b00111100;
        font_rom[11][1]  = 8'b01100110;
        font_rom[11][2]  = 8'b01100000;
        font_rom[11][3]  = 8'b01100000;
        font_rom[11][4]  = 8'b01100000;
        font_rom[11][5]  = 8'b01100000;
        font_rom[11][6]  = 8'b01100000;
        font_rom[11][7]  = 8'b01100000;
        font_rom[11][8]  = 8'b01100000;
        font_rom[11][9]  = 8'b01100000;
        font_rom[11][10] = 8'b01100110;
        font_rom[11][11] = 8'b00111100;
        
        // char 'O' (index 12)
        font_rom[12][0]  = 8'b00111100;
        font_rom[12][1]  = 8'b01100110;
        font_rom[12][2]  = 8'b01100110;
        font_rom[12][3]  = 8'b01100110;
        font_rom[12][4]  = 8'b01100110;
        font_rom[12][5]  = 8'b01100110;
        font_rom[12][6]  = 8'b01100110;
        font_rom[12][7]  = 8'b01100110;
        font_rom[12][8]  = 8'b01100110;
        font_rom[12][9]  = 8'b01100110;
        font_rom[12][10] = 8'b01100110;
        font_rom[12][11] = 8'b00111100;
        
        // char 'R' (index 13)
        font_rom[13][0]  = 8'b01111100;
        font_rom[13][1]  = 8'b01100110;
        font_rom[13][2]  = 8'b01100110;
        font_rom[13][3]  = 8'b01100110;
        font_rom[13][4]  = 8'b01100110;
        font_rom[13][5]  = 8'b01111100;
        font_rom[13][6]  = 8'b01111000;
        font_rom[13][7]  = 8'b01101100;
        font_rom[13][8]  = 8'b01100110;
        font_rom[13][9]  = 8'b01100110;
        font_rom[13][10] = 8'b01100110;
        font_rom[13][11] = 8'b01100110;
        
        // char 'E' (index 14)
        font_rom[14][0]  = 8'b01111110;
        font_rom[14][1]  = 8'b01100000;
        font_rom[14][2]  = 8'b01100000;
        font_rom[14][3]  = 8'b01100000;
        font_rom[14][4]  = 8'b01100000;
        font_rom[14][5]  = 8'b01111100;
        font_rom[14][6]  = 8'b01100000;
        font_rom[14][7]  = 8'b01100000;
        font_rom[14][8]  = 8'b01100000;
        font_rom[14][9]  = 8'b01100000;
        font_rom[14][10] = 8'b01100000;
        font_rom[14][11] = 8'b01111110;
    end
    
    // char lookup function
    function [3:0] get_char_index(input [9:0] digit);
        case (digit)
            10'd0: get_char_index = 4'd0;
            10'd1: get_char_index = 4'd1;
            10'd2: get_char_index = 4'd2;
            10'd3: get_char_index = 4'd3;
            10'd4: get_char_index = 4'd4;
            10'd5: get_char_index = 4'd5;
            10'd6: get_char_index = 4'd6;
            10'd7: get_char_index = 4'd7;
            10'd8: get_char_index = 4'd8;
            10'd9: get_char_index = 4'd9;
            default: get_char_index = 4'd0;
        endcase
    endfunction
    
    // score digit extraction
    logic [9:0] hundreds, tens, ones;
    always_comb begin
        hundreds = 10'((score / 10'd100) % 10'd10);
        tens = 10'((score / 10'd10) % 10'd10);
        ones = 10'(score %10'd10);
    end
    
    // character rendering logic
    logic in_score_text, in_score_value;
    logic [2:0] char_index;
    logic [3:0] font_index;
    logic [9:0] char_x, char_y;
    logic [2:0] pixel_x;
    logic [3:0] pixel_y;
    logic [3:0] row_index;
    logic pixel_on;
    
    always_comb begin
        shape_color = BLACK;
        char_index = 3'd0;
        font_index = 4'd0;
        char_x = 10'd0;
        char_y = 10'd0;
        pixel_x = 3'd0;
        pixel_y = 4'd0;
        pixel_on = 1'b0;
        
        // check if in the "SCORE" text area
        in_score_text = (x >= SCORE_TEXT_X) && 
                       (x < SCORE_TEXT_X + (5 * CHAR_WIDTH * CHAR_SCALE)) &&
                       (y >= SCORE_START_Y) && 
                       (y < SCORE_START_Y + (CHAR_HEIGHT * CHAR_SCALE));
        
        // check if in the score value area
        in_score_value = (x >= SCORE_VALUE_X) && 
                        (x < SCORE_VALUE_X + (3 * CHAR_WIDTH * CHAR_SCALE)) &&
                        (y >= SCORE_START_Y) && 
                        (y < SCORE_START_Y + (CHAR_HEIGHT * CHAR_SCALE));
        
        if (in_score_text) begin
            // calc what letter it is 
            char_x = (x - SCORE_TEXT_X) / CHAR_SCALE;
            char_y = (y - SCORE_START_Y) / CHAR_SCALE;
            char_index = 3'({22'd0, char_x} / CHAR_WIDTH);
            pixel_x = 3'({22'd0, char_x} % CHAR_WIDTH);
            pixel_y = 4'({22'd0, char_y} % CHAR_HEIGHT);
            
            // map char
            case (char_index)
                3'd0: font_index = 4'd10; // s
                3'd1: font_index = 4'd11; // c
                3'd2: font_index = 4'd12; // o
                3'd3: font_index = 4'd13; // r
                3'd4: font_index = 4'd14; // e
                default: font_index = 4'd0;
            endcase

            pixel_on = font_rom[font_index][pixel_y][7-pixel_x];
            
            if (pixel_on) begin
                shape_color = YELLOW;
            end
            
        end else if (in_score_value) begin
            char_x = (x - SCORE_VALUE_X) / CHAR_SCALE;
            char_y = (y - SCORE_START_Y) / CHAR_SCALE;
            char_index = 3'({22'd0, char_x} / CHAR_WIDTH);
            pixel_x = 3'({22'd0, char_x} % CHAR_WIDTH);
            pixel_y = 4'({22'd0, char_y} % CHAR_HEIGHT);
            
            case (char_index)
                3'd0: font_index = get_char_index(hundreds);
                3'd1: font_index = get_char_index(tens);
                3'd2: font_index = get_char_index(ones);
                default: font_index = 4'd0;
            endcase

            pixel_on = font_rom[font_index][pixel_y][7-pixel_x];
            
            if (pixel_on) begin
                shape_color = WHITE;
            end
        end
    end

endmodule