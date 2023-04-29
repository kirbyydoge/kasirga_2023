`timescale 1ns/1ps
 
`include "sabitler.vh"

module dequantizer (
    input                       clk_i,
    input                       rstn_i,

    input   [`HDATA_BIT-1:0]    zig_veri_i,
    input   [`BLOCK_BIT-1:0]    zig_veri_row_i,
    input   [`BLOCK_BIT-1:0]    zig_veri_col_i,
    input                       zig_veri_gecerli_i,
    input                       zig_blok_son_i,
    output                      zig_veri_hazir_o,

    output  [`Q_BIT-1:0]        idct_veri_o,
    output  [`BLOCK_BIT-1:0]    idct_veri_row_o,
    output  [`BLOCK_BIT-1:0]    idct_veri_col_o,
    output                      idct_veri_gecerli_o,
    output                      idct_blok_son_o,
    input                       idct_veri_hazir_i
);

reg [`DQ_TABLO_BIT-1:0]  rom_nicem_tablosu_r [0:`BLOCK_AREA-1];

reg                      veri_hazir_cmb;

reg  [`Q_BIT-1:0]        veri_r;
reg  [`Q_BIT-1:0]        veri_ns;

reg  [`BLOCK_BIT-1:0]    veri_row_r;
reg  [`BLOCK_BIT-1:0]    veri_row_ns;

reg  [`BLOCK_BIT-1:0]    veri_col_r;
reg  [`BLOCK_BIT-1:0]    veri_col_ns;

reg                      veri_gecerli_r;
reg                      veri_gecerli_ns;

reg                      blok_son_r;
reg                      blok_son_ns;

