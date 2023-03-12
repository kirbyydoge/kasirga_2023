`timescale 1ns/1ps
 
`include "sabitler.vh"

module histogram_top (
    input                       clk_i,
    input                       rstn_i,
    input                       etkin_i,
    input  [`PIXEL_BIT-1:0]     pixel_i,
    output [`PIXEL_BIT-1:0]     pixel_o,
    output                      hazir_o
);

histogram_birimi hb (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .etkin_i(etkin_i),
    .pixel_i(pixel_i),
    
    .wr_en_o(wr_en_o),
    .addr_w_o(addr_w_o),
    .data_in_o(data_in_o),
    .rd_en_o(rd_en_o),
    .addr_r_o(addr_r_o),
    .data_out_i(data_out_w),
    .cdf_min_o(cdf_min_w),
    .valid_o(valid_w),
    .hazir_o(hazir_o)
);

reg                     wr_en_cmb;
reg [`PIXEL_BIT-1:0]    addr_w_cmb;
reg [16:0]              data_in_cmb;
reg                     rd_en_cmb;
reg [`PIXEL_BIT-1:0]    addr_r_cmb;
wire[16:0]              data_out_w;

sram_histogram memory (
    .clk0 (clk_i),
	.csb0 (wr_en_cmb),
	.addr0 (addr_w_cmb),
	.din0 (data_in_cmb),
	.clk1 (clk_i),
	.csb1 (rd_en_cmb),
    .addr1 (addr_r_cmb),
    .dout1 (data_out_w)
);

wire                    wr_en_o;
wire [`PIXEL_BIT-1:0]   addr_w_o;
wire [16:0]             data_in_o;
wire                    rd_en_o;
wire [`PIXEL_BIT-1:0]   addr_r_o;
wire                    hazir_o;
wire [16:0]             cdf_min_w;

localparam HB=0;
localparam HE=1;
reg sram_kontrol,sram_kontrol_ns;

reg [16:0] cdf_min_r,cdf_min_r_ns;
reg [255:0] valid_r,valid_r_ns;
wire valid_w;

reg [`PIXEL_BIT:0] rd_adres,rd_adres_ns;
reg he_etkin,he_etkin_ns;
reg[16:0] he_cdf,he_cdf_ns;

always@* begin
    rd_adres_ns=rd_adres;
    valid_r_ns = valid_r;
    cdf_min_r_ns = cdf_min_r;
    he_cdf_ns = he_cdf;
    he_etkin_ns = he_etkin;
    sram_kontrol_ns = sram_kontrol;
    if(etkin_i) begin
        sram_kontrol_ns = HB;
    end
    if(hazir_o) begin
        sram_kontrol_ns = HE;
        cdf_min_r_ns = cdf_min_w;
        valid_r_ns = valid_w;
        rd_adres_ns = 0;
    end
    case(sram_kontrol)
        HB: begin
            wr_en_cmb = wr_en_o;
            addr_w_cmb = addr_w_o;
            data_in_cmb = data_in_o;
            rd_en_cmb = rd_en_o;
            addr_r_cmb = addr_r_o;
        end
        HE: begin
            wr_en_cmb = `HIGH;
            addr_w_cmb = `LOW;
            data_in_cmb = `LOW;
            rd_en_cmb = `LOW;
            addr_r_cmb = rd_adres;
            if(rd_adres == 256) begin
                he_etkin_ns = `LOW;
                rd_adres_ns = 0;
                sram_kontrol_ns=HB;
            end
            if(rd_adres > 0 && rd_adres < 256) begin
                rd_adres_ns = rd_adres+1;
                he_etkin_ns = `HIGH;
                he_cdf_ns = he_cdf + data_out_w;
            end
            if(rd_adres == 0) begin
                he_etkin_ns = `HIGH;
                rd_adres_ns = rd_adres+1;
            end
        end
    endcase
end

always@(posedge clk_i) begin
    if(!rstn_i) begin
        sram_kontrol <= 0;
        cdf_min_r <= 0;
        valid_r <= 0;
        rd_adres <= 0;
        he_cdf <= 0;
        he_etkin <= 0;
    end else begin
        sram_kontrol <= sram_kontrol_ns;
        cdf_min_r <= cdf_min_r_ns;
        valid_r <= valid_r_ns;
        rd_adres <= rd_adres_ns;
        he_cdf <= he_cdf_ns;
        he_etkin <= he_etkin_ns;
    end
end

endmodule