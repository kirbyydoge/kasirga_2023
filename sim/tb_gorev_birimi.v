`timescale 1ns/1ps
`include "sabitler.vh"

module tb_gorev_birimi();

reg clk_i;
reg rstn_i;
reg basla;
reg etkin_i;
reg [7:0] pixel_i;
reg [2:0] gorev_i;
wire etkin_o;
wire [7:0] pixel_o;

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end


gorev_birimi ss (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .basla(basla),
    .etkin_i(etkin_i),
    .pixel_i(pixel_i),
    .gorev_i(gorev_i),
    .etkin_o(etkin_o),
    .pixel_o(pixel_o)
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
    else if (etkin_o) begin
        res_mem[res_ctr] <= pixel_o;
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
    basla = 0;
    etkin_i = 0;
    pixel_i=0;
    gorev_i=0;
    @(posedge clk_i); #2;
    rstn_i = 1;
    basla=1;
    gorev_i= `GRV3_M;
    @(posedge clk_i); #2;
    basla=0;
    etkin_i=1;
    for(i=0;i<240;i=i+1) begin
        for(j=0;j<320;j=j+1) begin
            pixel_i= img_mem[i * 320 + j];
            @(posedge clk_i); #2;
        end
    end
    etkin_i=0;
    wait(res_ctr == 320*240);
    @(posedge clk_i);
    for (i = 0; i < 320*240; i = i + 1) begin
        $fwrite(f,"%0h\n", res_mem[i]);
    end
    $fclose(f);

    $finish;
end


endmodule