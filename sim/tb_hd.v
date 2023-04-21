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
wire    [`CAT_BIT-1:0]    nd_cat_o;
wire                      nd_gecerli_o;
reg                       nd_hazir_i;

huffman_decoder uut (
    .clk_i         ( clk_i ),
    .rstn_i        ( rstn_i ),
    .m_veri_i      ( m_veri_i ),
    .m_gecerli_i   ( m_gecerli_i ),
    .m_hazir_o     ( m_hazir_o ),
    .dc_data_o     ( dc_data_o ),
    .dc_valid_o    ( dc_valid_o ),
    .dc_ready_i    ( dc_ready_i ),
    .nd_run_o      ( nd_run_o ),
    .nd_cat_o      ( nd_cat_o ),
    .nd_gecerli_o  ( nd_gecerli_o ),
    .nd_hazir_i    ( nd_hazir_i )
);

always begin
    clk_i = 1'b1;
    #5;
    clk_i = 1'b0;
    #5;
end

localparam TEST_LEN = 32;
reg [TEST_LEN-1:0] test_deger; 

integer i;
initial begin
    dc_ready_i = 1;
    // test_deger = {TEST_AC_0_0, TEST_AC_0_2, TEST_AC_0_1, TEST_AC_0_9, TEST_AC_0_5, TEST_AC_0_3};
    test_deger = {8'b10101110};
    rstn_i = 1'b0;
    m_veri_i = test_deger;
    m_gecerli_i = 0;
    nd_hazir_i = 0;
    repeat(20) @(posedge clk_i);
    m_gecerli_i = 1'b1;
    rstn_i = 1'b1;
    wait(m_gecerli_i && m_hazir_o);
    @(posedge clk_i); #2;
    m_gecerli_i = 1'b0;
end

endmodule