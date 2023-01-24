`timescale 1ns/1ps

`include "sabitler.vh"

module task_unit (
    input                           clk_i,
    input                           rstn_i,

    input   [`PIXEL_BIT-1:0]        idct_veri_i,
    input   [`BLOCK_BIT-1:0]        idct_row_i,
    input   [`BLOCK_BIT-1:0]        idct_col_i,
    input                           idct_gecerli_i,
    input                           idct_blok_son_i,
    output                          idct_hazir_o,

    output  [`PIXEL_BIT-1:0]        res_veri_o,
    output  [`IMG_HEIGHT_BIT-1:0]   res_row_o,
    output  [`IMG_WIDTH_BIT-1:0]    res_col_o,
    output                          res_gecerli_o,
    input                           res_hazir_i,

    output                          res_bitti_o
);

localparam SATIR_WIDTH = `IMG_WIDTH + `GB_FILTER_WEDGE;

reg [`PIXEL_BIT-1:0] gecmis_satir_r [0:2*SATIR_WIDTH-1];
reg [`PIXEL_BIT-1:0] gecmis_satir_ns [0:2*SATIR_WIDTH-1];

reg [`PIXEL_BIT-1:0] gecmis_sutun_r [0:2*`BLOCK_SIZE-1];
reg [`PIXEL_BIT-1:0] gecmis_sutun_ns [0:2*`BLOCK_SIZE-1];

reg [`PIXEL_BIT-1:0] aktif_gecmis_sutun_r [0:2*`BLOCK_SIZE-1];
reg [`PIXEL_BIT-1:0] aktif_gecmis_sutun_ns [0:2*`BLOCK_SIZE-1];

reg [`PIXEL_BIT-1:0] buf_satir_r [0:`GB_FILTER_SIZE*`BLOCK_SIZE-1];
reg [`PIXEL_BIT-1:0] buf_satir_ns [0:`GB_FILTER_SIZE*`BLOCK_SIZE-1];

localparam DURUM_BOSTA       = 0; // Test Gorevi
localparam DURUM_GOREV0_INIT = 1; // Test Gorevi
localparam DURUM_GOREV0_MUL0 = 2;
localparam DURUM_GOREV0_MUL1 = 3;
localparam DURUM_GOREV0_END  = 4;
localparam DURUM_GOREV1_INIT = 5; // Edge Detection

reg [2:0] durum_r;
reg [2:0] durum_ns;

reg [`BLOCK_BIT:0] islem_row_r;
reg [`BLOCK_BIT:0] islem_row_ns;

reg [`BLOCK_BIT:0] islem_col_r;
reg [`BLOCK_BIT:0] islem_col_ns;

reg [`BLOCK_AREA_BIT:0] ptr_yukle_r;
reg [`BLOCK_AREA_BIT:0] ptr_yukle_ns;

reg [`IMG_BLOCKS_BIT-1:0] ptr_blok_r;
reg [`IMG_BLOCKS_BIT-1:0] ptr_blok_ns;

reg [`PIXEL_BIT-1:0] aktif_filtre_r [0:`GB_FILTER_AREA-1];
reg [`PIXEL_BIT-1:0] aktif_filtre_ns [0:`GB_FILTER_AREA-1];

reg [`PIXEL_BIT*`GB_FILTER_AREA-1:0] veri_pencere_cmb;
reg [`PIXEL_BIT*`GB_FILTER_AREA-1:0] veri_agirlik_cmb;

wire [`BLOCK_BIT-1:0] yukle_row_w;
wire [`BLOCK_BIT-1:0] yukle_col_w;

reg idct_hazir_cmb;
reg islem_gecerli_cmb;

