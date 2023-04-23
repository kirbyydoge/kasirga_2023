`timescale 1ns/1ps

`include "sabitler.vh"
`include "idctii.vh"

module icosine_transformer (
    input                       clk_i,
    input                       rstn_i,

    input   [`Q_BIT-1:0]        dq_veri_i,
    input   [`BLOCK_BIT-1:0]    dq_row_i,
    input   [`BLOCK_BIT-1:0]    dq_col_i,
    input                       dq_gecerli_i,
    input                       dq_blok_son_i,
    output                      dq_hazir_o,

    output  [`PIXEL_BIT-1:0]    gd_veri_o,
    output  [`BLOCK_BIT-1:0]    gd_row_o,
    output  [`BLOCK_BIT-1:0]    gd_col_o,
    output                      gd_gecerli_o,
    output                      gd_blok_son_o,
    input                       gd_hazir_i
);

reg                             dq_hazir_cmb;

reg  [`PIXEL_BIT-1:0]           gd_veri_cmb;
reg  [`BLOCK_BIT-1:0]           gd_row_cmb;
reg  [`BLOCK_BIT-1:0]           gd_col_cmb;
reg                             gd_gecerli_cmb;
reg                             gd_blok_son_cmb;

reg [`Q_BIT-1:0]                buf_blok_r [0:`BLOCK_AREA-1];
reg [`Q_BIT-1:0]                buf_blok_ns [0:`BLOCK_AREA-1];

reg [`Q_BIT-1:0]                buf_sonuc_r [0:`BLOCK_AREA-1];
reg [`Q_BIT-1:0]                buf_sonuc_ns [0:`BLOCK_AREA-1];

reg [`BLOCK_AREA_BIT-1:0]       ptr_idct_istek_r;      
reg [`BLOCK_AREA_BIT-1:0]       ptr_idct_istek_ns;

reg [`BLOCK_AREA_BIT:0]         ptr_idct_sonuc_r;      
reg [`BLOCK_AREA_BIT:0]         ptr_idct_sonuc_ns;

reg [`BLOCK_AREA_BIT:0]         ptr_gonder_r;      
reg [`BLOCK_AREA_BIT:0]         ptr_gonder_ns;    

reg  [`Q_BIT-1:0]               idct_matrix_cmb;
reg  [`BLOCK_AREA_BIT-1:0]      idct_index_cmb;
reg  [`Q_BIT-1:0]               idct_cos_mp_cmb;
reg  [`Q_BIT-1:0]               idct_cos_nq_cmb;
reg  [`Q_BIT-1:0]               idct_ap_cmb;
reg  [`Q_BIT-1:0]               idct_aq_cmb;
reg                             idct_gecerli_cmb;

wire [`Q_BIT-1:0]               idct_veri_w;
wire [`BLOCK_AREA_BIT-1:0]      idct_index_w;
wire                            idct_gecerli_w;  


wire [`BLOCK_BIT-1:0]           carp_m_w;
wire [`BLOCK_BIT-1:0]           carp_n_w;
wire [`BLOCK_BIT-1:0]           carp_p_w;
wire [`BLOCK_BIT-1:0]           carp_q_w;

localparam                      DURUM_HAZIRLA      = 'd0;
localparam                      DURUM_DOLDUR       = 'd1;
localparam                      DURUM_CARP         = 'd2;
localparam                      DURUM_GONDER       = 'd3;

reg [1:0]                       durum_r;
reg [1:0]                       durum_ns;

