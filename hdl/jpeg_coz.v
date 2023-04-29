`timescale 1ns/1ps

`include "sabitler.vh"

module jpeg_coz (
    input                       clk_i,
    input                       rstn_i,

    input   [7:0]               m_veri_i,
    input                       m_gecerli_i,
    output                      m_hazir_o,

    output  [`PIXEL_BIT-1:0]    coz_veri_o,
    output                      coz_gecerli_o,
    input                       coz_hazir_i
);



wire    [`RUN_BIT-1:0]    nd_run_o;
wire    [`HDATA_BIT-1:0]  nd_data_o;
wire                      nd_gecerli_o;
wire                      nd_hazir_i;
wire                      nd_blk_son_o;

wire  [`HDATA_BIT-1:0]    ct_veri_o;
wire  [`BLOCK_BIT-1:0]    ct_row_o;
wire  [`BLOCK_BIT-1:0]    ct_col_o;
wire                      ct_gecerli_o;
wire                      ct_hazir_i = 1;
wire                      ct_blok_son_o;

wire                      dq_zig_veri_hazir_w;
wire  [`Q_BIT-1:0]        dq_idct_veri_w;
wire  [`BLOCK_BIT-1:0]    dq_idct_veri_row_w;
wire  [`BLOCK_BIT-1:0]    dq_idct_veri_col_w;
wire                      dq_idct_veri_gecerli_w;
wire                      dq_idct_blok_son_w;

wire                      ict_dq_hazir_w;
wire  [`PIXEL_BIT-1:0]    ict_gd_veri_w;
wire  [`BLOCK_BIT-1:0]    ict_gd_row_w;
wire  [`BLOCK_BIT-1:0]    ict_gd_col_w;
wire                      ict_gd_gecerli_w;
wire                      ict_gd_blok_son_w;

wire                      idct_hazir_w;


huffman_decoder uut (
    .clk_i         ( clk_i ),
    .rstn_i        ( rstn_i ),
    .m_veri_i      ( m_veri_i ),
    .m_gecerli_i   ( m_gecerli_i ),
    .m_hazir_o     ( m_hazir_o ),
    .nd_run_o      ( nd_run_o ),
    .nd_data_o     ( nd_data_o ),
    .nd_gecerli_o  ( nd_gecerli_o ),
    .nd_hazir_i    ( nd_hazir_i ),
    .nd_blk_son_o  ( nd_blk_son_o )
);

zigzag_normalizer zn (
    .clk_i         ( clk_i ),
    .rstn_i        ( rstn_i ),
    .hd_run_i      ( nd_run_o ),
    .hd_veri_i     ( nd_data_o ),
    .hd_gecerli_i  ( nd_gecerli_o ),
    .hd_son_i      ( nd_blk_son_o ),
    .hd_hazir_o    ( nd_hazir_i ),
    .ct_veri_o     ( ct_veri_o ),
    .ct_row_o      ( ct_row_o ),
    .ct_col_o      ( ct_col_o ),
    .ct_gecerli_o  ( ct_gecerli_o ),
    .ct_blok_son_o ( ct_blok_son_o ),
    .ct_hazir_i    ( dq_zig_veri_hazir_w )
);

dequantizer dq (
    .clk_i               ( clk_i ),
    .rstn_i              ( rstn_i ),
    .zig_veri_i          ( ct_veri_o ),
    .zig_veri_row_i      ( ct_row_o ),
    .zig_veri_col_i      ( ct_col_o ),
    .zig_veri_gecerli_i  ( ct_gecerli_o ),
    .zig_blok_son_i      ( ct_blok_son_o ),
    .zig_veri_hazir_o    ( dq_zig_veri_hazir_w ),
    .idct_veri_o         ( dq_idct_veri_w ),
    .idct_veri_row_o     ( dq_idct_veri_row_w ),
    .idct_veri_col_o     ( dq_idct_veri_col_w ),
    .idct_veri_gecerli_o ( dq_idct_veri_gecerli_w ),
    .idct_blok_son_o     ( dq_idct_blok_son_w ),
    .idct_veri_hazir_i   ( ict_dq_hazir_w )
);

icosine_transformer ict (
    .clk_i          ( clk_i ),
    .rstn_i         ( rstn_i ),
    .dq_veri_i      ( dq_idct_veri_w ),
    .dq_row_i       ( dq_idct_veri_row_w ),
    .dq_col_i       ( dq_idct_veri_col_w ),
    .dq_gecerli_i   ( dq_idct_veri_gecerli_w ),
    .dq_blok_son_i  ( dq_idct_blok_son_w ),
    .dq_hazir_o     ( ict_dq_hazir_w ),
    .gd_veri_o      ( ict_gd_veri_w ),
    .gd_row_o       ( ict_gd_row_w ),
    .gd_col_o       ( ict_gd_col_w ),
    .gd_gecerli_o   ( ict_gd_gecerli_w ),
    .gd_blok_son_o  ( ict_gd_blok_son_w ),
    .gd_hazir_i     ( idct_hazir_w )
);

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