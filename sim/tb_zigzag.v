`timescale 1ns/1ps

`include "sabitler.vh"

module tb_zigzag();

reg                       clk_i;
reg                       rstn_i;
reg   [`RUN_BIT-1:0]      hd_run_i;
reg   [`CAT_BIT-1:0]      hd_cat_i;
reg                       hd_gecerli_i;
wire                      hd_hazir_o;
wire  [`PIXEL_BIT-1:0]    ct_veri_o;
wire  [`BLOCK_BIT-1:0]    ct_row_o;
wire  [`BLOCK_BIT-1:0]    ct_col_o;
wire                      ct_gecerli_o;
wire                      ct_blok_son_o;
reg                       ct_hazir_i;

zigzag_normalizer zn (
    .clk_i         ( clk_i ),
    .rstn_i        ( rstn_i ),
    .hd_run_i      ( hd_run_i ),
    .hd_cat_i      ( hd_cat_i ),
    .hd_gecerli_i  ( hd_gecerli_i ),
    .hd_hazir_o    ( hd_hazir_o ),
    .ct_veri_o     ( ct_veri_o ),
    .ct_row_o      ( ct_row_o ),
    .ct_col_o      ( ct_col_o ),
    .ct_gecerli_o  ( ct_gecerli_o ),
    .ct_blok_son_o ( ct_blok_son_o ),
    .ct_hazir_i    ( ct_hazir_i )
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

integer i;
localparam TEST_LEN = 8;
reg [`RUN_BIT-1:0] test_runs [0:TEST_LEN-1]; 
reg [`RUN_BIT-1:0] test_cats [0:TEST_LEN-1]; 
reg handshake;

initial begin
    test_runs['d0 ] = 0;
    test_runs['d1 ] = 3;
    test_runs['d2 ] = 1;
    test_runs['d3 ] = 0;
    test_runs['d4 ] = 10;
    test_runs['d5 ] = 5;
    test_runs['d6 ] = 5;

    test_cats['d0 ] = 1;
    test_cats['d1 ] = 2;
    test_cats['d2 ] = 3;
    test_cats['d3 ] = 4;
    test_cats['d4 ] = 5;
    test_cats['d5 ] = 6;
    test_cats['d6 ] = 7;

    test_runs[TEST_LEN-1] = 0;
    test_cats[TEST_LEN-1] = 0;
    rstn_i = 1'b0;
    handshake = `LOW;
    ct_hazir_i = `HIGH;
    repeat (20) @(posedge clk_i) #2;
    rstn_i = 1'b1;
    
    for (i = 0; i < TEST_LEN;) begin
        hd_run_i = test_runs[i];
        hd_cat_i = test_cats[i];
        hd_gecerli_i = `HIGH;
        handshake = hd_hazir_o && hd_gecerli_i;
        @(posedge clk_i) #2;
        if (handshake) begin
            i = i + 1;
        end
    end
    hd_gecerli_i = `LOW;
end

endmodule