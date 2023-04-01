`timescale 1ns/1ps

module idctii (
    input               clk_i,
    input               rstn_i,

    input   [`Q_BIT-1:0]            islem_matrix_i,
    input   [`BLOCK_AREA_BIT-1:0]   islem_index_i,
    input   [`Q_BIT-1:0]            islem_cos_mp_i,
    input   [`Q_BIT-1:0]            islem_cos_nq_i,
    input   [`Q_BIT-1:0]            islem_ap_i,
    input   [`Q_BIT-1:0]            islem_aq_i,
    input                           islem_gecerli_i,

    output  [`Q_BIT-1:0]            sonuc_veri_o,
    output  [`BLOCK_AREA_BIT-1:0]   sonuc_index_o,
    output                          sonuc_gecerli_o
);

// ---- Stage 0: Cosine x Cosine and Alpha x Alpha ----
reg [`Q_BIT-1:0]            s0_cosmul_r;
reg [`BLOCK_AREA_BIT-1:0]   s0_index_r;
reg [`Q_BIT-1:0]            s0_alpmul_r;
reg [`Q_BIT-1:0]            s0_matrix_r;
reg                         s0_gecerli_r;

reg [2*`Q_BIT-1:0]          s0_cosmul_cmb;
reg [2*`Q_BIT-1:0]          s0_alpmul_cmb;

// ---- Stage 1: Cosine x Alpha
reg [`Q_BIT-1:0]            s1_cosalpmul_r;
reg [`Q_BIT-1:0]            s1_matrix_r;
reg [`BLOCK_AREA_BIT-1:0]   s1_index_r;
reg                         s1_gecerli_r;

reg [2*`Q_BIT-1:0]          s1_cosalpmul_cmb;

// ---- Stage 2: Matrix x Alpha
reg [`Q_BIT-1:0]            s2_sonuc_r;
reg [`BLOCK_AREA_BIT-1:0]   s2_index_r;
reg                         s2_gecerli_r;

reg [2*`Q_BIT-1:0]          s2_sonuc_cmb;

always @* begin
    // S0
    s0_cosmul_cmb = $signed(islem_cos_mp_i) * $signed(islem_cos_nq_i);
    s0_alpmul_cmb = $signed(islem_ap_i) * $signed(islem_aq_i);
    // S1
    s1_cosalpmul_cmb = $signed(s0_cosmul_r) * $signed(s0_alpmul_r);
    // S2
    s2_sonuc_cmb = $signed(s1_cosalpmul_r) * $signed(s1_matrix_r);
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        s0_gecerli_r <= `LOW;
        s1_gecerli_r <= `LOW;
        s2_gecerli_r <= `LOW;
    end
    else begin
        // S0
        s0_cosmul_r <= s0_cosmul_cmb[`Q_MUL_SELECT];
        s0_alpmul_r <= s0_alpmul_cmb[`Q_MUL_SELECT];
        s0_matrix_r <= islem_matrix_i;
        s0_index_r <= islem_index_i;
        s0_gecerli_r <= islem_gecerli_i;
        // S1
        s1_cosalpmul_r <= s1_cosalpmul_cmb[`Q_MUL_SELECT];
        s1_matrix_r <= s0_matrix_r;
        s1_index_r <= s0_index_r;
        s1_gecerli_r <= s0_gecerli_r;
        // S2
        s2_sonuc_r <= s2_sonuc_cmb[`Q_MUL_SELECT];
        s2_index_r <= s1_index_r;
        s2_gecerli_r <= s1_gecerli_r;
    end
end

assign sonuc_veri_o = s2_sonuc_r;
assign sonuc_index_o = s2_index_r;
assign sonuc_gecerli_o = s2_gecerli_r;

endmodule