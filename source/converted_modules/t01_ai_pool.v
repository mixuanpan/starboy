`default_nettype none
module t01_ai_pool (
	clk,
	rst,
	pool_en,
	pool_valid,
	feature_map,
	output_map,
	done
);
	parameter signed [31:0] MAP_H = 20;
	parameter signed [31:0] MAP_W = 10;
	parameter signed [31:0] K_WIDTH = 4;
	parameter signed [31:0] S_WIDTH = 4;
	parameter signed [31:0] C_WIDTH = 3;
	input wire clk;
	input wire rst;
	input wire pool_en;
	input wire pool_valid;
	input wire [(MAP_H * MAP_W) - 1:0] feature_map;
	output reg [((MAP_H / 2) * (MAP_W / 2)) - 1:0] output_map;
	output reg done;
	reg [1:0] max_inx;
	reg [31:0] col_inx;
	reg [31:0] row_inx;
	reg [3:0] window;
	reg [1:0] window_inx;
	always @(posedge clk or posedge rst)
		if (rst) begin
			max_inx <= 0;
			col_inx <= 0;
			row_inx <= 0;
			window <= 4'b0000;
			window_inx <= 0;
			output_map <= 0;
			done <= 0;
		end
		else if (pool_en && pool_valid) begin
			if ((row_inx >= 'd18) && (col_inx >= 'd8))
				done <= 1;
			else begin
				window[0] <= feature_map[(row_inx * MAP_W) + col_inx];
				window[1] <= feature_map[(row_inx * MAP_W) + (col_inx + 1)];
				window[2] <= feature_map[((row_inx + 1) * MAP_W) + col_inx];
				window[3] <= feature_map[((row_inx + 1) * MAP_W) + (col_inx + 1)];
				if (window_inx < 'd3) begin
					if (window[window_inx] < window[window_inx + 1])
						max_inx <= window_inx + 'd1;
					else
						max_inx <= window_inx;
					window_inx <= window_inx + 'd1;
				end
				else begin
					output_map[((row_inx / 2) * (MAP_W / 2)) + (col_inx / 2)] <= window[max_inx];
					window_inx <= 0;
					max_inx <= 0;
					if (col_inx < 'd8)
						col_inx <= col_inx + 'd2;
					else begin
						col_inx <= 0;
						row_inx <= row_inx + 'd2;
					end
				end
			end
		end
endmodule