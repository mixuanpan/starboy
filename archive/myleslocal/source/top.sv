/*
This is the converted SystemVerilog code for toplevel.v, modified to remove SPI and LCD related modules and signals,
adapted for the new FPGA button configuration, and integrated with user's custom VGA and Tetris grid visualization modules.
*/

`timescale 1ns / 1ps

module top(
  // I/O ports
  input  logic clk, //50MHz
  input  logic reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         output logic ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,
  output logic vga_hs,
  output logic vga_vs,
  output logic [1:0] vga_red, vga_green, vga_blue
);

// Game states
parameter logic [3:0] STATE_LOGO      = 4'b0000;
parameter logic [3:0] STATE_NEWBLOCK  = 4'b0001;
parameter logic [3:0] STATE_MOVING    = 4'b0010;
parameter logic [3:0] STATE_EVAL      = 4'b0011;
parameter logic [3:0] STATE_PREROTATE = 4'b0100;
parameter logic [3:0] STATE_FALL      = 4'b0101;
parameter logic [3:0] STATE_RIGHT     = 4'b0110;
parameter logic [3:0] STATE_LEFT      = 4'b0111;
parameter logic [3:0] STATE_ROTATE    = 4'b1000;
parameter logic [3:0] STATE_GAMEOVER  = 4'b1001;
// Game point increment
parameter logic [25:0] GAME_POINT_INCREMENT = 26'd100;
// Game speed
parameter logic [3:0] GAME_SPEED_MIN  = 4'd1;
parameter logic [3:0] GAME_SPEED_MAX  = 4'd9;
  
// Global wirings
logic rst;
assign rst = reset;
logic [5:0] game_prbs;    // PRBS wiring

// Game actions
logic action_rotate;
assign action_rotate = pb[0]; // Assuming pb[0] is rotate
logic action_right;
assign action_right = pb[1]; // Assuming pb[1] is right
logic action_left;
assign action_left = pb[2];  // Assuming pb[2] is left
logic action_down;
assign action_down = pb[3];  // Assuming pb[3] is down
logic action_enter;
assign action_enter = pb[4]; // Assuming pb[4] is enter
logic action_up;
assign action_up = pb[5];    // Assuming pb[5] is up
logic action_fall; // Rategen wiring
logic action_drop; // User drop

// Building blocks & Graphics
logic [7:0] building_blocks[6:0];
logic [11:0] game_area_init[5:0];
// initial $readmemh("data/graphics_buildingblocks.txt", building_blocks);
// initial $readmemh("data/graphics_gamearea.txt", game_area_init);

// Game area

logic [11:0] game_area[19:0];
logic [11:0] game_area_newblock[3:0];
logic [11:0] game_area_backup[3:0];
logic [4:0]  game_area_vga_addr;
logic [11:0] game_area_vga_data;
// Game state
(* KEEP = "TRUE" *) logic [3:0] gamestate;
logic framebuffer_game_update;
// Position
logic [2:0] rel_cntr;
logic [4:0] abs_cntr;
logic [4:0] cntr_top;
logic [3:0] cntr_left;
// Collision detection
logic collision;
logic check;
logic checked;
// Player points & achievements
logic [25:0] gamepoints;
logic [25:0] gamepoints_inc;
logic [25:0] gamelines;
logic [3:0] gamespeed; // 1 > 9
// Misc counter
logic [7:0] cntr_event;
// Next Block
logic [2:0] block_id;
logic [2:0] next_block_id;
// Frame borders
logic gameborder_left;
logic gameborder_right;
assign gameborder_left  = |(game_area_newblock[0][11]|game_area_newblock[1][11]|game_area_newblock[2][11]|game_area_newblock[3][11]);
assign gameborder_right = |(game_area_newblock[0][0]|game_area_newblock[1][0]|game_area_newblock[2][0]|game_area_newblock[3][0]);

integer i;

always_ff @ (posedge clk)
begin
  if(rst) begin
    action_drop <= 0;
    gamespeed <= 1;
    gamestate <= STATE_LOGO;
    framebuffer_game_update <= 1;
    check <= 0;
    gamepoints <= 0;
    gamelines <= 0;
    checked <= 0;
    gamepoints_inc <= 0; 
    rel_cntr <= 0;
    abs_cntr <= 0;
    cntr_top <= 0;
    cntr_left <= 0;
  end else if(framebuffer_game_update)
    framebuffer_game_update <= 0;
  else if(check) begin
    rel_cntr <= rel_cntr +1;
    abs_cntr <= abs_cntr +1;
    if(~collision && (rel_cntr <4) && (abs_cntr <20)) begin
      if((game_area[abs_cntr] & game_area_newblock[rel_cntr[1:0]]) != 12'h000)
        collision <= 1;
    end else if((abs_cntr == 20) && (rel_cntr <4) && (game_area_newblock[rel_cntr[1:0]]!=0))
      collision <= 1;
    else begin
      checked <= 1;
      check <= 0;
    end
  end else begin
    case(gamestate)
      STATE_LOGO: begin
        if(action_enter) begin
          for(i=0;i<20;i=i+1) begin
            game_area[i] <= 0;
          end
          gamepoints <= 0;
          gamelines <= 0;
          checked <= 0;
          framebuffer_game_update <= 1;
          gamestate  <= STATE_NEWBLOCK;
          for(i=0;i<20;i=i+1)
            game_area[i] <= 0;
        end else if(action_up && gamespeed < GAME_SPEED_MAX)
          gamespeed <= gamespeed + 1;
        else if(action_down && gamespeed > GAME_SPEED_MIN)
          gamespeed <= gamespeed - 1;
        else if((game_prbs[2:0] < 7) && (game_prbs[5:3] < 7)) begin
          block_id <= game_prbs[2:0];
          next_block_id <= game_prbs[5:3];
        end
      end
      STATE_NEWBLOCK: begin
        if(~checked) begin
          action_drop <= 0;
          cntr_left <= 4;
          cntr_top <= 0;
          rel_cntr <= 0;
          abs_cntr <= 0;
          game_area_newblock[0] <= {4'h00,building_blocks[block_id][3:0],4'h00};
          game_area_newblock[1] <= {4'h00,building_blocks[block_id][7:4],4'h00};
          game_area_newblock[2] <= 0;
          game_area_newblock[3] <= 0;
          check <= 1;
          collision <= 0;
        end else if(collision) begin
          gamestate <= STATE_GAMEOVER;
          framebuffer_game_update <= 1;
        end else if (checked) begin
          framebuffer_game_update <= 1;
          gamestate <= STATE_MOVING;
        end
      end
      STATE_MOVING: begin
        checked   <= 0;
        if(action_fall)
          gamestate <= STATE_FALL;
        else if(action_right && ~gameborder_right)
          gamestate <= STATE_RIGHT;
        else if(action_left && ~gameborder_left)
          gamestate <= STATE_LEFT;
        else if(action_rotate) begin
          gamestate <= STATE_PREROTATE;
          cntr_event <= 0;
          for(i=0;i<4;i=i+1) begin
            game_area_backup[i] <= game_area_newblock[i];
          end
        end else if(action_down)
          action_drop <= 1;
        // Removed action_exit as it's not in the new button configuration
      end
      STATE_FALL: begin
        if(~checked) begin
          if(cntr_top < 19) begin
            collision <= 0;
            check <= 1;
          end else if(cntr_top == 19 && game_area_newblock[0]!=0) begin
            collision <= 1;
            checked <= 1;
          end
          rel_cntr <= 0;
          abs_cntr <= cntr_top+1;
        end else if(collision) begin  // Collision either with gamespace or game border bottom
          // Update gamepsace
          for(i=0;i<20;i=i+1) begin
            if(i >= int'(cntr_top) && (i - int'(cntr_top)) < 4) begin
              game_area[i] <= game_area[i] | game_area_newblock[i - int'(cntr_top)];
            end
          end
          framebuffer_game_update <= 1;
          gamestate <= STATE_EVAL;
          cntr_event <= 0;
          abs_cntr <= 0;
        end else begin
          cntr_top <= cntr_top + 1;
          framebuffer_game_update <= 1;
          gamestate <= STATE_MOVING;
        end
      end
      STATE_LEFT: begin
        if(~checked) begin
          collision <= 0;
          check <= 1;
          rel_cntr <= 0;
          abs_cntr <= cntr_top;
          for(i=0;i<4;i=i+1) begin
            game_area_newblock[i] <= {game_area_newblock[i][10:0],1'b0};
          end
        end else begin
          if(collision) begin
            for(i=0;i<4;i=i+1)
              game_area_newblock[i] <= {1'b0,game_area_newblock[i][11:1]};
          end else
            cntr_left <= cntr_left - 1;
          framebuffer_game_update <= 1;
          gamestate <= STATE_MOVING;
        end
      end
      STATE_RIGHT: begin
        if(~checked) begin
          collision <= 0;
          check <= 1;
          rel_cntr <= 0;
          abs_cntr <= cntr_top;
          for(i=0;i<4;i=i+1) begin
            game_area_newblock[i] <= {1'b0,game_area_newblock[i][11:1]};
          end
        end else begin
          if(collision) begin
            for(i=0;i<4;i=i+1)
              game_area_newblock[i] <= {game_area_newblock[i][10:0],1'b0};
          end else begin
            cntr_left <= cntr_left+1;
            framebuffer_game_update <= 1;
            gamestate   <= STATE_MOVING;
          end
        end
      end
      STATE_EVAL: begin
        if(abs_cntr == 20) begin
          if(game_prbs[2:0]<7) begin
            block_id <= next_block_id;
            next_block_id <= game_prbs[2:0];
            framebuffer_game_update <= 1;
            gamestate <= STATE_NEWBLOCK;
            checked <= 0;
          end
        end else begin
          abs_cntr <= abs_cntr +1;
          if(game_area[abs_cntr]==12'hFFF) begin
            gamelines <= gamelines + 1;
            gamepoints_inc <= {gamepoints_inc[24:0] ,1'b0};  // 100 200 400 800: Tetris 
            gamepoints <= gamepoints + gamepoints_inc;  
            for(int i = 19; i > 0; i = i - 1) begin
              if(i<=abs_cntr)
                game_area[i] <= game_area[i - 1];
            end
            game_area[0]<=12'h000;
          end else
            gamepoints_inc <= GAME_POINT_INCREMENT;
        end
      end
      STATE_PREROTATE: begin
        if(cntr_event < {4'b0, cntr_left}) begin // Move object to Top Left Corner
          for(i=0; i < 4; i = i + 1) begin
            game_area_newblock[i] <= {game_area_newblock[i][10:0],1'b0};
          end
          cntr_event <= cntr_event +1;
        end else begin 
          //  | 0x11 0x10 0x9 0x8 |    >>      | 3x11  2x11  1x11  0x11 |
          //  | 1x11 1x10 1x9 1x8 |            | 3x10  2x10  1x10  0x10 |
          //  | 2x11 2x10 2x9 2x8 |            | 3x9   2x9   1x9   0x9  |
          //  | 3x11 3x10 3x9 3x8 |            | 3x8   2x8   1x8   0x8  |
          game_area_newblock[0] <= {game_area_newblock[3][11],game_area_newblock[2][11],game_area_newblock[1][11],game_area_newblock[0][11],8'h00};
          game_area_newblock[1] <= {game_area_newblock[3][10],game_area_newblock[2][10],game_area_newblock[1][10],game_area_newblock[0][10],8'h00};        
          game_area_newblock[2] <= {game_area_newblock[3][9],game_area_newblock[2][9],game_area_newblock[1][9],game_area_newblock[0][9],8'h00};
          game_area_newblock[3] <= {game_area_newblock[3][8],game_area_newblock[2][8],game_area_newblock[1][8],game_area_newblock[0][8],8'h00};
          cntr_event <= 0;
          checked <= 0;
          gamestate <= STATE_ROTATE;
        end
      end
      STATE_GAMEOVER: begin
        if(action_enter) begin
          gamestate <= STATE_LOGO;
          framebuffer_game_update <= 1;
        end  
      end
      STATE_ROTATE: begin
        if(game_area_newblock[0]==12'h000) begin // Top row is empty
          for(i=0;i<3;i=i+1) begin
            game_area_newblock[i] <= game_area_newblock[i+1];
          end
          game_area_newblock[3] <= 12'h000;
        end else if(~gameborder_left && (cntr_event == 0)) begin // Left column is empty
          for(i=0;i<4;i=i+1) begin
            game_area_newblock[i] <= {game_area_newblock[i][10:0],1'b0};
          end
        end else if(cntr_event < {4'b0, cntr_left}) begin // Object is in the top left corner > shifting right > if applicable
          cntr_event <= cntr_event +1;
          if(~gameborder_right) begin
            for(i=0;i<4;i=i+1) begin
              game_area_newblock[i] <= {1'b0,game_area_newblock[i][11:1]};
            end
          end else begin // Revert changes
            gamestate <= STATE_MOVING;
            for(i=0;i<4;i=i+1) begin
              game_area_newblock[i] <= game_area_backup[i];
            end
          end
        end else begin // Shifting down > if applicable
          if(~checked) begin
            collision <= 0;
            check <= 1;
            rel_cntr <= 0;
            abs_cntr <= cntr_top;
          end else if(collision) begin // Revert changes
            gamestate <= STATE_MOVING;
            for(i=0;i<4;i=i+1) begin
              game_area_newblock[i] <= game_area_backup[i];
            end
          end else begin // Successful rotate
            gamestate <= STATE_MOVING;
            framebuffer_game_update <= 1;
          end
        end
      end
        default: begin
          gamestate <= STATE_LOGO;
      end
    endcase
  end
end

// Internal signals for VGA and Tetris Grid
logic [9:0] vga_x, vga_y;
logic vga_hsync, vga_vsync;
logic [2:0] tetris_pixel_color;

always_ff @(posedge clk) begin
  if (rst) begin
    game_area_vga_data <= '0;
  end
  else if (gamestate != STATE_LOGO) begin
    if (game_area_vga_addr >= cntr_top
        && (game_area_vga_addr - cntr_top) < 4)
      game_area_vga_data <=
        game_area[game_area_vga_addr]
        | game_area_newblock[game_area_vga_addr - cntr_top];
    else
      game_area_vga_data <= game_area[game_area_vga_addr];
  end
  else begin
    if (game_area_vga_addr < 10)
      game_area_vga_data <= '0;
    else if (game_area_vga_addr < 16)
      game_area_vga_data <= game_area_init
                            [game_area_vga_addr - 10];
    else if (game_area_vga_addr < 20)
      game_area_vga_data <= 12'hFFF;
    else
      game_area_vga_data <= '0;
  end
end

// PRBS
prbs prbs (
  .clk(clk), 
  .rst(rst), 
  .dout(game_prbs),
  .new_sample()
);

// Rategen
rategen rategen (
  .clk(clk), 
  .reset(reset), 
  .en(action_fall),
  .speed(gamespeed),
  .drop(action_drop)
);

vga vgaIF (
  .clk(clk),
  .rst(rst),
  .game_state(gamestate),
  .game_area_data(game_area_vga_data),
  .game_area_addr(game_area_vga_addr),
  .game_block_next(building_blocks[next_block_id]),
  .game_points(gamepoints),
  .game_lines(gamelines),
  .game_level(gamespeed),
  .vga_hs(vga_hs), 
  .vga_vs(vga_vs), 
  .vga_red(vga_red), 
  .vga_green(vga_green), 
  .vga_blue(vga_blue)
);

// Assign unused outputs to default values
assign left = 8'h00;
assign right = 8'h00;
assign ss7 = 1'b0;
assign ss6 = 1'b0;
assign ss5 = 1'b0;
assign ss4 = 1'b0;
assign ss3 = 1'b0;
assign ss2 = 1'b0;
assign ss1 = 1'b0;
assign ss0 = 1'b0;

endmodule

