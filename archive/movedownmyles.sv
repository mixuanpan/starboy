module movedown(
    input logic clk, rst, en, check,
    input logic [21:0][9:0] input_array, stored_array,
    input logic [2:0] current_state,
    output logic [21:0][9:0]output_array,
    output logic [4:0] collision_row, 
    output logic finish, checked, collision
);

    logic [4:0] blockY, blockYN, maxY;
    logic [21:0][9:0][2:0] shifted_array;

    localparam BLOCK_H = 4; 
    // Sequential logic for block position
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            blockY <= 5'd0;
            c_arr <= 0; 
        end else if (en) begin
            blockY <= blockYN;
            c_arr <= n_arr; 
        end
    end

    logic [4:0] abs_cntr;
    logic [2:0] rel_cntr;
    logic checking; 

    always_ff@(posedge clk, posedge rst) begin 
    if (rst) begin
        checking <= 0;
        checked <= 0;
        collision <= 0;
        rel_cntr <= 0;
        abs_cntr <= 0;
    end
    else if (check) begin
        checking <= 1;
        checked <= 0;
        collision <= 0;
        rel_cntr <= 0;
        abs_cntr <= blockY;
    end else if (checking) begin
        if (rel_cntr < 3'd4) begin
            if ((stored_array[abs_cntr] & input_array[rel_cntr]) != 0)
            collision <= 1;
        rel_cntr <= rel_cntr +1;
        abs_cntr <= abs_cntr + 1;
        end else begin
            checking <= 0;
            checked <= 1;
        end
    end
end

    logic [21:0][9:0]c_arr,n_arr; 
    assign output_array = c_arr; 

    // Shift the input array down by blockY positions
    always_comb begin
        case(current_state)
            3'd0: begin //line
            maxY = 5'd16;
            end
            3'd1: begin //square
            maxY = 5'd18;
            end
            3'd2: begin //L
            maxY = 5'd17;
            end
            3'd3: begin// reverse L
            maxY = 5'd17;
            end
            3'd4: begin // S
            maxY = 5'd18;
            end
            3'd5: begin // Z
            maxY = 5'd18;
            end
            3'd6: begin // T
            maxY = 5'd18;
            end
            default: maxY = 5'd19;
        endcase
    end


    always_comb begin
    // default values
    blockYN = blockY;
    finish  = 1'b0;

    // compute next row
    if (blockY < maxY)
        blockYN = blockY + 5'd1;
    // else blockYN stays at blockY

    // signal “done” if disabled or about to hit the bottom
    if (!en || blockYN == maxY)
        finish = 1'b1;
end


       always_comb begin
        // Initialize output array to all zeros
        // output_array = 0;
        collision_row = maxY + 'd4;
        n_arr = 0; 
        // if (en) begin 
        // Place the block pattern at the current Y position
            case(current_state)
                3'd0: begin // LINE
                    collision_row = blockY + 'd4; 
                    if (blockY + 3 < 20) begin
                        n_arr[blockY][4] = 'b1;
                        n_arr[blockY+1][4] = 'b1;
                        n_arr[blockY+2][4] = 'b1;
                        n_arr[blockY+3][4] = 'b1;
                    end
                end
                3'd1: begin // SMASHBOY
                    collision_row = blockY + 'd2;
                    if (blockY + 1 < 20) begin
                        n_arr[blockY][4] = 'b1;
                        n_arr[blockY][5] = 'b1;
                        n_arr[blockY+1][4] = 'b1;
                        n_arr[blockY+1][5] = 'b1;
                    end
                end
                3'd2: begin // L
                    if (blockY + 2 < 20) begin
                        n_arr[blockY][4] = 'b1;
                        n_arr[blockY+1][4] = 'b1;
                        n_arr[blockY+2][4] = 'b1;
                        n_arr[blockY+2][5] = 'b1;
                    end
                end
                3'd3: begin // REVERSE_L
                    if (blockY + 2 < 20) begin
                        n_arr[blockY][5] = 'b1;
                        n_arr[blockY+1][5] = 'b1;
                        n_arr[blockY+2][5] = 'b1;
                        n_arr[blockY+2][4] = 'b1;
                    end
                end
                3'd4: begin // S
                    if (blockY + 1 < 20) begin
                        n_arr[blockY][6] = 'b1;
                        n_arr[blockY][5] = 'b1;
                        n_arr[blockY+1][5] = 'b1;
                        n_arr[blockY+1][4] = 'b1;
                    end
                end
                3'd5: begin // Z
                    if (blockY + 1 < 20) begin
                        n_arr[blockY][4] = 'b1;
                        n_arr[blockY][5] = 'b1;
                        n_arr[blockY+1][5] = 'b1;
                        n_arr[blockY+1][6] = 'b1;
                    end
                end
                3'd6: begin // T
                    if (blockY + 1 < 20) begin
                        n_arr[blockY][4] = 'b1;
                        n_arr[blockY+1][3] = 'b1;
                        n_arr[blockY+1][4] = 'b1;
                        n_arr[blockY+1][5] = 'b1;
                    end
                end
                default: begin
                    // Do nothing for invalid state
                    collision_row = maxY + 'd4;
                end
            endcase
    //    end
    end


endmodule