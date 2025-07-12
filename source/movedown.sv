module movedown(
    input logic clk, rst, en, 
    input logic [21:0][9:0] input_array,
    input logic [2:0] current_state,
    output logic [21:0][9:0]output_array,
    output logic [4:0] collision_row1, collision_row2, 
    output logic [3:0] collision_col1, collision_col2, collision_col3,  
    output logic finish
);

    logic [4:0] blockY, blockYN, maxY;
    logic [21:0][9:0][2:0] shifted_array;

    // Sequential logic for block position
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            blockY <= 5'd0;
            c_arr <= 0; 
        end else if (!finish) begin
            blockY <= blockYN;
            c_arr <= n_arr; 
        end
    end

    logic [21:0][9:0]c_arr,n_arr; 
    // assign output_array = c_arr; 

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
        if (!en) begin // collision 
            finish = '1; 
        end else begin 
            finish = '0;
        end 
        blockYN = blockY;
        
        // Move down if not at bottom (leave some space at bottom)
        if (blockY < maxY) begin
            blockYN = blockY + 5'd1;
        end else begin
            blockYN = blockY; 
            finish = '1; 
        end

        if (blockYN == maxY - '1) begin
            finish = '1;
        end
    end

       always_comb begin
        // Initialize output array to all zeros
        n_arr = c_arr; 
        output_array = 0; 
        collision_row1 = blockY + 'd4; // out of bounds 
        collision_row2 = 'd21; // last row 
        collision_col1 = 0;
        collision_col2 = 0; 
        collision_col3 = 0;  
        // if (en) begin 
        // Place the block pattern at the current Y position
            case(current_state)
                3'd0: begin // LINE
                collision_row1 = blockY + 'd4; 
                collision_col1 = 'd4; 
                    if (blockY + 3 < 20) begin
                        output_array[blockY][4] = 'b1;
                        output_array[blockY+1][4] = 'b1;
                        output_array[blockY+2][4] = 'b1;
                        output_array[blockY+3][4] = 'b1;
                    end
                end
                3'd1: begin // SMASHBOY
                collision_col1 = 'd4; 
                collision_row1 = blockY + 'd2; 
                collision_col2 = 'd5; 
                    if (blockY + 1 < 20) begin
                        output_array[blockY][4] = 'b1;
                        output_array[blockY][5] = 'b1;
                        output_array[blockY+1][4] = 'b1;
                        output_array[blockY+1][5] = 'b1;
                    end
                end
                3'd2: begin // L
                collision_col1 = 'd4; 
                collision_row1 = blockY + 'd3; 
                collision_col2 = 'd5; 
                    if (blockY + 2 < 20) begin
                        output_array[blockY][4] = 'b1;
                        output_array[blockY+1][4] = 'b1;
                        output_array[blockY+2][4] = 'b1;
                        output_array[blockY+2][5] = 'b1;
                    end
                end
                3'd3: begin // REVERSE_L
                collision_col1 = 'd4; 
                collision_row1 = blockY + 'd3; 
                collision_col2 = 'd5; 
                    if (blockY + 2 < 20) begin
                        output_array[blockY][5] = 'b1;
                        output_array[blockY+1][5] = 'b1;
                        output_array[blockY+2][5] = 'b1;
                        output_array[blockY+2][4] = 'b1;
                    end
                end
                3'd4: begin // S
                collision_row1 = blockY + 'd1; 
                collision_col1 = 'd4; 
                collision_row2 = blockY + 'd2; 
                collision_col2 = 'd5; 
                collision_col3 = 'd6; 
                    if (blockY + 1 < 20) begin
                        output_array[blockY][6] = 'b1;
                        output_array[blockY][5] = 'b1;
                        output_array[blockY+1][5] = 'b1;
                        output_array[blockY+1][4] = 'b1;
                    end
                end
                3'd5: begin // Z
                collision_row1 = blockY + 'd1; 
                collision_col1 = 'd6; 
                collision_row2 = blockY + 'd2; 
                collision_col2 = 'd5; 
                collision_col3 = 'd4; 
                    if (blockY + 1 < 20) begin
                        output_array[blockY][4] = 'b1;
                        output_array[blockY][5] = 'b1;
                        output_array[blockY+1][5] = 'b1;
                        output_array[blockY+1][6] = 'b1;
                    end
                end
                3'd6: begin // T
                collision_row1 = blockY + 'd2; 
                collision_col1 = 'd4; 
                collision_col2 = 'd5; 
                collision_col3 = 'd3; 
                    if (blockY + 1 < 20) begin
                        output_array[blockY][4] = 'b1;
                        output_array[blockY+1][3] = 'b1;
                        output_array[blockY+1][4] = 'b1;
                        output_array[blockY+1][5] = 'b1;
                    end
                end
                default: begin
                    // Do nothing for invalid state
                end
            endcase
    //    end
    end

       // collision check 
    // always_comb begin 
    //     collision_row1 = blockY + 'd4; // out of bounds 
    //     collision_row2 = blockY + 'd4; // out of bounds 
    //     collision_col1 = 0;
    //     collision_col2 = 0; 
    //     collision_col3 = 0;  
    //     case(current_state)
    //         3'd0: begin // LINE
    //             collision_row1 = blockY + 'd4; 
    //             collision_col1 = 'd4; 
    //         end

    //         3'd1, 3'd2, 3'd3: begin // SMASHBOY
    //             collision_col1 = 'd4; 
    //             collision_row1 = blockY + 'd2; 
    //             collision_col2 = 'd5; 
    //         end

    //         3'd4, 3'd5: begin // S 
    //             collision_row1 = blockY + 'd1; 
    //             collision_col1 = 'd4; 
    //             collision_row2 = blockY + 'd2; 
    //             collision_col2 = 'd5; 
    //             collision_col3 = 'd6; 
    //         end

    //         3'd6: begin // T
    //             collision_row1 = blockY + 'd2; 
    //             collision_col1 = 'd4; 
    //             collision_col2 = 'd5; 
    //             collision_col3 = 'd3; 
    //         end
    //         default: begin
    //             // Do nothing for invalid state
    //         end
    //     endcase
    // end


endmodule