`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER
//
// Module : t01_tetrisCredits
// Description : Display credits text beside the tetris grid
//
//
/////////////////////////////////////////////////////////////////
module t01_tetrisCredits(
    input logic [9:0] x, y,
    output logic [2:0] text_color
);

// Colors
localparam BLACK = 3'b000;
localparam WHITE = 3'b111;

// Font parameters - 8x8 pixel characters
localparam CHAR_WIDTH = 8;
localparam CHAR_HEIGHT = 8;

// Text display area - positioned to the right of the grid
localparam TEXT_START_X = 10'd420; // Start after grid (395 + some margin)
localparam TEXT_START_Y = 10'd100; // Align with grid start

// Font ROM for characters we need
// Using same successful pattern as your starboy module
logic [7:0] font_rom [0:28][0:7]; // 29 characters, 8 rows each

// Character mapping: A=0, B=1, ..., Z=25, space=26, colon=27, comma=28
initial begin
    // Character 'A' (index 0)
    font_rom[0][0] = 8'b00111100;
    font_rom[0][1] = 8'b01000010;
    font_rom[0][2] = 8'b01000010;
    font_rom[0][3] = 8'b01111110;
    font_rom[0][4] = 8'b01000010;
    font_rom[0][5] = 8'b01000010;
    font_rom[0][6] = 8'b01000010;
    font_rom[0][7] = 8'b00000000;
    
    // Character 'B' (index 1)
    font_rom[1][0] = 8'b01111100;
    font_rom[1][1] = 8'b01000010;
    font_rom[1][2] = 8'b01000010;
    font_rom[1][3] = 8'b01111100;
    font_rom[1][4] = 8'b01000010;
    font_rom[1][5] = 8'b01000010;
    font_rom[1][6] = 8'b01111100;
    font_rom[1][7] = 8'b00000000;
    
    // Character 'C' (index 2)
    font_rom[2][0] = 8'b00111100;
    font_rom[2][1] = 8'b01000010;
    font_rom[2][2] = 8'b01000000;
    font_rom[2][3] = 8'b01000000;
    font_rom[2][4] = 8'b01000000;
    font_rom[2][5] = 8'b01000010;
    font_rom[2][6] = 8'b00111100;
    font_rom[2][7] = 8'b00000000;
    
    // Character 'D' (index 3)
    font_rom[3][0] = 8'b01111100;
    font_rom[3][1] = 8'b01000010;
    font_rom[3][2] = 8'b01000010;
    font_rom[3][3] = 8'b01000010;
    font_rom[3][4] = 8'b01000010;
    font_rom[3][5] = 8'b01000010;
    font_rom[3][6] = 8'b01111100;
    font_rom[3][7] = 8'b00000000;
    
    // Character 'E' (index 4)
    font_rom[4][0] = 8'b01111110;
    font_rom[4][1] = 8'b01000000;
    font_rom[4][2] = 8'b01000000;
    font_rom[4][3] = 8'b01111100;
    font_rom[4][4] = 8'b01000000;
    font_rom[4][5] = 8'b01000000;
    font_rom[4][6] = 8'b01111110;
    font_rom[4][7] = 8'b00000000;
    
    // Character 'F' (index 5)
    font_rom[5][0] = 8'b01111110;
    font_rom[5][1] = 8'b01000000;
    font_rom[5][2] = 8'b01000000;
    font_rom[5][3] = 8'b01111100;
    font_rom[5][4] = 8'b01000000;
    font_rom[5][5] = 8'b01000000;
    font_rom[5][6] = 8'b01000000;
    font_rom[5][7] = 8'b00000000;
    
    // Character 'G' (index 6)
    font_rom[6][0] = 8'b00111100;
    font_rom[6][1] = 8'b01000010;
    font_rom[6][2] = 8'b01000000;
    font_rom[6][3] = 8'b01001110;
    font_rom[6][4] = 8'b01000010;
    font_rom[6][5] = 8'b01000010;
    font_rom[6][6] = 8'b00111100;
    font_rom[6][7] = 8'b00000000;
    
    // Character 'H' (index 7)
    font_rom[7][0] = 8'b01000010;
    font_rom[7][1] = 8'b01000010;
    font_rom[7][2] = 8'b01000010;
    font_rom[7][3] = 8'b01111110;
    font_rom[7][4] = 8'b01000010;
    font_rom[7][5] = 8'b01000010;
    font_rom[7][6] = 8'b01000010;
    font_rom[7][7] = 8'b00000000;
    
    // Character 'I' (index 8)
    font_rom[8][0] = 8'b00111110;
    font_rom[8][1] = 8'b00001000;
    font_rom[8][2] = 8'b00001000;
    font_rom[8][3] = 8'b00001000;
    font_rom[8][4] = 8'b00001000;
    font_rom[8][5] = 8'b00001000;
    font_rom[8][6] = 8'b00111110;
    font_rom[8][7] = 8'b00000000;
    
    // Character 'J' (index 9)
    font_rom[9][0] = 8'b00001110;
    font_rom[9][1] = 8'b00000100;
    font_rom[9][2] = 8'b00000100;
    font_rom[9][3] = 8'b00000100;
    font_rom[9][4] = 8'b00000100;
    font_rom[9][5] = 8'b01000100;
    font_rom[9][6] = 8'b00111000;
    font_rom[9][7] = 8'b00000000;
    
    // Character 'K' (index 10)
    font_rom[10][0] = 8'b01000010;
    font_rom[10][1] = 8'b01000100;
    font_rom[10][2] = 8'b01001000;
    font_rom[10][3] = 8'b01110000;
    font_rom[10][4] = 8'b01001000;
    font_rom[10][5] = 8'b01000100;
    font_rom[10][6] = 8'b01000010;
    font_rom[10][7] = 8'b00000000;
    
    // Character 'L' (index 11)
    font_rom[11][0] = 8'b01000000;
    font_rom[11][1] = 8'b01000000;
    font_rom[11][2] = 8'b01000000;
    font_rom[11][3] = 8'b01000000;
    font_rom[11][4] = 8'b01000000;
    font_rom[11][5] = 8'b01000000;
    font_rom[11][6] = 8'b01111110;
    font_rom[11][7] = 8'b00000000;
    
    // Character 'M' (index 12)
    font_rom[12][0] = 8'b01000010;
    font_rom[12][1] = 8'b01100110;
    font_rom[12][2] = 8'b01011010;
    font_rom[12][3] = 8'b01000010;
    font_rom[12][4] = 8'b01000010;
    font_rom[12][5] = 8'b01000010;
    font_rom[12][6] = 8'b01000010;
    font_rom[12][7] = 8'b00000000;
    
    // Character 'N' (index 13)
    font_rom[13][0] = 8'b01000010;
    font_rom[13][1] = 8'b01100010;
    font_rom[13][2] = 8'b01010010;
    font_rom[13][3] = 8'b01001010;
    font_rom[13][4] = 8'b01000110;
    font_rom[13][5] = 8'b01000010;
    font_rom[13][6] = 8'b01000010;
    font_rom[13][7] = 8'b00000000;
    
    // Character 'O' (index 14)
    font_rom[14][0] = 8'b00111100;
    font_rom[14][1] = 8'b01000010;
    font_rom[14][2] = 8'b01000010;
    font_rom[14][3] = 8'b01000010;
    font_rom[14][4] = 8'b01000010;
    font_rom[14][5] = 8'b01000010;
    font_rom[14][6] = 8'b00111100;
    font_rom[14][7] = 8'b00000000;
    
    // Character 'P' (index 15)
    font_rom[15][0] = 8'b01111100;
    font_rom[15][1] = 8'b01000010;
    font_rom[15][2] = 8'b01000010;
    font_rom[15][3] = 8'b01111100;
    font_rom[15][4] = 8'b01000000;
    font_rom[15][5] = 8'b01000000;
    font_rom[15][6] = 8'b01000000;
    font_rom[15][7] = 8'b00000000;
    
    // Character 'Q' (index 16)
    font_rom[16][0] = 8'b00111100;
    font_rom[16][1] = 8'b01000010;
    font_rom[16][2] = 8'b01000010;
    font_rom[16][3] = 8'b01000010;
    font_rom[16][4] = 8'b01001010;
    font_rom[16][5] = 8'b01000100;
    font_rom[16][6] = 8'b00111010;
    font_rom[16][7] = 8'b00000000;
    
    // Character 'R' (index 17)
    font_rom[17][0] = 8'b01111100;
    font_rom[17][1] = 8'b01000010;
    font_rom[17][2] = 8'b01000010;
    font_rom[17][3] = 8'b01111100;
    font_rom[17][4] = 8'b01001000;
    font_rom[17][5] = 8'b01000100;
    font_rom[17][6] = 8'b01000010;
    font_rom[17][7] = 8'b00000000;
    
    // Character 'S' (index 18)
    font_rom[18][0] = 8'b00111100;
    font_rom[18][1] = 8'b01000010;
    font_rom[18][2] = 8'b01000000;
    font_rom[18][3] = 8'b00111100;
    font_rom[18][4] = 8'b00000010;
    font_rom[18][5] = 8'b01000010;
    font_rom[18][6] = 8'b00111100;
    font_rom[18][7] = 8'b00000000;
    
    // Character 'T' (index 19)
    font_rom[19][0] = 8'b01111111;
    font_rom[19][1] = 8'b00001000;
    font_rom[19][2] = 8'b00001000;
    font_rom[19][3] = 8'b00001000;
    font_rom[19][4] = 8'b00001000;
    font_rom[19][5] = 8'b00001000;
    font_rom[19][6] = 8'b00001000;
    font_rom[19][7] = 8'b00000000;
    
    // Character 'U' (index 20)
    font_rom[20][0] = 8'b01000010;
    font_rom[20][1] = 8'b01000010;
    font_rom[20][2] = 8'b01000010;
    font_rom[20][3] = 8'b01000010;
    font_rom[20][4] = 8'b01000010;
    font_rom[20][5] = 8'b01000010;
    font_rom[20][6] = 8'b00111100;
    font_rom[20][7] = 8'b00000000;
    
    // Character 'V' (index 21)
    font_rom[21][0] = 8'b01000010;
    font_rom[21][1] = 8'b01000010;
    font_rom[21][2] = 8'b01000010;
    font_rom[21][3] = 8'b01000010;
    font_rom[21][4] = 8'b00100100;
    font_rom[21][5] = 8'b00011000;
    font_rom[21][6] = 8'b00011000;
    font_rom[21][7] = 8'b00000000;
    
    // Character 'W' (index 22)
    font_rom[22][0] = 8'b01000010;
    font_rom[22][1] = 8'b01000010;
    font_rom[22][2] = 8'b01000010;
    font_rom[22][3] = 8'b01000010;
    font_rom[22][4] = 8'b01011010;
    font_rom[22][5] = 8'b01100110;
    font_rom[22][6] = 8'b01000010;
    font_rom[22][7] = 8'b00000000;
    
    // Character 'X' (index 23)
    font_rom[23][0] = 8'b01000010;
    font_rom[23][1] = 8'b01000010;
    font_rom[23][2] = 8'b00100100;
    font_rom[23][3] = 8'b00011000;
    font_rom[23][4] = 8'b00100100;
    font_rom[23][5] = 8'b01000010;
    font_rom[23][6] = 8'b01000010;
    font_rom[23][7] = 8'b00000000;
    
    // Character 'Y' (index 24)
    font_rom[24][0] = 8'b01000001;
    font_rom[24][1] = 8'b01000001;
    font_rom[24][2] = 8'b00100010;
    font_rom[24][3] = 8'b00010100;
    font_rom[24][4] = 8'b00001000;
    font_rom[24][5] = 8'b00001000;
    font_rom[24][6] = 8'b00001000;
    font_rom[24][7] = 8'b00000000;
    
    // Character 'Z' (index 25)
    font_rom[25][0] = 8'b01111110;
    font_rom[25][1] = 8'b00000010;
    font_rom[25][2] = 8'b00000100;
    font_rom[25][3] = 8'b00011000;
    font_rom[25][4] = 8'b00100000;
    font_rom[25][5] = 8'b01000000;
    font_rom[25][6] = 8'b01111110;
    font_rom[25][7] = 8'b00000000;
    
    // Space (index 26)
    font_rom[26][0] = 8'b00000000;
    font_rom[26][1] = 8'b00000000;
    font_rom[26][2] = 8'b00000000;
    font_rom[26][3] = 8'b00000000;
    font_rom[26][4] = 8'b00000000;
    font_rom[26][5] = 8'b00000000;
    font_rom[26][6] = 8'b00000000;
    font_rom[26][7] = 8'b00000000;
    
    // Colon (index 27)
    font_rom[27][0] = 8'b00000000;
    font_rom[27][1] = 8'b00011000;
    font_rom[27][2] = 8'b00011000;
    font_rom[27][3] = 8'b00000000;
    font_rom[27][4] = 8'b00000000;
    font_rom[27][5] = 8'b00011000;
    font_rom[27][6] = 8'b00011000;
    font_rom[27][7] = 8'b00000000;
    
    // Comma (index 28)
    font_rom[28][0] = 8'b00000000;
    font_rom[28][1] = 8'b00000000;
    font_rom[28][2] = 8'b00000000;
    font_rom[28][3] = 8'b00000000;
    font_rom[28][4] = 8'b00000000;
    font_rom[28][5] = 8'b00011000;
    font_rom[28][6] = 8'b00011000;
    font_rom[28][7] = 8'b00110000;
end

// Text to display: "Made by:" on first line, names on subsequent lines
// Character encoding: A=0, B=1, ..., Z=25, space=26, colon=27, comma=28
logic [4:0] text_data [0:191]; // 6 lines * 32 chars max per line

// Initialize text data
initial begin
    // Line 0: "Made by:"
    text_data[0] = 12;  // M
    text_data[1] = 0;   // a
    text_data[2] = 3;   // d
    text_data[3] = 4;   // e
    text_data[4] = 26;  // space
    text_data[5] = 1;   // b
    text_data[6] = 24;  // y
    text_data[7] = 27;  // colon
    text_data[8] = 26;  // space (end of line marker)
    
    // Line 1: "Cristian, Safa,"
    text_data[32] = 2;   // C
    text_data[33] = 17;  // r
    text_data[34] = 8;   // i
    text_data[35] = 18;  // s
    text_data[36] = 19;  // t
    text_data[37] = 8;   // i
    text_data[38] = 0;   // a
    text_data[39] = 13;  // n
    text_data[40] = 28;  // comma
    text_data[41] = 26;  // space
    text_data[42] = 18;  // S
    text_data[43] = 0;   // a
    text_data[44] = 5;   // f
    text_data[45] = 0;   // a
    text_data[46] = 28;  // comma
    text_data[47] = 26;  // space (end of line)
    
    // Line 2: "Myles, Mixuan,"
    text_data[64] = 12;  // M
    text_data[65] = 24;  // y
    text_data[66] = 11;  // l
    text_data[67] = 4;   // e
    text_data[68] = 18;  // s
    text_data[69] = 28;  // comma
    text_data[70] = 26;  // space
    text_data[71] = 12;  // M
    text_data[72] = 8;   // i
    text_data[73] = 23;  // x
    text_data[74] = 20;  // u
    text_data[75] = 0;   // a
    text_data[76] = 13;  // n
    text_data[77] = 28;  // comma
    text_data[78] = 26;  // space (end of line)
    
    // Line 3: "and PM Johnny"
    text_data[96] = 0;   // a
    text_data[97] = 13;  // n
    text_data[98] = 3;   // d
    text_data[99] = 26;  // space
    text_data[100] = 15; // P
    text_data[101] = 12; // M
    text_data[102] = 26; // space
    text_data[103] = 9;  // J
    text_data[104] = 14; // o
    text_data[105] = 7;  // h
    text_data[106] = 13; // n
    text_data[107] = 13; // n
    text_data[108] = 24; // y
    text_data[109] = 26; // space (end of line)
    
    // Initialize remaining positions to spaces
    for (int i = 9; i < 32; i++) text_data[i] = 26;
    for (int i = 48; i < 64; i++) text_data[i] = 26;
    for (int i = 79; i < 96; i++) text_data[i] = 26;
    for (int i = 110; i < 128; i++) text_data[i] = 26;
    for (int i = 128; i < 192; i++) text_data[i] = 26;
end

// Character rendering logic
logic in_text_area;
logic [4:0] char_index;
logic [4:0] line_num;
logic [4:0] char_in_line;
logic [9:0] text_x, text_y;
logic [2:0] char_x_offset;
logic [2:0] char_y_offset;
logic pixel_on;

always_comb begin
    // Initialize all signals to prevent latches
    text_color = BLACK;
    text_x = 10'd0;
    text_y = 10'd0;
    in_text_area = 1'b0;
    line_num = 5'd0;
    char_in_line = 5'd0;
    char_index = 5'd0;
    char_x_offset = 3'd0;
    char_y_offset = 3'd0;
    pixel_on = 1'b0;
    
    // Calculate position within text area
    text_x = x - TEXT_START_X;
    text_y = y - TEXT_START_Y;
    
    // Check if we're in the text display area
    in_text_area = (x >= TEXT_START_X) && (x < TEXT_START_X + 32*CHAR_WIDTH) &&
                   (y >= TEXT_START_Y) && (y < TEXT_START_Y + 6*CHAR_HEIGHT);
    
    if (in_text_area) begin
        // Calculate which character we're in
        line_num = 5'(10'(text_y) / 10'(CHAR_HEIGHT));
        char_in_line = 5'(10'(text_x) / 10'(CHAR_WIDTH));
        char_index = text_data[line_num * 32 + char_in_line];
        
        // Calculate position within character
        char_x_offset = 3'(10'(text_x) % 10'(CHAR_WIDTH));
        char_y_offset = 3'(10'(text_y) % 10'(CHAR_HEIGHT));
        
        // Get pixel from font ROM - using same pattern as your working module
        pixel_on = font_rom[char_index][char_y_offset][7-char_x_offset];
        
        // Set color
        text_color = pixel_on ? WHITE : BLACK;
    end
end

endmodule
