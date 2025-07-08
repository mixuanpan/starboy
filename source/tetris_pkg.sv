`default_nettype none
package tetris_pkg; 

// self-defined states for the finite state machine 
// block reference: https://docs.google.com/spreadsheets/d/1A7IpiXzjc0Yx8wuKXJpoMbAaJQVSf6PPc_mYC25cqE8/edit?gid=0#gid=0 

    typedef enum logic [4:0] {
        IDLE, // reset state 
        READY, // count down to start 
        NEW_BLOCK, // load new block 
        A1, // 011
        A2, 
        B1, // 101
        B2, 
        C1, // 111 
        C2, 
        D0, // 1001
        E1, // 1010 
        E2, 
        E3, 
        E4, 
        F1, // 1110 
        F2, 
        F3, 
        F4, 
        G1, // 10010
        G2, 
        G3, 
        G4, 
        EVAL, // evaluation 
        GAME_OVER // user run out of space 11000 
    } state_t; 

    typedef enum logic [2:0] {
        RIGHT, 
        LEFT, 
        ROR, // ROTATE RIGHT
        ROL, // ROTATE LEFT 
        DOWN
    } move_t; 

    typedef enum logic [2:0] {
        CL0, // BLACK   
        CL1, 
        CL2, 
        CL3, 
        CL4, 
        CL5, 
        CL6, 
        CL7
    } color_t; 

endpackage 