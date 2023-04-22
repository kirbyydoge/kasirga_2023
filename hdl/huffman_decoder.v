`timescale 1ns/1ps

`include "sabitler.vh"
`include "huffman.vh"

module huffman_decoder (
    input                   clk_i,
    input                   rstn_i,

    // Caravel Master <> Huffman Decoder
    input  [`AC_IN_BIT-1:0] m_veri_i,
    input                   m_gecerli_i,
    output                  m_hazir_o,

    // Huffman Decoder <> Nicemleme Donusturucu
    output [`RUN_BIT-1:0]   nd_run_o,
    output [`HDATA_BIT-1:0] nd_data_o,
    output                  nd_gecerli_o,
    input                   nd_hazir_i,

    output                  nd_blk_son_o
);

localparam HD_BUF_PTR_BIT = $clog2(`HD_BUF_BIT);
localparam HD_COZ_PTR_BIT = $clog2(`HD_AC_TABLO_BIT + 1);

localparam DURUM_BOSTA       = 'd0;
localparam DURUM_DC_COZ      = 'd1;
localparam DURUM_DC_OKU      = 'd2;
localparam DURUM_VERI_GONDER = 'd3;
localparam DURUM_AC_COZ      = 'd4;
localparam DURUM_AC_OKU      = 'd5;
localparam DURUM_COZ_KONTROL = 'd6;

reg [`HD_BUF_BIT-1:0]       buf_girdi_r;
reg [`HD_BUF_BIT-1:0]       buf_girdi_ns;

reg [HD_BUF_PTR_BIT-1:0]    ptr_buf_oku_r;
reg [HD_BUF_PTR_BIT-1:0]    ptr_buf_oku_ns;

reg [HD_BUF_PTR_BIT-1:0]    ptr_buf_yaz_r;
reg [HD_BUF_PTR_BIT-1:0]    ptr_buf_yaz_ns;

reg                         buf_bos_r;
reg                         buf_bos_ns;

reg                         m_hazir_r;
reg                         m_hazir_ns;

reg [`RUN_BIT-1:0]          nd_run_r;
reg [`RUN_BIT-1:0]          nd_run_ns;

reg [`CAT_BIT-1:0]          nd_cat_r;
reg [`CAT_BIT-1:0]          nd_cat_ns;

reg [`HDATA_BIT-1:0]        nd_data_r;
reg [`HDATA_BIT-1:0]        nd_data_ns;

reg                         nd_gecerli_r;
reg                         nd_gecerli_ns;

wire [HD_BUF_PTR_BIT:0]     buf_veri_sayisi_w;

reg [2:0]                   hd_durum_r;
reg [2:0]                   hd_durum_ns;

reg                         buf_oku_gecmis_r;
reg                         buf_oku_gecmis_ns;

reg [`HD_AC_TABLO_ROW-1:0]  coz_satir_gecerli_r;
reg [`HD_AC_TABLO_ROW-1:0]  coz_satir_gecerli_ns;

