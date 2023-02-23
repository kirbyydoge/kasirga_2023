`timescale 1ns/1ps
 
`include "sabitler.vh"

module evrisim_birimi (
    input                       clk_i,
    input                       rstn_i,
    input                       filtre_etkin_i,
    input        [71:0]         filtre_i,
    input                       veri_etkin_i,
    input        [7:0]          veri_i,
    output                      veri_etkin_o,
    output       [7:0]          veri_o

);

    reg veri_etkin_o_r;
    assign veri_etkin_o = veri_etkin_o_r;

    reg [31:0] mul_cmb;
    reg [15:0] veri_o_r;
    assign veri_o = veri_o_r;

    reg [16:0] sayac_320_r;
    reg [16:0] sayac_320_r_ns;
    reg [16:0] sayac_240_r;
    reg [16:0] sayac_240_r_ns;

    reg[7:0] filtre_r [8:0];
    reg[7:0] filtre_r_ns [8:0];

    reg[7:0] resim_r [8:0];
    reg[7:0] resim_r_ns [8:0];

    reg rsm0[7:0];
    reg rsm1[7:0]; 

    wire cmd_en_i_w[2:0];
    wire wr_en_i_w[2:0];
    wire [8:0] addr_i_w[2:0];
    wire [7:0] data_i_w[2:0];
    wire [7:0] data_o_w[2:0];

    reg cmd_en_i_cmb[2:0];
    reg wr_en_i_cmb[2:0];
    reg [8:0] addr_i_cmb[2:0];
    reg [7:0] data_i_cmb[2:0];

    assign cmd_en_i_w[0] = cmd_en_i_cmb[0];
    assign wr_en_i_w[0] = wr_en_i_cmb[0];
    assign addr_i_w[0] = addr_i_cmb[0];
    assign data_i_w [0]= data_i_cmb[0];
    assign cmd_en_i_w[1] = cmd_en_i_cmb[1];
    assign wr_en_i_w[1] = wr_en_i_cmb[1];
    assign addr_i_w[1] = addr_i_cmb[1];
    assign data_i_w [1]= data_i_cmb[1];
    assign cmd_en_i_w[2] = cmd_en_i_cmb[2];
    assign wr_en_i_w[2] = wr_en_i_cmb[2];
    assign addr_i_w[2] = addr_i_cmb[2];
    assign data_i_w [2]= data_i_cmb[2];
    
    reg[2:0] yaz_index;
    reg[2:0] yaz_index_ns;
    
    reg[7:0] ilk_veri, ilk_veri_ns;


    bram_model 
    #(.DATA_WIDTH(8), .BRAM_DEPTH(320))
    bram_0 (
        .clk_i      (clk_i )    ,
        .data_i     (data_i_w[0] ) ,
        .addr_i     (addr_i_w[0])  ,
        .wr_en_i    (wr_en_i_w[0]) ,
        .cmd_en_i   (cmd_en_i_w[0]),
        .data_o     (data_o_w[0])
    );

    bram_model 
    #(.DATA_WIDTH(8), .BRAM_DEPTH(320))
    bram_1 (
        .clk_i      (clk_i )    ,
        .data_i     (data_i_w[1] ) ,
        .addr_i     (addr_i_w[1])  ,
        .wr_en_i    (wr_en_i_w[1]) ,
        .cmd_en_i   (cmd_en_i_w[1]),
        .data_o     (data_o_w[1])
    );

    bram_model 
    #(.DATA_WIDTH(8), .BRAM_DEPTH(320))
    bram_2 (
        .clk_i      (clk_i )    ,
        .data_i     (data_i_w[2] ) ,
        .addr_i     (addr_i_w[2])  ,
        .wr_en_i    (wr_en_i_w[2]) ,
        .cmd_en_i   (cmd_en_i_w[2]),
        .data_o     (data_o_w[2])
    );

    integer i;
    always @* begin
        mul_cmb = 0;
        sayac_320_r_ns = sayac_320_r;
        sayac_240_r_ns = sayac_240_r;
        yaz_index_ns = yaz_index;
        resim_r_ns[0] = resim_r[0];
        resim_r_ns[1] = resim_r[1];
        resim_r_ns[3] = resim_r[3];
        resim_r_ns[4] = resim_r[4];
        resim_r_ns[6] = resim_r[6];
        resim_r_ns[7] = resim_r[7];
        ilk_veri_ns = ilk_veri;
        for(i=0;i<9;i=i+1) begin
            filtre_r_ns[i] = filtre_r[i];
        end
        if(filtre_etkin_i) begin
            for(i=9;i>0;i=i-1) begin
                filtre_r_ns[9-i] = filtre_i[(i*8-1)-:8];
            end
        end
        if(veri_etkin_i) begin
            if(((sayac_320_r+1)%320)==0) begin
                yaz_index_ns = (yaz_index +1) % 3;
                sayac_320_r_ns = 0;
                sayac_240_r_ns = sayac_240_r+1;
            end else begin
                sayac_320_r_ns = sayac_320_r+1;
            end
            data_i_cmb[yaz_index] = veri_i;
            addr_i_cmb[yaz_index] = sayac_320_r;
            wr_en_i_cmb[yaz_index] = 1;
            cmd_en_i_cmb[yaz_index] = 1;
            wr_en_i_cmb[(yaz_index +1) % 3] = 0;
            wr_en_i_cmb[(yaz_index +2) % 3] = 0;
        end

        /*if(sayac_320_r==319 && sayac_240_r==0) begin
            addr_i_cmb[yaz_index] = 0;
            wr_en_i_cmb[yaz_index] = 0;
            cmd_en_i_cmb[yaz_index] = 1;
        end*/

        if(sayac_320_r==0 && sayac_240_r==0) begin
            ilk_veri_ns = veri_i;
            veri_etkin_o_r=0;
        end

        if(sayac_320_r==319 && sayac_240_r==1) begin
            
            resim_r[2] = 0;
            resim_r[5] = data_o_w[(yaz_index+2)%3];
            resim_r[8] = veri_i;

            resim_r_ns[0] = 0;
            resim_r_ns[1] = 0;
            resim_r_ns[3] = resim_r[4];
            resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[6] = resim_r[7];
            resim_r_ns[7] = veri_i;

            

            /*addr_i_cmb[yaz_index] = 0;
            wr_en_i_cmb[yaz_index] = 0;
            cmd_en_i_cmb[yaz_index] = 1;*/

            addr_i_cmb[(yaz_index+2)%3] = 0;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;
        end

        if(sayac_320_r==319 && sayac_240_r>1 && sayac_240_r<239) begin
            
            resim_r[2]= data_o_w[(yaz_index+1)%3];
            resim_r[5]= data_o_w[(yaz_index+2)%3];
            resim_r[8]= veri_i;
            
            resim_r_ns[0] = resim_r[1];
            resim_r_ns[1] = data_o_w[(yaz_index+1)%3];
            resim_r_ns[3] = resim_r[4];
            resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[6] = resim_r[7];
            resim_r_ns[7] = veri_i;
            
            

            /*addr_i_cmb[yaz_index] = 0;
            wr_en_i_cmb[yaz_index] = 0;
            cmd_en_i_cmb[yaz_index] = 1;*/

            addr_i_cmb[(yaz_index+2)%3] = 0;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;

        end

        if(sayac_320_r==319 && sayac_240_r==239) begin

            resim_r[2]= data_o_w[(yaz_index+1)%3];
            resim_r[5]= data_o_w[(yaz_index+2)%3];
            resim_r[8]= veri_i;

            resim_r_ns[0] = resim_r[1];
            resim_r_ns[1] = data_o_w[(yaz_index+1)%3];
            resim_r_ns[3] = resim_r[4];
            resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[6] = resim_r[7];
            resim_r_ns[7] = veri_i;

            addr_i_cmb[(yaz_index+2)%3] = 0;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;
        end

        if(sayac_320_r == 0 && sayac_240_r == 1) begin
            
            resim_r[2]=0;
            resim_r[5]=0;
            resim_r[8]=0;

            resim_r_ns[0] = 0;
            resim_r_ns[1] = 0;
            resim_r_ns[3] = 0;
            //resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[4] = ilk_veri;
            resim_r_ns[6] = 0;
            resim_r_ns[7] = veri_i;

            ilk_veri_ns=veri_i;
            

            addr_i_cmb[(yaz_index+2)%3] = 1;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;


        end

        if(sayac_320_r == 0 && sayac_240_r > 1 && sayac_240_r <= 239) begin
            
            resim_r[2]=0;
            resim_r[5]=0;
            resim_r[8]=0;

            resim_r_ns[0] = 0;
            resim_r_ns[1] = data_o_w[(yaz_index+1)%3];
            resim_r_ns[3] = 0;
            //resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[4] = ilk_veri;
            resim_r_ns[6] = 0;
            resim_r_ns[7] = veri_i;

            ilk_veri_ns = veri_i;

            addr_i_cmb[(yaz_index+1)%3] = 1;
            wr_en_i_cmb[(yaz_index+1)%3] = 0;
            cmd_en_i_cmb[(yaz_index+1)%3] = 1;

            addr_i_cmb[(yaz_index+2)%3] = 1;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;

        end

        if(sayac_320_r > 0 && sayac_320_r < 319 && sayac_240_r == 1) begin
            
            veri_etkin_o_r=1;

            resim_r[2]=0;
            resim_r[5]=data_o_w[(yaz_index+2)%3];
            resim_r[8]=veri_i;

            resim_r_ns[0] = 0;
            resim_r_ns[1] = 0;
            resim_r_ns[3] = resim_r[4];
            resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[6] = resim_r[7];
            resim_r_ns[7] = veri_i;

            

            addr_i_cmb[(yaz_index+2)%3] = sayac_320_r +1;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;

        end

        if(sayac_320_r > 0 && sayac_320_r < 319 && sayac_240_r > 1 && sayac_240_r <= 239) begin
            
            resim_r[2]=data_o_w[(yaz_index+1)%3];
            resim_r[5]=data_o_w[(yaz_index+2)%3];
            resim_r[8]=veri_i;

            resim_r_ns[0] = resim_r[1];
            resim_r_ns[1] = data_o_w[(yaz_index+1)%3];
            resim_r_ns[3] = resim_r[4];
            resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[6] = resim_r[7];
            resim_r_ns[7] = veri_i;

            

            addr_i_cmb[(yaz_index+1)%3] = sayac_320_r +1;
            wr_en_i_cmb[(yaz_index+1)%3] = 0;
            cmd_en_i_cmb[(yaz_index+1)%3] = 1;

            addr_i_cmb[(yaz_index+2)%3] = sayac_320_r +1;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;

        end

        if(sayac_240_r==240) begin
            if(sayac_320_r==0) begin
                resim_r[2]=0;
                resim_r[5]=0;
                resim_r[8]=0;

                resim_r_ns[0] = 0;
                resim_r_ns[1] = data_o_w[(yaz_index+1)%3];
                resim_r_ns[3] = 0;
                resim_r_ns[4] = ilk_veri;
                resim_r_ns[6] = 0;
                resim_r_ns[7] = 0;



                addr_i_cmb[(yaz_index+2)%3] = sayac_320_r +1;
                wr_en_i_cmb[(yaz_index+2)%3] = 0;
                cmd_en_i_cmb[(yaz_index+2)%3] = 1;

                addr_i_cmb[(yaz_index+1)%3] = sayac_320_r +1;
                wr_en_i_cmb[(yaz_index+1)%3] = 0;
                cmd_en_i_cmb[(yaz_index+1)%3] = 1;
                sayac_320_r_ns=sayac_320_r+1;
            end
            if(sayac_320_r>0 && sayac_320_r<=319) begin
                resim_r[2]=data_o_w[(yaz_index+1)%3];
                resim_r[5]=data_o_w[(yaz_index+2)%3];
                resim_r[8]=0;

                resim_r_ns[0] = resim_r[1];
                resim_r_ns[1] = data_o_w[(yaz_index+1)%3];
                resim_r_ns[3] = resim_r[4];
                resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
                resim_r_ns[6] = 0;
                resim_r_ns[7] = 0;



                addr_i_cmb[(yaz_index+2)%3] = sayac_320_r +1;
                wr_en_i_cmb[(yaz_index+2)%3] = 0;
                cmd_en_i_cmb[(yaz_index+2)%3] = 1;

                addr_i_cmb[(yaz_index+1)%3] = sayac_320_r +1;
                wr_en_i_cmb[(yaz_index+1)%3] = 0;
                cmd_en_i_cmb[(yaz_index+1)%3] = 1;
                sayac_320_r_ns=sayac_320_r+1;
            end

            if(sayac_320_r==320) begin
                resim_r[2]=0;
                resim_r[5]=0;
                resim_r[8]=0;
                sayac_240_r_ns=0;
                sayac_320_r_ns=0;
            end

            
        end

        mul_cmb = 0;
        for (i = 0; i < 9; i = i + 1) begin
            mul_cmb = $signed(mul_cmb) + $signed(filtre_r[i]) * $signed({1'b0, resim_r[i]});
        end

        veri_o_r = mul_cmb; 
        if ($signed(mul_cmb) < 0) begin
            veri_o_r = 0;
        end
        else if (mul_cmb > 255) begin
            veri_o_r = 255;
        end

    end

    always @(posedge clk_i) begin
        if (!rstn_i) begin
            sayac_320_r <= 0;
            sayac_240_r <= 0;
            yaz_index <= 0;
            for(i=8;i>=0;i=i-1) begin
                filtre_r[i] <= 0;
            end
            resim_r[0] <= 0;
            resim_r[1] <= 0;
            resim_r[3] <= 0;
            resim_r[4] <= 0;
            resim_r[6] <= 0;
            resim_r[7] <= 0;
            ilk_veri <= 0;
            veri_etkin_o_r <= 0;
        end
        else begin
            sayac_320_r <= sayac_320_r_ns;
            sayac_240_r <= sayac_240_r_ns;
            yaz_index <= yaz_index_ns;
            for(i=0;i<9;i=i+1) begin
                filtre_r[i] <= filtre_r_ns[i];
            end
            resim_r[0] <= resim_r_ns[0];
            resim_r[1] <= resim_r_ns[1];
            resim_r[3] <= resim_r_ns[3];
            resim_r[4] <= resim_r_ns[4];
            resim_r[6] <= resim_r_ns[6];
            resim_r[7] <= resim_r_ns[7];
            ilk_veri <= ilk_veri_ns;
        end
    end    


endmodule