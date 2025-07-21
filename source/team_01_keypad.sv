`default_nettype none
module keypad (
    input   logic       clk, nRST,
    input   logic [3:0] rows,
    output  logic [3:0] cols,
    output  logic [7:0] data,
    output  logic       keyvalid, 
    input   logic       enable
);
    // Last button press' rows & columns
    logic [7:0] code;
    // Logic to assign columns
    logic [1:0] count;
    // Used to detect positive edge of a keypress
    logic       next_keyvalid;
    // States for a keypress
    typedef enum logic {IDLE, WAIT} StateType;
    StateType   state, next_state;

    // Valid Keypress Register
    always_ff @(posedge clk, negedge nRST) begin
        if (!nRST) begin
            state       <= IDLE;
            keyvalid    <= 1'b0;
        end else begin
            state       <= next_state;
            keyvalid    <= next_keyvalid;
        end
    end
    // Next Keypress logic
    always_comb begin
        next_keyvalid   = 1'b0;
        next_state      = state;
        case (state)
            IDLE: begin
                if (rows != 4'b0) begin
                    next_keyvalid   = 1'b1;
                    next_state      = WAIT;
                end
            end
            WAIT: begin
                next_keyvalid   = 1'b0;
                if (rows == 4'b0) begin
                    next_state  = IDLE;
                end
            end 
            default: begin
                next_keyvalid   = 1'b0;
                next_state      = IDLE;
            end
        endcase
    end

    // The row input will be all 0s unless button is pressed 
    // (=1, 0100 button in 3rd row was pressed)
    // The column to be scanned will have its input as 0 
    // (1101 to scan column 2)

    // Scanned Code Register
    always_ff @(posedge clk, negedge nRST) begin
        if (!nRST) begin
            count       <= 2'b00;
            code        <= 8'b0;
        end else begin
            if (rows != 4'b0000) begin
                code <= {rows, cols};
            end else if (enable) begin
                count <= (count == 2'b11) ? 2'b00 : (count + 1'b1);
            end
        end
    end

    // Column to Scan
    always @(count) begin
        case (count)
            2'b00: cols <= 4'b1110;
            2'b01: cols <= 4'b1101;
            2'b10: cols <= 4'b1011;
            2'b11: cols <= 4'b0111;
            default: cols <= 4'b1110; 
        endcase
    end

    // Translate Scanned Code to Button's ASCII value
    always_comb begin
        case (code)
            8'b0001_1110: data = "1";
            8'b0010_1110: data = "4";
            8'b0100_1110: data = "7";
            8'b1000_1110: data = "*";
            8'b0001_1101: data = "2";
            8'b0010_1101: data = "5";
            8'b0100_1101: data = "8";
            8'b1000_1101: data = "0";
            8'b0001_1011: data = "3";
            8'b0010_1011: data = "6";
            8'b0100_1011: data = "9";
            8'b1000_1011: data = "#";
            8'b0001_0111: data = "A";
            8'b0010_0111: data = "B";
            8'b0100_0111: data = "C";
            8'b1000_0111: data = "D";
            default: data = 8'b0;
        endcase
    end
endmodule