`timescale 1ns/1ps
 
`include "sabitler.vh"

module histogram_esitleme #(
    parameter M = 320,
    parameter N =240    
)(
    input                       clk_i,
    input                       rstn_i,
    input                       etkin_i,
    input                       stal_i,
    input        [16:0]         cdf_min_i,
    input        [7:0]          pixel_i,
    input        [16:0]         cdf_i,
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
reg[34:0] say1 [17:0];
reg[34:0] say2 [17:0];
reg[34:0] say1_ns [17:0];
reg[34:0] say2_ns [17:0];

reg[17:0] bolum [18:0];
reg[17:0] bolum_ns [18:0];

reg[31:0] ss,ss_ns;

integer i;

always@* begin
    cikarma_r1_ns = cikarma_r1;
    cikarma_r2_ns = cikarma_r2;
    zero_ns = zero;
    for(i=0;i<18;i=i+1) begin
        say1_ns[i] = say1[i];
        say2_ns[i] = say2[i];
        bolum_ns[i] = bolum[i];
    end
    bolum_ns[18] = bolum[18];
    pipe_ns = {pipe[30:0],etkin_i};
    ss_ns = ss;
    hazir_cmb_o=0;
    sonuc_cmb_o= 0;
    
    if(etkin_i) begin
        cikarma_r1_ns = {1'b0,cdf_i}-{1'b0,cdf_min_i};
        cikarma_r2_ns = {1'b0,MN}-{1'b0,cdf_min_i};
    end 
    if(pipe[0]) begin
        zero_ns = {zero[30:0],cikarma_r1[17]};
        say1_ns[0] = cikarma_r1<<16;
        say2_ns[0] = cikarma_r2<<17;
    end

    for(i=0;i<18;i=i+1) begin
        if(say1[i]>=say2[i]) begin
            bolum_ns[i+1]={bolum[i][16:0],1'b1};
            say1_ns[i+1]=say1[i]-say2[i]; 
            say2_ns[i+1]=  say2[i] >> 1 ;
        end else begin
            bolum_ns[i+1]={bolum[i][16:0],1'b0};
            say1_ns[i+1]=say1[i];
            say2_ns[i+1]= say2[i] >> 1;
        end        
    end
    if(pipe[19]) begin
        ss_ns=(bolum[18]) - (bolum[18] >> 8);
    end
    if(pipe[20]) begin
        hazir_cmb_o=1;
        sonuc_cmb_o= zero[19] ? 0 : (ss[31:8] + ss[7]);
    end
                
end

always@(posedge clk_i) begin
    if(rstn_i) begin
        if(!stal_i) begin
            cikarma_r1 <= cikarma_r1_ns;
            cikarma_r2 <= cikarma_r2_ns;
            zero <= zero_ns;
            for(i=0;i<18;i=i+1) begin
                say1[i] <= say1_ns[i];
                say2[i] <= say2_ns[i];
                bolum[i] <= bolum_ns[i];
            end
            bolum[18] <= bolum_ns[18];
            pipe <= pipe_ns;
            ss <= ss_ns;
        end
    end else begin
        cikarma_r1 <= 0;
        cikarma_r2 <= 0;
        zero <= 0;
        for(i=0;i<18;i=i+1) begin
            say1[i] <= 0;
            say2[i] <= 0;
            bolum[i] <= 0;
        end
        bolum[18] <= 0;
        pipe <= 0;
        ss <= 0;    
    end
end

endmodule