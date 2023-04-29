`timescale 1ns / 1ps

`include "sabitler.vh"

module top (
    input   clk_p,
    input   clk_n,
    input   rstn_i,
    input   uart_rx,
    output  uart_tx
);

wire rstn_i;
wire locked_w;
wire clk_w;

clk_wiz_0 clk_wzrd(
   .reset(rst_i), 
   .clk_in1_p(clk_p),
   .clk_in1_n(clk_n),
   .clk_out1(clk_w),
   .locked(locked_w)
);

assign rstn_i = !rst_i && locked_w;

localparam BAUD_DIV = `CLK_HZ / `BAUD_RATE;

wire [7:0]  alici_veri_o;
wire        alici_gecerli_o;

uart_alici alici (
    .clk_i             ( clk_w ),
    .rstn_i            ( rstn_i ),
    .alinan_veri_o     ( alici_veri_o ),
    .alinan_gecerli_o  ( alici_gecerli_o ),
    .baud_div_i        ( BAUD_DIV ),
    .rx_i              ( uart_rx )
);

// ila_1 uart_alici_rx (
//    .clk     ( clk_w ),
//    .probe0  ( alici_veri_o ),
//    .probe1  ( alici_gecerli_o )
// );

wire [7:0]  rx_fifo_wr_data_w;
wire        rx_fifo_wr_en_w;
wire [7:0]  rx_fifo_rd_data_w;
wire        rx_fifo_rd_en_w;
wire        rx_fifo_full_w;
wire        rx_fifo_empty_w;

assign rx_fifo_wr_data_w = alici_veri_o;
assign rx_fifo_wr_en_w = alici_gecerli_o;

fifo #(
   .DATA_WIDTH(8),
   .DATA_DEPTH(32)
) rx_buffer (
   .clk_i    ( clk_w ),         
   .rstn_i   ( rstn_i ),         
   .data_i   ( rx_fifo_wr_data_w ),         
   .wr_en_i  ( rx_fifo_wr_en_w ),         
   .data_o   ( rx_fifo_rd_data_w ),         
   .rd_en_i  ( rx_fifo_rd_en_w ),         
   .full_o   ( rx_fifo_full_w ),         
   .empty_o  ( rx_fifo_empty_w )         
);


wire[7:0] h_veri_i;
wire      h_gecerli_i;
wire     h_hazir_o;
wire[7:0] h_veri_o;
wire      h_gecerli_o;
wire      h_hazir_i;

assign h_veri_i = rx_fifo_rd_data_w;
assign h_gecerli_i = !rx_fifo_empty_w;
assign h_hazir_i = !tx_fifo_full_w;
assign rx_fifo_rd_en_w = h_hazir_o;

// ila_0 debug_rx (
//    .clk     ( clk_w ),
//    .probe0  ( rx_fifo_rd_data_w ),
//    .probe1  ( rx_fifo_rd_en_w ),
//    .probe2  ( rx_fifo_empty_w ),
//    .probe3  ( rx_fifo_full_w )
// );

hizlandirici hz(
    .clk_i(clk_w),
    .rstn_i(rstn_i),
    .h_veri_i(h_veri_i),
    .h_gecerli_i(h_gecerli_i),
    .h_hazir_o(h_hazir_o),
    .h_veri_o(h_veri_o),
    .h_gecerli_o(h_gecerli_o),
    .h_hazir_i(h_hazir_i)
);

// ila_2 debug_hizlandirci(
//    .clk     ( clk_w ),
//    .probe0  (h_veri_i),
//    .probe1  ( h_gecerli_i),
//    .probe2  (h_hazir_o ),
//    .probe3  (h_veri_o ),
//    .probe4  ( h_gecerli_o),
//    .probe5  ( h_hazir_i)
// );

wire[7:0] tx_fifo_wr_data_w;
wire      tx_fifo_wr_en_w;
wire[7:0] tx_fifo_rd_data_w;
wire tx_fifo_rd_en_w;
wire tx_fifo_full_w;
wire tx_fifo_empty_w;

assign tx_fifo_wr_data_w = h_veri_o;
assign tx_fifo_wr_en_w = h_gecerli_o;

fifo #(
   .DATA_WIDTH(8),
   .DATA_DEPTH(320*240 + 4)
) tx_buffer (
   .clk_i    ( clk_w ),         
   .rstn_i   ( rstn_i ),         
   .data_i   ( tx_fifo_wr_data_w ),         
   .wr_en_i  ( tx_fifo_wr_en_w ),         
   .data_o   ( tx_fifo_rd_data_w ),         
   .rd_en_i  ( tx_fifo_rd_en_w ),         
   .full_o   ( tx_fifo_full_w ),         
   .empty_o  ( tx_fifo_empty_w )         
);

// ila_0 debug_tx (
//    .clk     ( clk_w ),
//    .probe0  ( tx_fifo_wr_data_w ),
//    .probe1  ( tx_fifo_wr_en_w),
//    .probe2  ( tx_fifo_empty_w ),
//    .probe3  ( tx_fifo_full_w )
// );

uart_verici verici (
   .clk_i          ( clk_w ),
   .rstn_i         ( rstn_i ),
   .veri_gecerli_i ( !tx_fifo_empty_w ),
   .consume_o      ( tx_fifo_rd_en_w ),
   .gelen_veri_i   ( tx_fifo_rd_data_w ),
   .baud_div_i     ( BAUD_DIV ),
   .tx_o           ( uart_tx )
);

// ila_1 uart_verici_tx (
//    .clk     ( clk_w ),
//    .probe0  ( tx_fifo_rd_data_w ),
//    .probe1  ( tx_fifo_rd_en_w )
// );

endmodule