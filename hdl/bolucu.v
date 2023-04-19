`timescale 1ns/1ps
 
`include "sabitler.vh"

module histogram_top (
    input clk,
    input rstn_i,
    input etkin_i,
    input [20:0] say1,
    input [20:0] say2,
    output etkin_o,
    output [20:0] sonuc
);

reg say1_r, say1_r_ns;
reg say2_r, say1_r_ns;

always@* begin
    if(etkin_i) begin
    
    end
end

always@(posedge clk) begin
    
end

endmodule