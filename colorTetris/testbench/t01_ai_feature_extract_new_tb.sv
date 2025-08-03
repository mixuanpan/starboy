`timescale 1us/1ps
module t01_ai_feature_extract_new_tb();
    // Clock and reset
    logic clk;
    logic reset;
    
    // DUT inputs
    logic start_extract;
    logic [19:0][9:0] tetris_grid;
    
    // DUT outputs
    logic extract_ready;
    logic [9:0] lines_cleared;
    logic [7:0] holes;
    logic [7:0] bumpiness;
    logic [7:0] height_sum;
    
    // DUT instantiation
    t01_ai_feature_extract_new dut (
        .clk(clk),
        .rst(reset),
        .extract_start(start_extract),
        .tetris_grid(tetris_grid),
        .extract_ready(extract_ready),
        .lines_cleared(lines_cleared),
        .holes(holes),
        .bumpiness(bumpiness),
        .height_sum(height_sum)
    );
        
    task tog_rst; 
        reset = 1; #1; 
        reset = 0; 
    endtask 

    initial clk = 0; 
    always clk = #1 ~clk; 

    // Main test sequence
    initial begin
        $dumpfile("waves/t01_ai_feature_extract_new.vcd"); 
        $dumpvars(0, t01_ai_feature_extract_new_tb);
        // Initialize
        tetris_grid[5:0] = 0; 
        tetris_grid[6] = 10'b10101110; 
        tetris_grid[7] = 10'b01010001; 
        tetris_grid[8] = 10'b10101110; 
        tetris_grid[9] = 10'b10101101; 
        tog_rst(); 
        for (int i = 10; i <= 19; i++) begin 
            tetris_grid[i] = 10'b1111111111; 
        end
        for (int i = 0; i <= 19; i++) begin 
            $display("row \%d: \%b\n", i, tetris_grid[0]); 
        end
        for (int i = 0; i <= 1; i++) begin 
            start_extract = i[0]; 
            #5; 
        end
        #2000 $finish;
    end
    
endmodule
