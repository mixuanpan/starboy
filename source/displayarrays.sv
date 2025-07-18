module displayarrays(
    input logic start_i, collision_bottom, rotate_pulse, eval_complete,
    input logic [4:0] current_block_type,
    input logic [2:0] current_state,
    input logic [19:0][9:0] stored_array,falling_block_display, cleared_array,
    output logic [19:0][9:0] display_array
);

typedef enum logic [2:0] {
    INIT,
    SPAWN,
    FALLING,
    ROTATE, 
    STUCK,  
    LANDED,
    EVAL,
    GAMEOVER
} game_state_t;

game_state_t next_state;
always_comb begin
    display_array = stored_array;
    next_state = INIT;
    case (current_state)
        INIT: begin
            if (start_i)
                next_state = SPAWN;
            display_array = stored_array;
        end
        SPAWN: begin
            next_state = FALLING;
            display_array = falling_block_display | stored_array;
        end
        FALLING: begin
            // Check for bottom collision - can happen any time, but only drop on drop_tick
            if (collision_bottom) begin 
                next_state = STUCK;
            end else if (current_block_type != 'd1 && rotate_pulse) begin // square doesn't matter
                next_state = ROTATE; 
            end 
            display_array = falling_block_display | stored_array;
        end
        STUCK: begin 
            if (|stored_array[0])
                next_state = GAMEOVER;
            else
                next_state = LANDED;
            display_array = falling_block_display | stored_array;
        end
        ROTATE: begin 
            display_array = falling_block_display | stored_array;
            next_state = FALLING;   
        end
        LANDED: begin
            next_state = EVAL;
            display_array = stored_array;
        end
        EVAL: begin
            if (eval_complete)
                next_state = SPAWN;
            display_array = cleared_array;
        end
        GAMEOVER: begin
            next_state = GAMEOVER;
            display_array = stored_array;
        end
        default: begin
            next_state = INIT;
            display_array = stored_array;
        end
    endcase
end

endmodule