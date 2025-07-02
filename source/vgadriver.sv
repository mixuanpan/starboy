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

    typedef enum logic [1:0] {
        v_state_active = 2'b0,
        v_state_front = 2'b1,
        v_state_pulse = 2'b10,
        v_state_back = 2'b11
    } vstate_t;

endmodule