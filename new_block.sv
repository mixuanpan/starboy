`default_nettype none
// should be able to incorporate this in the main fsm file


/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : new_block 
// Description : Read in a random bew block 
// 
//
/////////////////////////////////////////////////////////////////

module new_block (
  input logic clk, rst, en, 
  output logic [2:0] block_o, 
  output logic [3:0] coordinate_o [3:0] // new block coordinates on top two rows 
);
  // use clock cycles to read through the blocks.mem file randomlly 
  logic [2:0] c_count, n_count;  
  logic [2:0] all_blocks [6:0]; // an array that stores the entire file 

  logic [2:0] block; 
  logic [3:0] coordinate [3:0]; 

  always_ff @(posedge clk, posedge rst) begin 
    if (rst) begin 
      c_count <= 0; 
    end else begin 
      c_count <= n_count; 
    end
  end

  // load in the random block only when en is high 
  always_comb begin 
    if (en) begin 
      block_o = block; 
      // coordinate_o = coordinate; 
    end else begin 
      block_o = 0;
      for (int i = 0; i < 4; i++) coordinate_o [i] = 0; // map the array to 0 
    end 
  end

  // read in the coordinates according to the block type  
  always_comb begin 
    
    if (c_count == 'd7) begin 
      n_count = 'd1; 
    end else begin 
      n_count = c_count + 'd1; // counting increments 
    end 

    // case(c_count) 
    //   3'b001: begin 
    //     coordinate = '{'{0, 0, 0, 0}, '{0, 1, 1, 0}, '{0, 0, 1, 1}, '{0, 0, 0, 0}}; // [][]
    //   end                                                                           //   [][]

    //   3'b010: begin 
    //     coordinate = '{'{0, 0, 0, 0}, '{0, 0, 1, 1}, '{0, 1, 1, 0}, '{0, 0, 0, 0}}; //   [][]
    //   end                                                                           // [][]

    //   3'b011: begin 
    //     coordinate = '{'{0, 0, 0, 0}, '{1, 1, 1, 1}, '{0, 0, 0, 0}, '{0, 0, 0, 0}}; // [][][][]
    //   end

    //   3'b100: begin 
    //     coordinate = '{'{0, 0, 0, 0}, '{0, 0, 1, 1}, '{0, 0, 1, 1}, '{0, 0, 0, 0}}; // [][]
    //   end                                                                           // [][]

    //   3'b101: begin 
    //     coordinate = '{'{0, 0, 0, 0}, '{0, 0, 1, 0}, '{0, 1, 1, 1}, '{0, 0, 0, 0}}; //   []
    //   end                                                                           // [][][]

    //   3'b110: begin 
    //     coordinate = '{'{0, 0, 0, 0}, '{0, 0, 0, 1}, '{0, 1, 1, 1}, '{0, 0, 0, 0}}; //     []
    //   end                                                                           // [][][]

    //   3'b111: begin 
    //     coordinate = '{'{0, 0, 0, 0}, '{0, 1, 0, 0}, '{0, 1, 1, 1}, '{0, 0, 0, 0}}; // []
    //   end                                                                           // [][][]

    //   default: begin // should never happen 
    //     coordinate = '{'{1, 1, 1, 1}, '{1, 1, 1, 1}, '{1, 1, 1, 1}, '{1, 1, 1, 1}}; // [][][][]
    //   end                                                                           // [][][][]
    // endcase
  end

endmodule