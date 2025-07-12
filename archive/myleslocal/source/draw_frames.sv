/*
This is a placeholder for the converted SystemVerilog code for draw_frames.v
*/

`timescale 1ns / 1ps

module draw_frames(
  input logic vga_clk,
  input logic rst,
  input logic [10:0] x,
  input logic [9:0] y,
  input logic [3:0] game_state,
  output logic [1:0] r,
  output logic [1:0] g,
  output logic [1:0] b,
  output logic dav
);

parameter logic [3:0] STATE_LOGO = 4'b0000;

always_ff @ (posedge vga_clk)
begin
  if(rst) begin
    r <= 0;
    g <= 0;
    b <= 0;
    dav <= 0;
  // Main frame
  end else if((y == 125 || y == 549) && (x >= 136 && x <= 392)) begin // Top & Bottom Horizontal @ line 126 |  from 138 to 394
    r <= 0;
    g <= 2'b11;
    b <= 2'b11;
    dav <= 1;
  end else if((x == 136 || x == 392) && (y >= 125 && y <= 549)) begin // Left & Right Horizontal
    r <= 0;
    g <= 2'b11;
    b <= 2'b11;
    dav <= 1;
  // Scores Side frames
  end else if((y == 125 || y == 235) && (x >= 404 && x <= 660)) begin // Top & Bottom Horizontal
    r <= 2'b11;
    g <= 2'b10;
    b <= 2'b00;
    dav <= 1;
  end else if((x == 404 || x == 660) && (y >= 125 && y <= 235)) begin // Left & Right Horizontal
    r <= 2'b11;
    g <= 2'b10;
    b <= 2'b00;
    dav <= 1;
  // Next element frame
  end else if((game_state != STATE_LOGO) && (y == 247 || y == 335) && (x >= 404 && x <= 660)) begin // Top & Bottom Horizontal
    r <= 2'b11;
    g <= 2'b00;
    b <= 2'b01;
    dav <= 1;
  end else if((game_state != STATE_LOGO) && (x == 404 || x == 660) && (y >= 247 && y <= 335)) begin // Left & Right Horizontal
    r <= 2'b11;
    g <= 2'b00;
    b <= 2'b01;
    dav <= 1;
  // Help frame
  end else if((game_state == STATE_LOGO) && (y == 247 || y == 389) && (x >= 404 && x <= 660)) begin // Top & Bottom Horizontal
    r <= 2'b11;
    g <= 2'b00;
    b <= 2'b01;
    dav <= 1;
  end else if((game_state == STATE_LOGO) && (x == 404 || x == 660) && (y >= 247 && y <= 389)) begin // Left & Right Horizontal
    r <= 2'b11;
    g <= 2'b00;
    b <= 2'b01;
    dav <= 1;
  end else begin
    dav <= 0;
  end
end

endmodule

