`timescale 1ns/1ps

`include "sabitler.vh"

module jpeg_coz (
    input                       clk_i,
    input                       rstn_i,

    input   [`WB_BIT-1:0]       m_veri_i,
    input                       m_gecerli_i,
    output                      m_hazir_o,

    output  [`PIXEL_BIT-1:0]    coz_veri_o,
    output                      coz_gecerli_o,
    input                       coz_hazir_i
);

wire [`RUN_BIT-1:0]   hd_nd_run_w;
wire [`CAT_BIT-1:0]   hd_nd_cat_w;
wire                  hd_nd_gecerli_w;

huffman_decoder hd (
    .clk_i        ( clk_i ),
    .rstn_i       ( rstn_i ),
    .m_veri_i     ( m_veri_i ),
    .m_gecerli_i  ( m_gecerli_i ),
    .m_hazir_o    ( m_hazir_o ),
    .nd_run_o     ( hd_nd_run_w ),
    .nd_cat_o     ( hd_nd_cat_w ),
    .nd_gecerli_o ( hd_nd_gecerli_w ),
    .nd_hazir_i   ( zn_hd_hazir_w )
);

wire                      zn_hd_hazir_w;
wire  [`PIXEL_BIT-1:0]    zn_ct_veri_w;
wire  [`BLOCK_BIT-1:0]    zn_ct_row_w;
wire  [`BLOCK_BIT-1:0]    zn_ct_col_w;
wire                      zn_ct_gecerli_w;
wire                      zn_ct_blok_son_w;

zigzag_normalizer zn (
    .clk_i         ( clk_i ),
    .rstn_i        ( rstn_i ),
    .hd_run_i      ( hd_nd_run_w ),
    .hd_cat_i      ( hd_nd_cat_w ),
    .hd_gecerli_i  ( hd_nd_gecerli_w ),
    .hd_hazir_o    ( zn_hd_hazir_w ),
    .ct_veri_o     ( zn_ct_veri_w ),
    .ct_row_o      ( zn_ct_row_w ),
    .ct_col_o      ( zn_ct_col_w ),
    .ct_gecerli_o  ( zn_ct_gecerli_w ),
    .ct_blok_son_o ( zn_ct_blok_son_w ),
    .ct_hazir_i    ( dq_zig_veri_hazir_w )
);

wire                      dq_zig_veri_hazir_w;
wire  [`Q_BIT-1:0]        dq_idct_veri_w;
wire  [`BLOCK_BIT-1:0]    dq_idct_veri_row_w;
wire  [`BLOCK_BIT-1:0]    dq_idct_veri_col_w;
wire                      dq_idct_veri_gecerli_w;

dequantizer dq (
    .clk_i               ( clk_i ),
    .rstn_i              ( rstn_i ),
    .zig_veri_i          ( zn_ct_veri_w ),
    .zig_veri_row_i      ( zn_ct_row_w ),
    .zig_veri_col_i      ( zn_ct_col_w ),
    .zig_veri_gecerli_i  ( zn_ct_gecerli_w ),
    .zig_veri_hazir_o    ( dq_zig_veri_hazir_w ),
    .idct_veri_o         ( dq_idct_veri_w ),
    .idct_veri_row_o     ( dq_idct_veri_row_w ),
    .idct_veri_col_o     ( dq_idct_veri_col_w ),
    .idct_veri_gecerli_o ( dq_idct_veri_gecerli_w ),
    .idct_veri_hazir_i   ( ict_dq_hazir_w )
);

wire                      ict_dq_hazir_w;
wire  [`PIXEL_BIT-1:0]    ict_gd_veri_w;
wire  [`BLOCK_BIT-1:0]    ict_gd_row_w;
wire  [`BLOCK_BIT-1:0]    ict_gd_col_w;
wire                      ict_gd_gecerli_w;
wire                      ict_gd_blok_son_w;

icosine_transformer ict (
    .clk_i          ( clk_i ),
    .rstn_i         ( rstn_i ),
    .dq_veri_i      ( dq_idct_veri_w ),
    .dq_row_i       ( dq_idct_veri_row_w ),
    .dq_col_i       ( dq_idct_veri_col_w ),
    .dq_gecerli_i   ( dq_idct_veri_gecerli_w ),
    .dq_blok_son_i  ( 1'b0 ),
    .dq_hazir_o     ( ict_dq_hazir_w ),
    .gd_veri_o      ( ict_gd_veri_w ),
    .gd_row_o       ( ict_gd_row_w ),
    .gd_col_o       ( ict_gd_col_w ),
    .gd_gecerli_o   ( ict_gd_gecerli_w ),
    .gd_blok_son_o  ( ict_gd_blok_son_w ),
    .gd_hazir_i     ( idct_hazir_w )
);

wire idct_hazir_w;

decode_normalizer denorm (
    .clk_i           ( clk_i ),
    .rstn_i          ( rstn_i ),
    .idct_veri_i     ( ict_gd_veri_w ),
    .idct_row_i      ( ict_gd_row_w ),
    .idct_col_i      ( ict_gd_col_w ),
    .idct_gecerli_i  ( ict_gd_gecerli_w ),
    .idct_blok_son_i ( ict_gd_blok_son_w ),
    .idct_hazir_o    ( idct_hazir_w ),
    .dn_veri_o       ( coz_veri_o ),
    .dn_gecerli_o    ( coz_gecerli_o ),
    .dn_hazir_i      ( coz_hazir_i )
);

endmodule