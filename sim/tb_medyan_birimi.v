`timescale 1ns/1ps
`include "sabitler.vh"

module tb_medyan_birimi();
reg                       clk_i;
reg                       rstn_i;
reg                       etkin_i;
reg [`PIXEL_BIT-1:0]      sayi_i; 
wire [`PIXEL_BIT-1:0]     medyan_o;
wire                      hazir_o;

medyan_birimi mb (
.clk_i ( clk_i),
.rstn_i ( rstn_i),
.etkin_i ( etkin_i ),
.sayi_i ( sayi_i),
.medyan_o ( medyan_o),
.hazir_o ( hazir_o)
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end
initial begin
rstn_i = 0;
@(posedge clk_i); #2;
@(posedge clk_i); #2;
@(posedge clk_i); #2;
@(posedge clk_i); #2;
rstn_i = 1;
etkin_i=1;
sayi_i = 8'd7;  @(posedge clk_i); #2;
sayi_i = 8'd7;  @(posedge clk_i); #2;
sayi_i = 8'd1;  @(posedge clk_i); #2;
sayi_i = 8'd1;  @(posedge clk_i); #2;
sayi_i = 8'd1;  @(posedge clk_i); #2;
sayi_i = 8'd2;  @(posedge clk_i); #2;
sayi_i = 8'd2;  @(posedge clk_i); #2;
sayi_i = 8'd9;  @(posedge clk_i); #2;
sayi_i = 8'd8;  @(posedge clk_i); #2;
etkin_i =0;
@(posedge clk_i); #2;
@(posedge clk_i); #2;
etkin_i=1;
sayi_i = 8'd7;  @(posedge clk_i); #2;
sayi_i = 8'd7;  @(posedge clk_i); #2;
sayi_i = 8'd1;  @(posedge clk_i); #2;
sayi_i = 8'd1;  @(posedge clk_i); #2;
sayi_i = 8'd1;  @(posedge clk_i); #2;
sayi_i = 8'd2;  @(posedge clk_i); #2;
sayi_i = 8'd2;  @(posedge clk_i); #2;
sayi_i = 8'd9;  @(posedge clk_i); #2;
sayi_i = 8'd8;  @(posedge clk_i); #2;
etkin_i =0;
end
endmodule