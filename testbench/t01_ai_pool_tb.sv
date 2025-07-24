`default_nettype none

module tb_t01_ai_pool;

    // Parameters matching the DUT
    parameter signed [31:0] MAP_H = 20;
    parameter signed [31:0] MAP_W = 10;
    parameter signed [31:0] K_WIDTH = 4;
    parameter signed [31:0] S_WIDTH = 4;
    parameter signed [31:0] C_WIDTH = 3;

    // Signals
    reg clk;
    reg rst;
    reg pool_en;
    reg pool_valid;
    reg [(MAP_H * MAP_W) - 1:0] feature_map;
    wire [((MAP_H / 2) * (MAP_W / 2)) - 1:0] output_map;
    wire done;

    // Instantiate DUT
    t01_ai_pool #(
        .MAP_H(MAP_H),
        .MAP_W(MAP_W),
        .K_WIDTH(K_WIDTH),
        .S_WIDTH(S_WIDTH),
        .C_WIDTH(C_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .pool_en(pool_en),
        .pool_valid(pool_valid),
        .feature_map(feature_map),
        .output_map(output_map),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to reset the DUT
    task reset_dut;
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;
    endtask

    // Task to apply feature map and start pooling
    task run_pooling;
        integer i;

        // Fill feature_map with sample data (random 0 or 1 for each bit)
        feature_map = 0;
        for (i = 0; i < (MAP_H * MAP_W); i = i + 1) begin
            feature_map[i] = $urandom_range(0, 1);  // Random 0 or 1
        end

        // Enable pooling
        pool_en = 1;
        pool_valid = 1;

        // Wait until done
        wait(done);
        $display("Pooling completed.");
        $display("Final output_map = %b", output_map);
        $display("Done signal = %b", done);

        // Optional: print output_map in 2D format
        print_output_map();
        print_input_map();
    endtask

    // Helper function to display input feature_map in 2D form
    function void print_input_map();
        integer r, c;
        $display("Input Feature Map (%0d x %0d):", MAP_H, MAP_W);
        for (r = 0; r < MAP_H; r = r + 1) begin
            for (c = 0; c < MAP_W; c = c + 1) begin
                $write("%b ", feature_map[r * MAP_W + c]);
            end
            $display("");
        end
    endfunction

    // Helper function to display output_map in 2D form
    function void print_output_map();
        integer r, c;
        $display("Output Map (%0d x %0d):", MAP_H/2, MAP_W/2);
        for (r = 0; r < MAP_H/2; r = r + 1) begin
            for (c = 0; c < MAP_W/2; c = c + 1) begin
                $write("%b ", output_map[r * (MAP_W/2) + c]);
            end
            $display("");
        end
    endfunction

      initial begin
    $dumpfile("waves/t01_ai_pool.vcd");
    $dumpvars(0, tb_t01_ai_pool);
  end

    // Initial block
    initial begin
        clk = 0;
        rst = 0;
        pool_en = 0;
        pool_valid = 0;
        feature_map = 0;

        $display("Starting testbench...");

        reset_dut();
        run_pooling();

        $display("Testbench finished.");
        $finish;
    end

endmodule
