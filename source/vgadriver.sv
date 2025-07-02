module vgadriver (
    input logic clk, rst,       //25 MHz
    input logic [7:0] color_in, //RRR GGG BB
    output logic [9:0] x_out, y_out,
    output logic hsync, vsync, VGAclk, VGAsync, blank,
    output logic [7:0] red, green, blue
);

//numbers are in clock cycles
//typical VGA display is 640 x 480 @ 60hz

    logic [9:0] H_ACTIVE = 10'd639; //visible screen region
    logic [9:0] H_FRONT = 10'd15; //frontporch
    logic [9:0] H_PULSE = 10'd95; // low for sync pulse
    logic [9:0] H_BACK = 10'd47; // back high to reset the cycle
//these are all just limits
    logic [9:0] V_ACTIVE = 10'd479; //same stuff different dimension
    logic [9:0] V_FRONT = 10'd9;
    logic [9:0] V_PULSE = 10'd1;
    logic [9:0] V_BACK = 10'd32;

//make this shit look readable please use constants
    logic LOW = 1'b0;
    logic HIGH = 1'b1;

    typedef enum logic [1:0] {
        h_state_active = 2'b0,
        h_state_front = 2'b1,
        h_state_pulse = 2'b10,
        h_state_back = 2'b11
    } hstate_t;

    hstate_t current_hstate, next_hstate;

    typedef enum logic [1:0] {
        v_state_active = 2'b0,
        v_state_front = 2'b1,
        v_state_pulse = 2'b10,
        v_state_back = 2'b11
    } vstate_t;

    vstate_t current_vstate, next_vstate;

    logic hsync_r, vsync_r, line_done;
    assign vsync = vsync_r;
    assign hsync = hsync_r;


     logic [9:0] h_current_count, h_next_count;
     logic [9:0] v_current_count, v_next_count;


    always_ff @(posedge clk, posedge rst) begin

        current_hstate <= next_hstate;
        current_vstate <= next_vstate;
        
    end

    always_comb begin // H comb
        case(current_hstate)

        h_state_active: begin
            hsync_r = HIGH;
            line_done = LOW;

            if (h_current_count == H_ACTIVE) begin
                h_next_count = 10'd0;
                next_hstate = h_state_front;
            end else begin
                h_next_count = h_current_count + 10'd1;
                next_hstate = current_hstate;
            end
        end

        h_state_front: begin
            hsync_r = HIGH;
            line_done = LOW;

            if (h_current_count == H_FRONT) begin
                h_next_count = 10'd0;
                next_hstate = h_state_pulse;
            end else begin
                h_next_count = h_current_count + 10'd1;
                next_hstate = current_hstate;
            end

        end

        h_state_pulse: begin
            hsync_r = LOW;
            line_done = LOW;

            if (h_current_count == H_PULSE) begin
                h_next_count = 10'd0;
                next_hstate = h_state_back;
            end else begin
                h_next_count = h_current_count + 10'd1;
                next_hstate = current_hstate;
            end
        end

        h_state_back: begin
            hsync_r = HIGH;

            if(h_current_count == H_BACK - 1) begin
                line_done = HIGH;
            end else begin
                line_done = LOW;
            end


            if (h_current_count == H_BACK) begin
                h_next_count = 10'd0;
                next_hstate = h_state_active;
            end else begin
                h_next_count = h_current_count + 10'd1;
                next_hstate = current_hstate;
            end


        end

        endcase
    end

//sean diddy combs was found not guilty today on July 2nd, 2025

    always_comb begin // V comb
        case(current_vstate)

        v_state_active: begin
            vsync_r = HIGH;


        end

        v_state_front: begin
            vsync_r = HIGH;
        end

        v_state_pulse: begin
            vsync_r = LOW;
        end

        v_state_back: begin
            vsync_r = HIGH;
        end

        endcase
    end

endmodule