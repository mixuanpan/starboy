`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER
//
// Module : t01_tlookahead
// Description : Display next block preview with label
//
//
/////////////////////////////////////////////////////////////////
module t01_lookahead(
    input logic [9:0] x, y,
    input logic [3:0][3:0][2:0] next_block_data, // 4x4 block data input
    output logic [2:0] display_color
);

// Colors
localparam BLACK = 3'b000;
localparam WHITE = 3'b111;

// Font parameters - 8x8 pixel characters
localparam CHAR_WIDTH = 8;
localparam CHAR_HEIGHT = 8;

// Preview box parameters
localparam PREVIEW_START_X = 10'd420; // Align with credits
localparam PREVIEW_START_Y = 10'd250; // Below credits
localparam PREVIEW_WIDTH = 10'd80;   // 4 blocks * 20 pixels each
localparam PREVIEW_HEIGHT = 10'd80;  // 4 blocks * 20 pixels each
localparam BLOCK_SIZE = 20;          // Size of each preview block

// Text positioning
localparam TEXT_START_X = PREVIEW_START_X;
localparam TEXT_START_Y = PREVIEW_START_Y - 10'd20; // Above preview box

// Font ROM for characters we need
logic [7:0] font_rom [0:25][0:7]; // A-Z characters

// Initialize font ROM (A=0, B=1, ..., Z=25)
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
end

// Text data for "NEXT BLOCK" (N=13, E=4, X=23, T=19, space=26, B=1, L=11, O=14, C=2, K=10)
logic [4:0] text_string [0:9];
initial begin
    text_string[0] = 13; // N
    text_string[1] = 4;  // E
    text_string[2] = 23; // X
    text_string[3] = 19; // T
    text_string[4] = 26; // space (using index 26 as placeholder)
    text_string[5] = 1;  // B
    text_string[6] = 11; // L
    text_string[7] = 14; // O
    text_string[8] = 2;  // C
    text_string[9] = 10; // K
end

// Rendering logic
logic in_text_area, in_preview_area, in_preview_border;
logic [9:0] text_x, text_y, preview_x, preview_y;
logic [3:0] char_pos;
logic [2:0] char_x_offset, char_y_offset;
logic [4:0] current_char;
logic text_pixel, border_pixel;
logic [1:0] block_x, block_y;

always_comb begin
    // Initialize signals
    display_color = BLACK;
    text_x = 10'd0;
    text_y = 10'd0;
    preview_x = 10'd0;
    preview_y = 10'd0;
    in_text_area = 1'b0;
    in_preview_area = 1'b0;
    in_preview_border = 1'b0;
    char_pos = 4'd0;
    char_x_offset = 3'd0;
    char_y_offset = 3'd0;
    current_char = 5'd0;
    text_pixel = 1'b0;
    border_pixel = 1'b0;
    block_x = 2'd0;
    block_y = 2'd0;
    
    // Check text area
    text_x = x - TEXT_START_X;
    text_y = y - TEXT_START_Y;
    in_text_area = (x >= TEXT_START_X) && (x < TEXT_START_X + 10*CHAR_WIDTH) &&
                   (y >= TEXT_START_Y) && (y < TEXT_START_Y + CHAR_HEIGHT);
    
    // Check preview area
    preview_x = x - PREVIEW_START_X;
    preview_y = y - PREVIEW_START_Y;
    in_preview_area = (x >= PREVIEW_START_X) && (x < PREVIEW_START_X + PREVIEW_WIDTH) &&
                      (y >= PREVIEW_START_Y) && (y < PREVIEW_START_Y + PREVIEW_HEIGHT);
    
    // Check preview border (2-pixel thick border)
    in_preview_border = ((x >= PREVIEW_START_X - 2) && (x < PREVIEW_START_X + PREVIEW_WIDTH + 2) &&
                        (y >= PREVIEW_START_Y - 2) && (y < PREVIEW_START_Y + PREVIEW_HEIGHT + 2)) &&
                       !in_preview_area;
    
    // Render text
    if (in_text_area) begin
        char_pos = 4'({22'd0, text_x} / 32'd8);  // Extend to 32-bit for division
        if (char_pos < 10) begin
            current_char = (char_pos == 4) ? 5'd26 : text_string[char_pos]; // Space character handling
            char_x_offset = 3'({22'd0, text_x} % 32'd8);  // Extend to 32-bit for modulo
            char_y_offset = 3'({22'd0, text_y} % 32'd8);  // Extend to 32-bit for modulo
            
            if (char_pos == 4) begin // Space between NEXT and BLOCK
                text_pixel = 1'b0;
            end else begin
                text_pixel = (current_char < 26) ? font_rom[current_char][char_y_offset][7-char_x_offset] : 1'b0;
            end
            
            display_color = text_pixel ? WHITE : BLACK;
        end
    end
    // Render preview border
    else if (in_preview_border) begin
        display_color = WHITE;
    end
    // Render preview area
    else if (in_preview_area) begin
        // Calculate which 4x4 block position we're in
        block_x = 2'({22'd0, preview_x} / 32'd20);  // Extend to 32-bit for division
        block_y = 2'({22'd0, preview_y} / 32'd20);  // Extend to 32-bit for division
        
        // Display the block data
        if ({30'd0, block_x} < 32'd4 && {30'd0, block_y} < 32'd4) begin
            display_color = next_block_data[block_y][block_x];
        end else begin
            display_color = BLACK;
        end
    end
end

endmodule
