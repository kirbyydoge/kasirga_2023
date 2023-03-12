`timescale 1ns/1ps
 
`include "sabitler.vh"

module histogram_esitleme #(
    parameter M = 320,
    parameter N =240    
)(
    input                       clk_i,
    input                       rstn_i,
    input                       etkin_i,
    input        [17:0]         cdf_min_i,
    input        [7:0]          pixel_i,
    input        [17:0]         cdf_i,
    output       [7:0]          sonuc_o,
    output                      hazir_o
);

reg hazir_cmb_o;
assign hazir_o=hazir_cmb_o;
reg[7:0] sonuc_cmb_o;
assign sonuc_o=sonuc_cmb_o;


wire[17:0] MN;
assign MN= M*N;

reg[17:0] cikarma_r1;
reg[17:0] cikarma_r1_ns;
reg[17:0] cikarma_r2;
reg[17:0] cikarma_r2_ns;


reg[31:0] pipe,pipe_ns;
reg[31:0] zero,zero_ns;
reg[20:0] say1 [19:0];
reg[20:0] say2 [19:0];
reg[20:0] say1_ns [19:0];
reg[20:0] say2_ns [19:0];

reg[20:0] bolum [20:0];
reg[20:0] bolum_ns [20:0];

reg[31:0] ss,ss_ns;

integer i;

always@* begin
    cikarma_r1_ns = cikarma_r1;
    cikarma_r2_ns = cikarma_r2;
    zero_ns = zero;
    for(i=0;i<20;i=i+1) begin
        say1_ns[i] = say1[i];
        say2_ns[i] = say2[i];
        bolum_ns[i] = bolum[i];
    end
    bolum_ns[20] = bolum[20];
    pipe_ns = {pipe[30:0],etkin_i};
    ss_ns = ss;
    
    if(etkin_i) begin
        cikarma_r1_ns = cdf_i-cdf_min_i;
        cikarma_r2_ns = MN-cdf_min_i;
    end 
    if(pipe[0]) begin
        zero_ns = {zero[30:0],cikarma_r1[17]};
        say1_ns[0] = cikarma_r1<<3;
        say2_ns[0] = cikarma_r2[16] ? cikarma_r2<<3 : cikarma_r2<<4;
    end

    for(i=0;i<20;i=i+1) begin
        if(say1[i]>=say2[i]) begin
            bolum_ns[i+1]={bolum[i][20:1],1'b1};
            say1_ns[i+1]=say1[i]-say2[i];
            say2_ns[i+1]=  1 >> say2[i];
        end else begin
            bolum_ns[i+1]={bolum[i][20:1],1'b0};
            say1_ns[i+1]=say1[i];
            say2_ns[i+1]= 1 >> say2[i];
        end        
    end
    if(pipe[21]) begin
        ss_ns=(bolum[20]<<8) - bolum[20];
    end
    if(pipe[22]) begin
        hazir_cmb_o=1;
        sonuc_cmb_o= ss[11:3]+ss[2];
    end
                
end

always@(posedge clk_i) begin
    if(!rstn_i) begin
        cikarma_r1 <= cikarma_r1_ns;
        cikarma_r2 <= cikarma_r2_ns;
        zero <= zero_ns;
        for(i=0;i<20;i=i+1) begin
            say1[i] <= say1_ns[i];
            say2[i] <= say2_ns[i];
            bolum[i] <= bolum_ns[i];
        end
        bolum[20] <= bolum_ns[20];
        pipe <= pipe_ns;
        ss <= ss_ns;
    end else begin
        
    end
end

endmodule