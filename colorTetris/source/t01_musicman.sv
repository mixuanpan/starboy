module t01_musicman(
    input clk, rst, 
    input logic [15:0] lfsr,
    output logic square_out
);


    //for sample counter (~9Hz)
    logic [23:0] count, count_n;
    logic newclk_n;
    logic newclk;
    always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
            count <= '0;
       end else begin
            count <= count_n;
       end
    end

    always_comb begin
        count_n = count;
        if (count < 'd4500000 >> 0 ) begin
            count_n = count + 1;
            newclk = 0;
        end else begin
            count_n = '0;
            newclk = 1;
        end
    end

    //typedef for max_counts
    typedef enum logic [22:0] {
        E4 =  'd75843,
        B3 =  'd101238,
        C3 =  'd191113,
        D4 =  'd85131,
        A4 =  'd56818,
        F4 =  'd71586,
        A5 =  'd28409,
        G4 =  'd63776,
        A3 =  'd113636,
        C4 =  'd95556,
        AB3 = 'd120393,
        REST =  'b1
    } note_t;

    note_t current_note, next_note;
    logic [6:0] sample, sample_next;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            sample <= '0;
        end else if (newclk) begin
            sample <= sample + 1;
        end
    end

    //square wave oscilator284
    logic [22:0] square_count, square_count_next;
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            square_count <= 0;
        end else begin
            square_count <= square_count_next;
        end
    end

    always_comb begin
        square_out = 1;
        square_count_next = square_count + 1;
        if (square_count < max_count >> 2 + 0) begin
            square_out = 0;
        end else if (square_count > max_count >> 1 + 0) begin
            square_count_next = '0;
        end
    end

    logic [22:0] max_count;
    always_comb begin
        case (sample)
            0:  max_count = E4;
            1:  max_count = E4;
            2:  max_count = B3;
            3:  max_count = C4;
            4:  max_count = D4;
            5:  max_count = D4;
            6:  max_count = C4;
            7:  max_count = B3;
            8:  max_count = A3;
            9:  max_count = {7'b1111111,lfsr};
            10: max_count = A3;
            11: max_count = C4;
            12: max_count = E4;
            13: max_count = E4;
            14: max_count = D4;
            15: max_count = C4;
            16: max_count = B3;
            17: max_count = B3;
            18: max_count = B3;
            19: max_count = C4;
            20: max_count = D4;
            21: max_count = D4;
            22: max_count = E4;
            23: max_count = E4;
            24: max_count = C4;
            25: max_count = C4;
            26: max_count = A3;
            27: max_count = {7'b1111111,lfsr};
            28: max_count = A3;
            29: max_count = A3;
            30: max_count = A3;
            31: max_count = {7'b1111111,lfsr};
            32: max_count = {7'b1111111,lfsr};
            33: max_count = D4;
            34: max_count = D4;
            35: max_count = F4;
            36: max_count = A4;
            37: max_count = A4;
            38: max_count = G4;
            39: max_count = F4;
            40: max_count = E4;
            41: max_count = E4;
            42: max_count = E4;
            43: max_count = C4;
            44: max_count = E4;
            45: max_count = E4;
            46: max_count = D4;
            47: max_count = C4;
            48: max_count = B3;
            49: max_count = {7'b1111111,lfsr};
            50: max_count = B3;
            51: max_count = C4;
            52: max_count = D4;
            53: max_count = D4;
            54: max_count = E4;
            55: max_count = E4;
            56: max_count = C4;
            57: max_count = C4;
            58: max_count = A3;
            59: max_count = {7'b1111111,lfsr};
            60: max_count = A3;
            61: max_count = A3;
            62: max_count = A3;
            63: max_count = {7'b1111111,lfsr};
            64: max_count = E4;
            65: max_count = E4;
            66: max_count = E4;
            67: max_count = E4; 
            68: max_count = C4;
            69: max_count = C4;
            70: max_count = C4;
            71: max_count = C4;
            72: max_count = D4;
            73: max_count = D4;
            74: max_count = D4;
            75: max_count = D4;
            76: max_count = B3;
            77: max_count = B3;
            78: max_count = B3;
            79: max_count = B3;
            80: max_count = C4;
            81: max_count = C4;
            82: max_count = C4;
            83: max_count = C4;
            84: max_count = A3;
            85: max_count = A3;
            86: max_count = A3;
            87: max_count = A3;
            88: max_count = AB3;
            89: max_count = AB3;
            90: max_count = AB3;
            91: max_count = AB3;
            92: max_count = B3;
            93: max_count = B3;
            94: max_count = B3;
            95: max_count = B3;
            96: max_count = E4;
            97: max_count = E4;
            98: max_count = E4;
            99: max_count = E4;
            100: max_count = C4;
            101: max_count = C4;
            102: max_count = C4;
            103: max_count = C4;
            104: max_count = D4;
            105: max_count = D4;
            106: max_count = D4;
            107: max_count = D4;
            108: max_count = B3;
            109: max_count = B3;
            110: max_count = B3;
            111: max_count = B3;
            112: max_count = C4;
            113: max_count = C4;
            114: max_count = E4;
            115: max_count = E4;
            116: max_count = A3;
            117: max_count = A3;
            118: max_count = A3;
            119: max_count = A3;
            120: max_count = AB3;
            121: max_count = AB3;
            122: max_count = AB3;
            123: max_count = AB3;
            124: max_count = AB3; // REST (if sounds bad)
            125: max_count = AB3; // REST (if sounds bad)
            126: max_count = AB3; // REST (if sounds bad)
            127: max_count = AB3; // REST (if sounds bad)
            default:max_count = {7'b1111111,lfsr};
        endcase
    end
endmodule
