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
    .ct_hazir_i    ( ct_hazir_i )
);

always begin
    clk_i = 1'b1;
    #5;
    clk_i = 1'b0;
    #5;
end

localparam TEST_LEN = 96;
localparam BYTE_LEN = TEST_LEN/8;
reg [TEST_LEN-1:0] temp_deger;
reg [7:0] bytes [0:BYTE_LEN-1];

integer step;

integer i;
initial begin
    dc_ready_i = 1;
    step = 0;
    temp_deger = 96'b101101000111111101110111111111110001111100110101011010001111111011101111111111100011111001101000;
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