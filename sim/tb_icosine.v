`timescale 1ns/1ps

`include "sabitler.vh"
`include "idctii.vh"

module tb_icosine();

reg                         clk_i;
reg                         rstn_i;
reg     [`Q_BIT-1:0]        dq_veri_i;
reg     [`BLOCK_BIT-1:0]    dq_row_i;
reg     [`BLOCK_BIT-1:0]    dq_col_i;
reg                         dq_gecerli_i;
reg                         dq_blok_son_i;
wire                        dq_hazir_o;
wire    [`PIXEL_BIT-1:0]    gd_veri_o;
wire    [`BLOCK_BIT-1:0]    gd_row_o;
wire    [`BLOCK_BIT-1:0]    gd_col_o;
wire                        gd_gecerli_o;
wire                        gd_blok_son_o;
reg                         gd_hazir_i;

icosine_transformer uut (
    .clk_i         ( clk_i ),
    .rstn_i        ( rstn_i ),
    .dq_veri_i     ( dq_veri_i ),
    .dq_row_i      ( dq_row_i ),
    .dq_col_i      ( dq_col_i ),
    .dq_gecerli_i  ( dq_gecerli_i ),
    .dq_blok_son_i ( dq_blok_son_i ),
    .dq_hazir_o    ( dq_hazir_o ),
    .gd_veri_o     ( gd_veri_o ),
    .gd_row_o      ( gd_row_o ),
    .gd_col_o      ( gd_col_o ),
    .gd_gecerli_o  ( gd_gecerli_o ),
    .gd_blok_son_o ( gd_blok_son_o ),
    .gd_hazir_i    ( gd_hazir_i )
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

integer i;
reg handshake;
initial begin
    rstn_i = 1'b0;
    repeat(20) @(posedge clk_i);
    rstn_i = 1'b1;
    gd_hazir_i = 1'b1;

    for (i = 0; i < 64;) begin
        dq_veri_i = 0;
        dq_veri_i[`Q_INT] = i * 64;
        dq_row_i = i / 8;
        dq_col_i = i % 8;
        dq_gecerli_i = 1'b1;
        dq_blok_son_i = i == 63;
        handshake = dq_hazir_o && dq_gecerli_i;
        @(posedge clk_i) #2;
        if (handshake) begin
            i = i + 1;
        end
    end
    dq_blok_son_i = 1'b0;
    dq_gecerli_i = 1'b0;
end

endmodule