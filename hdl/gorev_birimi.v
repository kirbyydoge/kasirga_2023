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

evrisim_birimi eb0 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb0),
    .filtre_i(filtre_cmb0),
    .gaus_i(gaus_cmb0),
    .veri_etkin_i(veri_etkin_cmb0),
    .veri_i(veri_cmb0),
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

evrisim_birimi eb1 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb1),
    .filtre_i(filtre_cmb1),
    .gaus_i(gaus_cmb1),
    .veri_etkin_i(veri_etkin_cmb1),
    .veri_i(veri_cmb1),
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

evrisim_birimi eb2 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_cmb2),
    .filtre_i(filtre_cmb2),
    .gaus_i(gaus_cmb2),
    .veri_etkin_i(veri_etkin_cmb2),
    .veri_i(veri_cmb2),
    .veri_etkin_o(veri_etkin_w2),
    .veri_o(veri_w2)
);

reg[3:0] durum,durum_ns;

always@* begin

    if(basla) begin
        case(gorev_i)
            `GRV1_G_SXY: begin
                $display("%h\n",`GAUSIAN_FLTR);
                filtre_cmb0 = `GAUSIAN_FLTR;
                filtre_etkin_cmb0 = `HIGH;
                gaus_cmb0=1;
                filtre_cmb1 = `SOBEL_X_FLTR;
                filtre_etkin_cmb1 = `HIGH;
                gaus_cmb1=0;
                filtre_cmb2 = `SOBEL_Y_FLTR;
                filtre_etkin_cmb2 = `HIGH;
                gaus_cmb2=0;
                durum_ns = `GRV1_G_SXY+1;
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
    endcase

end

always@(posedge clk_i) begin
    if(!rstn_i) begin
        durum <= 0;
    end else begin
        durum <= durum_ns;
    end
end

endmodule