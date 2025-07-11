// module gridstore(
//     input logic [21:0][9:0] movement_array,
//     input logic [21:0][9:0] current_stored_array,
//     input logic finish,
//     output logic [21:0][9:0] next_stored_array
// );


// always_comb begin

//     if (finish) begin

//         next_stored_array = current_stored_array + movement_array;
//     end else begin
//         next_stored_array = current_stored_array;
//     end

//     end

// endmodule