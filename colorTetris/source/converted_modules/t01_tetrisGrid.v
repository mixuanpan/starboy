`default_nettype none
module t01_tetrisGrid (
	x,
	y,
	final_display_color,
	gameover,
	top_level_state,
	shape_color
);
	reg _sv2v_0;
	input wire [9:0] x;
	input wire [9:0] y;
	input wire [599:0] final_display_color;
	input wire gameover;
	input wire [1:0] top_level_state;
	output reg [2:0] shape_color;
	localparam BLOCK_SIZE = 15;
	localparam BLACK = 3'b000;
	localparam WHITE = 3'b111;
	localparam RED = 3'b100;
	localparam BLUE = 3'b001;
	reg in_grid;
	reg [9:0] temp_x;
	reg [9:0] temp_y;
	reg [3:0] grid_x;
	reg [4:0] grid_y;
	reg on_grid_line;
	always @(*) begin
		if (_sv2v_0)
			;
		in_grid = (((x >= 10'd245) && (x < 10'd395)) && (y >= 10'd90)) && (y < 10'd390);
		temp_x = (x - 10'd245) / BLOCK_SIZE;
		temp_y = (y - 10'd90) / BLOCK_SIZE;
		grid_x = temp_x[3:0];
		grid_y = temp_y[4:0];
		on_grid_line = (((((x - 10'd245) % BLOCK_SIZE) == 0) || (((y - 10'd90) % BLOCK_SIZE) == 0)) || (x == 10'd394)) || (y == 10'd389);
		if (in_grid) begin
			if (on_grid_line && ((top_level_state == 2'b10) || (top_level_state == 2'b11)))
				shape_color = BLUE;
			else if (on_grid_line && !gameover)
				shape_color = WHITE;
			else if (on_grid_line && gameover)
				shape_color = RED;
			else if ((grid_y < 5'd20) && (grid_x < 4'd10))
				shape_color = final_display_color[((grid_y * 10) + grid_x) * 3+:3];
			else
				shape_color = BLACK;
		end
		else
			shape_color = BLACK;
	end
	initial _sv2v_0 = 0;
endmodule
