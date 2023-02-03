`timescale 1ns/1ps

`include "sabitler.vh"

module decode_normalizer (
    input                       clk_i,
    input                       rstn_i,

    input  [`PIXEL_BIT-1:0]     idct_veri_i,
    input  [`BLOCK_BIT-1:0]     idct_row_i,
    input  [`BLOCK_BIT-1:0]     idct_col_i,
    input                       idct_gecerli_i,
    input                       idct_blok_son_i,
    output                      idct_hazir_o,

    output [`PIXEL_BIT-1:0]     dn_veri_o,
    output                      dn_gecerli_o,
    input                       dn_hazir_i
);

localparam BUF_LEN = `BLOCK_SIZE*`IMG_WIDTH;

reg [`PIXEL_BIT-1:0]        buf0_r [0:BUF_LEN-1];
reg [`PIXEL_BIT-1:0]        buf0_ns [0:BUF_LEN-1];

reg [`PIXEL_BIT-1:0]        buf1_r [0:BUF_LEN-1];
reg [`PIXEL_BIT-1:0]        buf1_ns [0:BUF_LEN-1];

reg [`IMG_AREA_BIT-1:0]     ptr_recv_r;
reg [`IMG_AREA_BIT-1:0]     ptr_recv_ns;

reg [`IMG_AREA_BIT-1:0]     ptr_send_r;
reg [`IMG_AREA_BIT-1:0]     ptr_send_ns;

reg [`IMG_BLOCKS_BIT-1:0]   ctr_block_r;
reg [`IMG_BLOCKS_BIT-1:0]   ctr_block_ns;

reg [`PIXEL_BIT-1:0]        dn_veri_cmb;
reg                         idct_hazir_cmb;
reg                         dn_gecerli_cmb;

localparam                  DURUM_BUF0_KULLAN = 'd0;
localparam                  DURUM_BUF1_KULLAN = 'd1;

reg                         buf0_valid_r;
reg                         buf0_valid_ns;

reg                         buf1_valid_r;
reg                         buf1_valid_ns;

reg                         recv_durum_r;
reg                         recv_durum_ns;

reg                         send_durum_r;
reg                         send_durum_ns;

function [`IMG_AREA_BIT-1:0] index (
    input   [`BLOCK_BIT-1:0]        idx_row,
    input   [`BLOCK_BIT-1:0]        idx_col,
    input   [`IMG_BLOCKS_BIT-1:0]   idx_block
);

begin
    index = ((idx_row % `BLOCK_SIZE) * `IMG_WIDTH) + ((idx_block * `BLOCK_SIZE) + idx_col);
end

endfunction

integer i;
always @* begin
    for (i = 0; i < BUF_LEN; i = i + 1) begin
        buf0_ns[i] = buf0_r[i];
        buf1_ns[i] = buf1_r[i];
    end
    ptr_recv_ns = ptr_recv_r;
    ptr_send_ns = ptr_send_r;
    recv_durum_ns = recv_durum_r;
    send_durum_ns = send_durum_r;
    buf0_valid_ns = buf0_valid_r;
    buf1_valid_ns = buf1_valid_r;
    ctr_block_ns = ctr_block_r;
    dn_veri_cmb = 0;
    idct_hazir_cmb = `LOW;
    dn_gecerli_cmb = `LOW;

    case(recv_durum_r)
    DURUM_BUF0_KULLAN: begin
        if (ptr_recv_r == BUF_LEN) begin
            buf0_valid_ns = `HIGH;
            ptr_recv_ns = 0;
            ctr_block_ns = 0;
            recv_durum_ns = DURUM_BUF1_KULLAN;
        end 
        else if (!buf0_valid_r) begin
            idct_hazir_cmb = `HIGH;
            if (idct_hazir_o && idct_gecerli_i) begin
                ptr_recv_ns = ptr_recv_r + 1;
                buf0_ns[index(idct_row_i, idct_col_i, ctr_block_r)] = idct_veri_i;
                if (ptr_recv_r % `BLOCK_AREA == `BLOCK_AREA - 1) begin
                    ctr_block_ns = ctr_block_r + 1;
                end
            end
        end
    end
    DURUM_BUF1_KULLAN: begin
        if (ptr_recv_r == BUF_LEN) begin
            buf1_valid_ns = `HIGH;
            ptr_recv_ns = 0;
            ctr_block_ns = 0;
            recv_durum_ns = DURUM_BUF0_KULLAN;
        end
        else if (!buf1_valid_r) begin
            idct_hazir_cmb = `HIGH;
            if (idct_hazir_o && idct_gecerli_i) begin
                ptr_recv_ns = ptr_recv_r + 1;
                buf1_ns[index(idct_row_i, idct_col_i, ctr_block_r)] = idct_veri_i;
                if (ptr_recv_r % `BLOCK_AREA == `BLOCK_AREA - 1) begin
                    ctr_block_ns = ctr_block_r + 1;
                end
            end
        end
    end
    endcase

    case(send_durum_r)
    DURUM_BUF0_KULLAN: begin
        dn_veri_cmb = buf0_r[ptr_send_r];
        dn_gecerli_cmb = buf0_valid_r;
        if (dn_hazir_i && dn_gecerli_o) begin
            ptr_send_ns = ptr_send_r + 1;
            buf0_valid_ns = ptr_send_r < BUF_LEN - 1;
        end
        if (ptr_send_r == BUF_LEN) begin
            buf0_valid_ns = `LOW;
            ptr_send_ns = 0;
            send_durum_ns = DURUM_BUF1_KULLAN;
        end
    end
    DURUM_BUF1_KULLAN: begin
        dn_veri_cmb = buf1_r[ptr_send_r];
        dn_gecerli_cmb = buf1_valid_r;
        if (dn_hazir_i && dn_gecerli_o) begin
            ptr_send_ns = ptr_send_r + 1;
            buf1_valid_ns = ptr_send_r < BUF_LEN - 1;
        end
        if (ptr_send_r == BUF_LEN) begin
            buf1_valid_ns = `LOW;
            ptr_send_ns = 0;
            send_durum_ns = DURUM_BUF0_KULLAN;
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        ptr_recv_r <= 0;
        ptr_send_r <= 0;
        recv_durum_r <= DURUM_BUF0_KULLAN;
        send_durum_r <= DURUM_BUF0_KULLAN;
        buf0_valid_r <= `LOW;
        buf1_valid_r <= `LOW;
        ctr_block_r <= 0;
    end
    else begin
        for (i = 0; i < BUF_LEN; i = i + 1) begin
            buf0_r[i] <= buf0_ns[i];
            buf1_r[i] <= buf1_ns[i];
        end
        ptr_recv_r <= ptr_recv_ns;
        ptr_send_r <= ptr_send_ns;
        recv_durum_r <= recv_durum_ns;
        send_durum_r <= send_durum_ns;
        buf0_valid_r <= buf0_valid_ns;
        buf1_valid_r <= buf1_valid_ns;
        ctr_block_r <= ctr_block_ns;
    end
end

assign idct_hazir_o = idct_hazir_cmb;
assign dn_veri_o = dn_veri_cmb;
assign dn_gecerli_o = dn_gecerli_cmb;

endmodule