reg [`BLOCK_AREA_BIT-1:0] index_cmb;

task quantize_init();
begin
    rom_nicem_tablosu_r[6'd0]   <= 8'd16;
    rom_nicem_tablosu_r[6'd1]   <= 8'd11;
    rom_nicem_tablosu_r[6'd2]   <= 8'd10;
    rom_nicem_tablosu_r[6'd3]   <= 8'd16;
    rom_nicem_tablosu_r[6'd4]   <= 8'd24;
    rom_nicem_tablosu_r[6'd5]   <= 8'd40;
    rom_nicem_tablosu_r[6'd6]   <= 8'd51;
    rom_nicem_tablosu_r[6'd7]   <= 8'd61;
    rom_nicem_tablosu_r[6'd8]   <= 8'd12;
    rom_nicem_tablosu_r[6'd9]   <= 8'd12;
    rom_nicem_tablosu_r[6'd10]  <= 8'd14; 
    rom_nicem_tablosu_r[6'd11]  <= 8'd19;
    rom_nicem_tablosu_r[6'd12]  <= 8'd26;
    rom_nicem_tablosu_r[6'd13]  <= 8'd58;
    rom_nicem_tablosu_r[6'd14]  <= 8'd60;
    rom_nicem_tablosu_r[6'd15]  <= 8'd55;
    rom_nicem_tablosu_r[6'd16]  <= 8'd14;
    rom_nicem_tablosu_r[6'd17]  <= 8'd13;
    rom_nicem_tablosu_r[6'd18]  <= 8'd16;
    rom_nicem_tablosu_r[6'd19]  <= 8'd24;
    rom_nicem_tablosu_r[6'd20]  <= 8'd40;
    rom_nicem_tablosu_r[6'd21]  <= 8'd57;
    rom_nicem_tablosu_r[6'd22]  <= 8'd69;
    rom_nicem_tablosu_r[6'd23]  <= 8'd56;
    rom_nicem_tablosu_r[6'd24]  <= 8'd14;
    rom_nicem_tablosu_r[6'd25]  <= 8'd17;
    rom_nicem_tablosu_r[6'd26]  <= 8'd22;
    rom_nicem_tablosu_r[6'd27]  <= 8'd29;
    rom_nicem_tablosu_r[6'd28]  <= 8'd51;
    rom_nicem_tablosu_r[6'd29]  <= 8'd87;
    rom_nicem_tablosu_r[6'd30]  <= 8'd80;
    rom_nicem_tablosu_r[6'd31]  <= 8'd62;
    rom_nicem_tablosu_r[6'd32]  <= 8'd18;
    rom_nicem_tablosu_r[6'd33]  <= 8'd22;
    rom_nicem_tablosu_r[6'd34]  <= 8'd37;
    rom_nicem_tablosu_r[6'd35]  <= 8'd56;
    rom_nicem_tablosu_r[6'd36]  <= 8'd68;
    rom_nicem_tablosu_r[6'd37]  <= 8'd109;
    rom_nicem_tablosu_r[6'd38]  <= 8'd103;
    rom_nicem_tablosu_r[6'd39]  <= 8'd77;
    rom_nicem_tablosu_r[6'd40]  <= 8'd24;
    rom_nicem_tablosu_r[6'd41]  <= 8'd35;
    rom_nicem_tablosu_r[6'd42]  <= 8'd55;
    rom_nicem_tablosu_r[6'd43]  <= 8'd64;
    rom_nicem_tablosu_r[6'd44]  <= 8'd81;
    rom_nicem_tablosu_r[6'd45]  <= 8'd104;
    rom_nicem_tablosu_r[6'd46]  <= 8'd113;
    rom_nicem_tablosu_r[6'd47]  <= 8'd92;
    rom_nicem_tablosu_r[6'd48]  <= 8'd49;
    rom_nicem_tablosu_r[6'd49]  <= 8'd64;
    rom_nicem_tablosu_r[6'd50]  <= 8'd78;
    rom_nicem_tablosu_r[6'd51]  <= 8'd87;
    rom_nicem_tablosu_r[6'd52]  <= 8'd103;
    rom_nicem_tablosu_r[6'd53]  <= 8'd121;
    rom_nicem_tablosu_r[6'd54]  <= 8'd120;
    rom_nicem_tablosu_r[6'd55]  <= 8'd101;
    rom_nicem_tablosu_r[6'd56]  <= 8'd72;
    rom_nicem_tablosu_r[6'd57]  <= 8'd92;
    rom_nicem_tablosu_r[6'd58]  <= 8'd95;
    rom_nicem_tablosu_r[6'd59]  <= 8'd98;
    rom_nicem_tablosu_r[6'd60]  <= 8'd112;
    rom_nicem_tablosu_r[6'd61]  <= 8'd100;
    rom_nicem_tablosu_r[6'd62]  <= 8'd103;
    rom_nicem_tablosu_r[6'd63]  <= 8'd99;
end
endtask

always @* begin
    veri_hazir_cmb = !(idct_veri_gecerli_o && !idct_veri_hazir_i);
    veri_ns = veri_r;
    veri_row_ns = veri_row_r;
    veri_col_ns = veri_col_r;
    veri_gecerli_ns = veri_gecerli_r;
    blok_son_ns = blok_son_r;
    index_cmb = (zig_veri_row_i << 3) + zig_veri_col_i;

    if (idct_veri_gecerli_o && idct_veri_hazir_i) begin
        veri_gecerli_ns = `LOW;
    end

    if (zig_veri_gecerli_i && zig_veri_hazir_o) begin
        veri_ns = {`Q_BIT{1'b0}};
        veri_ns[`Q_INT] = $signed(zig_veri_i) * $signed(rom_nicem_tablosu_r[index_cmb]);
        veri_row_ns = zig_veri_row_i;
        veri_col_ns = zig_veri_col_i;
        blok_son_ns = zig_blok_son_i;
        veri_gecerli_ns = `HIGH;
    end

end

// TODO: Carpim modulu buraya baglanacak
always @(posedge clk_i) begin
    if (!rstn_i) begin
        veri_r <= 0;
        veri_row_r <= 0;
        veri_col_r <= 0;
        veri_gecerli_r <= 0;
        blok_son_r <= 0;
        quantize_init();
    end
    else begin
        veri_r <= veri_ns;
        veri_row_r <= veri_row_ns;
        veri_col_r <= veri_col_ns;
        veri_gecerli_r <= veri_gecerli_ns;
        blok_son_r <= blok_son_ns;
    end
end

assign zig_veri_hazir_o = veri_hazir_cmb;
assign idct_veri_o = veri_r;
assign idct_veri_row_o = veri_row_r;
assign idct_veri_col_o = veri_col_r;
assign idct_veri_gecerli_o = veri_gecerli_r;
assign idct_blok_son_o = blok_son_r;

endmodule