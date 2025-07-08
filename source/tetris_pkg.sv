`default_nettype none
package tetris_pkg; 
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
    GAME_OVER // user run out of space 10111 
    } state_t; 

    typedef enum logic [2:0] {
    RIGHT, 
    LEFT, 
    ROR, // ROTATE RIGHT
    ROL, // ROTATE LEFT 
    DOWN
    } move_t; 

endpackage 