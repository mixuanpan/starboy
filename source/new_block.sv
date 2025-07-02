`default_nettype none
module new_block (
  input logic clk, rst, 
  output logic coordinate [1:0][3:0] // new block coordinates on top two rows 
);
  // use clock cycles to read through the blocks.mem file randomlly 
  logic [2:0] block;
  logic c_count, n_count;  
  int all_blocks [2:0][6:0]; // an array that stores the entire file 

  initial begin 
    $readmemh("blocks.mem", all_blocks, 1, 7); 
  end

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      c_count <= 0; 
    end else begin 
      c_count <= n_count; 
    end
  end

  // assign the current count as the index to read the current line of all the blocks
  assign block = all_blocks[c_count]; 

  // read in the coordinates according to the block type  
  always_comb begin 
    n_count = c_count + 'd1; // counting increments 
    case(block) 
      3'b001: begin 
        coordinate = '{'{0, 1, 1, 0}, '{0, 0, 1, 1}}; // [][]
      end                                             //   [][] 

      3'b010: begin 
        coordinate = '{'{0, 0, 1, 1}, '{0, 1, 1, 0}}; //   [][]
      end                                             // [][]

      3'b011: begin 
        coordinate = '{'{1, 1, 1, 1}, '{0, 0, 0, 0}}; // [][][][]
      end

      3'b100: begin 
        coordinate = '{'{0, 0, 1, 1}, '{0, 0, 1, 1}}; // [][]
      end                                             // [][]

      3'b101: begin 
        coordinate = '{'{0, 0, 1, 0}, '{0, 1, 1, 1}}; //   []
      end                                             // [][][]

      3'b110: begin 
        coordinate = '{'{0, 0, 0, 1}, '{0, 1, 1, 1}}; //     []
      end                                             // [][][]

      3'b111: begin 
        coordinate = '{'{0, 1, 0, 0}, '{0, 1, 1, 1}}; // []
      end                                             // [][][]

      default: begin // should never happen 
        coordinate = '{'{1, 1, 1, 1}, '{1, 1, 1, 1}}; // [][][][]
      end                                             // [][][][]
    endcase
  end

endmodule