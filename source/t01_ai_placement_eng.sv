`default_nettype none
/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : t01_ai_placement_engine
// Description : determines all possible placements for a given piece
// 
//
/////////////////////////////////////////////////////////////////
// after writing this code i think that we should have a seperate fsm for the AI bc ts is NOT going 
// to fit ANYTHING on the chip LMAO. I made like a million different arrays to store the next boards
// and placements and it is just not going to work. I think we should have a seperate fsm
// and only tape out the uh original tetris one 

// no way in this good amazing earth can we tape out 40 200-bit boards and placements
module t01_ai_placement_engine (
    input logic clk,
    input logic reset,
    input logic start_placement, //start flag
    input logic [19:0][9:0] display_array, 
    input logic [4:0] piece_type,
    
    output logic placement_ready, //done flag
    output logic [199:0] [0:39]next_boards, //LMAOOO THIS IS NOT CRAMMING BTW
    output logic [5:0] valid_placements,
    output logic [1:0] rotations [0:39],
    output logic [3:0] x_positions [0:39]
);

    typedef enum logic [2:0] {
        IDLE,
        GET_ROTATIONS,
        TEST_PLACEMENT,
        COMPUTE_DROP,
        STORE_RESULT,
        DONE
    } placement_state_t;
    
    placement_state_t current_state, next_state;
    
    logic [1:0] current_rotation;
    logic [3:0] current_x;
    logic [5:0] placement_index;
    logic [3:0][3:0] current_pattern;
    logic [1:0] max_rotations;
    logic [3:0] min_x, max_x;
    logic [199:0] current_board; 
    logic [199:0] shifted_mask;
    logic [4:0] landing_row;
    logic [199:0] merged_board;
    logic collision_detected;
    logic valid_position;
    logic [3:0][3:0][0:18] piece_patterns;
    
    //legal X positions for each piece type and rotation
    logic [3:0] legal_x_min [0:18];
    logic [3:0] legal_x_max [0:18];
    
    // initialize piece patterns and legal positions (i love hardcoding <333)
    initial begin
        // I-piece vert
        piece_patterns[0] = '{4'b0100, 4'b0100, 4'b0100, 4'b0100};
        legal_x_min[0] = 0; legal_x_max[0] = 9;
        
        // I-piece hori
        piece_patterns[7] = '{4'b0000, 4'b1111, 4'b0000, 4'b0000};
        legal_x_min[7] = 0; legal_x_max[7] = 6;
        
        // O-piece 
        piece_patterns[1] = '{4'b0110, 4'b0110, 4'b0000, 4'b0000};
        legal_x_min[1] = 0; legal_x_max[1] = 8;
        
        // S-piece hori
        piece_patterns[2] = '{4'b0110, 4'b1100, 4'b0000, 4'b0000};
        legal_x_min[2] = 0; legal_x_max[2] = 7;
        
        // S-piece vert
        piece_patterns[9] = '{4'b1000, 4'b1100, 4'b0100, 4'b0000};
        legal_x_min[9] = 0; legal_x_max[9] = 8;
        
        // Z-piece hori
        piece_patterns[3] = '{4'b1100, 4'b0110, 4'b0000, 4'b0000};
        legal_x_min[3] = 0; legal_x_max[3] = 7;
        
        // Z-piece vert
        piece_patterns[8] = '{4'b0100, 4'b1100, 4'b1000, 4'b0000};
        legal_x_min[8] = 0; legal_x_max[8] = 8;
        
        // J-piece 0
        piece_patterns[4] = '{4'b1000, 4'b1110, 4'b0000, 4'b0000};
        legal_x_min[4] = 0; legal_x_max[4] = 7;
        
        // J-piece 90
        piece_patterns[10] = '{4'b1100, 4'b1000, 4'b1000, 4'b0000};
        legal_x_min[10] = 0; legal_x_max[10] = 8;
        
        // J-piece 180
        piece_patterns[11] = '{4'b1110, 4'b0010, 4'b0000, 4'b0000};
        legal_x_min[11] = 0; legal_x_max[11] = 7;
        
        // J-piece 270
        piece_patterns[12] = '{4'b0100, 4'b0100, 4'b1100, 4'b0000};
        legal_x_min[12] = 0; legal_x_max[12] = 8;
        
        // L-piece 0
        piece_patterns[5] = '{4'b0010, 4'b1110, 4'b0000, 4'b0000};
        legal_x_min[5] = 0; legal_x_max[5] = 7;
        
        // L-piece 90
        piece_patterns[13] = '{4'b1000, 4'b1000, 4'b1100, 4'b0000};
        legal_x_min[13] = 0; legal_x_max[13] = 8;
        
        // L-piece 180
        piece_patterns[14] = '{4'b1110, 4'b1000, 4'b0000, 4'b0000};
        legal_x_min[14] = 0; legal_x_max[14] = 7;
        
        // L-piece 270
        piece_patterns[15] = '{4'b1100, 4'b0100, 4'b0100, 4'b0000};
        legal_x_min[15] = 0; legal_x_max[15] = 8;
        
        // T-piece 0
        piece_patterns[6] = '{4'b0100, 4'b1110, 4'b0000, 4'b0000};
        legal_x_min[6] = 0; legal_x_max[6] = 7;
        
        // T-piece 270
        piece_patterns[16] = '{4'b1000, 4'b1100, 4'b1000, 4'b0000};
        legal_x_min[16] = 0; legal_x_max[16] = 8;
        
        // T-piece 180
        piece_patterns[17] = '{4'b1110, 4'b0100, 4'b0000, 4'b0000};
        legal_x_min[17] = 0; legal_x_max[17] = 7;
        
        // T-piece 90
        piece_patterns[18] = '{4'b0100, 4'b1100, 4'b0100, 4'b0000};
        legal_x_min[18] = 0; legal_x_max[18] = 8;
    end
    
    //nested for loop so the map is easier for us to use !!
    always_comb begin
        current_board = 200'd0;
        for (int row = 0; row < 20; row++) begin
            for (int col = 0; col < 10; col++) begin
                if (display_array[row][col]) begin
                    current_board[row * 10 + col] = 1'b1;
                end
            end
        end
    end
    
    // State register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Get rotation information based on piece type
    always_comb begin
        case (piece_type[2:0]) // Use lower 3 bits for base piece type
            3'd0: begin // I-piece
                max_rotations = 2'd1; // 2 rotations (0: vertical, 1: horizontal)
            end
            3'd1: begin // O-piece
                max_rotations = 2'd0; // 1 rotation (square doesn't change)
            end
            3'd2, 3'd3: begin // S-piece, Z-piece
                max_rotations = 2'd1; // 2 rotations
            end
            default: begin // J, L, T pieces
                max_rotations = 2'd3; // 4 rotations
            end
        endcase
    end
    
    // Get actual piece type index for patterns array
    logic [4:0] pattern_index;
    always_comb begin
        case (piece_type[2:0])
            3'd0: pattern_index = (current_rotation == 0) ? 5'd0 : 5'd7;   // I-piece
            3'd1: pattern_index = 5'd1;                                     // O-piece
            3'd2: pattern_index = (current_rotation == 0) ? 5'd2 : 5'd9;   // S-piece
            3'd3: pattern_index = (current_rotation == 0) ? 5'd3 : 5'd8;   // Z-piece
            3'd4: begin // J-piece
                case (current_rotation)
                    2'd0: pattern_index = 5'd4;
                    2'd1: pattern_index = 5'd10;
                    2'd2: pattern_index = 5'd11;
                    2'd3: pattern_index = 5'd12;
                endcase
            end
            3'd5: begin // L-piece
                case (current_rotation)
                    2'd0: pattern_index = 5'd5;
                    2'd1: pattern_index = 5'd13;
                    2'd2: pattern_index = 5'd14;
                    2'd3: pattern_index = 5'd15;
                endcase
            end
            3'd6: begin // T-piece
                case (current_rotation)
                    2'd0: pattern_index = 5'd6;
                    2'd1: pattern_index = 5'd18;
                    2'd2: pattern_index = 5'd17;
                    2'd3: pattern_index = 5'd16;
                endcase
            end
            default: pattern_index = 5'd0;
        endcase
    end
    
    // Control logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_rotation <= 2'd0;
            current_x <= 4'd0;
            placement_index <= 6'd0;
            valid_placements <= 6'd0;
            placement_ready <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (start_placement) begin
                        current_rotation <= 2'd0;
                        current_x <= 4'd0;
                        placement_index <= 6'd0;
                        valid_placements <= 6'd0;
                        placement_ready <= 1'b0;
                    end
                end
                
                GET_ROTATIONS: begin
                    current_pattern <= piece_patterns[pattern_index];
                    min_x <= legal_x_min[pattern_index];
                    max_x <= legal_x_max[pattern_index];
                    current_x <= legal_x_min[pattern_index];
                end
                
                TEST_PLACEMENT: begin
                    if (valid_position && !collision_detected) begin
                        next_boards[placement_index] <= merged_board;
                        rotations[placement_index] <= current_rotation;
                        x_positions[placement_index] <= current_x;
                        placement_index <= placement_index + 1;
                        valid_placements <= valid_placements + 1;
                    end
                    if (current_x < max_x) begin
                        current_x <= current_x + 1;
                    end else begin
                        current_x <= legal_x_min[pattern_index];
                        if (current_rotation < max_rotations) begin
                            current_rotation <= current_rotation + 1;
                        end else begin
                        end
                    end
                end
                
                DONE: begin
                    placement_ready <= 1'b1;
                end
            endcase
        end
    end
    
    always_comb begin
        case (current_state)
            IDLE: begin
                if (start_placement)
                    next_state = GET_ROTATIONS;
                else
                    next_state = IDLE;
            end
            
            GET_ROTATIONS: begin
                next_state = TEST_PLACEMENT;
            end
            
            TEST_PLACEMENT: begin
                if (current_x >= max_x && current_rotation >= max_rotations)
                    next_state = DONE;
                else
                    next_state = COMPUTE_DROP;
            end
            
            COMPUTE_DROP: begin
                next_state = STORE_RESULT;
            end
            
            STORE_RESULT: begin
                next_state = GET_ROTATIONS;
            end
            
            DONE: begin
                if (!start_placement)
                    next_state = IDLE;
                else
                    next_state = DONE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // had to do it twice LOL
    always_comb begin
        shifted_mask = 200'd0;
        for (int row = 0; row < 4; row++) begin
            for (int col = 0; col < 4; col++) begin
                if (current_pattern[row][col]) begin
                    if ((current_x + col) < 10) begin
                        shifted_mask[row * 10 + current_x + col] = 1'b1;
                    end
                end
            end
        end
    end
    
    // drop sim
    always_comb begin
        landing_row = 5'd0;
        collision_detected = 1'b0;
        valid_position = 1'b1;
        
        if (shifted_mask & current_board) begin
            valid_position = 1'b0;
        end else begin
            for (int drop_row = 16; drop_row >= 0; drop_row--) begin
                logic [199:0] mask_at_row;
                logic [199:0] mask_below;
                mask_at_row = shifted_mask << (drop_row * 10);
                if (drop_row > 0) begin
                    mask_below = shifted_mask << ((drop_row - 1) * 10);
                    if (mask_below & current_board) begin
                        landing_row = drop_row;
                        break;
                    end
                end else begin
                    landing_row = 5'd0;
                    break;
                end
            end
        end
    end
    
    always_comb begin
        logic [199:0] final_mask;
        final_mask = shifted_mask << (landing_row * 10);
        merged_board = current_board | final_mask;
    end

endmodule