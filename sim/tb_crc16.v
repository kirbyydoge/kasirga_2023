`timescale 1ns/1ps
`include "sabitler.vh"

module tb_crc16();

reg clk_i;
reg rstn_i;
reg[7:0] byte_i;
reg etkin_i;
wire[15:0] crc16_o;

crc16 uut(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .byte_i(byte_i),
    .etkin_i(etkin_i),
    .crc16_o(crc16_o)
);
always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

initial begin
    rstn_i=0;
    etkin_i =0;
    byte_i =0;
    @(posedge clk_i); #2;
    rstn_i = 1;
    @(posedge clk_i); #2;
    etkin_i = 1;
    byte_i = 8'h4;
    @(posedge clk_i); #2;
    byte_i = 8'h3;
    @(posedge clk_i); #2;
    byte_i = 8'h2;
    @(posedge clk_i); #2;
    byte_i = 8'h1;
    @(posedge clk_i); #2;
    etkin_i=0;
end


endmodule