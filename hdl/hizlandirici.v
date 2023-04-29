`timescale 1ns/1ps
 
`include "sabitler.vh"

module hizlandirici (
    input clk_i,
    input rstn_i,

    input   [7:0]               h_veri_i,
    input                       h_gecerli_i,
    output                      h_hazir_o,

    output  [`PIXEL_BIT-1:0]    h_veri_o,
    output                      h_gecerli_o,
    input                       h_hazir_i

);

reg                     h_hazir_cmb;
assign h_hazir_o =      h_hazir_cmb;
reg [`PIXEL_BIT-1:0]    h_veri_cmb;
assign h_veri_o = h_veri_cmb;
reg                     h_gecerli_cmb;
assign h_gecerli_o= h_gecerli_cmb;

reg[`WB_BIT-1:0] m_veri_cmb;
reg m_gecerli_cmb;
wire m_hazir_w;

wire[`PIXEL_BIT-1:0] coz_veri_w;
wire coz_gecerli_w;

jpeg_coz cz(
    .clk_i(clk_i),
    .rstn_i(rstn_i),

    .m_veri_i(m_veri_cmb),
    .m_gecerli_i(m_gecerli_cmb),
    .m_hazir_o(m_hazir_w),

    .coz_veri_o(coz_veri_w),
    .coz_gecerli_o(coz_gecerli_w),
    .coz_hazir_i(h_hazir_i)
);

reg                   grv_basla_cmb;
reg                   grv_etkin_cmb;
reg[`PIXEL_BIT-1:0]   grv_pixel_cmb;
reg[2:0]              grv_gorev_cmb;
reg                   grv_stal_cmb;
wire                  grv_stal_w;
wire                  grv_etkin_w;
wire[`PIXEL_BIT-1:0]  grv_pixel_w;
gorev_birimi grv_brm (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .basla(grv_basla_cmb),
    .etkin_i(grv_etkin_cmb),
    .pixel_i(grv_pixel_cmb),
    .gorev_i(grv_gorev_cmb),
    .stal_i(grv_stal_cmb),
    .stal_o(grv_stal_w),
    .etkin_o(grv_etkin_w),
    .pixel_o(grv_pixel_w)
);

localparam grv1 = 16'hA010;
localparam grv2 = 16'hA020;
localparam grv3 = 16'hA030;
localparam grv4 = 16'hA040;
localparam grv5 = 16'hA050;
localparam grv6 = 16'hA060;

localparam BEKLE = 0;
localparam HAZIRLAN = 1;
localparam BASLA = 2;

reg[7:0] kontrol,kontrol_ns;

reg[1:0] durum,durum_ns;
reg ilk_etkin,ilk_etkin_ns;

reg[7:0] veri_sabit,veri_sabit_ns;

reg[6:0] say,say_ns;
reg say_i,say_i_ns;

reg grv_ctrl,grv_ctrl_ns;
always@* begin
    kontrol_ns = kontrol;
    ilk_etkin_ns = ilk_etkin;
    veri_sabit_ns = veri_sabit;
    durum_ns = durum;
    grv_ctrl_ns = grv_ctrl;
    say_ns = say;
    say_i_ns = say_i;
    h_hazir_cmb = 0;
    h_veri_cmb = 0;
    h_gecerli_cmb=0;
    m_veri_cmb=0;
    m_gecerli_cmb=0;
    grv_basla_cmb = 0;
    grv_etkin_cmb = 0;
    grv_pixel_cmb = 0;
    grv_gorev_cmb = 0;
    grv_stal_cmb = 0;
    case(durum)
        BEKLE: begin
            h_hazir_cmb = 1;
            if(h_gecerli_i && h_hazir_i) begin
                kontrol_ns = h_veri_i;
                durum_ns = ({kontrol,h_veri_i} == 16'hbacd) ? HAZIRLAN : BEKLE;
            end
        end
        HAZIRLAN: begin
            h_hazir_cmb = 1;
            if(h_gecerli_i && h_hazir_i) begin
                kontrol_ns = h_veri_i;
                case({kontrol,h_veri_i})
                    grv1 : begin
                        grv_basla_cmb = `HIGH;
                        grv_gorev_cmb = `GRV1_G_SXY;
                        durum_ns = BASLA;
                    end
                    grv2 : begin
                        grv_basla_cmb = `HIGH;
                        grv_gorev_cmb = `GRV2_G_L;
                        durum_ns = BASLA;
                    end
                    grv3 : begin
                        grv_basla_cmb = `HIGH;
                        grv_gorev_cmb = `GRV3_M;
                        durum_ns = BASLA;
                    end
                    grv4 : begin
                        grv_basla_cmb = `HIGH;
                        grv_gorev_cmb = `GRV4_H;
                        durum_ns = BASLA;
                        grv_ctrl_ns = 1;
                    end
                    grv5 : begin
                        grv_basla_cmb = `HIGH;
                        grv_gorev_cmb = `GRV5_HE;
                        durum_ns = BASLA;
                    end    
                    grv6 : begin
                        grv_basla_cmb = `HIGH;
                        grv_gorev_cmb = `GRV6_G2BW_E;
                        durum_ns = BASLA;
                    end
                endcase
            end    
        end
        BASLA: begin
            /*
            if((ilk_etkin == 0) && coz_gecerli_w ) begin
                ilk_etkin_ns = 1;
            end
            if(coz_gecerli_w) begin
                veri_sabit_ns = coz_veri_w;
            end
            grv_basla_cmb = `LOW;
            m_gecerli_cmb = h_gecerli_i;
            m_veri_cmb = h_veri_i;
            h_hazir_cmb = m_hazir_w;
            grv_stal_cmb = ((say == 30) ? `LOW : (ilk_etkin ? !coz_gecerli_w : `LOW)) || !h_hazir_i ;
            grv_etkin_cmb = (say==30) ? coz_gecerli_w : (ilk_etkin ? `HIGH : coz_gecerli_w);
            grv_pixel_cmb = coz_gecerli_w ? coz_veri_w : veri_sabit;
            h_veri_cmb = grv_pixel_w;
            h_gecerli_cmb =  grv_stal_cmb ? `LOW : grv_etkin_w;
            if(say_i != h_gecerli_cmb) begin
                say_ns = h_gecerli_cmb ? (say+1) : say ;
                say_i_ns = h_gecerli_cmb;
            end*/
            if((ilk_etkin == 0) && coz_gecerli_w ) begin
                ilk_etkin_ns = 1;
            end
            if(coz_gecerli_w) begin
                veri_sabit_ns = coz_veri_w;
            end
            grv_basla_cmb = `LOW;
            m_gecerli_cmb = h_gecerli_i;
            m_veri_cmb = h_veri_i;
            h_hazir_cmb = m_hazir_w;
            grv_stal_cmb = ((say == 30) ? `LOW : (ilk_etkin ? !coz_gecerli_w : `LOW)) || !h_hazir_i ;
            grv_etkin_cmb = (say==30) ? coz_gecerli_w : (ilk_etkin ? `HIGH : coz_gecerli_w);
            grv_pixel_cmb = coz_gecerli_w ? coz_veri_w : veri_sabit;
            h_veri_cmb = grv_pixel_w;
            h_gecerli_cmb =  grv_stal_cmb ? `LOW : grv_etkin_w;
            if(say_i != coz_gecerli_w) begin
                say_ns = coz_gecerli_w ? (say+1) : say ;
                say_i_ns = coz_gecerli_w;
            end
        end
    endcase
end

always@(posedge clk_i) begin
    if(!rstn_i) begin
        durum <= BEKLE;
        kontrol <= 0;
        ilk_etkin <= 0;
        veri_sabit <= 0;
        say <= 0;
        say_i <= 0;
        grv_ctrl <= 0;
    end else begin
        durum <= durum_ns;
        kontrol <= kontrol_ns;
        ilk_etkin <= ilk_etkin_ns;
        veri_sabit <= veri_sabit_ns;
        say <= say_ns;
        say_i <= say_i_ns;
        grv_ctrl <= grv_ctrl_ns;
    end
end

endmodule