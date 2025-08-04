`timescale 1us/1ps
module t01_ai_game_engine_tb; 
    logic clk, rst;
    logic [3:0] gamestate;
    logic extract_ready;
    logic extract_start;
    logic col_right, col_left;
    logic ai_right, ai_left, ai_rotation;
    logic [3:0] blockX;
    logic ai_new_spawn;

 
    t01_ai_game_engine ge (
        .clk(clk), .rst(rst), .gamestate(gamestate), .extract_ready(extract_ready), .extract_start(extract_start), .col_right(col_right), .col_left(col_left), .ai_right(ai_right), .ai_left(ai_left), .ai_rotation(ai_rotation), .blockX(blockX), .ai_new_spawn(ai_new_spawn)
    ); 

    task tog_rst; 
        rst = 1; #1; 
        rst = 0; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

    task tog_state(); 
        repeat (10) begin 
            @(posedge clk);
            gamestate = 'd10; @(posedge clk); 
            gamestate = 'd11;  @(posedge clk); 
            gamestate = 'd2;  @(posedge clk); 
        end
    endtask
    initial begin 
        $dumpfile("waves/t01_ai_game_engine.vcd"); 
        $dumpvars(0, t01_ai_game_engine_tb);
        extract_ready = 1; 
        tog_rst(); 
        tog_state(); 
        gamestate = 'd1; 
        tog_state(); 
        #5; 

    #1 $finish; 
    end
endmodule 