reg                                 ac_satir_one_hot_cmb;
reg [$clog2(`HD_AC_TABLO_ROW)-1:0]  ac_satir_one_hot_idx_cmb;
reg                                 one_hot_flag;

reg [`HD_AC_TABLO_BIT-1:0]  rom_ac_huffman_r [0:`HD_AC_TABLO_ROW-1];
reg [`HD_AC_TABLO_BIT-1:0]  rom_ac_run_r [0:`HD_AC_TABLO_ROW-1];
reg [`HD_AC_TABLO_BIT-1:0]  rom_ac_cat_r [0:`HD_AC_TABLO_ROW-1];
reg [`HD_AC_TABLO_BIT-1:0]  rom_ac_gecerli_r [0:`HD_AC_TABLO_ROW-1];

reg [10:0] dc_diff_cmb;

reg [8:0] rom_dc_bit_r [0:11];
reg [8:0] rom_dc_gecerli_r [0:11];

reg [3:0] dc_ptr_r;
reg [3:0] dc_ptr_ns;

reg [10:0] last_dc_blk_r;
reg [10:0] last_dc_blk_ns;

reg [10:0] dc_data_cmb;
reg dc_valid_cmb;

reg [11:0] dc_degerlendir_r;
reg [11:0] dc_degerlendir_ns;

reg [3:0] dc_oku_boyut_r;
reg [3:0] dc_oku_boyut_ns;

reg dc_one_hot_cmb;
reg [3:0] dc_one_hot_idx;

reg nd_blk_son_cmb;

reg [`HD_COZ_ADIM-1:0]      ac_huffman_adim_bit_cmb [0:`HD_AC_TABLO_ROW-1];
reg [`HD_COZ_ADIM-1:0]      ac_huffman_adim_gecerli_cmb [0:`HD_AC_TABLO_ROW-1];
reg [`HD_COZ_ADIM-1:0]      buf_adim_veri_cmb;
reg [HD_COZ_PTR_BIT-1:0]    guncel_gecerli_bit_cmb;
reg [HD_COZ_PTR_BIT-1:0]    gecmis_gecerli_bit_cmb;

reg [HD_COZ_PTR_BIT-1:0]    ptr_coz_r;
reg [HD_COZ_PTR_BIT-1:0]    ptr_coz_ns;

task rom_dc_init();
begin
    rom_dc_bit_r[0]      <= 9'b000000000;
    rom_dc_gecerli_r[0]  <= 9'b110000000;

    rom_dc_bit_r[1]      <= 9'b010000000;
    rom_dc_gecerli_r[1]  <= 9'b111000000;

    rom_dc_bit_r[2]      <= 9'b011000000;
    rom_dc_gecerli_r[2]  <= 9'b111000000;

    rom_dc_bit_r[3]      <= 9'b100000000;
    rom_dc_gecerli_r[3]  <= 9'b111000000;

    rom_dc_bit_r[4]      <= 9'b101000000;
    rom_dc_gecerli_r[4]  <= 9'b111000000;
    
    rom_dc_bit_r[5]      <= 9'b110000000;
    rom_dc_gecerli_r[5]  <= 9'b111000000;

    rom_dc_bit_r[6]      <= 9'b111000000;
    rom_dc_gecerli_r[6]  <= 9'b111100000;
    
    rom_dc_bit_r[7]      <= 9'b111100000;
    rom_dc_gecerli_r[7]  <= 9'b111110000;

    rom_dc_bit_r[8]      <= 9'b111110000;
    rom_dc_gecerli_r[8]  <= 9'b111111000;
    
    rom_dc_bit_r[9]      <= 9'b111111000;
    rom_dc_gecerli_r[9]  <= 9'b111111100;

    rom_dc_bit_r[10]     <= 9'b111111100;
    rom_dc_gecerli_r[10] <= 9'b111111110;

    rom_dc_bit_r[11]     <= 9'b111111110;
    rom_dc_gecerli_r[11] <= 9'b111111111;
end
endtask

task rom_ac_init();
begin
    rom_ac_huffman_r[`IDX_AC_0_0]   <= `HUF_AC_0_0;
    rom_ac_huffman_r[`IDX_AC_0_1]   <= `HUF_AC_0_1;
    rom_ac_huffman_r[`IDX_AC_0_2]   <= `HUF_AC_0_2;
    rom_ac_huffman_r[`IDX_AC_0_3]   <= `HUF_AC_0_3;
    rom_ac_huffman_r[`IDX_AC_0_4]   <= `HUF_AC_0_4;
    rom_ac_huffman_r[`IDX_AC_0_5]   <= `HUF_AC_0_5;
    rom_ac_huffman_r[`IDX_AC_0_6]   <= `HUF_AC_0_6;
    rom_ac_huffman_r[`IDX_AC_0_7]   <= `HUF_AC_0_7;
    rom_ac_huffman_r[`IDX_AC_0_8]   <= `HUF_AC_0_8;
    rom_ac_huffman_r[`IDX_AC_0_9]   <= `HUF_AC_0_9;
    rom_ac_huffman_r[`IDX_AC_0_10]  <= `HUF_AC_0_10;
    rom_ac_huffman_r[`IDX_AC_1_1]   <= `HUF_AC_1_1;
    rom_ac_huffman_r[`IDX_AC_1_2]   <= `HUF_AC_1_2;
    rom_ac_huffman_r[`IDX_AC_1_3]   <= `HUF_AC_1_3;
    rom_ac_huffman_r[`IDX_AC_1_4]   <= `HUF_AC_1_4;
    rom_ac_huffman_r[`IDX_AC_1_5]   <= `HUF_AC_1_5;
    rom_ac_huffman_r[`IDX_AC_1_6]   <= `HUF_AC_1_6;
    rom_ac_huffman_r[`IDX_AC_1_7]   <= `HUF_AC_1_7;
    rom_ac_huffman_r[`IDX_AC_1_8]   <= `HUF_AC_1_8;
    rom_ac_huffman_r[`IDX_AC_1_9]   <= `HUF_AC_1_9;
    rom_ac_huffman_r[`IDX_AC_1_10]  <= `HUF_AC_1_10;
    rom_ac_huffman_r[`IDX_AC_2_1]   <= `HUF_AC_2_1;
    rom_ac_huffman_r[`IDX_AC_2_2]   <= `HUF_AC_2_2;
    rom_ac_huffman_r[`IDX_AC_2_3]   <= `HUF_AC_2_3;
    rom_ac_huffman_r[`IDX_AC_2_4]   <= `HUF_AC_2_4;
    rom_ac_huffman_r[`IDX_AC_2_5]   <= `HUF_AC_2_5;
    rom_ac_huffman_r[`IDX_AC_2_6]   <= `HUF_AC_2_6;
    rom_ac_huffman_r[`IDX_AC_2_7]   <= `HUF_AC_2_7;
    rom_ac_huffman_r[`IDX_AC_2_8]   <= `HUF_AC_2_8;
    rom_ac_huffman_r[`IDX_AC_2_9]   <= `HUF_AC_2_9;
    rom_ac_huffman_r[`IDX_AC_2_10]  <= `HUF_AC_2_10;
    rom_ac_huffman_r[`IDX_AC_3_1]   <= `HUF_AC_3_1;
    rom_ac_huffman_r[`IDX_AC_3_2]   <= `HUF_AC_3_2;
    rom_ac_huffman_r[`IDX_AC_3_3]   <= `HUF_AC_3_3;
    rom_ac_huffman_r[`IDX_AC_3_4]   <= `HUF_AC_3_4;
    rom_ac_huffman_r[`IDX_AC_3_5]   <= `HUF_AC_3_5;
    rom_ac_huffman_r[`IDX_AC_3_6]   <= `HUF_AC_3_6;
    rom_ac_huffman_r[`IDX_AC_3_7]   <= `HUF_AC_3_7;
    rom_ac_huffman_r[`IDX_AC_3_8]   <= `HUF_AC_3_8;
    rom_ac_huffman_r[`IDX_AC_3_9]   <= `HUF_AC_3_9;
    rom_ac_huffman_r[`IDX_AC_3_10]  <= `HUF_AC_3_10;
    rom_ac_huffman_r[`IDX_AC_4_1]   <= `HUF_AC_4_1;
    rom_ac_huffman_r[`IDX_AC_4_2]   <= `HUF_AC_4_2;
    rom_ac_huffman_r[`IDX_AC_4_3]   <= `HUF_AC_4_3;
    rom_ac_huffman_r[`IDX_AC_4_4]   <= `HUF_AC_4_4;
    rom_ac_huffman_r[`IDX_AC_4_5]   <= `HUF_AC_4_5;
    rom_ac_huffman_r[`IDX_AC_4_6]   <= `HUF_AC_4_6;
    rom_ac_huffman_r[`IDX_AC_4_7]   <= `HUF_AC_4_7;
    rom_ac_huffman_r[`IDX_AC_4_8]   <= `HUF_AC_4_8;
    rom_ac_huffman_r[`IDX_AC_4_9]   <= `HUF_AC_4_9;
    rom_ac_huffman_r[`IDX_AC_4_10]  <= `HUF_AC_4_10;
    rom_ac_huffman_r[`IDX_AC_5_1]   <= `HUF_AC_5_1;
    rom_ac_huffman_r[`IDX_AC_5_2]   <= `HUF_AC_5_2;
    rom_ac_huffman_r[`IDX_AC_5_3]   <= `HUF_AC_5_3;
    rom_ac_huffman_r[`IDX_AC_5_4]   <= `HUF_AC_5_4;
    rom_ac_huffman_r[`IDX_AC_5_5]   <= `HUF_AC_5_5;
    rom_ac_huffman_r[`IDX_AC_5_6]   <= `HUF_AC_5_6;
    rom_ac_huffman_r[`IDX_AC_5_7]   <= `HUF_AC_5_7;
    rom_ac_huffman_r[`IDX_AC_5_8]   <= `HUF_AC_5_8;
    rom_ac_huffman_r[`IDX_AC_5_9]   <= `HUF_AC_5_9;
    rom_ac_huffman_r[`IDX_AC_5_10]  <= `HUF_AC_5_10;
    rom_ac_huffman_r[`IDX_AC_6_1]   <= `HUF_AC_6_1;
    rom_ac_huffman_r[`IDX_AC_6_2]   <= `HUF_AC_6_2;
    rom_ac_huffman_r[`IDX_AC_6_3]   <= `HUF_AC_6_3;
    rom_ac_huffman_r[`IDX_AC_6_4]   <= `HUF_AC_6_4;
    rom_ac_huffman_r[`IDX_AC_6_5]   <= `HUF_AC_6_5;
    rom_ac_huffman_r[`IDX_AC_6_6]   <= `HUF_AC_6_6;
    rom_ac_huffman_r[`IDX_AC_6_7]   <= `HUF_AC_6_7;
    rom_ac_huffman_r[`IDX_AC_6_8]   <= `HUF_AC_6_8;
    rom_ac_huffman_r[`IDX_AC_6_9]   <= `HUF_AC_6_9;
    rom_ac_huffman_r[`IDX_AC_6_10]  <= `HUF_AC_6_10;
    rom_ac_huffman_r[`IDX_AC_7_1]   <= `HUF_AC_7_1;
    rom_ac_huffman_r[`IDX_AC_7_2]   <= `HUF_AC_7_2;
    rom_ac_huffman_r[`IDX_AC_7_3]   <= `HUF_AC_7_3;
    rom_ac_huffman_r[`IDX_AC_7_4]   <= `HUF_AC_7_4;
    rom_ac_huffman_r[`IDX_AC_7_5]   <= `HUF_AC_7_5;
    rom_ac_huffman_r[`IDX_AC_7_6]   <= `HUF_AC_7_6;
    rom_ac_huffman_r[`IDX_AC_7_7]   <= `HUF_AC_7_7;
    rom_ac_huffman_r[`IDX_AC_7_8]   <= `HUF_AC_7_8;
    rom_ac_huffman_r[`IDX_AC_7_9]   <= `HUF_AC_7_9;
    rom_ac_huffman_r[`IDX_AC_7_10]  <= `HUF_AC_7_10;
    rom_ac_huffman_r[`IDX_AC_8_1]   <= `HUF_AC_8_1;
    rom_ac_huffman_r[`IDX_AC_8_2]   <= `HUF_AC_8_2;
    rom_ac_huffman_r[`IDX_AC_8_3]   <= `HUF_AC_8_3;
    rom_ac_huffman_r[`IDX_AC_8_4]   <= `HUF_AC_8_4;
    rom_ac_huffman_r[`IDX_AC_8_5]   <= `HUF_AC_8_5;
    rom_ac_huffman_r[`IDX_AC_8_6]   <= `HUF_AC_8_6;
    rom_ac_huffman_r[`IDX_AC_8_7]   <= `HUF_AC_8_7;
    rom_ac_huffman_r[`IDX_AC_8_8]   <= `HUF_AC_8_8;
    rom_ac_huffman_r[`IDX_AC_8_9]   <= `HUF_AC_8_9;
    rom_ac_huffman_r[`IDX_AC_8_10]  <= `HUF_AC_8_10;
    rom_ac_huffman_r[`IDX_AC_9_1]   <= `HUF_AC_9_1;
    rom_ac_huffman_r[`IDX_AC_9_2]   <= `HUF_AC_9_2;
    rom_ac_huffman_r[`IDX_AC_9_3]   <= `HUF_AC_9_3;
    rom_ac_huffman_r[`IDX_AC_9_4]   <= `HUF_AC_9_4;
    rom_ac_huffman_r[`IDX_AC_9_5]   <= `HUF_AC_9_5;
    rom_ac_huffman_r[`IDX_AC_9_6]   <= `HUF_AC_9_6;
    rom_ac_huffman_r[`IDX_AC_9_7]   <= `HUF_AC_9_7;
    rom_ac_huffman_r[`IDX_AC_9_8]   <= `HUF_AC_9_8;
    rom_ac_huffman_r[`IDX_AC_9_9]   <= `HUF_AC_9_9;
    rom_ac_huffman_r[`IDX_AC_9_10]  <= `HUF_AC_9_10;
    rom_ac_huffman_r[`IDX_AC_10_1]  <= `HUF_AC_10_1;
    rom_ac_huffman_r[`IDX_AC_10_2]  <= `HUF_AC_10_2;
    rom_ac_huffman_r[`IDX_AC_10_3]  <= `HUF_AC_10_3;
    rom_ac_huffman_r[`IDX_AC_10_4]  <= `HUF_AC_10_4;
    rom_ac_huffman_r[`IDX_AC_10_5]  <= `HUF_AC_10_5;
    rom_ac_huffman_r[`IDX_AC_10_6]  <= `HUF_AC_10_6;
    rom_ac_huffman_r[`IDX_AC_10_7]  <= `HUF_AC_10_7;
    rom_ac_huffman_r[`IDX_AC_10_8]  <= `HUF_AC_10_8;
    rom_ac_huffman_r[`IDX_AC_10_9]  <= `HUF_AC_10_9;
    rom_ac_huffman_r[`IDX_AC_10_10] <= `HUF_AC_10_10;
    rom_ac_huffman_r[`IDX_AC_11_1]  <= `HUF_AC_11_1;
    rom_ac_huffman_r[`IDX_AC_11_2]  <= `HUF_AC_11_2;
    rom_ac_huffman_r[`IDX_AC_11_3]  <= `HUF_AC_11_3;
    rom_ac_huffman_r[`IDX_AC_11_4]  <= `HUF_AC_11_4;
    rom_ac_huffman_r[`IDX_AC_11_5]  <= `HUF_AC_11_5;
    rom_ac_huffman_r[`IDX_AC_11_6]  <= `HUF_AC_11_6;
    rom_ac_huffman_r[`IDX_AC_11_7]  <= `HUF_AC_11_7;
    rom_ac_huffman_r[`IDX_AC_11_8]  <= `HUF_AC_11_8;
    rom_ac_huffman_r[`IDX_AC_11_9]  <= `HUF_AC_11_9;
    rom_ac_huffman_r[`IDX_AC_11_10] <= `HUF_AC_11_10;
    rom_ac_huffman_r[`IDX_AC_12_1]  <= `HUF_AC_12_1;
    rom_ac_huffman_r[`IDX_AC_12_2]  <= `HUF_AC_12_2;
    rom_ac_huffman_r[`IDX_AC_12_3]  <= `HUF_AC_12_3;
    rom_ac_huffman_r[`IDX_AC_12_4]  <= `HUF_AC_12_4;
    rom_ac_huffman_r[`IDX_AC_12_5]  <= `HUF_AC_12_5;
    rom_ac_huffman_r[`IDX_AC_12_6]  <= `HUF_AC_12_6;
    rom_ac_huffman_r[`IDX_AC_12_7]  <= `HUF_AC_12_7;
    rom_ac_huffman_r[`IDX_AC_12_8]  <= `HUF_AC_12_8;
    rom_ac_huffman_r[`IDX_AC_12_9]  <= `HUF_AC_12_9;
    rom_ac_huffman_r[`IDX_AC_12_10] <= `HUF_AC_12_10;
    rom_ac_huffman_r[`IDX_AC_13_1]  <= `HUF_AC_13_1;
    rom_ac_huffman_r[`IDX_AC_13_2]  <= `HUF_AC_13_2;
    rom_ac_huffman_r[`IDX_AC_13_3]  <= `HUF_AC_13_3;
    rom_ac_huffman_r[`IDX_AC_13_4]  <= `HUF_AC_13_4;
    rom_ac_huffman_r[`IDX_AC_13_5]  <= `HUF_AC_13_5;
    rom_ac_huffman_r[`IDX_AC_13_6]  <= `HUF_AC_13_6;
    rom_ac_huffman_r[`IDX_AC_13_7]  <= `HUF_AC_13_7;
    rom_ac_huffman_r[`IDX_AC_13_8]  <= `HUF_AC_13_8;
    rom_ac_huffman_r[`IDX_AC_13_9]  <= `HUF_AC_13_9;
    rom_ac_huffman_r[`IDX_AC_13_10] <= `HUF_AC_13_10;
    rom_ac_huffman_r[`IDX_AC_14_1]  <= `HUF_AC_14_1;
    rom_ac_huffman_r[`IDX_AC_14_2]  <= `HUF_AC_14_2;
    rom_ac_huffman_r[`IDX_AC_14_3]  <= `HUF_AC_14_3;
    rom_ac_huffman_r[`IDX_AC_14_4]  <= `HUF_AC_14_4;
    rom_ac_huffman_r[`IDX_AC_14_5]  <= `HUF_AC_14_5;
    rom_ac_huffman_r[`IDX_AC_14_6]  <= `HUF_AC_14_6;
    rom_ac_huffman_r[`IDX_AC_14_7]  <= `HUF_AC_14_7;
    rom_ac_huffman_r[`IDX_AC_14_8]  <= `HUF_AC_14_8;
    rom_ac_huffman_r[`IDX_AC_14_9]  <= `HUF_AC_14_9;
    rom_ac_huffman_r[`IDX_AC_14_10] <= `HUF_AC_14_10;
    rom_ac_huffman_r[`IDX_AC_15_1]  <= `HUF_AC_15_1;
    rom_ac_huffman_r[`IDX_AC_15_2]  <= `HUF_AC_15_2;
    rom_ac_huffman_r[`IDX_AC_15_3]  <= `HUF_AC_15_3;
    rom_ac_huffman_r[`IDX_AC_15_4]  <= `HUF_AC_15_4;
    rom_ac_huffman_r[`IDX_AC_15_5]  <= `HUF_AC_15_5;
    rom_ac_huffman_r[`IDX_AC_15_6]  <= `HUF_AC_15_6;
    rom_ac_huffman_r[`IDX_AC_15_7]  <= `HUF_AC_15_7;
    rom_ac_huffman_r[`IDX_AC_15_8]  <= `HUF_AC_15_8;
    rom_ac_huffman_r[`IDX_AC_15_9]  <= `HUF_AC_15_9;
    rom_ac_huffman_r[`IDX_AC_15_10] <= `HUF_AC_15_10;
    rom_ac_huffman_r[`IDX_AC_15_0]  <= `HUF_AC_15_0;

    rom_ac_gecerli_r[`IDX_AC_0_0]   <= `EN_AC_0_0;
    rom_ac_gecerli_r[`IDX_AC_0_1]   <= `EN_AC_0_1;
    rom_ac_gecerli_r[`IDX_AC_0_2]   <= `EN_AC_0_2;
    rom_ac_gecerli_r[`IDX_AC_0_3]   <= `EN_AC_0_3;
    rom_ac_gecerli_r[`IDX_AC_0_4]   <= `EN_AC_0_4;
    rom_ac_gecerli_r[`IDX_AC_0_5]   <= `EN_AC_0_5;
    rom_ac_gecerli_r[`IDX_AC_0_6]   <= `EN_AC_0_6;
    rom_ac_gecerli_r[`IDX_AC_0_7]   <= `EN_AC_0_7;
    rom_ac_gecerli_r[`IDX_AC_0_8]   <= `EN_AC_0_8;
    rom_ac_gecerli_r[`IDX_AC_0_9]   <= `EN_AC_0_9;
    rom_ac_gecerli_r[`IDX_AC_0_10]  <= `EN_AC_0_10;
    rom_ac_gecerli_r[`IDX_AC_1_1]   <= `EN_AC_1_1;
    rom_ac_gecerli_r[`IDX_AC_1_2]   <= `EN_AC_1_2;
    rom_ac_gecerli_r[`IDX_AC_1_3]   <= `EN_AC_1_3;
    rom_ac_gecerli_r[`IDX_AC_1_4]   <= `EN_AC_1_4;
    rom_ac_gecerli_r[`IDX_AC_1_5]   <= `EN_AC_1_5;
    rom_ac_gecerli_r[`IDX_AC_1_6]   <= `EN_AC_1_6;
    rom_ac_gecerli_r[`IDX_AC_1_7]   <= `EN_AC_1_7;
    rom_ac_gecerli_r[`IDX_AC_1_8]   <= `EN_AC_1_8;
    rom_ac_gecerli_r[`IDX_AC_1_9]   <= `EN_AC_1_9;
    rom_ac_gecerli_r[`IDX_AC_1_10]  <= `EN_AC_1_10;
    rom_ac_gecerli_r[`IDX_AC_2_1]   <= `EN_AC_2_1;
    rom_ac_gecerli_r[`IDX_AC_2_2]   <= `EN_AC_2_2;
    rom_ac_gecerli_r[`IDX_AC_2_3]   <= `EN_AC_2_3;
    rom_ac_gecerli_r[`IDX_AC_2_4]   <= `EN_AC_2_4;
    rom_ac_gecerli_r[`IDX_AC_2_5]   <= `EN_AC_2_5;
    rom_ac_gecerli_r[`IDX_AC_2_6]   <= `EN_AC_2_6;
    rom_ac_gecerli_r[`IDX_AC_2_7]   <= `EN_AC_2_7;
    rom_ac_gecerli_r[`IDX_AC_2_8]   <= `EN_AC_2_8;
    rom_ac_gecerli_r[`IDX_AC_2_9]   <= `EN_AC_2_9;
    rom_ac_gecerli_r[`IDX_AC_2_10]  <= `EN_AC_2_10;
    rom_ac_gecerli_r[`IDX_AC_3_1]   <= `EN_AC_3_1;
    rom_ac_gecerli_r[`IDX_AC_3_2]   <= `EN_AC_3_2;
    rom_ac_gecerli_r[`IDX_AC_3_3]   <= `EN_AC_3_3;
    rom_ac_gecerli_r[`IDX_AC_3_4]   <= `EN_AC_3_4;
    rom_ac_gecerli_r[`IDX_AC_3_5]   <= `EN_AC_3_5;
    rom_ac_gecerli_r[`IDX_AC_3_6]   <= `EN_AC_3_6;
    rom_ac_gecerli_r[`IDX_AC_3_7]   <= `EN_AC_3_7;
    rom_ac_gecerli_r[`IDX_AC_3_8]   <= `EN_AC_3_8;
    rom_ac_gecerli_r[`IDX_AC_3_9]   <= `EN_AC_3_9;
    rom_ac_gecerli_r[`IDX_AC_3_10]  <= `EN_AC_3_10;
    rom_ac_gecerli_r[`IDX_AC_4_1]   <= `EN_AC_4_1;
    rom_ac_gecerli_r[`IDX_AC_4_2]   <= `EN_AC_4_2;
    rom_ac_gecerli_r[`IDX_AC_4_3]   <= `EN_AC_4_3;
    rom_ac_gecerli_r[`IDX_AC_4_4]   <= `EN_AC_4_4;
    rom_ac_gecerli_r[`IDX_AC_4_5]   <= `EN_AC_4_5;
    rom_ac_gecerli_r[`IDX_AC_4_6]   <= `EN_AC_4_6;
    rom_ac_gecerli_r[`IDX_AC_4_7]   <= `EN_AC_4_7;
    rom_ac_gecerli_r[`IDX_AC_4_8]   <= `EN_AC_4_8;
    rom_ac_gecerli_r[`IDX_AC_4_9]   <= `EN_AC_4_9;
    rom_ac_gecerli_r[`IDX_AC_4_10]  <= `EN_AC_4_10;
    rom_ac_gecerli_r[`IDX_AC_5_1]   <= `EN_AC_5_1;
    rom_ac_gecerli_r[`IDX_AC_5_2]   <= `EN_AC_5_2;
    rom_ac_gecerli_r[`IDX_AC_5_3]   <= `EN_AC_5_3;
    rom_ac_gecerli_r[`IDX_AC_5_4]   <= `EN_AC_5_4;
    rom_ac_gecerli_r[`IDX_AC_5_5]   <= `EN_AC_5_5;
    rom_ac_gecerli_r[`IDX_AC_5_6]   <= `EN_AC_5_6;
    rom_ac_gecerli_r[`IDX_AC_5_7]   <= `EN_AC_5_7;
    rom_ac_gecerli_r[`IDX_AC_5_8]   <= `EN_AC_5_8;
    rom_ac_gecerli_r[`IDX_AC_5_9]   <= `EN_AC_5_9;
    rom_ac_gecerli_r[`IDX_AC_5_10]  <= `EN_AC_5_10;
    rom_ac_gecerli_r[`IDX_AC_6_1]   <= `EN_AC_6_1;
    rom_ac_gecerli_r[`IDX_AC_6_2]   <= `EN_AC_6_2;
    rom_ac_gecerli_r[`IDX_AC_6_3]   <= `EN_AC_6_3;
    rom_ac_gecerli_r[`IDX_AC_6_4]   <= `EN_AC_6_4;
    rom_ac_gecerli_r[`IDX_AC_6_5]   <= `EN_AC_6_5;
    rom_ac_gecerli_r[`IDX_AC_6_6]   <= `EN_AC_6_6;
    rom_ac_gecerli_r[`IDX_AC_6_7]   <= `EN_AC_6_7;
    rom_ac_gecerli_r[`IDX_AC_6_8]   <= `EN_AC_6_8;
    rom_ac_gecerli_r[`IDX_AC_6_9]   <= `EN_AC_6_9;
    rom_ac_gecerli_r[`IDX_AC_6_10]  <= `EN_AC_6_10;
    rom_ac_gecerli_r[`IDX_AC_7_1]   <= `EN_AC_7_1;
    rom_ac_gecerli_r[`IDX_AC_7_2]   <= `EN_AC_7_2;
    rom_ac_gecerli_r[`IDX_AC_7_3]   <= `EN_AC_7_3;
    rom_ac_gecerli_r[`IDX_AC_7_4]   <= `EN_AC_7_4;
    rom_ac_gecerli_r[`IDX_AC_7_5]   <= `EN_AC_7_5;
    rom_ac_gecerli_r[`IDX_AC_7_6]   <= `EN_AC_7_6;
    rom_ac_gecerli_r[`IDX_AC_7_7]   <= `EN_AC_7_7;
    rom_ac_gecerli_r[`IDX_AC_7_8]   <= `EN_AC_7_8;
    rom_ac_gecerli_r[`IDX_AC_7_9]   <= `EN_AC_7_9;
    rom_ac_gecerli_r[`IDX_AC_7_10]  <= `EN_AC_7_10;
    rom_ac_gecerli_r[`IDX_AC_8_1]   <= `EN_AC_8_1;
    rom_ac_gecerli_r[`IDX_AC_8_2]   <= `EN_AC_8_2;
    rom_ac_gecerli_r[`IDX_AC_8_3]   <= `EN_AC_8_3;
    rom_ac_gecerli_r[`IDX_AC_8_4]   <= `EN_AC_8_4;
    rom_ac_gecerli_r[`IDX_AC_8_5]   <= `EN_AC_8_5;
    rom_ac_gecerli_r[`IDX_AC_8_6]   <= `EN_AC_8_6;
    rom_ac_gecerli_r[`IDX_AC_8_7]   <= `EN_AC_8_7;
    rom_ac_gecerli_r[`IDX_AC_8_8]   <= `EN_AC_8_8;
    rom_ac_gecerli_r[`IDX_AC_8_9]   <= `EN_AC_8_9;
    rom_ac_gecerli_r[`IDX_AC_8_10]  <= `EN_AC_8_10;
    rom_ac_gecerli_r[`IDX_AC_9_1]   <= `EN_AC_9_1;
    rom_ac_gecerli_r[`IDX_AC_9_2]   <= `EN_AC_9_2;
    rom_ac_gecerli_r[`IDX_AC_9_3]   <= `EN_AC_9_3;
    rom_ac_gecerli_r[`IDX_AC_9_4]   <= `EN_AC_9_4;
    rom_ac_gecerli_r[`IDX_AC_9_5]   <= `EN_AC_9_5;
    rom_ac_gecerli_r[`IDX_AC_9_6]   <= `EN_AC_9_6;
    rom_ac_gecerli_r[`IDX_AC_9_7]   <= `EN_AC_9_7;
    rom_ac_gecerli_r[`IDX_AC_9_8]   <= `EN_AC_9_8;
    rom_ac_gecerli_r[`IDX_AC_9_9]   <= `EN_AC_9_9;
    rom_ac_gecerli_r[`IDX_AC_9_10]  <= `EN_AC_9_10;
    rom_ac_gecerli_r[`IDX_AC_10_1]  <= `EN_AC_10_1;
    rom_ac_gecerli_r[`IDX_AC_10_2]  <= `EN_AC_10_2;
    rom_ac_gecerli_r[`IDX_AC_10_3]  <= `EN_AC_10_3;
    rom_ac_gecerli_r[`IDX_AC_10_4]  <= `EN_AC_10_4;
    rom_ac_gecerli_r[`IDX_AC_10_5]  <= `EN_AC_10_5;
    rom_ac_gecerli_r[`IDX_AC_10_6]  <= `EN_AC_10_6;
    rom_ac_gecerli_r[`IDX_AC_10_7]  <= `EN_AC_10_7;
    rom_ac_gecerli_r[`IDX_AC_10_8]  <= `EN_AC_10_8;
    rom_ac_gecerli_r[`IDX_AC_10_9]  <= `EN_AC_10_9;
    rom_ac_gecerli_r[`IDX_AC_10_10] <= `EN_AC_10_10;
    rom_ac_gecerli_r[`IDX_AC_11_1]  <= `EN_AC_11_1;
    rom_ac_gecerli_r[`IDX_AC_11_2]  <= `EN_AC_11_2;
    rom_ac_gecerli_r[`IDX_AC_11_3]  <= `EN_AC_11_3;
    rom_ac_gecerli_r[`IDX_AC_11_4]  <= `EN_AC_11_4;
    rom_ac_gecerli_r[`IDX_AC_11_5]  <= `EN_AC_11_5;
    rom_ac_gecerli_r[`IDX_AC_11_6]  <= `EN_AC_11_6;
    rom_ac_gecerli_r[`IDX_AC_11_7]  <= `EN_AC_11_7;
    rom_ac_gecerli_r[`IDX_AC_11_8]  <= `EN_AC_11_8;
    rom_ac_gecerli_r[`IDX_AC_11_9]  <= `EN_AC_11_9;
    rom_ac_gecerli_r[`IDX_AC_11_10] <= `EN_AC_11_10;
    rom_ac_gecerli_r[`IDX_AC_12_1]  <= `EN_AC_12_1;
    rom_ac_gecerli_r[`IDX_AC_12_2]  <= `EN_AC_12_2;
    rom_ac_gecerli_r[`IDX_AC_12_3]  <= `EN_AC_12_3;
    rom_ac_gecerli_r[`IDX_AC_12_4]  <= `EN_AC_12_4;
    rom_ac_gecerli_r[`IDX_AC_12_5]  <= `EN_AC_12_5;
    rom_ac_gecerli_r[`IDX_AC_12_6]  <= `EN_AC_12_6;
    rom_ac_gecerli_r[`IDX_AC_12_7]  <= `EN_AC_12_7;
    rom_ac_gecerli_r[`IDX_AC_12_8]  <= `EN_AC_12_8;
    rom_ac_gecerli_r[`IDX_AC_12_9]  <= `EN_AC_12_9;
    rom_ac_gecerli_r[`IDX_AC_12_10] <= `EN_AC_12_10;
    rom_ac_gecerli_r[`IDX_AC_13_1]  <= `EN_AC_13_1;
    rom_ac_gecerli_r[`IDX_AC_13_2]  <= `EN_AC_13_2;
    rom_ac_gecerli_r[`IDX_AC_13_3]  <= `EN_AC_13_3;
    rom_ac_gecerli_r[`IDX_AC_13_4]  <= `EN_AC_13_4;
    rom_ac_gecerli_r[`IDX_AC_13_5]  <= `EN_AC_13_5;
    rom_ac_gecerli_r[`IDX_AC_13_6]  <= `EN_AC_13_6;
    rom_ac_gecerli_r[`IDX_AC_13_7]  <= `EN_AC_13_7;
    rom_ac_gecerli_r[`IDX_AC_13_8]  <= `EN_AC_13_8;
    rom_ac_gecerli_r[`IDX_AC_13_9]  <= `EN_AC_13_9;
    rom_ac_gecerli_r[`IDX_AC_13_10] <= `EN_AC_13_10;
    rom_ac_gecerli_r[`IDX_AC_14_1]  <= `EN_AC_14_1;
    rom_ac_gecerli_r[`IDX_AC_14_2]  <= `EN_AC_14_2;
    rom_ac_gecerli_r[`IDX_AC_14_3]  <= `EN_AC_14_3;
    rom_ac_gecerli_r[`IDX_AC_14_4]  <= `EN_AC_14_4;
    rom_ac_gecerli_r[`IDX_AC_14_5]  <= `EN_AC_14_5;
    rom_ac_gecerli_r[`IDX_AC_14_6]  <= `EN_AC_14_6;
    rom_ac_gecerli_r[`IDX_AC_14_7]  <= `EN_AC_14_7;
    rom_ac_gecerli_r[`IDX_AC_14_8]  <= `EN_AC_14_8;
    rom_ac_gecerli_r[`IDX_AC_14_9]  <= `EN_AC_14_9;
    rom_ac_gecerli_r[`IDX_AC_14_10] <= `EN_AC_14_10;
    rom_ac_gecerli_r[`IDX_AC_15_1]  <= `EN_AC_15_1;
    rom_ac_gecerli_r[`IDX_AC_15_2]  <= `EN_AC_15_2;
    rom_ac_gecerli_r[`IDX_AC_15_3]  <= `EN_AC_15_3;
    rom_ac_gecerli_r[`IDX_AC_15_4]  <= `EN_AC_15_4;
    rom_ac_gecerli_r[`IDX_AC_15_5]  <= `EN_AC_15_5;
    rom_ac_gecerli_r[`IDX_AC_15_6]  <= `EN_AC_15_6;
    rom_ac_gecerli_r[`IDX_AC_15_7]  <= `EN_AC_15_7;
    rom_ac_gecerli_r[`IDX_AC_15_8]  <= `EN_AC_15_8;
    rom_ac_gecerli_r[`IDX_AC_15_9]  <= `EN_AC_15_9;
    rom_ac_gecerli_r[`IDX_AC_15_10] <= `EN_AC_15_10;
    rom_ac_gecerli_r[`IDX_AC_15_0]  <= `EN_AC_15_0;

    rom_ac_cat_r[`IDX_AC_0_0]   <= `CAT_AC_0_0;
    rom_ac_cat_r[`IDX_AC_0_1]   <= `CAT_AC_0_1;
    rom_ac_cat_r[`IDX_AC_0_2]   <= `CAT_AC_0_2;
    rom_ac_cat_r[`IDX_AC_0_3]   <= `CAT_AC_0_3;
    rom_ac_cat_r[`IDX_AC_0_4]   <= `CAT_AC_0_4;
    rom_ac_cat_r[`IDX_AC_0_5]   <= `CAT_AC_0_5;
    rom_ac_cat_r[`IDX_AC_0_6]   <= `CAT_AC_0_6;
    rom_ac_cat_r[`IDX_AC_0_7]   <= `CAT_AC_0_7;
    rom_ac_cat_r[`IDX_AC_0_8]   <= `CAT_AC_0_8;
    rom_ac_cat_r[`IDX_AC_0_9]   <= `CAT_AC_0_9;
    rom_ac_cat_r[`IDX_AC_0_10]  <= `CAT_AC_0_10;
    rom_ac_cat_r[`IDX_AC_1_1]   <= `CAT_AC_1_1;
    rom_ac_cat_r[`IDX_AC_1_2]   <= `CAT_AC_1_2;
    rom_ac_cat_r[`IDX_AC_1_3]   <= `CAT_AC_1_3;
    rom_ac_cat_r[`IDX_AC_1_4]   <= `CAT_AC_1_4;
    rom_ac_cat_r[`IDX_AC_1_5]   <= `CAT_AC_1_5;
    rom_ac_cat_r[`IDX_AC_1_6]   <= `CAT_AC_1_6;
    rom_ac_cat_r[`IDX_AC_1_7]   <= `CAT_AC_1_7;
    rom_ac_cat_r[`IDX_AC_1_8]   <= `CAT_AC_1_8;
    rom_ac_cat_r[`IDX_AC_1_9]   <= `CAT_AC_1_9;
    rom_ac_cat_r[`IDX_AC_1_10]  <= `CAT_AC_1_10;
    rom_ac_cat_r[`IDX_AC_2_1]   <= `CAT_AC_2_1;
    rom_ac_cat_r[`IDX_AC_2_2]   <= `CAT_AC_2_2;
    rom_ac_cat_r[`IDX_AC_2_3]   <= `CAT_AC_2_3;
    rom_ac_cat_r[`IDX_AC_2_4]   <= `CAT_AC_2_4;
    rom_ac_cat_r[`IDX_AC_2_5]   <= `CAT_AC_2_5;
    rom_ac_cat_r[`IDX_AC_2_6]   <= `CAT_AC_2_6;
    rom_ac_cat_r[`IDX_AC_2_7]   <= `CAT_AC_2_7;
    rom_ac_cat_r[`IDX_AC_2_8]   <= `CAT_AC_2_8;
    rom_ac_cat_r[`IDX_AC_2_9]   <= `CAT_AC_2_9;
    rom_ac_cat_r[`IDX_AC_2_10]  <= `CAT_AC_2_10;
    rom_ac_cat_r[`IDX_AC_3_1]   <= `CAT_AC_3_1;
    rom_ac_cat_r[`IDX_AC_3_2]   <= `CAT_AC_3_2;
    rom_ac_cat_r[`IDX_AC_3_3]   <= `CAT_AC_3_3;
    rom_ac_cat_r[`IDX_AC_3_4]   <= `CAT_AC_3_4;
    rom_ac_cat_r[`IDX_AC_3_5]   <= `CAT_AC_3_5;
    rom_ac_cat_r[`IDX_AC_3_6]   <= `CAT_AC_3_6;
    rom_ac_cat_r[`IDX_AC_3_7]   <= `CAT_AC_3_7;
    rom_ac_cat_r[`IDX_AC_3_8]   <= `CAT_AC_3_8;
    rom_ac_cat_r[`IDX_AC_3_9]   <= `CAT_AC_3_9;
    rom_ac_cat_r[`IDX_AC_3_10]  <= `CAT_AC_3_10;
    rom_ac_cat_r[`IDX_AC_4_1]   <= `CAT_AC_4_1;
    rom_ac_cat_r[`IDX_AC_4_2]   <= `CAT_AC_4_2;
    rom_ac_cat_r[`IDX_AC_4_3]   <= `CAT_AC_4_3;
    rom_ac_cat_r[`IDX_AC_4_4]   <= `CAT_AC_4_4;
    rom_ac_cat_r[`IDX_AC_4_5]   <= `CAT_AC_4_5;
    rom_ac_cat_r[`IDX_AC_4_6]   <= `CAT_AC_4_6;
    rom_ac_cat_r[`IDX_AC_4_7]   <= `CAT_AC_4_7;
    rom_ac_cat_r[`IDX_AC_4_8]   <= `CAT_AC_4_8;
    rom_ac_cat_r[`IDX_AC_4_9]   <= `CAT_AC_4_9;
    rom_ac_cat_r[`IDX_AC_4_10]  <= `CAT_AC_4_10;
    rom_ac_cat_r[`IDX_AC_5_1]   <= `CAT_AC_5_1;
    rom_ac_cat_r[`IDX_AC_5_2]   <= `CAT_AC_5_2;
    rom_ac_cat_r[`IDX_AC_5_3]   <= `CAT_AC_5_3;
    rom_ac_cat_r[`IDX_AC_5_4]   <= `CAT_AC_5_4;
    rom_ac_cat_r[`IDX_AC_5_5]   <= `CAT_AC_5_5;
    rom_ac_cat_r[`IDX_AC_5_6]   <= `CAT_AC_5_6;
    rom_ac_cat_r[`IDX_AC_5_7]   <= `CAT_AC_5_7;
    rom_ac_cat_r[`IDX_AC_5_8]   <= `CAT_AC_5_8;
    rom_ac_cat_r[`IDX_AC_5_9]   <= `CAT_AC_5_9;
    rom_ac_cat_r[`IDX_AC_5_10]  <= `CAT_AC_5_10;
    rom_ac_cat_r[`IDX_AC_6_1]   <= `CAT_AC_6_1;
    rom_ac_cat_r[`IDX_AC_6_2]   <= `CAT_AC_6_2;
    rom_ac_cat_r[`IDX_AC_6_3]   <= `CAT_AC_6_3;
    rom_ac_cat_r[`IDX_AC_6_4]   <= `CAT_AC_6_4;
    rom_ac_cat_r[`IDX_AC_6_5]   <= `CAT_AC_6_5;
    rom_ac_cat_r[`IDX_AC_6_6]   <= `CAT_AC_6_6;
    rom_ac_cat_r[`IDX_AC_6_7]   <= `CAT_AC_6_7;
    rom_ac_cat_r[`IDX_AC_6_8]   <= `CAT_AC_6_8;
    rom_ac_cat_r[`IDX_AC_6_9]   <= `CAT_AC_6_9;
    rom_ac_cat_r[`IDX_AC_6_10]  <= `CAT_AC_6_10;
    rom_ac_cat_r[`IDX_AC_7_1]   <= `CAT_AC_7_1;
    rom_ac_cat_r[`IDX_AC_7_2]   <= `CAT_AC_7_2;
    rom_ac_cat_r[`IDX_AC_7_3]   <= `CAT_AC_7_3;
    rom_ac_cat_r[`IDX_AC_7_4]   <= `CAT_AC_7_4;
    rom_ac_cat_r[`IDX_AC_7_5]   <= `CAT_AC_7_5;
    rom_ac_cat_r[`IDX_AC_7_6]   <= `CAT_AC_7_6;
    rom_ac_cat_r[`IDX_AC_7_7]   <= `CAT_AC_7_7;
    rom_ac_cat_r[`IDX_AC_7_8]   <= `CAT_AC_7_8;
    rom_ac_cat_r[`IDX_AC_7_9]   <= `CAT_AC_7_9;
    rom_ac_cat_r[`IDX_AC_7_10]  <= `CAT_AC_7_10;
    rom_ac_cat_r[`IDX_AC_8_1]   <= `CAT_AC_8_1;
    rom_ac_cat_r[`IDX_AC_8_2]   <= `CAT_AC_8_2;
    rom_ac_cat_r[`IDX_AC_8_3]   <= `CAT_AC_8_3;
    rom_ac_cat_r[`IDX_AC_8_4]   <= `CAT_AC_8_4;
    rom_ac_cat_r[`IDX_AC_8_5]   <= `CAT_AC_8_5;
    rom_ac_cat_r[`IDX_AC_8_6]   <= `CAT_AC_8_6;
    rom_ac_cat_r[`IDX_AC_8_7]   <= `CAT_AC_8_7;
    rom_ac_cat_r[`IDX_AC_8_8]   <= `CAT_AC_8_8;
    rom_ac_cat_r[`IDX_AC_8_9]   <= `CAT_AC_8_9;
    rom_ac_cat_r[`IDX_AC_8_10]  <= `CAT_AC_8_10;
    rom_ac_cat_r[`IDX_AC_9_1]   <= `CAT_AC_9_1;
    rom_ac_cat_r[`IDX_AC_9_2]   <= `CAT_AC_9_2;
    rom_ac_cat_r[`IDX_AC_9_3]   <= `CAT_AC_9_3;
    rom_ac_cat_r[`IDX_AC_9_4]   <= `CAT_AC_9_4;
    rom_ac_cat_r[`IDX_AC_9_5]   <= `CAT_AC_9_5;
    rom_ac_cat_r[`IDX_AC_9_6]   <= `CAT_AC_9_6;
    rom_ac_cat_r[`IDX_AC_9_7]   <= `CAT_AC_9_7;
    rom_ac_cat_r[`IDX_AC_9_8]   <= `CAT_AC_9_8;
    rom_ac_cat_r[`IDX_AC_9_9]   <= `CAT_AC_9_9;
    rom_ac_cat_r[`IDX_AC_9_10]  <= `CAT_AC_9_10;
    rom_ac_cat_r[`IDX_AC_10_1]  <= `CAT_AC_10_1;
    rom_ac_cat_r[`IDX_AC_10_2]  <= `CAT_AC_10_2;
    rom_ac_cat_r[`IDX_AC_10_3]  <= `CAT_AC_10_3;
    rom_ac_cat_r[`IDX_AC_10_4]  <= `CAT_AC_10_4;
    rom_ac_cat_r[`IDX_AC_10_5]  <= `CAT_AC_10_5;
    rom_ac_cat_r[`IDX_AC_10_6]  <= `CAT_AC_10_6;
    rom_ac_cat_r[`IDX_AC_10_7]  <= `CAT_AC_10_7;
    rom_ac_cat_r[`IDX_AC_10_8]  <= `CAT_AC_10_8;
    rom_ac_cat_r[`IDX_AC_10_9]  <= `CAT_AC_10_9;
    rom_ac_cat_r[`IDX_AC_10_10] <= `CAT_AC_10_10;
    rom_ac_cat_r[`IDX_AC_11_1]  <= `CAT_AC_11_1;
    rom_ac_cat_r[`IDX_AC_11_2]  <= `CAT_AC_11_2;
    rom_ac_cat_r[`IDX_AC_11_3]  <= `CAT_AC_11_3;
    rom_ac_cat_r[`IDX_AC_11_4]  <= `CAT_AC_11_4;
    rom_ac_cat_r[`IDX_AC_11_5]  <= `CAT_AC_11_5;
    rom_ac_cat_r[`IDX_AC_11_6]  <= `CAT_AC_11_6;
    rom_ac_cat_r[`IDX_AC_11_7]  <= `CAT_AC_11_7;
    rom_ac_cat_r[`IDX_AC_11_8]  <= `CAT_AC_11_8;
    rom_ac_cat_r[`IDX_AC_11_9]  <= `CAT_AC_11_9;
    rom_ac_cat_r[`IDX_AC_11_10] <= `CAT_AC_11_10;
    rom_ac_cat_r[`IDX_AC_12_1]  <= `CAT_AC_12_1;
    rom_ac_cat_r[`IDX_AC_12_2]  <= `CAT_AC_12_2;
    rom_ac_cat_r[`IDX_AC_12_3]  <= `CAT_AC_12_3;
    rom_ac_cat_r[`IDX_AC_12_4]  <= `CAT_AC_12_4;
    rom_ac_cat_r[`IDX_AC_12_5]  <= `CAT_AC_12_5;
    rom_ac_cat_r[`IDX_AC_12_6]  <= `CAT_AC_12_6;
    rom_ac_cat_r[`IDX_AC_12_7]  <= `CAT_AC_12_7;
    rom_ac_cat_r[`IDX_AC_12_8]  <= `CAT_AC_12_8;
    rom_ac_cat_r[`IDX_AC_12_9]  <= `CAT_AC_12_9;
    rom_ac_cat_r[`IDX_AC_12_10] <= `CAT_AC_12_10;
    rom_ac_cat_r[`IDX_AC_13_1]  <= `CAT_AC_13_1;
    rom_ac_cat_r[`IDX_AC_13_2]  <= `CAT_AC_13_2;
    rom_ac_cat_r[`IDX_AC_13_3]  <= `CAT_AC_13_3;
    rom_ac_cat_r[`IDX_AC_13_4]  <= `CAT_AC_13_4;
    rom_ac_cat_r[`IDX_AC_13_5]  <= `CAT_AC_13_5;
    rom_ac_cat_r[`IDX_AC_13_6]  <= `CAT_AC_13_6;
    rom_ac_cat_r[`IDX_AC_13_7]  <= `CAT_AC_13_7;
    rom_ac_cat_r[`IDX_AC_13_8]  <= `CAT_AC_13_8;
    rom_ac_cat_r[`IDX_AC_13_9]  <= `CAT_AC_13_9;
    rom_ac_cat_r[`IDX_AC_13_10] <= `CAT_AC_13_10;
    rom_ac_cat_r[`IDX_AC_14_1]  <= `CAT_AC_14_1;
    rom_ac_cat_r[`IDX_AC_14_2]  <= `CAT_AC_14_2;
    rom_ac_cat_r[`IDX_AC_14_3]  <= `CAT_AC_14_3;
    rom_ac_cat_r[`IDX_AC_14_4]  <= `CAT_AC_14_4;
    rom_ac_cat_r[`IDX_AC_14_5]  <= `CAT_AC_14_5;
    rom_ac_cat_r[`IDX_AC_14_6]  <= `CAT_AC_14_6;
    rom_ac_cat_r[`IDX_AC_14_7]  <= `CAT_AC_14_7;
    rom_ac_cat_r[`IDX_AC_14_8]  <= `CAT_AC_14_8;
    rom_ac_cat_r[`IDX_AC_14_9]  <= `CAT_AC_14_9;
    rom_ac_cat_r[`IDX_AC_14_10] <= `CAT_AC_14_10;
    rom_ac_cat_r[`IDX_AC_15_1]  <= `CAT_AC_15_1;
    rom_ac_cat_r[`IDX_AC_15_2]  <= `CAT_AC_15_2;
    rom_ac_cat_r[`IDX_AC_15_3]  <= `CAT_AC_15_3;
    rom_ac_cat_r[`IDX_AC_15_4]  <= `CAT_AC_15_4;
    rom_ac_cat_r[`IDX_AC_15_5]  <= `CAT_AC_15_5;
    rom_ac_cat_r[`IDX_AC_15_6]  <= `CAT_AC_15_6;
    rom_ac_cat_r[`IDX_AC_15_7]  <= `CAT_AC_15_7;
    rom_ac_cat_r[`IDX_AC_15_8]  <= `CAT_AC_15_8;
    rom_ac_cat_r[`IDX_AC_15_9]  <= `CAT_AC_15_9;
    rom_ac_cat_r[`IDX_AC_15_10] <= `CAT_AC_15_10;
    rom_ac_cat_r[`IDX_AC_15_0]  <= `CAT_AC_15_0;

    rom_ac_run_r[`IDX_AC_0_0]   <= `RUN_AC_0_0;
    rom_ac_run_r[`IDX_AC_0_1]   <= `RUN_AC_0_1;
    rom_ac_run_r[`IDX_AC_0_2]   <= `RUN_AC_0_2;
    rom_ac_run_r[`IDX_AC_0_3]   <= `RUN_AC_0_3;
    rom_ac_run_r[`IDX_AC_0_4]   <= `RUN_AC_0_4;
    rom_ac_run_r[`IDX_AC_0_5]   <= `RUN_AC_0_5;
    rom_ac_run_r[`IDX_AC_0_6]   <= `RUN_AC_0_6;
    rom_ac_run_r[`IDX_AC_0_7]   <= `RUN_AC_0_7;
    rom_ac_run_r[`IDX_AC_0_8]   <= `RUN_AC_0_8;
    rom_ac_run_r[`IDX_AC_0_9]   <= `RUN_AC_0_9;
    rom_ac_run_r[`IDX_AC_0_10]  <= `RUN_AC_0_10;
    rom_ac_run_r[`IDX_AC_1_1]   <= `RUN_AC_1_1;
    rom_ac_run_r[`IDX_AC_1_2]   <= `RUN_AC_1_2;
    rom_ac_run_r[`IDX_AC_1_3]   <= `RUN_AC_1_3;
    rom_ac_run_r[`IDX_AC_1_4]   <= `RUN_AC_1_4;
    rom_ac_run_r[`IDX_AC_1_5]   <= `RUN_AC_1_5;
    rom_ac_run_r[`IDX_AC_1_6]   <= `RUN_AC_1_6;
    rom_ac_run_r[`IDX_AC_1_7]   <= `RUN_AC_1_7;
    rom_ac_run_r[`IDX_AC_1_8]   <= `RUN_AC_1_8;
    rom_ac_run_r[`IDX_AC_1_9]   <= `RUN_AC_1_9;
    rom_ac_run_r[`IDX_AC_1_10]  <= `RUN_AC_1_10;
    rom_ac_run_r[`IDX_AC_2_1]   <= `RUN_AC_2_1;
    rom_ac_run_r[`IDX_AC_2_2]   <= `RUN_AC_2_2;
    rom_ac_run_r[`IDX_AC_2_3]   <= `RUN_AC_2_3;
    rom_ac_run_r[`IDX_AC_2_4]   <= `RUN_AC_2_4;
    rom_ac_run_r[`IDX_AC_2_5]   <= `RUN_AC_2_5;
    rom_ac_run_r[`IDX_AC_2_6]   <= `RUN_AC_2_6;
    rom_ac_run_r[`IDX_AC_2_7]   <= `RUN_AC_2_7;
    rom_ac_run_r[`IDX_AC_2_8]   <= `RUN_AC_2_8;
    rom_ac_run_r[`IDX_AC_2_9]   <= `RUN_AC_2_9;
    rom_ac_run_r[`IDX_AC_2_10]  <= `RUN_AC_2_10;
    rom_ac_run_r[`IDX_AC_3_1]   <= `RUN_AC_3_1;
    rom_ac_run_r[`IDX_AC_3_2]   <= `RUN_AC_3_2;
    rom_ac_run_r[`IDX_AC_3_3]   <= `RUN_AC_3_3;
    rom_ac_run_r[`IDX_AC_3_4]   <= `RUN_AC_3_4;
    rom_ac_run_r[`IDX_AC_3_5]   <= `RUN_AC_3_5;
    rom_ac_run_r[`IDX_AC_3_6]   <= `RUN_AC_3_6;
    rom_ac_run_r[`IDX_AC_3_7]   <= `RUN_AC_3_7;
    rom_ac_run_r[`IDX_AC_3_8]   <= `RUN_AC_3_8;
    rom_ac_run_r[`IDX_AC_3_9]   <= `RUN_AC_3_9;
    rom_ac_run_r[`IDX_AC_3_10]  <= `RUN_AC_3_10;
    rom_ac_run_r[`IDX_AC_4_1]   <= `RUN_AC_4_1;
    rom_ac_run_r[`IDX_AC_4_2]   <= `RUN_AC_4_2;
    rom_ac_run_r[`IDX_AC_4_3]   <= `RUN_AC_4_3;
    rom_ac_run_r[`IDX_AC_4_4]   <= `RUN_AC_4_4;
    rom_ac_run_r[`IDX_AC_4_5]   <= `RUN_AC_4_5;
    rom_ac_run_r[`IDX_AC_4_6]   <= `RUN_AC_4_6;
    rom_ac_run_r[`IDX_AC_4_7]   <= `RUN_AC_4_7;
    rom_ac_run_r[`IDX_AC_4_8]   <= `RUN_AC_4_8;
    rom_ac_run_r[`IDX_AC_4_9]   <= `RUN_AC_4_9;
    rom_ac_run_r[`IDX_AC_4_10]  <= `RUN_AC_4_10;
    rom_ac_run_r[`IDX_AC_5_1]   <= `RUN_AC_5_1;
    rom_ac_run_r[`IDX_AC_5_2]   <= `RUN_AC_5_2;
    rom_ac_run_r[`IDX_AC_5_3]   <= `RUN_AC_5_3;
    rom_ac_run_r[`IDX_AC_5_4]   <= `RUN_AC_5_4;
    rom_ac_run_r[`IDX_AC_5_5]   <= `RUN_AC_5_5;
    rom_ac_run_r[`IDX_AC_5_6]   <= `RUN_AC_5_6;
    rom_ac_run_r[`IDX_AC_5_7]   <= `RUN_AC_5_7;
    rom_ac_run_r[`IDX_AC_5_8]   <= `RUN_AC_5_8;
    rom_ac_run_r[`IDX_AC_5_9]   <= `RUN_AC_5_9;
    rom_ac_run_r[`IDX_AC_5_10]  <= `RUN_AC_5_10;
    rom_ac_run_r[`IDX_AC_6_1]   <= `RUN_AC_6_1;
    rom_ac_run_r[`IDX_AC_6_2]   <= `RUN_AC_6_2;
    rom_ac_run_r[`IDX_AC_6_3]   <= `RUN_AC_6_3;
    rom_ac_run_r[`IDX_AC_6_4]   <= `RUN_AC_6_4;
    rom_ac_run_r[`IDX_AC_6_5]   <= `RUN_AC_6_5;
    rom_ac_run_r[`IDX_AC_6_6]   <= `RUN_AC_6_6;
    rom_ac_run_r[`IDX_AC_6_7]   <= `RUN_AC_6_7;
    rom_ac_run_r[`IDX_AC_6_8]   <= `RUN_AC_6_8;
    rom_ac_run_r[`IDX_AC_6_9]   <= `RUN_AC_6_9;
    rom_ac_run_r[`IDX_AC_6_10]  <= `RUN_AC_6_10;
    rom_ac_run_r[`IDX_AC_7_1]   <= `RUN_AC_7_1;
    rom_ac_run_r[`IDX_AC_7_2]   <= `RUN_AC_7_2;
    rom_ac_run_r[`IDX_AC_7_3]   <= `RUN_AC_7_3;
    rom_ac_run_r[`IDX_AC_7_4]   <= `RUN_AC_7_4;
    rom_ac_run_r[`IDX_AC_7_5]   <= `RUN_AC_7_5;
    rom_ac_run_r[`IDX_AC_7_6]   <= `RUN_AC_7_6;
    rom_ac_run_r[`IDX_AC_7_7]   <= `RUN_AC_7_7;
    rom_ac_run_r[`IDX_AC_7_8]   <= `RUN_AC_7_8;
    rom_ac_run_r[`IDX_AC_7_9]   <= `RUN_AC_7_9;
    rom_ac_run_r[`IDX_AC_7_10]  <= `RUN_AC_7_10;
    rom_ac_run_r[`IDX_AC_8_1]   <= `RUN_AC_8_1;
    rom_ac_run_r[`IDX_AC_8_2]   <= `RUN_AC_8_2;
    rom_ac_run_r[`IDX_AC_8_3]   <= `RUN_AC_8_3;
    rom_ac_run_r[`IDX_AC_8_4]   <= `RUN_AC_8_4;
    rom_ac_run_r[`IDX_AC_8_5]   <= `RUN_AC_8_5;
    rom_ac_run_r[`IDX_AC_8_6]   <= `RUN_AC_8_6;
    rom_ac_run_r[`IDX_AC_8_7]   <= `RUN_AC_8_7;
    rom_ac_run_r[`IDX_AC_8_8]   <= `RUN_AC_8_8;
    rom_ac_run_r[`IDX_AC_8_9]   <= `RUN_AC_8_9;
    rom_ac_run_r[`IDX_AC_8_10]  <= `RUN_AC_8_10;
    rom_ac_run_r[`IDX_AC_9_1]   <= `RUN_AC_9_1;
    rom_ac_run_r[`IDX_AC_9_2]   <= `RUN_AC_9_2;
    rom_ac_run_r[`IDX_AC_9_3]   <= `RUN_AC_9_3;
    rom_ac_run_r[`IDX_AC_9_4]   <= `RUN_AC_9_4;
    rom_ac_run_r[`IDX_AC_9_5]   <= `RUN_AC_9_5;
    rom_ac_run_r[`IDX_AC_9_6]   <= `RUN_AC_9_6;
    rom_ac_run_r[`IDX_AC_9_7]   <= `RUN_AC_9_7;
    rom_ac_run_r[`IDX_AC_9_8]   <= `RUN_AC_9_8;
    rom_ac_run_r[`IDX_AC_9_9]   <= `RUN_AC_9_9;
    rom_ac_run_r[`IDX_AC_9_10]  <= `RUN_AC_9_10;
    rom_ac_run_r[`IDX_AC_10_1]  <= `RUN_AC_10_1;
    rom_ac_run_r[`IDX_AC_10_2]  <= `RUN_AC_10_2;
    rom_ac_run_r[`IDX_AC_10_3]  <= `RUN_AC_10_3;
    rom_ac_run_r[`IDX_AC_10_4]  <= `RUN_AC_10_4;
    rom_ac_run_r[`IDX_AC_10_5]  <= `RUN_AC_10_5;
    rom_ac_run_r[`IDX_AC_10_6]  <= `RUN_AC_10_6;
    rom_ac_run_r[`IDX_AC_10_7]  <= `RUN_AC_10_7;
    rom_ac_run_r[`IDX_AC_10_8]  <= `RUN_AC_10_8;
    rom_ac_run_r[`IDX_AC_10_9]  <= `RUN_AC_10_9;
    rom_ac_run_r[`IDX_AC_10_10] <= `RUN_AC_10_10;
    rom_ac_run_r[`IDX_AC_11_1]  <= `RUN_AC_11_1;
    rom_ac_run_r[`IDX_AC_11_2]  <= `RUN_AC_11_2;
    rom_ac_run_r[`IDX_AC_11_3]  <= `RUN_AC_11_3;
    rom_ac_run_r[`IDX_AC_11_4]  <= `RUN_AC_11_4;
    rom_ac_run_r[`IDX_AC_11_5]  <= `RUN_AC_11_5;
    rom_ac_run_r[`IDX_AC_11_6]  <= `RUN_AC_11_6;
    rom_ac_run_r[`IDX_AC_11_7]  <= `RUN_AC_11_7;
    rom_ac_run_r[`IDX_AC_11_8]  <= `RUN_AC_11_8;
    rom_ac_run_r[`IDX_AC_11_9]  <= `RUN_AC_11_9;
    rom_ac_run_r[`IDX_AC_11_10] <= `RUN_AC_11_10;
    rom_ac_run_r[`IDX_AC_12_1]  <= `RUN_AC_12_1;
    rom_ac_run_r[`IDX_AC_12_2]  <= `RUN_AC_12_2;
    rom_ac_run_r[`IDX_AC_12_3]  <= `RUN_AC_12_3;
    rom_ac_run_r[`IDX_AC_12_4]  <= `RUN_AC_12_4;
    rom_ac_run_r[`IDX_AC_12_5]  <= `RUN_AC_12_5;
    rom_ac_run_r[`IDX_AC_12_6]  <= `RUN_AC_12_6;
    rom_ac_run_r[`IDX_AC_12_7]  <= `RUN_AC_12_7;
    rom_ac_run_r[`IDX_AC_12_8]  <= `RUN_AC_12_8;
    rom_ac_run_r[`IDX_AC_12_9]  <= `RUN_AC_12_9;
    rom_ac_run_r[`IDX_AC_12_10] <= `RUN_AC_12_10;
    rom_ac_run_r[`IDX_AC_13_1]  <= `RUN_AC_13_1;
    rom_ac_run_r[`IDX_AC_13_2]  <= `RUN_AC_13_2;
    rom_ac_run_r[`IDX_AC_13_3]  <= `RUN_AC_13_3;
    rom_ac_run_r[`IDX_AC_13_4]  <= `RUN_AC_13_4;
    rom_ac_run_r[`IDX_AC_13_5]  <= `RUN_AC_13_5;
    rom_ac_run_r[`IDX_AC_13_6]  <= `RUN_AC_13_6;
    rom_ac_run_r[`IDX_AC_13_7]  <= `RUN_AC_13_7;
    rom_ac_run_r[`IDX_AC_13_8]  <= `RUN_AC_13_8;
    rom_ac_run_r[`IDX_AC_13_9]  <= `RUN_AC_13_9;
    rom_ac_run_r[`IDX_AC_13_10] <= `RUN_AC_13_10;
    rom_ac_run_r[`IDX_AC_14_1]  <= `RUN_AC_14_1;
    rom_ac_run_r[`IDX_AC_14_2]  <= `RUN_AC_14_2;
    rom_ac_run_r[`IDX_AC_14_3]  <= `RUN_AC_14_3;
    rom_ac_run_r[`IDX_AC_14_4]  <= `RUN_AC_14_4;
    rom_ac_run_r[`IDX_AC_14_5]  <= `RUN_AC_14_5;
    rom_ac_run_r[`IDX_AC_14_6]  <= `RUN_AC_14_6;
    rom_ac_run_r[`IDX_AC_14_7]  <= `RUN_AC_14_7;
    rom_ac_run_r[`IDX_AC_14_8]  <= `RUN_AC_14_8;
    rom_ac_run_r[`IDX_AC_14_9]  <= `RUN_AC_14_9;
    rom_ac_run_r[`IDX_AC_14_10] <= `RUN_AC_14_10;
    rom_ac_run_r[`IDX_AC_15_1]  <= `RUN_AC_15_1;
    rom_ac_run_r[`IDX_AC_15_2]  <= `RUN_AC_15_2;
    rom_ac_run_r[`IDX_AC_15_3]  <= `RUN_AC_15_3;
    rom_ac_run_r[`IDX_AC_15_4]  <= `RUN_AC_15_4;
    rom_ac_run_r[`IDX_AC_15_5]  <= `RUN_AC_15_5;
    rom_ac_run_r[`IDX_AC_15_6]  <= `RUN_AC_15_6;
    rom_ac_run_r[`IDX_AC_15_7]  <= `RUN_AC_15_7;
    rom_ac_run_r[`IDX_AC_15_8]  <= `RUN_AC_15_8;
    rom_ac_run_r[`IDX_AC_15_9]  <= `RUN_AC_15_9;
    rom_ac_run_r[`IDX_AC_15_10] <= `RUN_AC_15_10;
    rom_ac_run_r[`IDX_AC_15_0]  <= `RUN_AC_15_0;
end
endtask

integer i;
integer j;
always @* begin
    nd_blk_son_cmb = `LOW;
    dc_degerlendir_ns = dc_degerlendir_r;
    dc_oku_boyut_ns = dc_oku_boyut_r;
    dc_ptr_ns = dc_ptr_r;
    last_dc_blk_ns = last_dc_blk_r;
    hd_durum_ns = hd_durum_r;
    m_hazir_ns = m_hazir_r;
    buf_girdi_ns = buf_girdi_r;
    ptr_buf_oku_ns = ptr_buf_oku_r;
    ptr_buf_yaz_ns = ptr_buf_yaz_r;
    nd_run_ns = nd_run_r;
    nd_cat_ns = nd_cat_r;
    nd_data_ns = nd_data_r;
    nd_gecerli_ns = nd_gecerli_r;
    ptr_coz_ns = ptr_coz_r;
    buf_bos_ns = buf_bos_r;
    coz_satir_gecerli_ns = coz_satir_gecerli_r;
    guncel_gecerli_bit_cmb = 0;
    gecmis_gecerli_bit_cmb = 0;
    buf_oku_gecmis_ns = `LOW;

    dc_data_cmb = last_dc_blk_r;
    dc_valid_cmb = `LOW;

    ac_satir_one_hot_cmb = (coz_satir_gecerli_r != 0) && ((coz_satir_gecerli_r & (coz_satir_gecerli_r - 1)) == 0);
    dc_one_hot_cmb = (dc_degerlendir_r != 0) && ((dc_degerlendir_r & (dc_degerlendir_r - 1)) == 0);

    ac_satir_one_hot_idx_cmb = 0;
    for (i = 0; i < `HD_AC_TABLO_ROW; i = i + 1) begin
        if (coz_satir_gecerli_r[i]) begin
            ac_satir_one_hot_idx_cmb = i;
        end
    end

    dc_one_hot_idx = 0;
    for (i = 0; i < 12; i = i + 1) begin
        if (dc_degerlendir_r[i]) begin
            dc_one_hot_idx = i;
        end
    end

    dc_diff_cmb = 0;
    for (i = 0; i < 11; i = i + 1) begin
        dc_diff_cmb[i] = i < dc_oku_boyut_r ? buf_girdi_r[(ptr_buf_oku_r + dc_oku_boyut_r - i - 1) % `HD_BUF_BIT]
                                            : 0;
    end

    if (!buf_girdi_r[ptr_buf_oku_r]) begin
        dc_diff_cmb = ~(~dc_diff_cmb & ~(~0 << dc_oku_boyut_r)) + 1;
    end
    
    for (i = 0; i < `HD_COZ_ADIM; i = i + 1) begin
        buf_adim_veri_cmb[`HD_COZ_ADIM - i - 1] = buf_girdi_r[(ptr_buf_oku_r + i) % `HD_BUF_BIT];
    end

    // Su anki adimda tablodaki hangi veriler degerlendiriliyor
    for (i = 0; i < `HD_AC_TABLO_ROW; i = i + 1) begin
        ac_huffman_adim_gecerli_cmb[i] = rom_ac_gecerli_r[i][`HD_AC_TABLO_BIT - `HD_COZ_ADIM - ptr_coz_r +: `HD_COZ_ADIM];
        for (j = 0; j < `HD_COZ_ADIM; j = j + 1) begin
            if (!ac_huffman_adim_gecerli_cmb[i][j] || (`HD_COZ_ADIM - j - 1) >= buf_veri_sayisi_w) begin
                ac_huffman_adim_bit_cmb[i][j] = buf_adim_veri_cmb[j];
            end
            else begin
                ac_huffman_adim_bit_cmb[i][j] = rom_ac_huffman_r[i][`HD_AC_TABLO_BIT - `HD_COZ_ADIM - ptr_coz_r + j];
            end
        end
    end

    if (m_gecerli_i && m_hazir_o) begin
        for (i = 0; i < `AC_IN_BIT; i = i + 1) begin
            buf_girdi_ns[(ptr_buf_yaz_r + i) % `HD_BUF_BIT] = m_veri_i[`AC_IN_BIT - i - 1];
        end
        ptr_buf_yaz_ns = (ptr_buf_yaz_r + `AC_IN_BIT) % `HD_BUF_BIT;
        buf_bos_ns = `LOW;
    end

    case(hd_durum_r)
    DURUM_BOSTA: begin
        if (!buf_bos_r) begin
            ptr_coz_ns = 'd0;
            coz_satir_gecerli_ns = {`HD_AC_TABLO_ROW{`HIGH}};
            dc_ptr_ns = 0;
            hd_durum_ns = DURUM_DC_COZ;
            dc_degerlendir_ns = 12'hFFF;
        end
    end
    DURUM_DC_COZ: begin
        if (dc_one_hot_cmb) begin
            hd_durum_ns = DURUM_DC_OKU;
            dc_oku_boyut_ns = dc_one_hot_idx;
            dc_ptr_ns = 0;
        end
        else if (buf_veri_sayisi_w > 0) begin
            dc_ptr_ns = dc_ptr_r + 1;
            ptr_buf_oku_ns = (ptr_buf_oku_r + 1) % `HD_BUF_BIT;
            for (i = 0; i < 12; i = i + 1) begin
                if (rom_dc_gecerli_r[i][8 - dc_ptr_r] && (rom_dc_bit_r[i][8 - dc_ptr_r] != buf_girdi_r[ptr_buf_oku_r])) begin
                    dc_degerlendir_ns[i] = `LOW;
                end
            end
        end
    end
    DURUM_DC_OKU: begin
        if (buf_veri_sayisi_w >= dc_oku_boyut_r) begin
            last_dc_blk_ns = last_dc_blk_r + dc_diff_cmb;
            ptr_buf_oku_ns = (ptr_buf_oku_r + dc_oku_boyut_r) % `HD_BUF_BIT;
            hd_durum_ns = DURUM_VERI_GONDER;
            nd_data_ns = last_dc_blk_r + dc_diff_cmb;
            nd_gecerli_ns = `HIGH;
            nd_run_ns = 0; 
        end
    end 
    DURUM_VERI_GONDER: begin
        if (nd_gecerli_o && nd_hazir_i) begin
            hd_durum_ns = DURUM_AC_COZ;
            nd_gecerli_ns = `LOW; 
        end
    end
    DURUM_AC_COZ: begin
        if (ac_satir_one_hot_cmb) begin
            nd_run_ns = rom_ac_run_r[ac_satir_one_hot_idx_cmb];
            nd_cat_ns = rom_ac_cat_r[ac_satir_one_hot_idx_cmb];
            if (rom_ac_run_r[ac_satir_one_hot_idx_cmb] == 0 && rom_ac_cat_r[ac_satir_one_hot_idx_cmb] == 0) begin
                nd_blk_son_cmb = `HIGH;
                hd_durum_ns = DURUM_BOSTA;
            end
            else begin
                buf_oku_gecmis_ns = buf_oku_gecmis_r;
                hd_durum_ns = DURUM_COZ_KONTROL;
            end
        end
        else begin
            for (i = 0; i < `HD_AC_TABLO_ROW; i = i + 1) begin
                if (ac_huffman_adim_bit_cmb[i] != buf_adim_veri_cmb) begin
                    coz_satir_gecerli_ns[i] = `LOW;
                end
            end
            if (buf_veri_sayisi_w >= `HD_COZ_ADIM) begin
                ptr_buf_oku_ns = (ptr_buf_oku_r + `HD_COZ_ADIM) % `HD_BUF_BIT;
                ptr_coz_ns = ptr_coz_r + `HD_COZ_ADIM;
                buf_oku_gecmis_ns = `HIGH;
            end
        end
    end
    DURUM_AC_OKU: begin
        if (buf_veri_sayisi_w >= dc_oku_boyut_r) begin
            ptr_buf_oku_ns = (ptr_buf_oku_r + dc_oku_boyut_r) % `HD_BUF_BIT;
            nd_data_ns = dc_diff_cmb;
            nd_gecerli_ns = `HIGH;
            hd_durum_ns = DURUM_VERI_GONDER;
        end
    end
    DURUM_COZ_KONTROL: begin
        // Cozucu eger arabellekte veri varsa spekulatif olarak okuma imlecini HD_COZ_ADIM ilerletiyor.
        // Bu nedenle asagidaki 2 durumun cozme tamamlandiginda kontrol edilmesi lazim:
        // 1. Cozulen degere ait olmayan bitler okuduysak imlecin geri goturulmesi
        // 2. Arabellekte HD_COZ_ADIM bit kalmamisken kalan veri cozulebilmisse imlecin ilerletilmesi
        gecmis_gecerli_bit_cmb = 0;
        for (i = 0; i < `HD_COZ_ADIM; i = i + 1) begin
            if (rom_ac_gecerli_r[ac_satir_one_hot_idx_cmb][`HD_AC_TABLO_BIT - ptr_coz_r + `HD_COZ_ADIM - i - 1]) begin
                gecmis_gecerli_bit_cmb = gecmis_gecerli_bit_cmb + 1;
            end 
        end
        guncel_gecerli_bit_cmb = 0;
        for (i = 0; i < `HD_COZ_ADIM; i = i + 1) begin
            if (rom_ac_gecerli_r[ac_satir_one_hot_idx_cmb][`HD_AC_TABLO_BIT - ptr_coz_r - i - 1]) begin
                guncel_gecerli_bit_cmb = guncel_gecerli_bit_cmb + 1;
            end 
        end
        ptr_buf_oku_ns = buf_oku_gecmis_r   ? (ptr_buf_oku_r - (`HD_COZ_ADIM - gecmis_gecerli_bit_cmb)) % `HD_BUF_BIT
                                            : (ptr_buf_oku_r + guncel_gecerli_bit_cmb) % `HD_BUF_BIT;

        dc_oku_boyut_ns = nd_cat_r; 
        ptr_coz_ns = 'd0;
        coz_satir_gecerli_ns = {`HD_AC_TABLO_ROW{`HIGH}};
        hd_durum_ns = DURUM_AC_OKU;
    end
    endcase

    m_hazir_ns = buf_bos_r || !(ptr_buf_oku_ns == ptr_buf_yaz_ns);
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        rom_dc_init();
        rom_ac_init(); // Openlanede initial begin yok?
        hd_durum_r <= DURUM_BOSTA;
        buf_girdi_r <= {`HD_BUF_BIT{1'b0}};
        ptr_buf_oku_r <= {$clog2(`HD_BUF_BIT){1'b0}};
        ptr_buf_yaz_r <= {$clog2(`HD_BUF_BIT){1'b0}};
        m_hazir_r <= `LOW;
        buf_bos_r <= `HIGH;
        nd_run_r <= {`RUN_BIT{1'b0}};
        nd_cat_r <= {`CAT_BIT{1'b0}};
        nd_data_r <= {`HDATA_BIT{1'b0}};
        nd_gecerli_r <= `LOW;
        ptr_coz_r <= 'd0;
        coz_satir_gecerli_r <= 0;
        buf_oku_gecmis_r <= `LOW;
        dc_ptr_r <= 0;
        last_dc_blk_r <= 0;
        dc_degerlendir_r <= 0;
        dc_oku_boyut_r <= 0;
    end
    else begin
        hd_durum_r <= hd_durum_ns;
        buf_girdi_r <= buf_girdi_ns;
        ptr_buf_oku_r <= ptr_buf_oku_ns;
        ptr_buf_yaz_r <= ptr_buf_yaz_ns;
        m_hazir_r <= m_hazir_ns;
        buf_bos_r <= buf_bos_ns;
        nd_run_r <= nd_run_ns;
        nd_cat_r <= nd_cat_ns;
        nd_data_r <= nd_data_ns;
        nd_gecerli_r <= nd_gecerli_ns;
        ptr_coz_r <= ptr_coz_ns;
        coz_satir_gecerli_r <= coz_satir_gecerli_ns;
        buf_oku_gecmis_r <= buf_oku_gecmis_ns;
        dc_ptr_r <= dc_ptr_ns;
        last_dc_blk_r <= last_dc_blk_ns;
        dc_degerlendir_r <= dc_degerlendir_ns;
        dc_oku_boyut_r <= dc_oku_boyut_ns;
    end
end

assign buf_veri_sayisi_w = ptr_buf_yaz_r > ptr_buf_oku_r ? ptr_buf_yaz_r - ptr_buf_oku_r : ptr_buf_oku_r - ptr_buf_yaz_r;

assign m_hazir_o = m_hazir_r;
assign nd_run_o = nd_run_r;
assign nd_data_o = nd_data_r;
assign nd_gecerli_o = nd_gecerli_r;
assign nd_blk_son_o = nd_blk_son_cmb;

endmodule 