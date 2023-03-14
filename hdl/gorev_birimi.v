`timescale 1ns/1ps
 
`include "sabitler.vh"

module gorev_birimi (
    input                       clk_i,
    input                       rstn_i,
    input                       basla,
    input                       etkin_i,
    input   [`PIXEL_BIT-1:0]    pixel_i,
    input   [`GRV_BIT-1:0]      gorev_i,
    output                      etkin_o,
    output  [`PIXEL_BIT-1:0]    pixel_o
);

reg etkin_cmb;
assign etkin_o = etkin_cmb;
reg [`PIXEL_BIT-1:0] pixel_cmb;
assign pixel_o = pixel_cmb;

reg filtre_etkin_cmb0;
reg [71:0] filtre_cmb0;
reg veri_etkin_cmb0;
reg [`PIXEL_BIT-1:0] veri_cmb0;
wire veri_etkin_w0;
wire [`PIXEL_BIT-1:0] veri_w0;
reg gaus_cmb0;
reg laplacian_cmb0;
reg[`PIXEL_BIT-1:0] laplacian_pixel_cmb0;
wire[7:0] laplacian_pixel_w0;
reg gr2bw_erosion_cmb0;
wire[71:0] medyan_w0;

evrisim_birimi eb0 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb0),
    .filtre_i(filtre_cmb0),
    .gaus_i(gaus_cmb0),
    .veri_etkin_i(veri_etkin_cmb0),
    .veri_i(veri_cmb0),
    .laplacian_i(laplacian_cmb0),
    .laplacian_pixel_i(laplacian_pixel_cmb0),
    .laplacian_pixel_o(laplacian_pixel_w0),
    .gr2bw_erosion_i(gr2bw_erosion_cmb0),
    .medyan_o(medyan_w0),
    .veri_etkin_o(veri_etkin_w0),
    .veri_o(veri_w0)
);

reg filtre_etkin_cmb1;
reg [71:0 ]filtre_cmb1;
reg veri_etkin_cmb1;
reg [`PIXEL_BIT-1:0] veri_cmb1;
wire veri_etkin_w1;
wire [`PIXEL_BIT-1:0] veri_w1;
reg gaus_cmb1;
reg laplacian_cmb1;
reg[`PIXEL_BIT-1:0] laplacian_pixel_cmb1;
wire[7:0] laplacian_pixel_w1;
reg gr2bw_erosion_cmb1;

evrisim_birimi eb1 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb1),
    .filtre_i(filtre_cmb1),
    .gaus_i(gaus_cmb1),
    .veri_etkin_i(veri_etkin_cmb1),
    .veri_i(veri_cmb1),
    .laplacian_i(laplacian_cmb1),
    .laplacian_pixel_i(laplacian_pixel_cmb1),
    .laplacian_pixel_o(laplacian_pixel_w1),
    .gr2bw_erosion_i(gr2bw_erosion_cmb1),
    .veri_etkin_o(veri_etkin_w1),
    .veri_o(veri_w1)
);

reg filtre_etkin_cmb2;
reg [71:0 ]filtre_cmb2;
reg veri_etkin_cmb2;
reg [`PIXEL_BIT-1:0] veri_cmb2;
wire veri_etkin_w2;
wire [`PIXEL_BIT-1:0] veri_w2;
reg gaus_cmb2;
reg laplacian_cmb2;
reg[`PIXEL_BIT-1:0] laplacian_pixel_cmb2;
wire[7:0] laplacian_pixel_w2;
reg gr2bw_erosion_cmb2;

evrisim_birimi eb2 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb2),
    .filtre_i(filtre_cmb2),
    .gaus_i(gaus_cmb2),
    .veri_etkin_i(veri_etkin_cmb2),
    .veri_i(veri_cmb2),
    .laplacian_i(laplacian_cmb2),
    .laplacian_pixel_i(laplacian_pixel_cmb2),
    .laplacian_pixel_o(laplacian_pixel_w2),
    .gr2bw_erosion_i(gr2bw_erosion_cmb2),
    .veri_etkin_o(veri_etkin_w2),
    .veri_o(veri_w2)
);

reg etkin_m_cmb;
reg [71:0] resim_m_cmb;
wire etkin_m_w;
wire [`PIXEL_BIT-1:0] pixel_m_w;

