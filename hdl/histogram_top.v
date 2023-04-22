`timescale 1ns/1ps
 
`include "sabitler.vh"

module histogram_top (
    input                       clk_i,
    input                       rstn_i,
    input                       etkin_i,
    input  [`PIXEL_BIT-1:0]     pixel_i,
    input                       stal_i,
    output                      wr_en_s_o,
    output [`PIXEL_BIT-1:0]     addr_w_s_o,
    output [16:0]               data_in_s_o,
    output                      rd_en_s_o,
    output [`PIXEL_BIT-1:0]     addr_r_s_o,
    output [23:0]               pixel_o,
    input  [16:0]               data_out_s_i,
    output                      hazir_o
);

reg[1:0] hazir_r,hazir_r_ns;
assign hazir_o = hazir_r[1];
reg[23:0] pixel_r,pixel_r_ns;
assign pixel_o = pixel_r;


wire hazir_hb_w;

reg                     wr_en_cmb;
reg [`PIXEL_BIT-1:0]    addr_w_cmb;
reg [16:0]              data_in_cmb;
reg                     rd_en_cmb;
reg [`PIXEL_BIT-1:0]    addr_r_cmb;
wire[16:0]              data_out_w;

wire                    wr_en_o;
wire [`PIXEL_BIT-1:0]   addr_w_o;
wire [16:0]             data_in_o;
wire                    rd_en_o;
wire [`PIXEL_BIT-1:0]   addr_r_o;
wire [16:0]             cdf_min_w;

reg [16:0] cdf_min_r,cdf_min_r_ns;
reg [255:0] valid_r,valid_r_ns;
wire[255:0] valid_w;

histogram_birimi hb (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .etkin_i(etkin_i),
    .pixel_i(pixel_i), 
    .stal_i(stal_i),
    .wr_en_o(wr_en_o),
    .addr_w_o(addr_w_o),
    .data_in_o(data_in_o),
    .rd_en_o(rd_en_o),
    .addr_r_o(addr_r_o),
    .data_out_i(data_out_w),
    .cdf_min_o(cdf_min_w),
    .valid_o(valid_w),
    .hazir_o(hazir_hb_w)
);

reg [`PIXEL_BIT:0] rd_adres,rd_adres_ns;
reg[16:0] he_cdf_min,he_cdf_min_ns;
wire[7:0] he_pixel_cmb;
assign he_pixel_cmb = rd_adres - 2;
wire[7:0] he_sonuc_w;
wire he_hazir_w;

reg he_etkin,he_etkin_ns;
reg[16:0] he_cdf,he_cdf_ns;

histogram_esitleme he (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .etkin_i(he_etkin),
    .stal_i(stal_i),
    .cdf_min_i(he_cdf_min),
    .cdf_i(he_cdf),
    .sonuc_o(he_sonuc_w),
    .hazir_o(he_hazir_w)
);






assign wr_en_s_o = wr_en_cmb;
assign addr_w_s_o = addr_w_cmb;
assign data_in_s_o = data_in_cmb;
assign rd_en_s_o = rd_en_cmb;
assign addr_r_s_o = addr_r_cmb;
assign data_out_w = data_out_s_i;



localparam bekle=0;
localparam HB=1;
localparam HE=2;
reg[1:0] sram_kontrol,sram_kontrol_ns;




reg[7:0] he_adres,he_adres_ns;

reg wr_en_last;
reg[7:0] addr_w_last;
reg[16:0] data_in_last;
reg rd_en_last;
reg[7:0] addr_r_last;
reg he_hazir_last;
reg[7:0] he_adres_last;
reg[16:0] he_sonuc_last;
reg[7:0] rd_adres_last;

always@* begin
    rd_adres_ns = rd_adres;
    valid_r_ns = valid_r;
    cdf_min_r_ns = cdf_min_r;
    he_cdf_ns = he_cdf;
    he_etkin_ns = he_etkin;
    sram_kontrol_ns = sram_kontrol;
    he_cdf_min_ns = he_cdf_min;
    he_adres_ns = he_hazir_w ? he_adres +1 : he_adres;
    pixel_r_ns = pixel_r;
    hazir_r_ns = hazir_r << 1;
    wr_en_cmb = `HIGH;
    addr_w_cmb = `LOW;
    data_in_cmb = `LOW;
    rd_en_cmb = `HIGH;
    addr_r_cmb = `LOW;
    if(etkin_i) begin
        sram_kontrol_ns = HB;
    end
    if(hazir_hb_w) begin
        sram_kontrol_ns = HE;
        cdf_min_r_ns = cdf_min_w;
        valid_r_ns = valid_w;
        rd_adres_ns = 0;
        he_cdf_min_ns = cdf_min_w;
    end
    case(sram_kontrol)
        bekle: begin
            wr_en_cmb = `HIGH;
            addr_w_cmb =  `LOW;
            data_in_cmb = `LOW;
            rd_en_cmb = `HIGH;
            addr_r_cmb = `LOW;
            pixel_r_ns = data_out_w;    
        end
        HB: begin
            wr_en_cmb = stal_i ? wr_en_last : wr_en_o;
            addr_w_cmb = stal_i ? addr_w_last : addr_w_o;
            data_in_cmb = stal_i ? data_in_last : data_in_o;
            rd_en_cmb = stal_i ? rd_en_last : rd_en_o;
            addr_r_cmb = stal_i ? addr_r_last : addr_r_o;
        end
        HE: begin
            wr_en_cmb = stal_i ? !he_hazir_last : !he_hazir_w;
            addr_w_cmb = stal_i ? he_adres_last : he_adres;
            data_in_cmb = stal_i ? he_sonuc_last : he_sonuc_w;
            rd_en_cmb = `LOW;
            addr_r_cmb = stal_i ? rd_adres_last : rd_adres;
            if(he_adres == 255) begin
                sram_kontrol_ns=bekle;
                rd_adres_ns = 0;
            end
            
            if(rd_adres == 257) begin
                he_etkin_ns = `LOW;
                rd_adres_ns = rd_adres +1;;
                rd_en_cmb = `HIGH;
            end
            if(rd_adres == 256) begin
                he_etkin_ns = `HIGH;
                rd_adres_ns = rd_adres+1;
                he_cdf_ns = valid_r[rd_adres-1] ? (he_cdf + data_out_w) : he_cdf;
            end
            if(rd_adres > 0 && rd_adres < 256) begin
                rd_adres_ns = rd_adres+1;
                he_etkin_ns = `HIGH;
                he_cdf_ns = valid_r[rd_adres-1] ? (he_cdf + data_out_w) : he_cdf;
                hazir_r_ns = {hazir_r[0],1'b1};
            end
            if(rd_adres == 0 ) begin
                he_etkin_ns = `LOW;
                rd_adres_ns = rd_adres+1;
                hazir_r_ns = {hazir_r[0],1'b1};
            end
            
            pixel_r_ns = valid_r[rd_adres-1] ? data_out_w : 0;
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
        he_cdf_min <= 0;
        he_adres <= 0;
        hazir_r <= 0;
        pixel_r <= 0;
        wr_en_last <= 0;
        addr_w_last <= 0;
        data_in_last <= 0;
        rd_en_last <= 0;
        addr_r_last <= 0;
        he_hazir_last <= 0;
        he_adres_last <= 0;
        he_sonuc_last <= 0;
        rd_adres_last <= 0;

    end else begin
        if(!stal_i) begin
            sram_kontrol <= sram_kontrol_ns;
            cdf_min_r <= cdf_min_r_ns;
            valid_r <= valid_r_ns;
            rd_adres <= rd_adres_ns;
            he_cdf <= he_cdf_ns;
            he_etkin <= he_etkin_ns;
            he_cdf_min <= he_cdf_min_ns;
            he_adres <= he_adres_ns;
            hazir_r <= hazir_r_ns;
            pixel_r <= pixel_r_ns;
            wr_en_last <= wr_en_o;
            addr_w_last <= addr_w_o;
            data_in_last <= data_in_o;
            rd_en_last <= rd_en_o;
            addr_r_last <= addr_r_o;
            he_hazir_last <= he_hazir_w;
            he_adres_last <= he_adres;
            he_sonuc_last <= he_sonuc_w;
            rd_adres_last <= rd_adres;
        end
    end
end

endmodule