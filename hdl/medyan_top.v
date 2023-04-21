`timescale 1ns/1ps

`include "sabitler.vh"

module medyan_top (
    input                       clk_i,
    input                       rstn_i,
    input                       etkin_i,
    input[71:0]                 resim_i,
    input                       stal_i,
    output                      etkin_o,
    output[`PIXEL_BIT-1:0]      pixel_o
);

reg etkin_o_cmb;
assign etkin_o = etkin_o_cmb;

reg[`PIXEL_BIT-1:0] pixel_cmb;
assign pixel_o = pixel_cmb;

reg[63:0] resim_r[9:0];
reg[63:0] resim_ns[9:0];

reg[9:0] etkin_cmb,etkin_cmb1;
reg[`PIXEL_BIT-1:0] sayi_cmb [9:0];
wire[`PIXEL_BIT-1:0] medyan_w[9:0];
wire[9:0] hazir_w;
genvar j;

generate
    for(j=0;j<10;j=j+1)
    medyan_birimi a (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .etkin_i(etkin_cmb[j]),
        .stal_i(stal_i),
        .sayi_i(sayi_cmb[j]),
        .medyan_o(medyan_w[j]),
        .hazir_o(hazir_w[j])
    );
endgenerate

integer i;

reg[4:0] giris_sayac_r,giris_sayac_ns;
reg[4:0] cikis_sayac_r,cikis_sayac_ns;

always@* begin
    for(i=0;i<10;i=i+1) begin
        resim_ns[i] = resim_r[i];
        sayi_cmb[i]=0;
    end
    cikis_sayac_ns = cikis_sayac_r;
    giris_sayac_ns = giris_sayac_r;
    pixel_cmb = 0;
    etkin_cmb = etkin_cmb1;

    for(i=0;i<10;i=i+1) begin
        if(i==giris_sayac_r) begin
            resim_ns[giris_sayac_r] = resim_i[71:8];
            etkin_cmb[giris_sayac_r] = etkin_i;
            sayi_cmb[giris_sayac_r] = resim_i[7:0];
        end else begin
            resim_ns[i] = resim_r[i] >> 8;
            sayi_cmb[i] = resim_r[i][7:0];
        end
    end

    if(etkin_i) begin
        if(giris_sayac_r==9) begin
            giris_sayac_ns =0;
        end else begin
            giris_sayac_ns = giris_sayac_r + 1;
        end
    end

    if(|hazir_w) begin
        etkin_cmb[cikis_sayac_r]=`LOW;
        etkin_o_cmb = `HIGH;
        pixel_cmb = medyan_w[cikis_sayac_r];
        if(cikis_sayac_r==9) begin
            cikis_sayac_ns =0;
        end else begin
            cikis_sayac_ns = cikis_sayac_r + 1;
        end
    end else begin
        etkin_o_cmb = `LOW;
    end
end

always@(posedge clk_i) begin
    if(!rstn_i) begin
        for(i=0;i<10;i=i+1) begin
            resim_r[i] <= 0;
        end
        giris_sayac_r <= 0;
        cikis_sayac_r <= 0;
        etkin_cmb1 <= 0; 
    end else begin
        if(!stal_i) begin
            for(i=0;i<10;i=i+1) begin
                resim_r[i] <= resim_ns[i];
            end
            giris_sayac_r <= giris_sayac_ns;
            cikis_sayac_r <= cikis_sayac_ns;
            etkin_cmb1 <= etkin_cmb;
        end
    end
end
endmodule