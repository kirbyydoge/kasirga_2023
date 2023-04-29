`timescale 1ns / 1ps

`include "sabitler.vh"

module al_ver (
    input   clk_i,
    input   rst_i,
    input   uart_rx,
    output  uart_tx
);
wire rstn_i;
wire locked_w;
wire clk_w;

clk_wiz_0 clk_wzrd(
   .reset(rst_i),
   .clk_in1(clk_i),
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

wire[7:0] fifo_rd_data_w;
wire      fifo_rd_en_w;
wire      fifo_empty_w;
wire      fifo_full_w;

fifo #(
   .DATA_WIDTH(8),
   .DATA_DEPTH(32)
) rx_buffer (
   .clk_i    ( clk_w ),         
   .rstn_i   ( rstn_i ),         
   .data_i   ( alici_veri_o ),         
   .wr_en_i  ( alici_gecerli_o ),         
   .data_o   ( fifo_rd_data_w ),         
   .rd_en_i  ( fifo_rd_en_w ),         
   .full_o   ( fifo_full_w ),         
   .empty_o  ( fifo_empty_w )         
);


uart_verici verici (
   .clk_i          ( clk_w ),
   .rstn_i         ( rstn_i ),
   .veri_gecerli_i (!fifo_empty_w),
   .consume_o      ( fifo_rd_en_w ),
   .gelen_veri_i   ( fifo_rd_data_w ),
   .baud_div_i     ( BAUD_DIV ),
   .tx_o           ( uart_tx )
);

endmodule