function [`BLOCK_BIT-1:0] get_row (
    input [`BLOCK_AREA_BIT-1:0] index
);
begin
    // require(`BLOCK_BIT == 2**k) for some k
    get_row = index / `BLOCK_SIZE;
end
endfunction

function [`BLOCK_BIT-1:0] get_col (
    input [`BLOCK_AREA_BIT-1:0] index
);
begin
    // require(`BLOCK_BIT == 2**k) for some k
    get_col = index % `BLOCK_SIZE;
end
endfunction

function [`Q_BIT-1:0] lookup_cosine (
    input [`BLOCK_BIT-1:0] mn,
    input [`BLOCK_BIT-1:0] pq
);
reg [2*`BLOCK_BIT-1:0] key;
begin
    key = {mn, pq};
    case(key)
    6'b000000: lookup_cosine = `IDCT_COS_VAL0;
    6'b000001: lookup_cosine = `IDCT_COS_VAL1;
    6'b000010: lookup_cosine = `IDCT_COS_VAL1;
    6'b000011: lookup_cosine = `IDCT_COS_VAL2;
    6'b000100: lookup_cosine = `IDCT_COS_VAL3;
    6'b000101: lookup_cosine = `IDCT_COS_VAL4;
    6'b000110: lookup_cosine = `IDCT_COS_VAL5;
    6'b000111: lookup_cosine = `IDCT_COS_VAL6;
    6'b001000: lookup_cosine = `IDCT_COS_VAL0;
    6'b001001: lookup_cosine = `IDCT_COS_VAL2;
    6'b001010: lookup_cosine = `IDCT_COS_VAL5;
    6'b001011: lookup_cosine = `IDCT_COS_VAL7;
    6'b001100: lookup_cosine = `IDCT_COS_VAL8;
    6'b001101: lookup_cosine = `IDCT_COS_VAL9;
    6'b001110: lookup_cosine = `IDCT_COS_VAL9;
    6'b001111: lookup_cosine = `IDCT_COS_VAL10;
    6'b010000: lookup_cosine = `IDCT_COS_VAL0;
    6'b010001: lookup_cosine = `IDCT_COS_VAL4;
    6'b010010: lookup_cosine = `IDCT_COS_VAL11;
    6'b010011: lookup_cosine = `IDCT_COS_VAL9;
    6'b010100: lookup_cosine = `IDCT_COS_VAL8;
    6'b010101: lookup_cosine = `IDCT_COS_VAL6;
    6'b010110: lookup_cosine = `IDCT_COS_VAL1;
    6'b010111: lookup_cosine = `IDCT_COS_VAL2;
    6'b011000: lookup_cosine = `IDCT_COS_VAL0;
    6'b011001: lookup_cosine = `IDCT_COS_VAL6;
    6'b011010: lookup_cosine = `IDCT_COS_VAL9;
    6'b011011: lookup_cosine = `IDCT_COS_VAL10;
    6'b011100: lookup_cosine = `IDCT_COS_VAL3;
    6'b011101: lookup_cosine = `IDCT_COS_VAL2;
    6'b011110: lookup_cosine = `IDCT_COS_VAL11;
    6'b011111: lookup_cosine = `IDCT_COS_VAL9;
    6'b100000: lookup_cosine = `IDCT_COS_VAL0;
    6'b100001: lookup_cosine = `IDCT_COS_VAL7;
    6'b100010: lookup_cosine = `IDCT_COS_VAL9;
    6'b100011: lookup_cosine = `IDCT_COS_VAL4;
    6'b100100: lookup_cosine = `IDCT_COS_VAL3;
    6'b100101: lookup_cosine = `IDCT_COS_VAL12;
    6'b100110: lookup_cosine = `IDCT_COS_VAL11;
    6'b100111: lookup_cosine = `IDCT_COS_VAL1;
    6'b101000: lookup_cosine = `IDCT_COS_VAL0;
    6'b101001: lookup_cosine = `IDCT_COS_VAL10;
    6'b101010: lookup_cosine = `IDCT_COS_VAL11;
    6'b101011: lookup_cosine = `IDCT_COS_VAL1;
    6'b101100: lookup_cosine = `IDCT_COS_VAL8;
    6'b101101: lookup_cosine = `IDCT_COS_VAL7;
    6'b101110: lookup_cosine = `IDCT_COS_VAL1;
    6'b101111: lookup_cosine = `IDCT_COS_VAL12;
    6'b110000: lookup_cosine = `IDCT_COS_VAL0;
    6'b110001: lookup_cosine = `IDCT_COS_VAL12;
    6'b110010: lookup_cosine = `IDCT_COS_VAL5;
    6'b110011: lookup_cosine = `IDCT_COS_VAL6;
    6'b110100: lookup_cosine = `IDCT_COS_VAL8;
    6'b110101: lookup_cosine = `IDCT_COS_VAL1;
    6'b110110: lookup_cosine = `IDCT_COS_VAL9;
    6'b110111: lookup_cosine = `IDCT_COS_VAL4;
    6'b111000: lookup_cosine = `IDCT_COS_VAL0;
    6'b111001: lookup_cosine = `IDCT_COS_VAL9;
    6'b111010: lookup_cosine = `IDCT_COS_VAL1;
    6'b111011: lookup_cosine = `IDCT_COS_VAL12;
    6'b111100: lookup_cosine = `IDCT_COS_VAL3;
    6'b111101: lookup_cosine = `IDCT_COS_VAL10;
    6'b111110: lookup_cosine = `IDCT_COS_VAL5;
    6'b111111: lookup_cosine = `IDCT_COS_VAL7;
    default  : lookup_cosine = {`Q_BIT{1'b0}};
    endcase
end
endfunction

function [`Q_BIT-1:0] lookup_alpha (
    input [`BLOCK_BIT-1:0]  pq
);
begin
    lookup_alpha = pq == 6'b0 ? `ALPHA_ZERO : `ALPHA_NZ;
end
endfunction

function [`BLOCK_AREA_BIT-1:0] index (
    input [`BLOCK_BIT-1:0] row,
    input [`BLOCK_BIT-1:0] col
);
begin
    index = row * `BLOCK_SIZE + col;
end 
endfunction

localparam IDCT_DELAY = 3;

integer i;
always @* begin
    for (i = 0; i < `BLOCK_AREA; i = i + 1) begin
        buf_blok_ns[i] =  buf_blok_r[i];
        buf_sonuc_ns[i] = buf_sonuc_r[i];
    end 

    ptr_idct_istek_ns = ptr_idct_istek_r;
    ptr_idct_sonuc_ns = ptr_idct_sonuc_r;
    ptr_gonder_ns = ptr_gonder_r;
    durum_ns = durum_r;

    idct_gecerli_cmb = `LOW;
    idct_index_cmb = 0;
    idct_matrix_cmb = 0;
    idct_cos_mp_cmb = 0;
    idct_cos_nq_cmb = 0;
    idct_ap_cmb = 0;
    idct_aq_cmb = 0;
    dq_hazir_cmb = `LOW;
    gd_gecerli_cmb = `LOW;

    gd_veri_cmb = buf_sonuc_r[ptr_gonder_r][`Q_FRAC_BIT +: `PIXEL_BIT];
    gd_row_cmb = get_row(ptr_gonder_r);
    gd_col_cmb = get_col(ptr_gonder_r);
    gd_blok_son_cmb = `LOW;

    if (ptr_gonder_r < ptr_idct_sonuc_r && (ptr_idct_istek_r > IDCT_DELAY || ptr_idct_sonuc_r == 64)) begin
        gd_gecerli_cmb = `HIGH;
        gd_blok_son_cmb = ptr_gonder_r == 63;
    end

    if (gd_gecerli_o && gd_hazir_i) begin
        ptr_gonder_ns = ptr_gonder_r + 1;
    end

    if (idct_gecerli_w) begin
        buf_sonuc_ns[idct_index_w] = buf_sonuc_r[idct_index_w] + idct_veri_w; 
    end

    case(durum_r)
    DURUM_HAZIRLA: begin
        for (i = 0; i < `BLOCK_AREA; i = i + 1) begin
            buf_blok_ns[i] = {`Q_BIT{1'b0}};
            buf_sonuc_ns[i] = {`Q_BIT{1'b0}};
        end 
        ptr_idct_sonuc_ns = {`BLOCK_AREA_BIT{1'b0}};
        ptr_gonder_ns = {`BLOCK_AREA_BIT{1'b0}};
        durum_ns = DURUM_DOLDUR;
    end
    DURUM_DOLDUR: begin
        dq_hazir_cmb = `HIGH;
        if (dq_gecerli_i && dq_hazir_o) begin
            buf_blok_ns[index(dq_row_i, dq_col_i)] = dq_veri_i;
            if (dq_blok_son_i) begin
                durum_ns = DURUM_CARP;
            end
        end
    end
    DURUM_CARP: begin
        ptr_idct_istek_ns = ptr_idct_istek_r + 1;
        idct_gecerli_cmb = `HIGH;
        idct_index_cmb = ptr_idct_sonuc_r;
        idct_matrix_cmb = buf_blok_r[ptr_idct_istek_r];
        idct_cos_mp_cmb = lookup_cosine(carp_m_w, carp_p_w); 
        idct_cos_nq_cmb = lookup_cosine(carp_n_w, carp_q_w); 
        idct_ap_cmb = lookup_alpha(carp_p_w);
        idct_aq_cmb = lookup_alpha(carp_q_w);
        if (ptr_idct_istek_r == 63) begin
            ptr_idct_sonuc_ns = ptr_idct_sonuc_r + 1;
            ptr_idct_istek_ns = 0;
            durum_ns = ptr_idct_sonuc_r < 63 ? DURUM_CARP : DURUM_GONDER;
        end
    end
    DURUM_GONDER: begin
        if (ptr_gonder_r == 64) begin
            durum_ns = DURUM_HAZIRLA;
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        for (i = 0; i < `BLOCK_AREA; i = i + 1) begin
            buf_blok_r[i] <=  0;
            buf_sonuc_r[i] <= 0;
        end 
        ptr_idct_istek_r <= 0;
        ptr_idct_sonuc_r <= 0;
        ptr_gonder_r <= 0;
        durum_r <= DURUM_HAZIRLA;
    end
    else begin
        for (i = 0; i < `BLOCK_AREA; i = i + 1) begin
            buf_blok_r[i] <=  buf_blok_ns[i];
            buf_sonuc_r[i] <= buf_sonuc_ns[i];
        end 
        ptr_idct_istek_r <= ptr_idct_istek_ns;
        ptr_idct_sonuc_r <= ptr_idct_sonuc_ns;
        ptr_gonder_r <= ptr_gonder_ns;
        durum_r <= durum_ns;
    end    
end

idctii idct (
    .clk_i           ( clk_i ),
    .rstn_i          ( rstn_i ),
    .islem_matrix_i  ( idct_matrix_cmb ),
    .islem_index_i   ( idct_index_cmb ),
    .islem_cos_mp_i  ( idct_cos_mp_cmb ),
    .islem_cos_nq_i  ( idct_cos_nq_cmb ),
    .islem_ap_i      ( idct_ap_cmb ),
    .islem_aq_i      ( idct_aq_cmb ),
    .islem_gecerli_i ( idct_gecerli_cmb ),
    .sonuc_veri_o    ( idct_veri_w ),
    .sonuc_index_o   ( idct_index_w ),
    .sonuc_gecerli_o ( idct_gecerli_w )
);

assign dq_hazir_o = dq_hazir_cmb;
assign gd_veri_o = gd_veri_cmb < 127 ? gd_veri_cmb + 8'd128 : 8'd255;
assign gd_row_o = gd_row_cmb;
assign gd_col_o = gd_col_cmb;
assign gd_gecerli_o = gd_gecerli_cmb;
assign gd_blok_son_o = gd_blok_son_cmb;

assign carp_m_w = get_row(ptr_idct_sonuc_r);
assign carp_n_w = get_col(ptr_idct_sonuc_r);
assign carp_p_w = get_row(ptr_idct_istek_r);
assign carp_q_w = get_col(ptr_idct_istek_r);

endmodule