module moveleftright(
    input logic clk, rst,
    input logic [21:0][9:0][2:0] input_array,
    input logic [2:0] current_state,
    input logic move_left,
    input logic move_right,
    output logic [21:0][9:0][2:0] output_array
);

    logic [3:0] blockX, blockXN;
    logic [3:0] minX, maxX;

    // Sequential logic for block X position
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            blockX <= 4'd4;  // Start at center position
        end else begin
            blockX <= blockXN;
        end
    end

    // Determine X bounds based on block type
    always_comb begin
        case(current_state)
            3'd0: begin // LINE - single column
                minX = 4'd0;
                maxX = 4'd9;
            end
            3'd1: begin // SMASHBOY - 2 columns wide
                minX = 4'd0;
                maxX = 4'd8;  // Can't go past column 8 (needs 8,9)
            end
            3'd2: begin // L - 2 columns wide
                minX = 4'd0;
                maxX = 4'd8;
            end
            3'd3: begin // REVERSE_L - 2 columns wide
                minX = 4'd1;  // Can't go to column 0 (needs -1)
                maxX = 4'd9;
            end
            3'd4: begin // S - 3 columns wide (4,5,6)
                minX = 4'd1;  // Can't go to column 0 (needs -1)
                maxX = 4'd6;  // Can't go past column 6 (needs 6,7,8)
            end
            3'd5: begin // Z - 3 columns wide (4,5,6)
                minX = 4'd0;
                maxX = 4'd7;  // Can't go past column 7 (needs 7,8,9)
            end
            3'd6: begin // T - 3 columns wide (3,4,5)
                minX = 4'd1;  // Can't go to column 0 (needs -1,0,1)
                maxX = 4'd7;  // Can't go past column 7 (needs 7,8,9)
            end
            default: begin
                minX = 4'd0;
                maxX = 4'd9;
            end
        endcase
    end

    // Movement logic
    always_comb begin
        blockXN = blockX;
        
        if (move_left && blockX > minX) begin
            blockXN = blockX - 4'd1;
        end else if (move_right && blockX < maxX) begin
            blockXN = blockX + 4'd1;
        end
    end

    // Generate output array with block at current X position
    always_comb begin
        // Initialize output array to copy input
        output_array = input_array;
        
        // Clear the input array first
        for (int row = 0; row < 22; row++) begin
            for (int col = 0; col < 10; col++) begin
                if (input_array[row][col] != 3'b000) begin
                    output_array[row][col] = 3'b000;
                end
            end
        end
        
        // Place the block pattern at the current X position
        case(current_state)
            3'd0: begin // LINE
                for (int row = 0; row < 22; row++) begin
                    if (input_array[row][4] != 3'b000) begin
                        output_array[row][blockX] = input_array[row][4];
                    end
                end
            end
            3'd1: begin // SMASHBOY
                for (int row = 0; row < 22; row++) begin
                    if (input_array[row][4] != 3'b000) begin
                        output_array[row][blockX] = input_array[row][4];
                    end
                    if (input_array[row][5] != 3'b000) begin
                        output_array[row][blockX+1] = input_array[row][5];
                    end
                end
            end
            3'd2: begin // L
                for (int row = 0; row < 22; row++) begin
                    if (input_array[row][4] != 3'b000) begin
                        output_array[row][blockX] = input_array[row][4];
                    end
                    if (input_array[row][5] != 3'b000) begin
                        output_array[row][blockX+1] = input_array[row][5];
                    end
                end
            end
            3'd3: begin // REVERSE_L
                for (int row = 0; row < 22; row++) begin
                    if (input_array[row][4] != 3'b000) begin
                        output_array[row][blockX-1] = input_array[row][4];
                    end
                    if (input_array[row][5] != 3'b000) begin
                        output_array[row][blockX] = input_array[row][5];
                    end
                end
            end
            3'd4: begin // S
                for (int row = 0; row < 22; row++) begin
                    if (input_array[row][4] != 3'b000) begin
                        output_array[row][blockX-1] = input_array[row][4];
                    end
                    if (input_array[row][5] != 3'b000) begin
                        output_array[row][blockX] = input_array[row][5];
                    end
                    if (input_array[row][6] != 3'b000) begin
                        output_array[row][blockX+1] = input_array[row][6];
                    end
                end
            end
            3'd5: begin // Z
                for (int row = 0; row < 22; row++) begin
                    if (input_array[row][4] != 3'b000) begin
                        output_array[row][blockX] = input_array[row][4];
                    end
                    if (input_array[row][5] != 3'b000) begin
                        output_array[row][blockX+1] = input_array[row][5];
                    end
                    if (input_array[row][6] != 3'b000) begin
                        output_array[row][blockX+2] = input_array[row][6];
                    end
                end
            end
            3'd6: begin // T
                for (int row = 0; row < 22; row++) begin
                    if (input_array[row][3] != 3'b000) begin
                        output_array[row][blockX-1] = input_array[row][3];
                    end
                    if (input_array[row][4] != 3'b000) begin
                        output_array[row][blockX] = input_array[row][4];
                    end
                    if (input_array[row][5] != 3'b000) begin
                        output_array[row][blockX+1] = input_array[row][5];
                    end
                end
            end
            default: begin
                // Do nothing for invalid state
            end
        endcase
    end

endmodule