function [`BLOCK_BIT-1:0] get_row_block (
    input [`BLOCK_AREA_BIT-1:0] index
);
begin
    // require(`BLOCK_BIT == 2**k) for some k
    get_row_block = index / `BLOCK_SIZE;
end
endfunction

function [`BLOCK_BIT-1:0] get_col_block (
    input [`BLOCK_AREA_BIT-1:0] index
);
begin
    // require(`BLOCK_BIT == 2**k) for some k
    get_col_block = index % `BLOCK_SIZE;
end
endfunction

function [`GB_FILTER_BIT-1:0] get_row_filter (
    input [`GB_FILTER_AREA_BIT-1:0] index
);
begin
    // require(`BLOCK_BIT == 2**k) for some k
    get_row_filter = index / `GB_FILTER_SIZE;
end
endfunction

function [`GB_FILTER_BIT-1:0] get_col_filter (
    input [`GB_FILTER_AREA_BIT-1:0] index
);
begin
    // require(`BLOCK_BIT == 2**k) for some k
    get_col_filter = index % `GB_FILTER_SIZE;
end
endfunction

function [`BLOCK_AREA_BIT-1:0] get_veri_idx (
    input [`BLOCK_BIT-1:0] row,
    input [`BLOCK_BIT-1:0] col
);
begin
    get_veri_idx = (row % `GB_FILTER_SIZE) * `BLOCK_SIZE + col;
end
endfunction

function [`BLOCK_AREA_BIT-1:0] get_veri_sutun_idx (
    input [`BLOCK_BIT-1:0] row,
    input [`BLOCK_BIT-1:0] col
);
begin
    get_veri_sutun_idx = col * `BLOCK_SIZE + row;
end
endfunction

function [31:0] get_veri_satir_idx (
    input [`IMG_BLOCKS_BIT-1:0] blok,
    input [`BLOCK_BIT-1:0] row,
    input [`BLOCK_BIT-1:0] col
);
begin
    get_veri_satir_idx = row * SATIR_WIDTH + (blok % `IMG_COL_BLOCKS) * `BLOCK_SIZE + col;
end
endfunction

// *** DEBUG ***
`define DEBUG
`ifdef DEBUG
    wire [`PIXEL_BIT-1:0] debug_view_veri [0:2][0:2];
    wire [`PIXEL_BIT-1:0] debug_view_filtre [0:2][0:2];

    genvar dbgi;
    genvar dbii;
    genvar dbij;
    generate
        for (dbii = 0; dbii < `GB_FILTER_SIZE; dbii = dbii + 1) begin
            for (dbij = 0; dbij < `GB_FILTER_SIZE; dbij = dbij + 1) begin
                assign debug_view_veri[dbii][dbij] = veri_pencere_cmb[(dbii * `GB_FILTER_SIZE + dbij) * `PIXEL_BIT +: `PIXEL_BIT];
                assign debug_view_filtre[dbii][dbij] = aktif_filtre_r[dbii * `GB_FILTER_SIZE + dbij];
            end
        end
    endgenerate
`endif 

integer i;
integer j;
always @* begin
    for (i = 0; i < 2*SATIR_WIDTH; i = i + 1) begin
        gecmis_satir_ns[i] = gecmis_satir_r[i];
    end
    for (i = 0; i < 2*`BLOCK_SIZE; i = i + 1) begin
        gecmis_sutun_ns[i] = gecmis_sutun_r[i];
    end
    for (i = 0; i < 2*`BLOCK_SIZE; i = i + 1) begin
        aktif_gecmis_sutun_ns[i] = aktif_gecmis_sutun_r[i];
    end
    for (i = 0; i < `GB_FILTER_SIZE*`BLOCK_SIZE; i = i + 1) begin
        buf_satir_ns[i] = buf_satir_r[i];
    end
    for (i = 0; i < `GB_FILTER_AREA; i = i + 1) begin
        aktif_filtre_ns[i] = aktif_filtre_r[i];
    end
    durum_ns = durum_r;
    islem_row_ns = islem_row_r;
    islem_col_ns = islem_col_r;
    ptr_yukle_ns = ptr_yukle_r;
    ptr_blok_ns = ptr_blok_r;
    veri_pencere_cmb = 0;
    veri_agirlik_cmb = 0;
    idct_hazir_cmb = ptr_yukle_r < 64;
    islem_gecerli_cmb = `LOW;

    for (i = 0; i < `GB_FILTER_SIZE - `GB_FILTER_EDGE; i = i + 1) begin
        if (idct_hazir_o && idct_gecerli_i && (idct_row_i == (`BLOCK_SIZE - `GB_FILTER_SIZE + `GB_FILTER_EDGE + i))) begin
            gecmis_satir_ns[SATIR_WIDTH * i + (ptr_blok_r % `IMG_COL_BLOCKS) * `BLOCK_SIZE + idct_col_i + `GB_FILTER_WEDGE] = idct_veri_i;
        end

        if (idct_hazir_o && idct_gecerli_i && (idct_col_i == (`BLOCK_SIZE - `GB_FILTER_SIZE + `GB_FILTER_EDGE + i))) begin
            gecmis_sutun_ns[`BLOCK_SIZE * i + idct_row_i] = idct_veri_i;
        end
    end

    if (idct_hazir_o && idct_gecerli_i) begin
        buf_satir_ns[get_veri_idx(idct_row_i, idct_col_i)] = idct_veri_i;
        ptr_yukle_ns = ptr_yukle_r + 1;
    end

    for (i = 0; i < `GB_FILTER_SIZE; i = i + 1) begin
        for (j = 0; j < `GB_FILTER_SIZE; j = j + 1) begin
            if (islem_row_r + i < `GB_FILTER_WEDGE + `GB_FILTER_EDGE) begin
                veri_pencere_cmb[(i * `GB_FILTER_SIZE + j) * `PIXEL_BIT +: `PIXEL_BIT] = gecmis_satir_r[get_veri_satir_idx(ptr_blok_r, islem_row_r + i - `GB_FILTER_EDGE, islem_col_r + j)]; 
            end
            else if (islem_col_r + j < `GB_FILTER_WEDGE + `GB_FILTER_EDGE) begin
                veri_pencere_cmb[(i * `GB_FILTER_SIZE + j) * `PIXEL_BIT +: `PIXEL_BIT] = aktif_gecmis_sutun_r[get_veri_sutun_idx(islem_row_r + i - `GB_FILTER_WEDGE - `GB_FILTER_EDGE, islem_col_r + j - `GB_FILTER_EDGE)];
            end
            else begin
                veri_pencere_cmb[(i * `GB_FILTER_SIZE + j) * `PIXEL_BIT +: `PIXEL_BIT] = buf_satir_r[get_veri_idx(islem_row_r + i - `GB_FILTER_EDGE - `GB_FILTER_WEDGE, islem_col_r + j - `GB_FILTER_EDGE - `GB_FILTER_WEDGE)]; 
            end
        end
    end

    for (i = 0; i < `GB_FILTER_AREA; i = i + 1) begin
        veri_agirlik_cmb[i * `PIXEL_BIT +: `PIXEL_BIT] = aktif_filtre_ns[i];
    end

    case (durum_r)
    DURUM_BOSTA: begin
        durum_ns = DURUM_GOREV0_INIT;
    end
    DURUM_GOREV0_INIT: begin
        aktif_filtre_ns[0] = -1; 
        aktif_filtre_ns[1] = 0;
        aktif_filtre_ns[2] = 1;
        aktif_filtre_ns[3] = -2;
        aktif_filtre_ns[4] = 0;
        aktif_filtre_ns[5] = 2;
        aktif_filtre_ns[6] = -1;
        aktif_filtre_ns[7] = 0;
        aktif_filtre_ns[8] = 1;
        islem_row_ns = 2;
        islem_col_ns = 2;
        ptr_yukle_ns = 0;
        ptr_blok_ns = 0;
        durum_ns = DURUM_GOREV0_MUL0;
    end
    DURUM_GOREV0_MUL0: begin
        // require (`GB_FILTER_SIZE / 2) == 1. If not, add a +`GB_FILTER_SIZE / 2 term and include equality
        if (ptr_yukle_r > ((islem_row_r - `GB_FILTER_WEDGE) * `BLOCK_SIZE + islem_col_r - `GB_FILTER_WEDGE) + `BLOCK_SIZE) begin
            islem_gecerli_cmb = `HIGH;
            if (islem_col_r + `GB_FILTER_EDGE < `BLOCK_SIZE + `GB_FILTER_WEDGE - 1) begin
                islem_col_ns = islem_col_r + 1;
            end
            else begin // jump to next row
                islem_col_ns = 2;
                islem_row_ns = islem_row_r + 1;
            end
        end

        if (islem_row_r + `GB_FILTER_EDGE == `BLOCK_SIZE + `GB_FILTER_WEDGE) begin
            islem_col_ns = 1;
            islem_row_ns = 2;  
            ptr_blok_ns = ptr_blok_r + 1;
            ptr_yukle_ns = 0;
            for (i = 0; i < 2*`BLOCK_SIZE; i = i + 1) begin
                aktif_gecmis_sutun_ns[i] = gecmis_sutun_r[i];
            end
            durum_ns = DURUM_GOREV0_MUL0;
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        durum_r <= DURUM_BOSTA;
        for (i = 0; i < `GB_FILTER_SIZE*`BLOCK_SIZE; i = i + 1) begin
            buf_satir_r[i] <= 0;
        end
        for (i = 0; i < `GB_FILTER_AREA; i = i + 1) begin
            aktif_filtre_r[i] = 0;
        end
        for (i = 0; i < 2*SATIR_WIDTH; i = i + 1) begin
            gecmis_satir_r[i] = 0;
        end
        for (i = 0; i < 2*`BLOCK_SIZE; i = i + 1) begin
            gecmis_sutun_r[i] = 0;
        end
        for (i = 0; i < 2*`BLOCK_SIZE; i = i + 1) begin
            aktif_gecmis_sutun_r[i] = 0;
        end
        islem_row_r <= 0;
        islem_col_r <= 0;
        ptr_yukle_r <= 0;
        ptr_blok_r <= 0;
    end
    else begin
        for (i = 0; i < `GB_FILTER_SIZE*`BLOCK_SIZE; i = i + 1) begin
            buf_satir_r[i] <= buf_satir_ns[i];
        end
        for (i = 0; i < `GB_FILTER_AREA; i = i + 1) begin
            aktif_filtre_r[i] = aktif_filtre_ns[i];
        end
        for (i = 0; i < 2*SATIR_WIDTH; i = i + 1) begin
            gecmis_satir_r[i] <= gecmis_satir_ns[i];
        end
        for (i = 0; i < 2*`BLOCK_SIZE; i = i + 1) begin
            gecmis_sutun_r[i] <= gecmis_sutun_ns[i];
        end
        for (i = 0; i < 2*`BLOCK_SIZE; i = i + 1) begin
            aktif_gecmis_sutun_r[i] <= aktif_gecmis_sutun_ns[i];
        end
        durum_r <= durum_ns;
        islem_row_r <= islem_row_ns;
        islem_col_r <= islem_col_ns;
        ptr_yukle_r <= ptr_yukle_ns;
        ptr_blok_r <= ptr_blok_ns;
    end
end

assign idct_hazir_o = idct_hazir_cmb;
assign yukle_row_w = get_row_block(ptr_yukle_r);
assign yukle_col_w = get_col_block(ptr_yukle_r);

endmodule