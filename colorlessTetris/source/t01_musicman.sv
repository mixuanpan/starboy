module t01_musicman(
    input clk, rst, 
    input logic [15:0] lfsr,
    input logic gameover,
    output logic square_out
);

    localparam NEWCLK_PER = 4900000;
    //for sample counter/
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

    //comb logic for sample counter
    always_comb begin
        count_n = count;
        if (count < NEWCLK_PER >> 0 ) begin
            count_n = count + 1;
            newclk = 0;
        end else begin
            count_n = '0;
            newclk = 1;
        end
    end

    //typedef for oscillator max_counts
    typedef enum logic [22:0] {
        A5 =  'd28409,
        A4 =  'd56818,
        AB4 = 'd60196,
        G4 =  'd63776,
        F4 =  'd71586,
        E4 =  'd75843,
        D4 =  'd85131,
        C4 =  'd95556,
        B3 =  'd101238,
        A3 =  'd113636,
        AB3 = 'd120393,
        G3 =  'd127551,
        F3 =  'd142857,
        E3 =  'd151515,
        C3 =  'd191113,
        REST =  'b0
    } note_t;

    note_t current_note, next_note;
    logic [7:0] sample, sample_next;

    //sample counter
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            sample <= '0;
        end else if (gameover) begin
            sample <= '0;
        end else if (newclk) begin
            sample <= sample_next;

        end
    end

    //logic to repeat A theme twice before B theme
    always_comb begin
        sample_next = sample + 1;
        if (sample < 64) begin
            count_val = sample[6:0];
        end else begin
            count_val = sample[6:0] - 64;
        end

        if (sample == 128 + 63) begin
            sample_next = 0;
        end
    end

    //square wave oscilator
    logic [22:0] square_count1, square_count_next1;
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            square_count1 <= 0;
        end else if (gameover) begin
            square_count1 <= '0;
        end else begin
            square_count1 <= square_count_next1;
        end
    end
    logic [22:0] square_count2, square_count_next2;
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            square_count2 <= 0;
        end else if (gameover) begin
            square_count2 <= '0;
        end else begin
            square_count2 <= square_count_next2;

        end
    end

    //sound output logic
    always_comb begin
        square_out = 1;
        square_count_next1 = square_count1 + 1;
        square_count_next2 = square_count2 + 1;
        if (gameover) begin
            square_out = lfsr[0];
        end else if ((count >> 7) % 10 < 3) begin
            if (sample % 16 == 5) begin
                if (count < NEWCLK_PER / 4 || (count > NEWCLK_PER / 2) && (count < (NEWCLK_PER / 2 + NEWCLK_PER / 4))) begin
                    square_out = lfsr[0];
                end
            end else if ((count < NEWCLK_PER >> 2) && ((sample % 2 == 1) || (sample % 16 == 14))) begin
                square_out = lfsr[0];
            end
        end else begin
            if ((count >> 7) % 10 < 8) begin
                if (square_count1 < max_count1 >> 2 + 0) begin
                    // square_out = count % 2 == 1 ? 0 : 1;
                    square_out = 0;
                end else if (square_count1 > max_count1 >> 1 + 0) begin
                    square_count_next1 = '0;
                end
            end else begin
                if (square_count2 < max_count2 >> 2 + 0) begin
                    // square_out = count % 2 == 1 ? 0 : 1;
                    square_out = 0;
                end else if (square_count2 > max_count2 >> 1 + 0) begin
                    square_count_next2 = '0;
                end
            end
        end
    end

    //tetris song LUT
    logic [22:0] max_count1, max_count2;
    logic [6:0] count_val;
    always_comb begin
        max_count1 = REST;

        case (count_val)
            0:   {max_count1, max_count2} = {E4  , REST};
            1:   {max_count1, max_count2} = {E4  , REST};
            2:   {max_count1, max_count2} = {B3  , AB3 };
            3:   {max_count1, max_count2} = {C4  , REST};
            4:   {max_count1, max_count2} = {D4  , REST};
            5:   {max_count1, max_count2} = {D4  , REST};
            6:   {max_count1, max_count2} = {C4  , A3  };
            7:   {max_count1, max_count2} = {B3  , G3  };
            8:   {max_count1, max_count2} = {A3  , E3  };
            9:   {max_count1, max_count2} = {REST, REST};
            10:  {max_count1, max_count2} = {A3  , E3  };
            11:  {max_count1, max_count2} = {C4  , REST};
            12:  {max_count1, max_count2} = {E4  , REST};
            13:  {max_count1, max_count2} = {E4  , REST};
            14:  {max_count1, max_count2} = {D4  , REST};
            15:  {max_count1, max_count2} = {C4  , REST};
            16:  {max_count1, max_count2} = {B3  , AB3 };
            17:  {max_count1, max_count2} = {B3  , AB3 };
            18:  {max_count1, max_count2} = {B3  , AB3 };
            19:  {max_count1, max_count2} = {C4  , A3  };
            20:  {max_count1, max_count2} = {D4  , B3  };
            21:  {max_count1, max_count2} = {D4  , B3  };
            22:  {max_count1, max_count2} = {E4  , REST};
            23:  {max_count1, max_count2} = {E4  , REST};
            24:  {max_count1, max_count2} = {C4  , REST};
            25:  {max_count1, max_count2} = {C4  , REST};
            26:  {max_count1, max_count2} = {A3  , REST};
            27:  {max_count1, max_count2} = {REST, REST};
            28:  {max_count1, max_count2} = {A3  , REST};
            29:  {max_count1, max_count2} = {A3  , REST};
            30:  {max_count1, max_count2} = {A3  , REST};
            31:  {max_count1, max_count2} = {REST, REST};
            32:  {max_count1, max_count2} = {REST, REST};
            33:  {max_count1, max_count2} = {D4  , F3  };
            34:  {max_count1, max_count2} = {D4  , F3  };
            35:  {max_count1, max_count2} = {F4  , A3  };
            36:  {max_count1, max_count2} = {A4  , C4  };
            37:  {max_count1, max_count2} = {A4  , C4  };
            38:  {max_count1, max_count2} = {G4  , B3  };
            39:  {max_count1, max_count2} = {F4  , A3  };
            40:  {max_count1, max_count2} = {E4  , G3  };
            41:  {max_count1, max_count2} = {E4  , G3  };
            42:  {max_count1, max_count2} = {E4  , G3  };
            43:  {max_count1, max_count2} = {C4  , E3  };
            44:  {max_count1, max_count2} = {E4  , G3  };
            45:  {max_count1, max_count2} = {E4  , G3  };
            46:  {max_count1, max_count2} = {D4  , F3  };
            47:  {max_count1, max_count2} = {C4  , E3  };
            48:  {max_count1, max_count2} = {B3  , AB3 };
            49:  {max_count1, max_count2} = {REST, REST};
            50:  {max_count1, max_count2} = {B3  , AB3 };
            51:  {max_count1, max_count2} = {C4  , A3  };
            52:  {max_count1, max_count2} = {D4  , B3  };
            53:  {max_count1, max_count2} = {D4  , B3  };
            54:  {max_count1, max_count2} = {E4  , REST};
            55:  {max_count1, max_count2} = {E4  , REST};
            56:  {max_count1, max_count2} = {C4  , REST};
            57:  {max_count1, max_count2} = {C4  , REST};
            58:  {max_count1, max_count2} = {A3  , REST};
            59:  {max_count1, max_count2} = {REST, REST};
            60:  {max_count1, max_count2} = {A3  , REST};
            61:  {max_count1, max_count2} = {A3  , REST};
            62:  {max_count1, max_count2} = {A3  , REST};
            63:  {max_count1, max_count2} = {REST, REST};
            64:  {max_count1, max_count2} = {E4  , C4  };
            65:  {max_count1, max_count2} = {E4  , C4  };
            66:  {max_count1, max_count2} = {E4  , C4  };
            67:  {max_count1, max_count2} = {E4  , C4  }; 
            68:  {max_count1, max_count2} = {C4  , A3  };
            69:  {max_count1, max_count2} = {C4  , A3  };
            70:  {max_count1, max_count2} = {C4  , A3  };
            71:  {max_count1, max_count2} = {C4  , A3  };
            72:  {max_count1, max_count2} = {D4  , B3  };
            73:  {max_count1, max_count2} = {D4  , B3  };
            74:  {max_count1, max_count2} = {D4  , B3  };
            75:  {max_count1, max_count2} = {D4  , B3  };
            76:  {max_count1, max_count2} = {B3  , AB3 };
            77:  {max_count1, max_count2} = {B3  , AB3 };
            78:  {max_count1, max_count2} = {B3  , AB3 };
            79:  {max_count1, max_count2} = {B3  , AB3 };
            80:  {max_count1, max_count2} = {C4  , A3  };
            81:  {max_count1, max_count2} = {C4  , A3  };
            82:  {max_count1, max_count2} = {C4  , A3  };
            83:  {max_count1, max_count2} = {C4  , A3  };
            84:  {max_count1, max_count2} = {A3  , E3  };
            85:  {max_count1, max_count2} = {A3  , E3  };
            86:  {max_count1, max_count2} = {A3  , E3  };
            87:  {max_count1, max_count2} = {A3  , E3  };
            88:  {max_count1, max_count2} = {AB3 , E3  };
            89:  {max_count1, max_count2} = {AB3 , E3  };
            90:  {max_count1, max_count2} = {AB3 , E3  };
            91:  {max_count1, max_count2} = {AB3 , E3  };
            92:  {max_count1, max_count2} = {B3  , AB3 };
            93:  {max_count1, max_count2} = {B3  , AB3 };
            94:  {max_count1, max_count2} = {B3  , AB3 };
            95:  {max_count1, max_count2} = {B3  , AB3 };
            96:  {max_count1, max_count2} = {E4  , C4  };
            97:  {max_count1, max_count2} = {E4  , C4  };
            98:  {max_count1, max_count2} = {E4  , C4  };
            99:  {max_count1, max_count2} = {E4  , C4  };
            100: {max_count1, max_count2} = {C4  , A3  };
            101: {max_count1, max_count2} = {C4  , A3  };
            102: {max_count1, max_count2} = {C4  , A3  };
            103: {max_count1, max_count2} = {C4  , A3  };
            104: {max_count1, max_count2} = {D4  , B3  };
            105: {max_count1, max_count2} = {D4  , B3  };
            106: {max_count1, max_count2} = {D4  , B3  };
            107: {max_count1, max_count2} = {D4  , B3  };
            108: {max_count1, max_count2} = {B3  , AB3 };
            109: {max_count1, max_count2} = {B3  , AB3 };
            110: {max_count1, max_count2} = {B3  , AB3 };
            111: {max_count1, max_count2} = {B3  , AB3 };
            112: {max_count1, max_count2} = {C4  , A3  };
            113: {max_count1, max_count2} = {C4  , A3  };
            114: {max_count1, max_count2} = {E4  , C4  };
            115: {max_count1, max_count2} = {E4  , C4  };
            116: {max_count1, max_count2} = {A4  , E4  };
            117: {max_count1, max_count2} = {A4  , E4  };
            118: {max_count1, max_count2} = {A4  , E4  };
            119: {max_count1, max_count2} = {A4  , E4  };
            120: {max_count1, max_count2} = {AB4 , E4  };
            121: {max_count1, max_count2} = {AB4 , E4  };
            122: {max_count1, max_count2} = {AB4 , E4  };
            123: {max_count1, max_count2} = {AB4 , E4  };
            124: {max_count1, max_count2} = {AB4 , E4  }; // REST (if sounds bad)
            125: {max_count1, max_count2} = {AB4 , E4  }; // REST (if sounds bad)
            126: {max_count1, max_count2} = {AB4 , E4  }; // REST (if sounds bad)
            127: {max_count1, max_count2} = {REST, REST}; // REST (if sounds bad)
            default:max_count1 = REST;
        endcase
        end
endmodule