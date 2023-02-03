`timescale 1ns/1ps

module tb_dn();

reg                           clk_i;
reg                           rstn_i;
reg   [`PIXEL_BIT-1:0]        idct_veri_i;
reg   [`BLOCK_BIT-1:0]        idct_row_i;
reg   [`BLOCK_BIT-1:0]        idct_col_i;
reg                           idct_gecerli_i;
reg                           idct_blok_son_i;
wire                          idct_hazir_o;
wire  [`PIXEL_BIT-1:0]        dn_veri_o;
wire                          dn_gecerli_o;
reg                           dn_hazir_i;

decode_normalizer uut (
    .clk_i           ( clk_i ),
    .rstn_i          ( rstn_i ),
    .idct_veri_i     ( idct_veri_i ),
    .idct_row_i      ( idct_row_i ),
    .idct_col_i      ( idct_col_i ),
    .idct_gecerli_i  ( idct_gecerli_i ),
    .idct_blok_son_i ( idct_blok_son_i ),
    .idct_hazir_o    ( idct_hazir_o ),
    .dn_veri_o       ( dn_veri_o ),
    .dn_gecerli_o    ( dn_gecerli_o ),
    .dn_hazir_i      ( dn_hazir_i )
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

integer i;
integer j;
reg fire;
initial begin
    rstn_i = 1'b0;
    idct_veri_i = 0;
    idct_row_i = 0;
    idct_col_i = 0;
    idct_gecerli_i = 0;
    idct_blok_son_i = 0;
    dn_hazir_i = 0;
    repeat (20) @(posedge clk_i);
    rstn_i = 1'b1;
    dn_hazir_i = 1;
    for (j = 0; j < 120; j = j + 1) begin
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
end

endmodule