`timescale 1ns/1ps
 
`include "sabitler.vh"

module gorev_birimi (
    input                       clk_i,
    input                       rstn_i,
    input                       basla,
    input                       etkin_i,
    input   [`PIXEL_BIT-1:0]    pixel_i,
    input   [`GRV_BIT-1:0]      gorev_i,
    input                       stal_i,
    output                      stal_o,
    output                      etkin_o,
    output  [`PIXEL_BIT-1:0]    pixel_o
);

reg stal_cmb;
assign stal_o = stal_cmb;

reg etkin_cmb;
assign etkin_o = etkin_cmb;

reg [`PIXEL_BIT-1:0] pixel_cmb;
assign pixel_o = pixel_cmb;

reg filtre_etkin_cmb0;
reg [71:0] filtre_cmb0;
reg veri_etkin_cmb0;
reg [10:0] veri_cmb0;
wire veri_etkin_w0;
wire [10:0] veri_w0;
reg gaus_cmb0;
reg laplacian_cmb0;
reg[10:0] laplacian_pixel_cmb0;
wire[10:0] laplacian_pixel_w0;
reg gr2bw_erosion_cmb0;
wire[71:0] medyan_w0;
reg tasma_cmb0;

evrisim_birimi eb0 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb0),
    .filtre_i(filtre_cmb0),
    .gaus_i(gaus_cmb0),
    .veri_etkin_i(veri_etkin_cmb0),
    .veri_i(veri_cmb0),
    .stal_i(stal_i),
    .laplacian_i(laplacian_cmb0),
    .laplacian_pixel_i(laplacian_pixel_cmb0),
    .laplacian_pixel_o(laplacian_pixel_w0),
    .gr2bw_erosion_i(gr2bw_erosion_cmb0),
    .tasma_i(tasma_cmb0),
    .medyan_o(medyan_w0),
    .veri_etkin_o(veri_etkin_w0),
    .veri_o(veri_w0)
);

reg filtre_etkin_cmb1;
reg [71:0 ]filtre_cmb1;
reg veri_etkin_cmb1;
reg [10:0] veri_cmb1;
wire veri_etkin_w1;
wire [10:0] veri_w1;
reg gaus_cmb1;
reg laplacian_cmb1;
reg[10:0] laplacian_pixel_cmb1;
wire[10:0] laplacian_pixel_w1;
reg gr2bw_erosion_cmb1;
wire[71:0] medyan_w1;
reg tasma_cmb1;

evrisim_birimi eb1 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb1),
    .filtre_i(filtre_cmb1),
    .gaus_i(gaus_cmb1),
    .veri_etkin_i(veri_etkin_cmb1),
    .veri_i(veri_cmb1),
    .stal_i(stal_i),
    .laplacian_i(laplacian_cmb1),
    .laplacian_pixel_i(laplacian_pixel_cmb1),
    .laplacian_pixel_o(laplacian_pixel_w1),
    .gr2bw_erosion_i(gr2bw_erosion_cmb1),
    .tasma_i(tasma_cmb1),
    .medyan_o(medyan_w1),
    .veri_etkin_o(veri_etkin_w1),
    .veri_o(veri_w1)
);

reg filtre_etkin_cmb2;
reg [71:0 ]filtre_cmb2;
reg veri_etkin_cmb2;
reg [10:0] veri_cmb2;
wire veri_etkin_w2;
wire [10:0] veri_w2;
reg gaus_cmb2;
reg laplacian_cmb2;
reg[10:0] laplacian_pixel_cmb2;
wire[10:0] laplacian_pixel_w2;
reg gr2bw_erosion_cmb2;
wire[71:0] medyan_w2;
reg tasma_cmb2;

evrisim_birimi eb2 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb2),
    .filtre_i(filtre_cmb2),
    .gaus_i(gaus_cmb2),
    .veri_etkin_i(veri_etkin_cmb2),
    .veri_i(veri_cmb2),
    .stal_i(stal_i),
    .laplacian_i(laplacian_cmb2),
    .laplacian_pixel_i(laplacian_pixel_cmb2),
    .laplacian_pixel_o(laplacian_pixel_w2),
    .gr2bw_erosion_i(gr2bw_erosion_cmb2),
    .medyan_o(medyan_w2),
    .tasma_i(tasma_cmb2),
    .veri_etkin_o(veri_etkin_w2),
    .veri_o(veri_w2)
);

