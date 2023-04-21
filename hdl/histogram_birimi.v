`timescale 1ns/1ps
 
`include "sabitler.vh"

module histogram_birimi (
    input                       clk_i,
    input                       rstn_i,
    input                       etkin_i,
    input  [`PIXEL_BIT-1:0]     pixel_i,
    input                       stal_i,
	output                      wr_en_o,
	output [`PIXEL_BIT-1:0]     addr_w_o,
	output [16:0]               data_in_o,
	output                      rd_en_o,
    output [`PIXEL_BIT-1:0]     addr_r_o,
    input  [16:0]               data_out_i,
    output [16:0]               cdf_min_o,
    output [255:0]              valid_o,
    output                      hazir_o
);

assign cdf_min_o=cdf_min_sayac;
reg [`PIXEL_BIT-1:0] cdf_min_pixel,cdf_min_pixel_ns;
reg [16:0]  cdf_min_sayac,cdf_min_sayac_ns;

reg [`PIXEL_BIT-1:0] cache_line1_r;
reg [`PIXEL_BIT-1:0] cache_line1_ns;
reg [16:0] cache_line1_counter_r;
reg [16:0] cache_line1_counter_ns;

reg [`PIXEL_BIT-1:0] cache_line2_r;
reg [`PIXEL_BIT-1:0] cache_line2_ns;
reg [16:0] cache_line2_counter_r;
reg [16:0] cache_line2_counter_ns;

reg [`PIXEL_BIT-1:0] cache_line3_r;
reg [`PIXEL_BIT-1:0] cache_line3_ns;
reg [16:0] cache_line3_counter_r;
reg [16:0] cache_line3_counter_ns;

reg [1:0] sayac_r;
reg [1:0] sayac_ns;
reg [1:0] flag_r;
reg [1:0] flag_ns;
reg [255:0] valid_r;
reg [255:0] valid_ns;
reg [16:0] pixel_sayac_r;
reg [16:0] pixel_sayac_ns;
reg hazir_cmb;
reg [1:0] durum_r;
reg [1:0] durum_ns;

assign valid_o = valid_r;
assign hazir_o = hazir_cmb;

localparam X = 3;
localparam BIR = 0;
localparam IKI = 1;
localparam UC  = 2;




reg wr_en_cmb;
reg [`PIXEL_BIT-1:0] addr_w_cmb;
reg [16:0] data_in_cmb;
reg rd_en_cmb;
reg [`PIXEL_BIT-1:0] addr_r_cmb;
wire [16:0] data_out_w;

reg[7:0]    addr_r_last;
reg[7:0]    addr_w_last;
reg         rd_en_last;
reg         wr_en_last;
reg[16:0]   data_in_last;
/*
assign wr_en_o = stal_i ? !wr_en_last : !wr_en_cmb;
assign addr_w_o = stal_i ? addr_w_last : addr_w_cmb;
assign data_in_o = stal_i ? data_in_last : data_in_cmb;
assign rd_en_o = stal_i ? !rd_en_last : !rd_en_cmb;
assign addr_r_o = stal_i ? addr_r_last : addr_r_cmb;
assign data_out_w = data_out_i;*/
assign wr_en_o = !wr_en_cmb;
assign addr_w_o = addr_w_cmb;
assign data_in_o = data_in_cmb;
assign rd_en_o = !rd_en_cmb;
assign addr_r_o = addr_r_cmb;
assign data_out_w = data_out_i;

reg isaret, isaret_ns;



always @* begin
    durum_ns = durum_r;
    wr_en_cmb = 0;
    addr_w_cmb = 0;
    isaret_ns = isaret;
    data_in_cmb = 0;
    rd_en_cmb = 0;
    addr_r_cmb = 0;
    cache_line1_ns = cache_line1_r;
    cache_line1_counter_ns = flag_r == 1 ? data_out_w + 1 : cache_line1_counter_r; 
    cache_line2_ns = cache_line2_r;
    cache_line2_counter_ns = flag_r == 2 ? data_out_w + 1 : cache_line2_counter_r;     
    cache_line3_ns = cache_line3_r;
    cache_line3_counter_ns = flag_r == 3 ? data_out_w + 1 : cache_line3_counter_r;  
    sayac_ns = sayac_r;
    valid_ns = valid_r;
    flag_ns = flag_r;
    cdf_min_pixel_ns = cdf_min_pixel;
    cdf_min_sayac_ns = cdf_min_sayac;

    hazir_cmb = pixel_sayac_r == 76803 ? 1 : 0;
    pixel_sayac_ns = pixel_sayac_r;

    if (etkin_i) begin
        isaret_ns = 1;
        pixel_sayac_ns = pixel_sayac_r == 76803 ? 0 : pixel_sayac_r + 1;
        if(pixel_i < cdf_min_pixel) begin
            cdf_min_pixel_ns = pixel_i;
            cdf_min_sayac_ns = 1;
        end else if(pixel_i == cdf_min_pixel) begin
            cdf_min_sayac_ns = cdf_min_sayac +1;
        end
        if (cache_line1_r == pixel_i || (cache_line2_r != pixel_i && cache_line3_r != pixel_i && cache_line1_counter_r == 0)) begin
            cache_line1_ns = pixel_i;
            cache_line1_counter_ns = flag_r == 1 ? data_out_w + 2 : cache_line1_counter_r + 1;
            flag_ns = 0;
        end
        else if (cache_line2_r == pixel_i || (cache_line1_r != pixel_i && cache_line3_r != pixel_i && cache_line2_counter_r == 0)) begin
            cache_line2_ns = pixel_i;
            cache_line2_counter_ns = flag_r == 2 ? data_out_w + 2 : cache_line2_counter_r + 1;
            flag_ns = 0;
        end
        else if (cache_line3_r == pixel_i || (cache_line1_r != pixel_i && cache_line2_r != pixel_i && cache_line3_counter_r == 0)) begin
            cache_line3_ns = pixel_i;
            cache_line3_counter_ns = flag_r == 3 ? data_out_w + 2 : cache_line3_counter_r + 1;
            flag_ns = 0;
        end
        else begin
        flag_ns = 0;
        // cache line'dan eleman çıkarıp memory'e yaz, memory'den yeni pixel'i cache line'a getir.
            case (sayac_r) 
                BIR: begin
                    wr_en_cmb = `HIGH;
                    addr_w_cmb = cache_line1_r;
                    data_in_cmb = cache_line1_counter_r;
                    valid_ns [cache_line1_r] = `HIGH;

                    if (valid_r [pixel_i]) begin
                        rd_en_cmb = `HIGH;
                        addr_r_cmb = pixel_i;
                        cache_line1_ns = pixel_i;
                        flag_ns = 1;
                    end
                    else begin
                        flag_ns = 0;
                        cache_line1_ns = pixel_i;
                        cache_line1_counter_ns = 1;
                    end
                    sayac_ns = IKI;
                end
                IKI: begin
                    
                    wr_en_cmb = `HIGH;
                    addr_w_cmb = cache_line2_r;
                    data_in_cmb = cache_line2_counter_r;
                    valid_ns [cache_line2_r] = `HIGH;

                    if (valid_r [pixel_i]) begin
                        rd_en_cmb = `HIGH;
                        addr_r_cmb = pixel_i;
                        cache_line2_ns = pixel_i;
                        flag_ns = 2;
                    end
                    else begin
                        cache_line2_ns = pixel_i;
                        cache_line2_counter_ns = 1;
                        flag_ns = 0;
                    end
                    sayac_ns = UC;

                end
                UC: begin
                    wr_en_cmb = `HIGH;
                    addr_w_cmb = cache_line3_r;
                    data_in_cmb = cache_line3_counter_r;
                    valid_ns [cache_line3_r] = `HIGH;

                    if (valid_r [pixel_i]) begin
                        rd_en_cmb = `HIGH;
                        addr_r_cmb = pixel_i;
                        cache_line3_ns = pixel_i;
                        flag_ns = 3;
                    end
                    else begin
                        cache_line3_ns = pixel_i;
                        cache_line3_counter_ns = 1;
                        flag_ns = 0;
                    end
                    sayac_ns = BIR;
                end
            endcase
        end
    end
    if(isaret & !etkin_i) begin
        case (durum_r) 
            X: begin
                //durum_ns = BIR;
                flag_ns = 0;
                pixel_sayac_ns = 0;
                isaret_ns =0;
            end
            BIR: begin
                wr_en_cmb = `HIGH;
                addr_w_cmb = cache_line1_r;
                data_in_cmb = cache_line1_counter_r;  
                durum_ns = IKI;
                flag_ns = 0;
                pixel_sayac_ns = pixel_sayac_r + 1; 
            end
            IKI: begin
                wr_en_cmb = `HIGH;
                addr_w_cmb = cache_line2_r;
                data_in_cmb = cache_line2_counter_r; 
                durum_ns = UC; 
                pixel_sayac_ns = pixel_sayac_r + 1;
            end
            UC: begin
                wr_en_cmb = `HIGH;
                addr_w_cmb = cache_line3_r;
                data_in_cmb = cache_line3_counter_r; 
                //durum_ns = BIR;
                durum_ns = X;
                pixel_sayac_ns = pixel_sayac_r + 1; 
            end
        endcase

    end

end

always @(posedge clk_i) begin
    if (!rstn_i) begin   
        cache_line1_r <= 0;
        cache_line1_counter_r <= 0;
        cache_line2_r <= 0;
        cache_line2_counter_r <= 0;
        cache_line3_r <= 0;
        cache_line3_counter_r <= 0;  
        sayac_r <= BIR;   
        valid_r <= 0;
        flag_r <= 0;
        pixel_sayac_r <= 0;
        cdf_min_pixel <= 255;
        cdf_min_sayac <= 0;
        durum_r <= BIR;
        isaret <= 0;
        addr_r_last <= 0;
        addr_w_last <= 0;
        rd_en_last <= 0;
        wr_en_last <= 0;
        data_in_last <= 0;

    end 

    else begin
        if(!stal_i) begin
            cache_line1_r <= cache_line1_ns;
            cache_line2_r <= cache_line2_ns;
            cache_line3_r <= cache_line3_ns;
            cache_line1_counter_r <= cache_line1_counter_ns;
            cache_line2_counter_r <= cache_line2_counter_ns;
            cache_line3_counter_r <= cache_line3_counter_ns;
            sayac_r <= sayac_ns;
            valid_r <= valid_ns;
            flag_r <= flag_ns; 
            pixel_sayac_r <= pixel_sayac_ns;  
            durum_r <= durum_ns;
            cdf_min_pixel <= cdf_min_pixel_ns;
            cdf_min_sayac <= cdf_min_sayac_ns;
            isaret <= isaret_ns;
            addr_r_last <= addr_r_cmb;
            addr_w_last <= addr_w_cmb;
            rd_en_last <= rd_en_cmb;
            wr_en_last <= wr_en_cmb;
            data_in_last <= data_in_cmb;

        end
    end
end


endmodule