medyan_top mdyn (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .etkin_i(etkin_m_cmb),
    .resim_i(resim_m_cmb),
    .etkin_o(etkin_m_w),
    .pixel_o(pixel_m_w)
);

reg[3:0] durum,durum_ns;
reg[7:0] bellek [320:0];
reg[7:0] bellek_ns [320:0];
integer i;

always@* begin
    durum_ns = durum;
    for(i=0;i<320;i=i+1) begin
        bellek_ns[i+1] = bellek[i];
    end
    bellek_ns[0] = laplacian_pixel_w0;

    if(basla) begin
        case(gorev_i)
            `GRV1_G_SXY: begin
                
                filtre_cmb0 = `GAUSIAN_FLTR;
                filtre_etkin_cmb0 = `HIGH;
                gaus_cmb0=1;
                laplacian_cmb0=0;
                gr2bw_erosion_cmb0=0;
                
                filtre_cmb1 = `SOBEL_X_FLTR;
                filtre_etkin_cmb1 = `HIGH;
                gaus_cmb1=0;
                laplacian_cmb1=0;
                gr2bw_erosion_cmb1=0;

                filtre_cmb2 = `SOBEL_Y_FLTR;
                filtre_etkin_cmb2 = `HIGH;
                gaus_cmb2=0;
                laplacian_cmb2=0;
                gr2bw_erosion_cmb2=0;

                durum_ns = `GRV1_G_SXY+1;
            end
            `GRV2_G_L: begin

                filtre_cmb0 = `GAUSIAN_FLTR;
                filtre_etkin_cmb0 = `HIGH;
                gaus_cmb0=1;
                laplacian_cmb0=0;
                gr2bw_erosion_cmb0=0;

                filtre_cmb1 = `LAPLACIAN_FLTR;
                filtre_etkin_cmb1 = `HIGH;
                gaus_cmb1=0;
                laplacian_cmb1=1;
                gr2bw_erosion_cmb1=0;

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
                laplacian_cmb1=0;
                gr2bw_erosion_cmb0=0;

                durum_ns = `GRV3_M+1;
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
           
            filtre_etkin_cmb0 = `LOW;
            filtre_etkin_cmb1 = `LOW;
            filtre_etkin_cmb2 = `LOW;
        end
        `GRV2_G_L+1: begin

            veri_etkin_cmb0 = etkin_i;
            veri_cmb0 = pixel_i;

            veri_etkin_cmb1 = veri_etkin_w0;
            veri_cmb1 = veri_w0;
            laplacian_pixel_cmb1= bellek[320];
            
            etkin_cmb = veri_etkin_w1;
            pixel_cmb = veri_w1;

            filtre_etkin_cmb0 = `LOW;
            filtre_etkin_cmb1 = `LOW;
        end
        `GRV6_G2BW_E+1: begin

            veri_etkin_cmb0 = etkin_i;
            veri_cmb0 = pixel_i;

            etkin_cmb = veri_etkin_w0;
            pixel_cmb = veri_w0;

            filtre_etkin_cmb0 = `LOW;
        end
        `GRV3_M+1: begin
            veri_etkin_cmb0 = etkin_i;
            veri_cmb0 = pixel_i;

            etkin_m_cmb = veri_etkin_w0;
            resim_m_cmb = medyan_w0;

            etkin_cmb = etkin_m_w;  
            pixel_cmb = pixel_m_w;

            filtre_cmb0 = `LOW;  
        end
    endcase

end

always@(posedge clk_i) begin
    if(!rstn_i) begin
        durum <= 0;
        for(i=0;i<=320;i=i+1) begin
            bellek[i] <= 0;
        end
    end else begin
        durum <= durum_ns;
        for(i=0;i<=320;i=i+1) begin
            bellek[i] <= bellek_ns[i];
        end
    end
end

endmodule