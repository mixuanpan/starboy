`default_nettype none

/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : tracker 
// Description : track and update individual frames of the grid 
// 
//
/////////////////////////////////////////////////////////////////

typedef enum logic [2:0] {
  RIGHT, 
  LEFT, 
  ROR, // ROTATE RIGHT
  ROL, // ROTATE LEFT 
  DOWN, 
} MOVE; 

// typedef enum logic [2:0] {} COLOR; // block color determined from block type
module tracker (
  input logic [4:0] state, // current state 
  input logic [4:0][4:0][2:0] frame_i, // input frame 
  input logic [2:0] color, // block color 
  output logic [4:0][4:0][2:0] frame_o, // output grame 
);

  logic check; // check if movement is available 

  always_comb begin 
    frame_o = frame_i; 
    check = 0; 
    case (state) 
      A1: begin 
        case (move) 
          RIGHT: begin 
            check = ! (frame_i[1][3] || frame_i[2][4]); 
            if (check) begin 
              frame_o[1][1] = 0; 
              frame_o[2][2] = 0; 
              frame_o[1][3] = color; 
              frame_o[2][4] = color; 
            end
          end

          LEFT: begin 
            check = ! (frame_i[1][1] || frame_i[2][2]); 
            if (check) begin 
              frame_o[1][3] = 0; 
              frame_o[2][4] = 0; 
              frame_o[1][1] = color; 
              frame_o[2][2] = color;
            end 
          end

          ROR: begin 
            check = ! (frame_i[0][2] || frame_i[2][1]); 
            if (check) begin 
              frame_o[2][2] = 0; 
              frame_o[2][3] = 0; 
              frame_o[0][2] = color; 
              frame_o[2][1] = color; 
            end
          end

          ROL: begin 
            check = ! (frame_i[0][2] || frame_i[2][1]); 
            if (check) begin 
              frame_o[2][2] = 0; 
              frame_o[2][3] = 0; 
              frame_o[0][2] = color; 
              frame_o[2][1] = color; 
            end
          end

          DOWN: begin 
            check = ! (frame_i[2][1] || frame_i[3][2] || frame_i[3][4]); 
            if (check) begin 
              frame_o[1][1] = 0; 
              frame_o[1][2] = 0; 
              frame_o[2][3] = 0; 
              frame_i[2][1] = color; 
              frame_o[3][2] = color; 
              frame_o[3][4] = color; 
            end
          end

          default: begin 
            frame_o = frame_i; 
          end
        endcase
      end

      default: begin 
        frame_o = frame_i; 
      end
    endcase
  end

endmodule