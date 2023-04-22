`timescale 1ns/1ps

`include "sabitler.vh"

module zigzag_normalizer (
    input                       clk_i,
    input                       rstn_i,

    input                       blok_son_i,

    input   [`RUN_BIT-1:0]      hd_run_i,
    input   [`HDATA_BIT-1:0]    hd_veri_i,
    input                       hd_gecerli_i,
    output                      hd_hazir_o,

    output  [`HDATA_BIT-1:0]    ct_veri_o,
    output  [`BLOCK_BIT-1:0]    ct_row_o,
    output  [`BLOCK_BIT-1:0]    ct_col_o,
    output                      ct_gecerli_o,
    input                       ct_hazir_i
);

reg [`BLOCK_AREA_BIT-1:0] rom_zigzag_order_r [0:`BLOCK_AREA-1];

reg [`BLOCK_AREA_BIT-1:0] ptr_block_r;
reg [`BLOCK_AREA_BIT-1:0] ptr_block_ns;

reg [`HDATA_BIT-1:0] ct_veri_r;
reg [`HDATA_BIT-1:0] ct_veri_ns;

reg [`BLOCK_BIT-1:0] ct_row_r;
reg [`BLOCK_BIT-1:0] ct_row_ns;

reg [`BLOCK_BIT-1:0] ct_col_r;
reg [`BLOCK_BIT-1:0] ct_col_ns;

reg                  ct_gecerli_r;
reg                  ct_gecerli_ns;

reg [`RUN_BIT-1:0]   buf_run_r;
reg [`RUN_BIT-1:0]   buf_run_ns;

reg [`HDATA_BIT-1:0] buf_data_r;
reg [`HDATA_BIT-1:0] buf_data_ns;

reg                  buf_gecerli_r;
reg                  buf_gecerli_ns;

localparam           HAZIR = 'd0;
localparam           BEKLE = 'd1;

reg                  durum_r;
reg                  durum_ns;

reg                  blk_flag_r;
reg                  blk_flag_ns;

reg                  hd_hazir_cmb;

task zigzag_init();
begin
    rom_zigzag_order_r['d0]   <= 6'd0;
    rom_zigzag_order_r['d1]   <= 6'd1;
    rom_zigzag_order_r['d2]   <= 6'd8;
    rom_zigzag_order_r['d3]   <= 6'd16;
    rom_zigzag_order_r['d4]   <= 6'd9;
    rom_zigzag_order_r['d5]   <= 6'd2;
    rom_zigzag_order_r['d6]   <= 6'd3;
    rom_zigzag_order_r['d7]   <= 6'd10;
    rom_zigzag_order_r['d8]   <= 6'd17;
    rom_zigzag_order_r['d9]   <= 6'd24;
    rom_zigzag_order_r['d10]  <= 6'd32; 
    rom_zigzag_order_r['d11]  <= 6'd25;
    rom_zigzag_order_r['d12]  <= 6'd18;
    rom_zigzag_order_r['d13]  <= 6'd11;
    rom_zigzag_order_r['d14]  <= 6'd4;
    rom_zigzag_order_r['d15]  <= 6'd5;
    rom_zigzag_order_r['d16]  <= 6'd12;
    rom_zigzag_order_r['d17]  <= 6'd19;
    rom_zigzag_order_r['d18]  <= 6'd26;
    rom_zigzag_order_r['d19]  <= 6'd33;
    rom_zigzag_order_r['d20]  <= 6'd40;
    rom_zigzag_order_r['d21]  <= 6'd48;
    rom_zigzag_order_r['d22]  <= 6'd41;
    rom_zigzag_order_r['d23]  <= 6'd34;
    rom_zigzag_order_r['d24]  <= 6'd27;
    rom_zigzag_order_r['d25]  <= 6'd20;
    rom_zigzag_order_r['d26]  <= 6'd13;
    rom_zigzag_order_r['d27]  <= 6'd6;
    rom_zigzag_order_r['d28]  <= 6'd7;
    rom_zigzag_order_r['d29]  <= 6'd14;
    rom_zigzag_order_r['d30]  <= 6'd21;
    rom_zigzag_order_r['d31]  <= 6'd28;
    rom_zigzag_order_r['d32]  <= 6'd35;
    rom_zigzag_order_r['d33]  <= 6'd42;
    rom_zigzag_order_r['d34]  <= 6'd49;
    rom_zigzag_order_r['d35]  <= 6'd56;
    rom_zigzag_order_r['d36]  <= 6'd57;
    rom_zigzag_order_r['d37]  <= 6'd50;
    rom_zigzag_order_r['d38]  <= 6'd43;
    rom_zigzag_order_r['d39]  <= 6'd36;
    rom_zigzag_order_r['d40]  <= 6'd29;
    rom_zigzag_order_r['d41]  <= 6'd22;
    rom_zigzag_order_r['d42]  <= 6'd15;
    rom_zigzag_order_r['d43]  <= 6'd23;
    rom_zigzag_order_r['d44]  <= 6'd30;
    rom_zigzag_order_r['d45]  <= 6'd37;
    rom_zigzag_order_r['d46]  <= 6'd44;
    rom_zigzag_order_r['d47]  <= 6'd51;
    rom_zigzag_order_r['d48]  <= 6'd58;
    rom_zigzag_order_r['d49]  <= 6'd59;
    rom_zigzag_order_r['d50]  <= 6'd52;
    rom_zigzag_order_r['d51]  <= 6'd45;
    rom_zigzag_order_r['d52]  <= 6'd38;
    rom_zigzag_order_r['d53]  <= 6'd31;
    rom_zigzag_order_r['d54]  <= 6'd39;
    rom_zigzag_order_r['d55]  <= 6'd46;
    rom_zigzag_order_r['d56]  <= 6'd53;
    rom_zigzag_order_r['d57]  <= 6'd60;
    rom_zigzag_order_r['d58]  <= 6'd61;
    rom_zigzag_order_r['d59]  <= 6'd54;
    rom_zigzag_order_r['d60]  <= 6'd47;
    rom_zigzag_order_r['d61]  <= 6'd55;
    rom_zigzag_order_r['d62]  <= 6'd62;
    rom_zigzag_order_r['d63]  <= 6'd63;
end
endtask

always @* begin
    ptr_block_ns = ptr_block_r;
    ct_veri_ns = ct_veri_r;
    ct_row_ns = ct_row_r;
    ct_col_ns = ct_col_r;
    ct_gecerli_ns = ct_gecerli_r;
    buf_run_ns = buf_run_r;
    buf_data_ns = buf_data_r;
    durum_ns = durum_r;
    buf_gecerli_ns = buf_gecerli_r;
    hd_hazir_cmb = `HIGH;

    if (blok_son_i) begin
        ptr_block_ns = 0;
    end

    if (ct_gecerli_o && ct_hazir_i) begin
        ct_gecerli_ns = `LOW;
    end

    if (buf_gecerli_r && !(ct_gecerli_o && !ct_hazir_i)) begin
        ct_row_ns = rom_zigzag_order_r[ptr_block_r - 1] >> 6'd3; // div 8
        ct_col_ns = rom_zigzag_order_r[ptr_block_r - 1] & 6'h7;  // mod 8
        ct_gecerli_ns = `HIGH;
        ct_veri_ns = buf_data_r;
        buf_gecerli_ns = `LOW;
    end

    case(durum_r)
    HAZIR: begin
        if (hd_hazir_o && hd_gecerli_i) begin
            buf_run_ns = hd_run_i;
            buf_data_ns = hd_veri_i;
            buf_gecerli_ns = `HIGH;
            ptr_block_ns = ptr_block_r + hd_run_i + 1;
            if (ct_gecerli_o && !ct_hazir_i) begin
                durum_ns = BEKLE;
            end
        end
    end
    BEKLE: begin
        hd_hazir_cmb = `LOW;
        if (!buf_gecerli_r) begin
            durum_ns = HAZIR;
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        zigzag_init();
        ptr_block_r <= 0;
        ct_veri_r <= 0;
        ct_row_r <= 0;
        ct_col_r <= 0;
        ct_gecerli_r <= 0;
        buf_run_r <= 0;
        buf_gecerli_r <= 0;
        durum_r <= HAZIR;
    end
    else begin
        ptr_block_r <= ptr_block_ns;
        ct_veri_r <= ct_veri_ns;
        ct_row_r <= ct_row_ns;
        ct_col_r <= ct_col_ns;
        ct_gecerli_r <= ct_gecerli_ns;
        buf_run_r <= buf_run_ns;
        buf_data_r <= buf_data_ns;
        buf_gecerli_r <= buf_gecerli_ns;
        durum_r <= durum_ns;
    end
end

assign hd_hazir_o = hd_hazir_cmb;
assign ct_veri_o = ct_veri_r;
assign ct_row_o = ct_row_r;
assign ct_col_o = ct_col_r;
assign ct_gecerli_o = ct_gecerli_r;

endmodule