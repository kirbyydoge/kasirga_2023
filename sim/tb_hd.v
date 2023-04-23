`timescale 1ns/1ps

`include "sabitler.vh"

module tb_hd();

localparam TEST_AC_0_0   =  4'b1010;
localparam TEST_AC_0_1   =  2'b00;
localparam TEST_AC_0_2   =  2'b01;
localparam TEST_AC_0_3   =  3'b100;
localparam TEST_AC_0_4   =  4'b1011;
localparam TEST_AC_0_5   =  5'b11010;
localparam TEST_AC_0_6   =  7'b1111000;
localparam TEST_AC_0_7   =  8'b11111000;
localparam TEST_AC_0_8   = 10'b1111110110;
localparam TEST_AC_0_9   = 16'b1111111110000010;
localparam TEST_AC_0_10  = 16'b1111111110000011;

reg                       clk_i;
reg                       rstn_i;
reg     [`WB_BIT-1:0]     m_veri_i;
reg                       m_gecerli_i;
wire                      m_hazir_o;
wire    [10:0]            dc_data_o;
wire                      dc_valid_o;
reg                       dc_ready_i;
wire    [`RUN_BIT-1:0]    nd_run_o;
wire    [`HDATA_BIT-1:0]  nd_data_o;
wire    [`CAT_BIT-1:0]    nd_cat_o;
wire                      nd_gecerli_o;
wire                      nd_hazir_i;
wire                      nd_blk_son_o;

wire  [`HDATA_BIT-1:0]    ct_veri_o;
wire  [`BLOCK_BIT-1:0]    ct_row_o;
wire  [`BLOCK_BIT-1:0]    ct_col_o;
wire                      ct_gecerli_o;
wire                      ct_hazir_i = 1;
wire                      ct_blok_son_o;

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
    .blok_son_i    ( nd_blk_son_o ),
    .hd_run_i      ( nd_run_o ),
    .hd_veri_i     ( nd_data_o ),
    .hd_gecerli_i  ( nd_gecerli_o ),
    .hd_hazir_o    ( nd_hazir_i ),
    .ct_veri_o     ( ct_veri_o ),
    .ct_row_o      ( ct_row_o ),
    .ct_col_o      ( ct_col_o ),
    .ct_gecerli_o  ( ct_gecerli_o ),
    .ct_blok_son_o ( ct_blok_son_o ),
    .ct_hazir_i    ( dq_zig_veri_hazir_w )
);

wire                      dq_zig_veri_hazir_w;
wire  [`Q_BIT-1:0]        dq_idct_veri_w;
wire  [`BLOCK_BIT-1:0]    dq_idct_veri_row_w;
wire  [`BLOCK_BIT-1:0]    dq_idct_veri_col_w;
wire                      dq_idct_veri_gecerli_w;
wire                      dq_idct_blok_son_w;
wire ict_dq_hazir_w;

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
    .dq_blok_son_i  ( dq_idct_blok_son_w ),
    .dq_hazir_o     ( ict_dq_hazir_w ),
    .gd_veri_o      ( ict_gd_veri_w ),
    .gd_row_o       ( ict_gd_row_w ),
    .gd_col_o       ( ict_gd_col_w ),
    .gd_gecerli_o   ( ict_gd_gecerli_w ),
    .gd_blok_son_o  ( ict_gd_blok_son_w ),
    .gd_hazir_i     ( idct_hazir_w )
);

wire idct_hazir_w;
wire[7:0] coz_veri_o;
wire coz_gecerli_o;
wire coz_hazir_i =1;

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

always begin
    clk_i = 1'b1;
    #5;
    clk_i = 1'b0;
    #5;
end

localparam TEST_LEN = 48;
localparam BYTE_LEN = TEST_LEN/8;
reg [TEST_LEN-1:0] temp_deger;
reg [7:0] bytes [0:BYTE_LEN-1];

integer step;

integer i;
initial begin
    dc_ready_i = 1;
    step = 0;
    //temp_deger = 96'b1011_0100011_1111101110111111111110001111100110101011010001111111011101111111111100011111001101000;
    temp_deger = 48'b1011010001111111011101111111111100011111001_10100;
    for (i = 0; i < BYTE_LEN; i = i + 1) begin
        bytes[i] = temp_deger[TEST_LEN - 1 - 8 * i -: 8];
    end
    rstn_i = 1'b0;
    m_gecerli_i = 0;
    repeat(20) @(posedge clk_i);
    rstn_i = 1'b1;

    for (i = 0; i < BYTE_LEN;) begin
        m_veri_i = bytes[i];
        m_gecerli_i = 1;
        @(posedge clk_i); #2;
        if (m_gecerli_i && m_hazir_o) begin
            i = i + 1;
        end
    end
    m_gecerli_i = 1'b0;
end

endmodule