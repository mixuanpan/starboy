`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : counter 
// Description : counter for reading in a new block 
// 
//
/////////////////////////////////////////////////////////////////

module counter(
    input logic clk, nRst_i,
    input logic button_i,
    output logic [2:0] current_state_o,
    output logic [2:0] counter_o
);

    //counter to 7
    logic [2:0] counter;

    always_ff @(posedge clk or negedge nRst_i) begin
        if (!nRst_i)
            counter <= 3'd0;
        else
            counter <= (counter == 3'd7) ? 3'd0 : counter + 3'd1;
    end

    assign counter_o = counter;

    //synchronizer
    logic sync_ff1, sync_ff2;
    logic strobe;

    always_ff @(posedge clk or negedge nRst_i) begin
        if (!nRst_i) begin
            sync_ff1 <= 0;
            sync_ff2 <= 0;
        end else begin
            sync_ff1 <= button_i;
            sync_ff2 <= sync_ff1;
        end
    end

    assign strobe = (sync_ff1 && ~sync_ff2);  //rising edge

    //fsm
    typedef enum logic [2:0] {
        BLOCK_L = 3'd0, // A1 
        BLOCK_T = 3'd1, // B1 
        BLOCK_I = 3'd2, // C1
        BLOCK_DOT = 3'd3, // D0 
        BLOCK_SQUARE = 3'd4, // E1 
        BLOCK_CROSS = 3'd5, // F1 
        BLOCK_STEPS = 3'd6 // G1
        // BLOCK_Z = 3'd7
    } block_t;

    block_t current_state, next_state;
    logic [2:0] latched_value;

    //Latch the counter on strobe
    always_ff @(posedge clk or negedge nRst_i) begin
        if (!nRst_i)
            latched_value <= 3'd0;
        else if (strobe)
            latched_value <= counter;
    end

    //FSM Logic
    always_ff @(posedge clk or negedge nRst_i) begin
        if (!nRst_i)
            current_state <= BLOCK_SQUARE;
        else if (strobe)
            current_state <= block_t'(latched_value);
    end

    assign current_state_o = current_state;

endmodule