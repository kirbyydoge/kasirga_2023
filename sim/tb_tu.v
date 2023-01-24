`timescale 1ns/1ps

module tb_tu();

reg                           clk_i;
reg                           rstn_i;
reg   [`PIXEL_BIT-1:0]        idct_veri_i;
reg   [`BLOCK_BIT-1:0]        idct_row_i;
reg   [`BLOCK_BIT-1:0]        idct_col_i;
reg                           idct_gecerli_i;
reg                           idct_blok_son_i;
wire                          idct_hazir_o;
wire  [`PIXEL_BIT-1:0]        res_veri_o;
wire  [`IMG_WIDTH_BIT-1:0]    res_col_o;
wire  [`IMG_HEIGHT_BIT-1:0]   res_row_o;
wire                          res_gecerli_o;
reg                           res_hazir_i;
wire                          res_bitti_o;

task_unit uut (
    .clk_i           ( clk_i ),
    .rstn_i          ( rstn_i ),
    .idct_veri_i     ( idct_veri_i ),
    .idct_row_i      ( idct_row_i ),
    .idct_col_i      ( idct_col_i ),
    .idct_gecerli_i  ( idct_gecerli_i ),
    .idct_blok_son_i ( idct_blok_son_i ),
    .idct_hazir_o    ( idct_hazir_o ),
    .res_veri_o      ( res_veri_o ),
    .res_col_o       ( res_col_o ),
    .res_row_o       ( res_row_o ),
    .res_gecerli_o   ( res_gecerli_o ),
    .res_hazir_i     ( res_hazir_i ),
    .res_bitti_o     ( res_bitti_o )
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

integer i;
reg fire;
initial begin
    rstn_i = 1'b0;
    idct_veri_i = 0;
    idct_row_i = 0;
    idct_col_i = 0;
    idct_gecerli_i = 0;
    idct_blok_son_i = 0;
    res_hazir_i = 0;
    repeat (20) @(posedge clk_i);
    rstn_i = 1'b1;
    res_hazir_i = 1;
    for (i = 0; i < 64;) begin
        idct_veri_i = i;
        idct_row_i = i / 8;
        idct_col_i = i % 8;
        idct_gecerli_i = 1;
        fire = idct_gecerli_i && idct_hazir_o;
        @(posedge clk_i) #2;
        if (fire) begin
            i = i + 1;
        end
    end
    idct_gecerli_i = 0;
    for (i = 0; i < 64;) begin
        idct_veri_i = i;
        idct_row_i = i / 8;
        idct_col_i = i % 8;
        idct_gecerli_i = 1;
        fire = idct_gecerli_i && idct_hazir_o;
        @(posedge clk_i) #2;
        if (fire) begin
            i = i + 1;
        end
    end
    idct_gecerli_i = 0;
end

endmodule