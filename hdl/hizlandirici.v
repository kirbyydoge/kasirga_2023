`timescale 1ns/1ps
 
`include "sabitler.vh"

module hizlandirici (
    input                       clk_i,
    input                       rstn_i,

`ifdef FPGA
    input                       uart_rx,
    output                      uart_tx
`elsif CARAVEL
    input   [`WB_BIT-1:0]       m_veri_i,
    input                       m_gecerli_i,
    output                      m_hazir_o,

    output  [`WB_BIT-1:0]       s_veri_o,
    output                      s_gecerli_o,
    input                       s_hazir_i
`endif
);

localparam BAUD_DIV = `CLK_HZ / `BAUD_RATE;

wire [7:0]  alici_veri_o;
wire        alici_gecerli_o;

uart_alici alici (
    .clk_i             ( clk_i ),
    .rstn_i            ( rstn_i ),
    .alinan_veri_o     ( alici_veri_o ),
    .alinan_gecerli_o  ( alici_gecerli_o ),
    .baud_div_i        ( BAUD_DIV ),
    .rx_i              ( uart_rx )
);

// DURUM MAKINESI LAZIM

// ILK 2 BAYTI VE SONRAKI GOREVI OKUYUP DAHA SONRA FIFOYA YAZMAYA BASLAYACAK

// DURUM MAKINESI LAZIM

reg  [7:0] rx_fifo_wr_data_w;
reg        rx_fifo_wr_en_w;
wire [7:0] rx_fifo_rd_data_w;
reg        rx_fifo_rd_en_w;
wire       rx_fifo_full_w;
wire       rx_fifo_empty_w;

assign rx_fifo_wr_data_w = alici_veri_o;
assign rx_fifo_wr_en_w = alici_gecerli_o;

fifo #(
   .DATA_WIDTH(8),
   .DATA_DEPTH(32)
) rx_buffer (
   .clk_i    ( clk_i ),         
   .rstn_i   ( rstn_i ),         
   .data_i   ( rx_fifo_wr_data_w ),         
   .wr_en_i  ( rx_fifo_wr_en_w ),         
   .data_o   ( rx_fifo_rd_data_w ),         
   .rd_en_i  ( rx_fifo_rd_en_w ),         
   .full_o   ( rx_fifo_full_w ),         
   .empty_o  ( rx_fifo_empty_w )         
);

wire [7:0]  m_veri_w;
wire        m_gecerli_w;
wire        m_hazir_w;

wire [7:0]  coz_veri_w;
wire        coz_gecerli_w;
wire        coz_hazir_w;

assign m_veri_w = rx_fifo_rd_data_w;
assign m_gecerli_w = !rx_fifo_empty_w;
assign rx_fifo_rd_en_w = m_hazir_w;

jpeg_coz jc (
    .clk_i          ( clk_i ),
    .rstn_i         ( rstn_i ),
    .m_veri_i       ( m_veri_w ),
    .m_gecerli_i    ( m_gecerli_w ),
    .m_hazir_o      ( m_hazir_w ),
    .coz_veri_o     ( coz_veri_o ),
    .coz_gecerli_o  ( coz_gecerli_o ),
    .coz_hazir_i    ( coz_hazir_w )
);

// TODO BIT GENISLIKLERI
wire                gb_basla_w;
wire   [7:0]        gb_coz_pixel_w;
wire                gb_coz_etkin_w;
wire                gb_coz_stall_w;
wire                gb_gorev_w;
wire                gb_etkin_w;
wire   [7:0]        gb_pixel_w;
wire                gb_stall_w;

assign gb_coz_pixel_w = coz_veri_w;
assign coz_gecerli_w = gb_coz_etkin_w;
assign coz_hazir_w = !gb_coz_stall_w;

gorev_birimi gb (
    .clk_i          ( clk_i ),
    .rstn_i         ( rstn_i ),
    // BASLA VE GOREV FSMDEN GELECEK
    .basla          ( gb_basla_w ),
    .gorev_i        ( gb_gorev_w ),
    .etkin_i        ( gb_coz_etkin_w ),
    .pixel_i        ( gb_coz_pixel_w ),
    .coz_stall_o    ( gb_coz_stall_w ),
    .stal_i         ( gb_stall_w ),
    .etkin_o        ( gb_etkin_w ),
    .pixel_o        ( gb_pixel_w )
);

reg  [7:0] tx_fifo_wr_data_w;
reg        tx_fifo_wr_en_w;
wire [7:0] tx_fifo_rd_data_w;
reg        tx_fifo_rd_en_w;
wire       tx_fifo_full_w;
wire       tx_fifo_empty_w;

assign tx_fifo_wr_data_w = gb_pixel_w;
assign tx_fifo_wr_en_w = gb_etkin_w;
assign gb_stal_w = tx_fifo_full_w;

// BURAYA FSM GELECEK

// CHECKSUM HESAPLAYIP ISLEM BITINCE CHECKSUMI DA FIFOYA YAZ

// BURAYA FSM GELECEK

fifo #(
   .DATA_WIDTH(8),
   .DATA_DEPTH(32)
) tx_buffer (
   .clk_i    ( clk_i ),         
   .rstn_i   ( rstn_i ),         
   .data_i   ( tx_fifo_wr_data_w ),         
   .wr_en_i  ( tx_fifo_wr_en_w ),         
   .data_o   ( tx_fifo_rd_data_w ),         
   .rd_en_i  ( tx_fifo_rd_en_w ),         
   .full_o   ( tx_fifo_full_w ),         
   .empty_o  ( tx_fifo_empty_w )         
);

uart_verici verici (
   .clk_i          ( clk_i ),
   .rstn_i         ( rstn_i ),
   .veri_gecerli_i ( !tx_fifo_empty_w ),
   .consume_o      ( tx_fifo_rd_en_w ),
   .gelen_veri_i   ( tx_fifo_rd_data_w ),
   .baud_div_i     ( BAUD_DIV ),
   .tx_o           ( uart_tx ),
   .hazir_o        (  )
);

endmodule