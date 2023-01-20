`timescale 1ns/1ps

module dequantizer (
    input                       clk_i,
    input                       rstn_i,

    input   [`PIXEL_BIT-1:0]    zig_veri_i,
    input   [`BLOCK_BIT-1:0]    zig_veri_row_i,
    input   [`BLOCK_BIT-1:0]    zig_veri_col_i,
    input                       zig_veri_gecerli_i,
    output                      zig_veri_hazir_o,

    output                      idct_veri_o,
    output  [`BLOCK_BIT-1:0]    idct_veri_row_o,
    output  [`BLOCK_BIT-1:0]    idct_veri_col_o,
    output                      idct_veri_gecerli_o,
    input                       idct_veri_hazir_i,
);

reg [`DQ_TABLO_BIT-1:0]  rom_nicem_tablosu_r [0:`BLOCK_AREA-1];

reg                      veri_hazir_cmb;

reg                      veri_r;
reg                      veri_ns;

reg  [`BLOCK_BIT-1:0]    veri_row_r;
reg  [`BLOCK_BIT-1:0]    veri_row_ns;

reg  [`BLOCK_BIT-1:0]    veri_col_r;
reg  [`BLOCK_BIT-1:0]    veri_col_ns;

reg                      veri_gecerli_r;
reg                      veri_gecerli_ns;

task quantize_init();
begin
    rom_nicem_tablosu_r['d0]   <= 8'd16;
    rom_nicem_tablosu_r['d1]   <= 8'd11;
    rom_nicem_tablosu_r['d2]   <= 8'd10;
    rom_nicem_tablosu_r['d3]   <= 8'd16;
    rom_nicem_tablosu_r['d4]   <= 8'd24;
    rom_nicem_tablosu_r['d5]   <= 8'd40;
    rom_nicem_tablosu_r['d6]   <= 8'd51;
    rom_nicem_tablosu_r['d7]   <= 8'd61;
    rom_nicem_tablosu_r['d8]   <= 8'd12;
    rom_nicem_tablosu_r['d9]   <= 8'd12;
    rom_nicem_tablosu_r['d10]  <= 8'd14; 
    rom_nicem_tablosu_r['d11]  <= 8'd19;
    rom_nicem_tablosu_r['d12]  <= 8'd26;
    rom_nicem_tablosu_r['d13]  <= 8'd58;
    rom_nicem_tablosu_r['d14]  <= 8'd60;
    rom_nicem_tablosu_r['d15]  <= 8'd55;
    rom_nicem_tablosu_r['d16]  <= 8'd14;
    rom_nicem_tablosu_r['d17]  <= 8'd13;
    rom_nicem_tablosu_r['d18]  <= 8'd16;
    rom_nicem_tablosu_r['d19]  <= 8'd24;
    rom_nicem_tablosu_r['d20]  <= 8'd40;
    rom_nicem_tablosu_r['d21]  <= 8'd57;
    rom_nicem_tablosu_r['d22]  <= 8'd69;
    rom_nicem_tablosu_r['d23]  <= 8'd56;
    rom_nicem_tablosu_r['d24]  <= 8'd14;
    rom_nicem_tablosu_r['d25]  <= 8'd17;
    rom_nicem_tablosu_r['d26]  <= 8'd22;
    rom_nicem_tablosu_r['d27]  <= 8'd29;
    rom_nicem_tablosu_r['d28]  <= 8'd51;
    rom_nicem_tablosu_r['d29]  <= 8'd87;
    rom_nicem_tablosu_r['d30]  <= 8'd80;
    rom_nicem_tablosu_r['d31]  <= 8'd62;
    rom_nicem_tablosu_r['d32]  <= 8'd18;
    rom_nicem_tablosu_r['d33]  <= 8'd22;
    rom_nicem_tablosu_r['d34]  <= 8'd37;
    rom_nicem_tablosu_r['d35]  <= 8'd56;
    rom_nicem_tablosu_r['d36]  <= 8'd68;
    rom_nicem_tablosu_r['d37]  <= 8'd109;
    rom_nicem_tablosu_r['d38]  <= 8'd103;
    rom_nicem_tablosu_r['d39]  <= 8'd77;
    rom_nicem_tablosu_r['d40]  <= 8'd24;
    rom_nicem_tablosu_r['d41]  <= 8'd35;
    rom_nicem_tablosu_r['d42]  <= 8'd55;
    rom_nicem_tablosu_r['d43]  <= 8'd64;
    rom_nicem_tablosu_r['d44]  <= 8'd81;
    rom_nicem_tablosu_r['d45]  <= 8'd104;
    rom_nicem_tablosu_r['d46]  <= 8'd113;
    rom_nicem_tablosu_r['d47]  <= 8'd92;
    rom_nicem_tablosu_r['d48]  <= 8'd49;
    rom_nicem_tablosu_r['d49]  <= 8'd64;
    rom_nicem_tablosu_r['d50]  <= 8'd78;
    rom_nicem_tablosu_r['d51]  <= 8'd87;
    rom_nicem_tablosu_r['d52]  <= 8'd103;
    rom_nicem_tablosu_r['d53]  <= 8'd121;
    rom_nicem_tablosu_r['d54]  <= 8'd120;
    rom_nicem_tablosu_r['d55]  <= 8'd101;
    rom_nicem_tablosu_r['d56]  <= 8'd72;
    rom_nicem_tablosu_r['d57]  <= 8'd92;
    rom_nicem_tablosu_r['d58]  <= 8'd95;
    rom_nicem_tablosu_r['d59]  <= 8'd98;
    rom_nicem_tablosu_r['d60]  <= 8'd112;
    rom_nicem_tablosu_r['d61]  <= 8'd100;
    rom_nicem_tablosu_r['d62]  <= 8'd103;
    rom_nicem_tablosu_r['d63]  <= 8'd99;
end
endtask


always @* begin
    veri_hazir_cmb = !(idct_veri_gecerli_o && !idct_veri_hazir_i);
    veri_ns = veri_r;
    veri_row_ns = veri_row_r;
    veri_col_ns = veri_col_r;
    veri_gecerli_ns = veri_gecerli_r;
    
    if (idct_veri_gecerli_o && idct_veri_hazir_i) begin
        veri_gecerli_ns = `LOW;
    end

    if (zig_veri_gecerli_i && zig_veri_hazir_o) begin
        veri_ns = zig_veri_i * rom_nicem_tablosu_r[zig_veri_row_i << 3 + zig_veri_col_i];
        veri_row_ns = zig_veri_row_i;
        veri_col_ns = zig_veri_col_i;
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
    end
    else begin
        veri_hazir_r <= veri_hazir_ns;
        veri_r <= veri_ns;
        veri_row_r <= veri_row_ns;
        veri_col_r <= veri_col_ns;
        veri_gecerli_r <= veri_gecerli_ns;
    end
end

assign idct_veri_hazir_o = veri_hazir_cmb;
assign idct_veri_o = veri_r;
assign idct_veri_row_o = veri_row_r;
assign idct_veri_col_o = veri_col_r;
assign idct_veri_gecerli_o = veri_gecerli_r;

endmodule