reg etkin_m_cmb;
reg [71:0] resim_m_cmb;
wire etkin_m_w;
wire [7:0] pixel_m_w;

medyan_top mdyn (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .etkin_i(etkin_m_cmb),
    .resim_i(resim_m_cmb),
    .stal_i(stal_i),
    .etkin_o(etkin_m_w),
    .pixel_o(pixel_m_w)
);

reg[1:0] h_sayac,h_sayac_ns;

reg etkin_h_cmb;
reg[7:0] pixel_h_cmb;
wire wr_en_h_w;
wire[7:0] addr_w_h_w;
wire[16:0] data_in_h_w;
wire rd_en_h_w;
wire[7:0] addr_r_h_w;
reg [16:0] data_out_h_cmb;
wire[23:0] pixel_h_w;
wire    hazir_h_w;

histogram_top ht (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .etkin_i(etkin_h_cmb),
    .pixel_i(pixel_h_cmb),
    .stal_i(stal_i || stal_cmb),
    .wr_en_s_o(wr_en_h_w),
    .addr_w_s_o(addr_w_h_w),
    .data_in_s_o(data_in_h_w),
    .rd_en_s_o(rd_en_h_w),
    .addr_r_s_o(addr_r_h_w),
    .pixel_o(pixel_h_w),
    .data_out_s_i(data_out_h_cmb),
    .hazir_o(hazir_h_w)
);


reg wr_en_s_cmb;
reg[7:0] addr_w_s_cmb;
reg[16:0] data_in_s_cmb;
reg rd_en_s_cmb;
reg[7:0] addr_r_s_cmb;
wire[16:0] data_out_s_w;

sram_histogram memory (
    .clk0 (clk_i),
	.csb0 (wr_en_s_cmb),
	.addr0 (addr_w_s_cmb),
	.din0 (data_in_s_cmb),
	.clk1 (clk_i),
	.csb1 (rd_en_s_cmb),
    .addr1 (addr_r_s_cmb),
    .dout1 (data_out_s_w)
);


reg[1:0] he_o_etkin, he_o_etkin_ns;
reg[7:0] he_o_pixel, he_o_pixel_ns;
reg h_basla,h_basla_ns;
reg[3:0] durum,durum_ns;
integer i;

