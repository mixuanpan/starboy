/////////////////////////////////////////////////////////////////
// HEADER 
//
// Module : america
// Description : freedom
// 
//
/////////////////////////////////////////////////////////////////
module america  (
    input logic [9:0] x, y,
    output logic [2:0] shape_color
);

    logic in_canton;
    logic is_star;
always_comb begin
        // Determine if we're in the canton (blue field)
        in_canton = (x < 10'd256) && (y < 10'd160);
        
        // Simple star pattern - create stars at specific coordinates
        is_star = 1'b0;
        
        // Row 1 of stars (y around 20)
        if ((y >= 10'd18 && y <= 10'd22) && 
            ((x >= 10'd30 && x <= 10'd34) || (x >= 10'd70 && x <= 10'd74) || (x >= 10'd110 && x <= 10'd114) || 
             (x >= 10'd150 && x <= 10'd154) || (x >= 10'd190 && x <= 10'd194) || (x >= 10'd230 && x <= 10'd234))) begin
            is_star = 1'b1;
        end
        
        // Row 2 of stars (y around 40)
        if ((y >= 10'd38 && y <= 10'd42) && 
            ((x >= 10'd50 && x <= 10'd54) || (x >= 10'd90 && x <= 10'd94) || (x >= 10'd130 && x <= 10'd134) || 
             (x >= 10'd170 && x <= 10'd174) || (x >= 10'd210 && x <= 10'd214))) begin
            is_star = 1'b1;
        end
        
        // Row 3 of stars (y around 60)
        if ((y >= 10'd58 && y <= 10'd62) && 
            ((x >= 10'd30 && x <= 10'd34) || (x >= 10'd70 && x <= 10'd74) || (x >= 10'd110 && x <= 10'd114) || 
             (x >= 10'd150 && x <= 10'd154) || (x >= 10'd190 && x <= 10'd194) || (x >= 10'd230 && x <= 10'd234))) begin
            is_star = 1'b1;
        end
        
        // Row 4 of stars (y around 80)
        if ((y >= 10'd78 && y <= 10'd82) && 
            ((x >= 10'd50 && x <= 10'd54) || (x >= 10'd90 && x <= 10'd94) || (x >= 10'd130 && x <= 10'd134) || 
             (x >= 10'd170 && x <= 10'd174) || (x >= 10'd210 && x <= 10'd214))) begin
            is_star = 1'b1;
        end
        
        // Row 5 of stars (y around 100)
        if ((y >= 10'd98 && y <= 10'd102) && 
            ((x >= 10'd30 && x <= 10'd34) || (x >= 10'd70 && x <= 10'd74) || (x >= 10'd110 && x <= 10'd114) || 
             (x >= 10'd150 && x <= 10'd154) || (x >= 10'd190 && x <= 10'd194) || (x >= 10'd230 && x <= 10'd234))) begin
            is_star = 1'b1;
        end
        
        // Row 6 of stars (y around 120)
        if ((y >= 10'd118 && y <= 10'd122) && 
            ((x >= 10'd50 && x <= 10'd54) || (x >= 10'd90 && x <= 10'd94) || (x >= 10'd130 && x <= 10'd134) || 
             (x >= 10'd170 && x <= 10'd174) || (x >= 10'd210 && x <= 10'd214))) begin
            is_star = 1'b1;
        end
        
        // Row 7 of stars (y around 140)
        if ((y >= 10'd138 && y <= 10'd142) && 
            ((x >= 10'd30 && x <= 10'd34) || (x >= 10'd70 && x <= 10'd74) || (x >= 10'd110 && x <= 10'd114) || 
             (x >= 10'd150 && x <= 10'd154) || (x >= 10'd190 && x <= 10'd194) || (x >= 10'd230 && x <= 10'd234))) begin
            is_star = 1'b1;
        end
        
        // Assign colors based on position
        if (in_canton) begin
            if (is_star) begin
                shape_color = 3'b111; // White stars
            end else begin
                shape_color = 3'b001;  // Blue field
            end
        end else begin
            // Manual stripe drawing
            if ((y < 10'd37) ||                    // Stripe 1 - Red
                (y >= 10'd74 && y < 10'd111) ||    // Stripe 3 - Red  
                (y >= 10'd148 && y < 10'd185) ||   // Stripe 5 - Red
                (y >= 10'd222 && y < 10'd259) ||   // Stripe 7 - Red
                (y >= 10'd296 && y < 10'd333) ||   // Stripe 9 - Red
                (y >= 10'd370 && y < 10'd407) ||   // Stripe 11 - Red
                (y >= 10'd444)) begin              // Stripe 13 - Red
                shape_color = 3'b100;
            end else begin
                shape_color = 3'b111; // White stripes (2,4,6,8,10,12)
            end
        end
    end

endmodule