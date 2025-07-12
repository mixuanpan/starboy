`timescale 1ns / 1ps

module vga(
  // General
  input logic clk,
  input logic rst,
  // Game
  input logic [3:0] game_state,
  input logic [11:0] game_area_data,
  output logic [4:0] game_area_addr,
  input logic [7:0] game_block_next,
  input logic [25:0] game_points,
  input logic [25:0] game_lines,
  input logic [3:0] game_level,
  // VGA signals
  output logic vga_hs,
  output logic vga_vs,
  output logic [1:0] vga_red,
  output logic [1:0] vga_green,
  output logic [1:0] vga_blue
);

// Region counters
logic [10:0] cntr_hr;
logic [9:0] cntr_vr;
always_ff @ (posedge clk)
begin
  if(rst) begin
    cntr_hr <= 0;
    cntr_vr <= 0;
  end else begin
    if(cntr_hr == 1039) begin
      cntr_hr <= 0;
      // Vertical sync
      if(cntr_vr == 665) cntr_vr <= 0;
      else   cntr_vr <= cntr_vr + 1;
    end else begin
      cntr_hr <= cntr_hr + 1;
    end
  end
end

// Is it a blank region?
logic blank_hs;
logic blank_vs;
logic blank_region;
assign blank_hr = (cntr_hr >= 800);
assign blank_vr = (cntr_vr >= 600);
always_ff @ (posedge clk)
begin
  if(rst)
    blank_region <= 0;
  else
    blank_region <= blank_hr | blank_vr;  // 1 pixel delay added
end
// Creating sync signals
always_ff @ (posedge clk)
begin
  if (rst) begin
    vga_hs <= 0;
    vga_vs <= 0;
  end else begin
    vga_hs <= (cntr_hr >= 856 && cntr_hr <= 975); // 1pixel delay added
    vga_vs <= (cntr_vr >= 637 && cntr_vr <= 643); // 1pixel delay added
  end
end

// Drawframes
logic [1:0] drawframes_r;
logic [1:0] drawframes_g;
logic [1:0] drawframes_b;
logic drawframes_dav;
draw_frames drawFrames(
  .vga_clk(clk), 
  .rst(rst), 
  .x(cntr_hr), 
  .y(cntr_vr),
  .game_state(game_state),
  .r(drawframes_r), 
  .g(drawframes_g), 
  .b(drawframes_b), 
  .dav(drawframes_dav)
);

// DrawBlocks
logic [1:0] drawblocks_r;
logic [1:0] drawblocks_g;
logic [1:0] drawblocks_b;
logic drawblocks_dav;
draw_blocks drawBlocks(
  .vga_clk(clk),
  .rst(rst),
  .x(cntr_hr),
  .y(cntr_vr),
  .game_state(game_state),
  .game_area_data(game_area_data),
  .game_area_addr(game_area_addr),
  .game_block_next(game_block_next),
  .r(drawblocks_r),
  .g(drawblocks_g),
  .b(drawblocks_b),
  .dav(drawblocks_dav)
);

// DrawStrings
logic [1:0] drawstrings_r;
logic [1:0] drawstrings_g;
logic [1:0] drawstrings_b;
logic drawstrings_dav;
draw_strings drawStrings(
  .vga_clk(clk),
  .rst(rst),
  .x(cntr_hr),
  .y(cntr_vr),
  .game_state(game_state),
  .r(drawstrings_r),
  .g(drawstrings_g),
  .b(drawstrings_b),
  .dav(drawstrings_dav)
);

// DrawScore
logic drawscore_dav;
logic [11:0] drawscore_addr;
draw_numbers #(
  .BINARY_BITS(26),
  .BCD_DIGITS(8),
  .NUM_OFFSET_Y(138-1)
) drawScore (
  .vga_clk(clk),
  .rst(rst),
  .x(cntr_hr),
  .y(cntr_vr),
  .bin_in(game_points),
  .addr(drawscore_addr),
  .dav(drawscore_dav)
);

// Drawlines
logic drawlines_dav;
logic [11:0] drawlines_addr;
draw_numbers #(
  .BINARY_BITS(26),
  .BCD_DIGITS(8),
  .NUM_OFFSET_Y(172-1)
) drawLines (
  .vga_clk(clk),
  .rst(rst),
  .x(cntr_hr),
  .y(cntr_vr),
  .bin_in(game_lines),
  .addr(drawlines_addr),
  .dav(drawlines_dav)
);

// Drawlevel
logic drawlevel_dav;
logic [11:0] drawlevel_addr;
draw_numbers #(
  .BINARY_BITS(4),
  .BCD_DIGITS(1),
  .NUM_OFFSET_Y(206-1)
) drawLevel (
  .vga_clk(clk),
  .rst(rst),
  .x(cntr_hr),
  .y(cntr_vr),
  .bin_in(game_level),
  .addr(drawlevel_addr),
  .dav(drawlevel_dav)
);

// Numbers\' string BROM
logic [1:0] drawnumbers_r;
logic [1:0] drawnumbers_g;
logic [1:0] drawnumbers_b;
logic [1:0] numbers_data;
logic [1:0] drawnumbers_dav;
logic [2:0] drawnumbers_mx; //multiplex
logic [11:0] drawnumbers_addr;
assign drawnumbers_r = numbers_data;
assign drawnumbers_g = numbers_data;
assign drawnumbers_b = numbers_data;
assign drawnumbers_dav = drawscore_dav | drawlevel_dav | drawlines_dav;
assign drawnumbers_mx = {drawlevel_dav,drawlines_dav,drawscore_dav};
always_comb
begin
  case (drawnumbers_mx)
    3\'b001: drawnumbers_addr = drawscore_addr;
    3\'b010: drawnumbers_addr = drawlines_addr;
    3\'b100: drawnumbers_addr = drawlevel_addr;
    default: drawnumbers_addr = drawscore_addr;
endcase
end

numbersBROM numbersBROM (
  .clka(clk), // input clka
  .addra(drawnumbers_addr), // input [11:0] addra
  .douta(numbers_data) // output [1:0] douta
);

// Data output multiplexer
// Color channels
logic [1:0] red;
logic [1:0] green;
logic [1:0] blue;
always_ff @ (posedge clk)
begin
  if(drawframes_dav) begin
    red <= drawframes_r;
    green <= drawframes_g;
    blue <= drawframes_b;
  end else if(drawblocks_dav) begin
    red <= drawblocks_r;
    green <= drawblocks_g;
    blue <= drawblocks_b;
  end else if(drawstrings_dav) begin
    red <= drawstrings_r;
    green <= drawstrings_g;
    blue <= drawstrings_b;
  end else if(drawnumbers_dav) begin
    red <= drawnumbers_r;
    green <= drawnumbers_g;
    blue <= drawnumbers_b;  
  end else begin // Background: black
    red <= 2\'b00;
    green <= 2\'b00;
    blue <= 2\'b00;
  end
end

// Color outputs
assign vga_red = blank_region ? 2\'b00 : red;
assign vga_green = blank_region ? 2\'b00 : green;
assign vga_blue = blank_region ? 2\'b00 : blue;

endmodule
