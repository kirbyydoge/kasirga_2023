`timescale 1ns/1ps

`include "sabitler.vh"

module tb_histogram_esitleme();
    reg                       clk_i;
    reg                       rstn_i;
    reg                       etkin_i;
    reg [`PIXEL_BIT-1:0]      pixel_i;
    wire                      hazir_o;

    histogram_top hb (
        .clk_i (clk_i),
        .rstn_i (rstn_i),
        .etkin_i (etkin_i),
        .pixel_i (pixel_i),
        .hazir_o (hazir_o)
    );

    localparam PATH_TO_IMG = "/home/ali/Desktop/TEKNOFEST/kasirga-goruntu-2023/verify/cevrilmis.txt";
    localparam cikti =       "/home/ali/Desktop/TEKNOFEST/kasirga-goruntu-2023/verify/sonuc.txt";
    localparam eq_verilog =       "/home/ali/Desktop/TEKNOFEST/kasirga-goruntu-2023/verify/eq_verilog.txt";
    
    
    reg [7:0] img_mem [0:320*240-1];
    always begin
        clk_i = 1'b0;
        #5;
        clk_i = 1'b1;
        #5;
    end
integer i;
integer j;
integer f;
integer z;
reg[8:0] say=0;
reg[7:0] eq_mem [255:0];
    always@(posedge clk_i) begin
        if(hb.he.hazir_o) begin
            eq_mem[say]=hb.he.sonuc_o;
            say=say+1;
        end
    end

    initial begin
        $readmemh(PATH_TO_IMG, img_mem);
         f = $fopen(cikti,"w");
         z = $fopen(eq_verilog,"w");

        etkin_i = 0;
        rstn_i = 0;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;;
        rstn_i = 1;
        etkin_i = 1;
        for(i=0;i<240;i=i+1) begin
            for(j=0;j<320;j=j+1) begin
                pixel_i= img_mem[i * 320 + j];
                @(posedge clk_i); 
            end
        end
        pixel_i= 0;
        etkin_i = 0;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
        @(posedge clk_i); #2;
            
        for(i=0;i<256;i=i+1) begin
            
                $fwrite(f,"%0d\n", hb.memory.mem[i]);
                @(posedge clk_i); #2;
           
        end
        
        for(i=0;i<256;i=i+1) begin
            
              @(posedge clk_i); #2;
           
        end
        for(i=0;i<256;i=i+1) begin
            
                $fwrite(z,"%0d\n", eq_mem[i]);
                @(posedge clk_i); #2;
           
        end
        
    $fclose(f);
    $fclose(z);
    $finish;
    end

endmodule