`timescale 1ns/1ps
`include "sabitler.vh"

module tb_evrisim_birimi();

reg clk_i;
reg rstn_i;
reg filtre_etkin_i;
reg [71:0] filtre_i;
reg veri_etkin_i;
reg [7:0] veri_i;
wire veri_etkin_o;
wire [7:0] veri_o;
wire [7:0] laplacian_pixel_o;
reg gaus_i;
always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

evrisim_birimi eb (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .filtre_etkin_i(filtre_etkin_i),
    .filtre_i(filtre_i),
    .veri_etkin_i(veri_etkin_i),
    .veri_i(veri_i),
    .gaus_i(gaus_i),
    .laplacian_pixel_o(laplacian_pixel_o),
    .veri_etkin_o(veri_etkin_o),
    .veri_o(veri_o)
);

localparam PATH_TO_IMG = "D:/Teknofest_2023/kasirga-goruntu-2023/verify/cevrilmis.txt";
localparam PATH_TO_RES = "D:/Teknofest_2023/kasirga-goruntu-2023/verify/sonuc.txt";
reg [7:0] img_mem [0:320*240-1];
reg [7:0] res_mem [0:320*240-1];

integer res_ctr;    
always @(posedge clk_i) begin
    if (!rstn_i) begin
        res_ctr <= 0;
    end
    else if (veri_etkin_o) begin
        res_mem[res_ctr] <= veri_o;
        res_ctr <= res_ctr + 1;
    end
end

    
integer i;
integer j;
integer f;
initial begin
    $readmemh(PATH_TO_IMG, img_mem);
    f = $fopen(PATH_TO_RES,"w");
    rstn_i = 0;
    filtre_etkin_i = 0;
    veri_etkin_i = 0;
    filtre_i=0;
    veri_i=0;
    @(posedge clk_i); #2;
    rstn_i = 1;
    gaus_i=0;
    filtre_etkin_i=1;
    filtre_i={-8'd1,8'd0,8'd1,-8'd2,8'd0,8'd2,-8'd1,8'd0,8'd1};
    veri_etkin_i=1;
    for(i=0;i<240;i=i+1) begin
        for(j=0;j<320;j=j+1) begin
            veri_i= img_mem[i * 320 + j];
            @(posedge clk_i); #2;
            filtre_etkin_i=0;
        end
    end
    veri_etkin_i=0;
    wait(res_ctr == 320*240);
    @(posedge clk_i);
    for (i = 0; i < 320*240; i = i + 1) begin
        $fwrite(f,"%0x\n", res_mem[i]);
    end
    $fclose(f);
    $finish;
end


endmodule