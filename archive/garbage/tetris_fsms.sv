module tetris_fsm (
    input logic clk, reset, start_i, 
    input logic collision_bottom, rotate_pulse,
    input logic [4:0] current_block_type,
    input logic [19:0][9:0] stored_array,
    input logic eval_complete,
    output logic gameover
);

// FSM States
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

game_state_t current_state, next_state;

// State Register
always_ff @(posedge clk, posedge reset) begin
    if (reset)
        current_state <= INIT;
    else
        current_state <= next_state;
end

// Next State Logic
always_comb begin
    next_state = current_state;
    gameover = (current_state == GAMEOVER);

    case (current_state)
        INIT: begin
            if (start_i)
                next_state = SPAWN;
        end
        SPAWN: begin
            next_state = FALLING;
        end
        FALLING: begin
            if (collision_bottom) begin 
                next_state = STUCK;
            end else if (current_block_type != 'd1 && rotate_pulse) begin
                next_state = ROTATE; 
            end 
        end
        STUCK: begin 
            if (|stored_array[0])
                next_state = GAMEOVER;
            else
                next_state = LANDED;
        end
        ROTATE: begin 
            next_state = FALLING;   
        end
        LANDED: begin
            next_state = EVAL;
        end
        EVAL: begin
            if (eval_complete)
                next_state = SPAWN;
        end
        GAMEOVER: begin
            next_state = GAMEOVER;
        end
        default: begin
            next_state = INIT;
        end
    endcase
end

endmodule