always@* begin
    h_basla_ns = h_basla;
    durum_ns = durum;
    filtre_etkin_cmb0 = 0;
    filtre_etkin_cmb1 = 0;
    filtre_etkin_cmb2 = 0;
    filtre_cmb0 = 0;
    filtre_cmb1 = 0;
    filtre_cmb2 = 0;
    veri_etkin_cmb0 = 0;
    veri_etkin_cmb1 = 0;
    veri_etkin_cmb2 = 0;
    veri_cmb0 = 0;
    veri_cmb1 = 0;
    veri_cmb2 = 0;
    gaus_cmb0 = 0;
    gaus_cmb1 = 0;
    gaus_cmb2 = 0;
    laplacian_cmb0 = 0;
    laplacian_cmb1 = 0;
    laplacian_cmb2 = 0;
    gr2bw_erosion_cmb0 = 0;
    gr2bw_erosion_cmb1 = 0;
    gr2bw_erosion_cmb2 = 0;
    laplacian_pixel_cmb0 = 0;
    laplacian_pixel_cmb1 = 0;
    laplacian_pixel_cmb2 = 0;
    etkin_cmb = 0;
    pixel_cmb = 0;
    etkin_m_cmb = 0;
    resim_m_cmb = 0;
    he_o_etkin_ns = he_o_etkin;
    he_o_pixel_ns = he_o_pixel;
    etkin_h_cmb = 0;
    pixel_h_cmb = 0;
    data_out_h_cmb = 0;
    wr_en_s_cmb = 1;
    addr_w_s_cmb = 0;
    data_in_s_cmb = 0;
    rd_en_s_cmb = 1;
    addr_r_s_cmb = 0;
    h_sayac_ns = h_sayac ==2 ? 0 : h_sayac + 1;
    stal_cmb =0;
    tasma_cmb0=0;
    tasma_cmb1=0;
    tasma_cmb2=0;

    if(basla) begin
        case(gorev_i)
            `GRV1_G_SXY: begin
                
                filtre_cmb0 = `GAUSIAN_FLTR;
                filtre_etkin_cmb0 = `HIGH;
                gaus_cmb0=1;
                laplacian_cmb0=0;
                gr2bw_erosion_cmb0=0;
                tasma_cmb0=0;
                
                filtre_cmb1 = `SOBEL_X_FLTR;
                filtre_etkin_cmb1 = `HIGH;
                gaus_cmb1=0;
                laplacian_cmb1=0;
                gr2bw_erosion_cmb1=0;
                tasma_cmb1=0;


                filtre_cmb2 = `SOBEL_Y_FLTR;
                filtre_etkin_cmb2 = `HIGH;
                gaus_cmb2=0;
                laplacian_cmb2=0;
                gr2bw_erosion_cmb2=0;
                tasma_cmb2=1;

                durum_ns = `GRV1_G_SXY+1;
            end
            `GRV2_G_L: begin

                filtre_cmb0 = `GAUSIAN_FLTR;
                filtre_etkin_cmb0 = `HIGH;
                gaus_cmb0=1;
                laplacian_cmb0=0;
                gr2bw_erosion_cmb0=0;
                tasma_cmb0=0;

                filtre_cmb1 = `LAPLACIAN_FLTR;
                filtre_etkin_cmb1 = `HIGH;
                gaus_cmb1=0;
                laplacian_cmb1=1;
                gr2bw_erosion_cmb1=0;
                tasma_cmb1=0;

                filtre_cmb2 = `NON_FLTR;
                filtre_etkin_cmb2 = `HIGH;
                gaus_cmb2=0;
                laplacian_cmb2=0;
                gr2bw_erosion_cmb2=0;
                tasma_cmb2=0;

                durum_ns = `GRV2_G_L+1;
            end
            `GRV6_G2BW_E: begin

                filtre_cmb0 = `NON_FLTR;
                filtre_etkin_cmb0= `HIGH;
                gaus_cmb0=0;
                laplacian_cmb1=0;
                gr2bw_erosion_cmb0=1;

                durum_ns = `GRV6_G2BW_E+1;

            end
            `GRV3_M: begin
                filtre_cmb0 = `NON_FLTR;
                filtre_etkin_cmb0= `HIGH;
                gaus_cmb0=0;
                laplacian_cmb0=0;
                gr2bw_erosion_cmb0=0;
                tasma_cmb0=0;

                durum_ns = `GRV3_M+1;
            end
            `GRV4_H: begin
                durum_ns = `GRV4_H+1;
            end
            `GRV5_HE: begin
                durum_ns = `GRV5_HE+1;
            end
        endcase
    end
    case(durum)
        `GRV1_G_SXY+1: begin

            veri_etkin_cmb0 = etkin_i;
            veri_cmb0 = pixel_i;

            veri_etkin_cmb1 = veri_etkin_w0;
            veri_cmb1 = veri_w0;
           
            veri_etkin_cmb2 = veri_etkin_w1;
            veri_cmb2 = veri_w1;
           
            etkin_cmb = veri_etkin_w2;
            pixel_cmb = veri_w2;

            gaus_cmb0=1;
            laplacian_cmb0=0;
            gr2bw_erosion_cmb0=0;

            gaus_cmb1=0;
            laplacian_cmb1=0;
            gr2bw_erosion_cmb1=0;

            gaus_cmb2=0;
            laplacian_cmb2=0;
            gr2bw_erosion_cmb2=0;

            gaus_cmb0=1;
            laplacian_cmb0=0;
            gr2bw_erosion_cmb0=0;

            gaus_cmb1=0;
            laplacian_cmb1=0;
            gr2bw_erosion_cmb1=0;

            gaus_cmb2=0;
            laplacian_cmb2=0;
            gr2bw_erosion_cmb2=0;
           
            filtre_etkin_cmb0 = `LOW;
            filtre_etkin_cmb1 = `LOW;
            filtre_etkin_cmb2 = `LOW;
        end
        `GRV2_G_L+1: begin

            veri_etkin_cmb0 = etkin_i;
            veri_cmb0 = pixel_i;

            veri_etkin_cmb2 = veri_etkin_w0;
            veri_cmb2 = laplacian_pixel_w0;

            veri_etkin_cmb1 = veri_etkin_w0;
            veri_cmb1 = veri_w0;
            laplacian_pixel_cmb1= laplacian_pixel_w2;
            
            etkin_cmb = veri_etkin_w1;
            pixel_cmb = veri_w1;

            gaus_cmb0=1;
            laplacian_cmb0=0;
            gr2bw_erosion_cmb0=0;

            gaus_cmb1=0;
            laplacian_cmb1=1;
            gr2bw_erosion_cmb1=0;

            gaus_cmb2=0;
            laplacian_cmb2=0;
            gr2bw_erosion_cmb2=0;

            filtre_etkin_cmb0 = `LOW;
            filtre_etkin_cmb1 = `LOW;
            filtre_etkin_cmb2 = `LOW;
        end
        `GRV6_G2BW_E+1: begin

            veri_etkin_cmb0 = etkin_i;
            veri_cmb0 = pixel_i;

            etkin_cmb = veri_etkin_w0;
            pixel_cmb = veri_w0;

            gaus_cmb0=0;
            laplacian_cmb1=0;
            gr2bw_erosion_cmb0=1;

            gaus_cmb0=0;
            laplacian_cmb1=0;
            gr2bw_erosion_cmb0=1;

            filtre_etkin_cmb0 = `LOW;
        end
        `GRV3_M+1: begin
            veri_etkin_cmb0 = etkin_i;
            veri_cmb0 = pixel_i;

            etkin_m_cmb = veri_etkin_w0;
            resim_m_cmb = medyan_w0;

            etkin_cmb = etkin_m_w;  
            pixel_cmb = pixel_m_w;

            gaus_cmb0=0;
            laplacian_cmb0=0;
            gr2bw_erosion_cmb0=0;
            tasma_cmb0=0;

            filtre_cmb0 = `LOW;  
        end
        `GRV4_H+1: begin
            etkin_h_cmb = etkin_i;
            pixel_h_cmb = pixel_i;
            etkin_cmb = hazir_h_w;
            pixel_cmb = pixel_h_w[h_sayac*8+:8];
            wr_en_s_cmb = wr_en_h_w;
            addr_w_s_cmb = addr_w_h_w;
            data_in_s_cmb = data_in_h_w;
            rd_en_s_cmb = rd_en_h_w;
            addr_r_s_cmb = addr_r_h_w;
            data_out_h_cmb = data_out_s_w;
            if(hazir_h_w) begin
                h_basla_ns = 1;
            end
            if(hazir_h_w || h_basla) begin
            if(h_sayac==0) begin
                stal_cmb = 1;
            end
            if(h_sayac==1) begin
                stal_cmb = 1;
            end
            if(h_sayac==2) begin
                stal_cmb = 0;
            end
            end
        end
        `GRV5_HE+1: begin
            wr_en_s_cmb= `HIGH;
            addr_w_s_cmb = `LOW;
            data_in_s_cmb = `LOW;
            rd_en_s_cmb = !etkin_i;
            addr_r_s_cmb = pixel_i;
            pixel_cmb = he_o_pixel;
            he_o_etkin_ns = {he_o_etkin[0],etkin_i};
            etkin_cmb = he_o_etkin[1];
            he_o_pixel_ns = data_out_s_w;
        end
    endcase

end

always@(posedge clk_i) begin
    if(!rstn_i) begin
        durum <= 0;
        he_o_etkin <= 0;
        he_o_pixel <= 0;
        h_sayac <= 2;
        h_basla <=0;
    end else begin
        if(!stal_i) begin
            durum <= durum_ns;
            he_o_etkin <= he_o_etkin_ns;
            he_o_pixel <= he_o_pixel_ns;
            h_sayac <= h_sayac_ns;
            h_basla <= h_basla_ns;
        end
    end
end

endmodule