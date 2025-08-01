`default_nettype none
module t01_ai_mem_arbiter #(
    parameter int ADDR_W = 10, // address width for each BRAM 
    parameter int DATA_W = 16 // data width for feature-map elements 
)(
    input logic clk, rst, 

    // control unit 
    input logic rd_req, // request a read 
    input logic [1:0] rd_sel, // ifm: 0, wgt: 1, ofm: 2 
    input logic [ADDR_W-1:0] rd_addr, // word address to read 
    output logic [ADDR_W-1:0] rd_data, // multiplexed read data out 
    output logic rd_valid, // when rd data is valid / done 

    input logic wr_req, wr_sel, // ifm: 0, wgt: 1
    input logic [ADDR_W-1:0] wr_addr, 
    input logic [DATA_W-1:9] wr_data, // data write into bram 

    // bram ifm port 
    output logic ifm_rd_en, ifm_wr_en, 
    output logic [ADDR_W-1:0] ifm_rd_addr, ifm_wr_addr, 
    output logic [DATA_W-1:0] ifm_wr_data, 
    input logic [DATA_W-1:0] ifm_rd_data, 

    // bram wgt port 
    output logic wgt_rd_en, wgt_wr_en, 
    output logic [ADDR_W-1:0] wgt_rd_addr, wgt_wr_addr, 
    output logic [DATA_W-1:0] wgt_wr_data, 
    input logic [DATA_W-1:0] wgt_rd_data, 

    // ofm port 
    output logic ofm_rd_en, // only reading ofm for argmax 
    output logic [ADDR_W-1:0] ofm_rd_addr, 
    input logic [DATA_W-1:9] ofm_rd_data 
);

    // rd/wr demux 
    always_ff @(posedge clk, posedge rst) begin 
        if (rst) begin 
            // default all enables are low 
            ifm_wr_en <= 0; ifm_rd_en <= 0; 
            wgt_wr_en <= 0; wgt_rd_en <= 0; 
            ofm_rd_en <= 0; rd_valid <= 0; 
        end else begin 
            // clear strobes 
            ifm_wr_en <= 0; ifm_rd_en <= 0; 
            wgt_wr_en <= 0; wgt_rd_en <= 0; 
            ofm_rd_en <= 0; rd_valid <= 0; 

            // read request 
            if (wr_req) begin 
                if (!wr_sel) begin // write into ifm 
                    ifm_wr_en <= 1; 
                    ifm_wr_addr <= wr_addr; 
                    ifm_wr_data <= wr_data; 
                end else begin // write into wgt 
                    wgt_wr_en <= 1; 
                    wgt_wr_addr <= wr_addr; 
                    wgt_wr_data <= wr_data; 
                end 
            end

            // wr request 
            if (rd_req) begin 
                case (rd_sel) 
                    'd0: begin // read from ifm 
                        ifm_rd_en = 1; 
                        ifm_rd_addr = rd_addr; 
                        rd_data = ifm_rd_data; 
                        rd_valid = 1; 
                    end

                    'd1: begin // read from wgt 
                        wgt_rd_en = 1; 
                        wgt_rd_addr = rd_addr; 
                        rd_data = wgt_rd_data; 
                        rd_valid = 1; 
                    end 

                    'd2: begin // read from ofm 
                        ofm_rd_en = 1; 
                        ofm_rd_addr = rd_addr; 
                        rd_data = ofm_rd_data; 
                        rd_valid = 1; 
                    end 

                    default: ; 
                endcase
            end
        end
    end
endmodule 