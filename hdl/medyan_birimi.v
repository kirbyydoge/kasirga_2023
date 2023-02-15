`timescale 1ns/1ps

`include "sabitler.vh"

module medyan_birimi (
    input                       clk_i,
    input                       rstn_i,

    input [`PIXEL_BIT-1:0]      sayi_i,
    output [`PIXEL_BIT-1:0]     medyan_o,
    output                      hazir_o                      
);
reg [`PIXEL_BIT*5-1:0] sayilar_r;
reg [`PIXEL_BIT*5-1:0] sayilar_ns;

reg [3:0] hazir_sayac_r;
reg [3:0] hazir_sayac_ns;
reg hazir_cmb;
reg [`PIXEL_BIT-1:0] medyan_cmb;

wire [4:0] karsilastir_w;

wire [`PIXEL_BIT-1:0] sayi1_w;
wire [`PIXEL_BIT-1:0] sayi2_w;
wire [`PIXEL_BIT-1:0] sayi3_w;
wire [`PIXEL_BIT-1:0] sayi4_w;
wire [`PIXEL_BIT-1:0] sayi5_w;

assign sayi1_w = sayilar_r [`PIXEL_BIT*5-1:`PIXEL_BIT*4];
assign sayi2_w = sayilar_r [`PIXEL_BIT*4-1:`PIXEL_BIT*3];
assign sayi3_w = sayilar_r [`PIXEL_BIT*3-1:`PIXEL_BIT*2];
assign sayi4_w = sayilar_r [`PIXEL_BIT*2-1:`PIXEL_BIT];
assign sayi5_w = sayilar_r [`PIXEL_BIT-1:0];

assign karsilastir_w [0] = (sayi_i > sayi5_w) ? 1 : 0;
assign karsilastir_w [1] = (sayi_i > sayi4_w) ? 1 : 0;
assign karsilastir_w [2] = (sayi_i > sayi3_w) ? 1 : 0;
assign karsilastir_w [3] = (sayi_i > sayi2_w) ? 1 : 0;
assign karsilastir_w [4] = (sayi_i > sayi1_w) ? 1 : 0;

wire [2:0] karsilastir_toplam_w;
assign karsilastir_toplam_w = karsilastir_w [0] + karsilastir_w [1] + karsilastir_w [2] + karsilastir_w [3] + karsilastir_w [4];

always @* begin
    sayilar_ns = sayilar_r;
    hazir_cmb = `LOW;
    medyan_cmb = 0;
    hazir_sayac_ns = hazir_sayac_r;
    case (karsilastir_toplam_w) 
        5: sayilar_ns = {sayilar_r [`PIXEL_BIT*4-1:0], sayi_i};     
        4: sayilar_ns = {sayilar_r [`PIXEL_BIT*4-1:`PIXEL_BIT], sayi_i, sayilar_r[`PIXEL_BIT-1:0]};
        3: sayilar_ns = {sayilar_r [`PIXEL_BIT*4-1:`PIXEL_BIT*2], sayi_i, sayilar_r[`PIXEL_BIT*2-1:0]};              
        2: sayilar_ns = {sayilar_r [`PIXEL_BIT*4-1:`PIXEL_BIT*3], sayi_i, sayilar_r[`PIXEL_BIT*3-1:0]};                  
        1: sayilar_ns = {sayi_i, sayilar_r[`PIXEL_BIT*4-1:0]};        
        0: sayilar_ns = sayilar_r;                
    endcase
    if (hazir_sayac_r == 9) begin   // Mecbur 1 çevrim kaybedicez --> 10 çevrimde bitiyor
        hazir_cmb = `HIGH;
        medyan_cmb = sayi1_w;  
        hazir_sayac_ns = 0;
        sayilar_ns = 0;
    end
    else begin
        hazir_sayac_ns = hazir_sayac_r + 1;
    end
end

always @ (posedge clk_i) begin
    if (!rstn_i) begin
        sayilar_r <= 0;
        hazir_sayac_r <= 0;

    end
    else begin
        sayilar_r <= sayilar_ns;
        hazir_sayac_r <= hazir_sayac_ns;

    end
end
assign hazir_o = hazir_cmb;
assign medyan_o = medyan_cmb;

endmodule