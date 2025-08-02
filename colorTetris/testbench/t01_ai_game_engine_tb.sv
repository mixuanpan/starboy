`timescale 1us/1ps
module t01_ai_game_engine_tb; 
    logic clk, rst;
    logic [3:0] gamestate;
    logic extract_ready;
    logic extract_start;
    logic [4:0] current_block_type; 
    logic collision_slide, ai_rotation; 

   
    t01_ai_game_engine ge (.clk(clk), .rst(rst), .collision_slide(collision_slide), .ai_rotation(ai_rotation), .gamestate(gamestate), .extract_ready(extract_ready), .extract_start(extract_start), .current_block_type(current_block_type)); 

    task tog_rst; 
        rst = 1; #1; 
        rst = 0; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

 
    initial begin 
        $dumpfile("waves/t01_ai_game_engine.vcd"); 
        $dumpvars(0, t01_ai_game_engine_tb);
        current_block_type = 'd3; 
        tog_rst(); 
        for (int m = 0; m <= 1; m++) begin 
        for (int i = 0; i <= 'd10; i++) begin 
            for (int j = 0; j <= 1; j++) begin 
                for (int k = 0; k <= 1; k ++) begin 
                    gamestate = i[3:0]; 
                    extract_ready = j[0]; 
                    collision_slide = k[0]; 
                    #1; 
                end 
            end
        end
        end 

    #1 $finish; 
    end
endmodule 