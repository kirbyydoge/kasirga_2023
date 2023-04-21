`timescale 1ns/1ps
 
`include "sabitler.vh"

module evrisim_birimi (
    input                       clk_i,
    input                       rstn_i,
    input                       filtre_etkin_i,
    input        [71:0]         filtre_i,
    input                       veri_etkin_i,
    input        [10:0]         veri_i,
    input                       stal_i,
    input                       gaus_i,
    input                       laplacian_i,
    input                       gr2bw_erosion_i,
    input                       tasma_i,
    input        [10:0]          laplacian_pixel_i,           
    output       [71:0]         medyan_o,
    output       [10:0]          laplacian_pixel_o,
    output                      veri_etkin_o,
    output       [10:0]          veri_o

);

    reg gaus_r, gaus_ns;
    reg laplacian_r, laplacian_ns;
    reg gr2bw_erosion_r, gr2bw_erosion_ns;
    reg tasma_r, tasma_ns;

    reg veri_etkin_o_r;
    //assign veri_etkin_o = veri_etkin_o_r;
    assign veri_etkin_o = veri1_etkin_o_r;

    assign laplacian_pixel_o = {2'd0,resim1_r[4]};

    reg [31:0] mul_cmb;
    reg [10:0] veri_o_r;
    assign veri_o = veri_o_r;

    reg [16:0] sayac_320_r;
    reg [16:0] sayac_320_r_ns;
    reg [16:0] sayac_240_r;
    reg [16:0] sayac_240_r_ns;

    reg[7:0] filtre_r [8:0];
    reg[7:0] filtre_r_ns [8:0];

    reg[10:0] resim_r [8:0];
    reg[10:0] resim_r_ns [8:0];

    reg[10:0] resim1_r [8:0];
    reg[10:0] resim1_r_ns [8:0];
    reg veri1_etkin_o_r,veri1_etkin_o_ns;
  

    assign medyan_o ={resim1_r[0][7:0],resim1_r[1][7:0],resim1_r[2][7:0],resim1_r[3][7:0],resim1_r[4][7:0],resim1_r[5][7:0],resim1_r[6][7:0],resim1_r[7][7:0],resim1_r[8][7:0]};

    wire[8:0] resim_BW_w;
    assign resim_BW_w[0] = (resim1_r[0] < 128) ? 0 : 1;
    assign resim_BW_w[1] = (resim1_r[1] < 128) ? 0 : 1;
    assign resim_BW_w[2] = (resim1_r[2] < 128) ? 0 : 1;
    assign resim_BW_w[3] = (resim1_r[3] < 128) ? 0 : 1;
    assign resim_BW_w[4] = (resim1_r[4] < 128) ? 0 : 1;
    assign resim_BW_w[5] = (resim1_r[5] < 128) ? 0 : 1;
    assign resim_BW_w[6] = (resim1_r[6] < 128) ? 0 : 1;
    assign resim_BW_w[7] = (resim1_r[7] < 128) ? 0 : 1;
    assign resim_BW_w[8] = (resim1_r[8] < 128) ? 0 : 1;
    
    wire sonuc_BW_w;
    assign sonuc_BW_w = &resim_BW_w;

    wire cmd_en_i_w[2:0];
    wire wr_en_i_w[2:0];
    wire [8:0] addr_i_w[2:0];
    wire [10:0] data_i_w[2:0];
    wire [10:0] data_o_w[2:0];

    reg cmd_en_i_cmb[2:0];
    reg wr_en_i_cmb[2:0];
    reg [8:0] addr_i_cmb[2:0];
    reg [10:0] data_i_cmb[2:0];

    assign cmd_en_i_w[0] = cmd_en_i_cmb[0];
    assign wr_en_i_w[0] = wr_en_i_cmb[0];
    assign addr_i_w[0] = addr_i_cmb[0];
    assign data_i_w [0] = data_i_cmb[0];
    assign cmd_en_i_w[1] = cmd_en_i_cmb[1];
    assign wr_en_i_w[1] = wr_en_i_cmb[1];
    assign addr_i_w[1] = addr_i_cmb[1];
    assign data_i_w[1] = data_i_cmb[1];
    assign cmd_en_i_w[2] = cmd_en_i_cmb[2];
    assign wr_en_i_w[2] = wr_en_i_cmb[2];
    assign addr_i_w[2] = addr_i_cmb[2];
    assign data_i_w [2] = data_i_cmb[2];
    
    reg[2:0] yaz_index;
    reg[2:0] yaz_index_ns;
    
    reg[10:0] ilk_veri, ilk_veri_ns;


    
    
    wire wr_en_sram0;
    assign wr_en_sram0 = (stal_i && (sayac_320_r == 16'd319)) ? (cmd_en_i_w[2] & wr_en_i_w[2]) : (cmd_en_i_w[0] & wr_en_i_w[0]);
    wire wr_en_sram1;
    assign wr_en_sram1 = (stal_i && (sayac_320_r == 16'd319)) ? (cmd_en_i_w[0] & wr_en_i_w[0]) : (cmd_en_i_w[1] & wr_en_i_w[1]); 
    wire wr_en_sram2;
    assign wr_en_sram2 = (stal_i && (sayac_320_r == 16'd319)) ? (cmd_en_i_w[1] & wr_en_i_w[1]) : (cmd_en_i_w[2] & wr_en_i_w[2]); 
    
    wire rd_en_sram0;
    assign rd_en_sram0 = (stal_i && (sayac_320_r == 16'd319)) ? (1) : (cmd_en_i_w[0] & (cmd_en_i_w[0] ^  wr_en_i_w[0]));
    wire rd_en_sram1;
    assign rd_en_sram1 = (stal_i && (sayac_320_r == 16'd319)) ? (1) : (cmd_en_i_w[1] & (cmd_en_i_w[1] ^  wr_en_i_w[1])); 
    wire rd_en_sram2;
    assign rd_en_sram2 = (stal_i && (sayac_320_r == 16'd319)) ? (1) : (cmd_en_i_w[2] & (cmd_en_i_w[2] ^  wr_en_i_w[2]));

    wire[10:0] data_i_sram0;
    assign data_i_sram0 =  (stal_i && (sayac_320_r == 16'd319)) ? data_i_w[1] : data_i_w[0];
    wire[10:0] data_i_sram1;
    assign data_i_sram1 =  (stal_i && (sayac_320_r == 16'd319)) ? data_i_w[2] : data_i_w[1];
    wire[10:0] data_i_sram2;
    assign data_i_sram2 =  (stal_i && (sayac_320_r == 16'd319)) ? data_i_w[0] : data_i_w[2];
    
    wire[8:0] addr0_i_sram0;
    assign addr0_i_sram0 = stal_i ? ((sayac_320_r == 16'd319) ? 0 : ( addr_i_w[0] + 1)): addr_i_w[0];
    wire[8:0] addr0_i_sram1;
    assign addr0_i_sram1 = stal_i ? ((sayac_320_r == 16'd319) ? 0 : ( addr_i_w[1] + 1)): addr_i_w[1];
    wire[8:0] addr0_i_sram2;
    assign addr0_i_sram2 = stal_i ? ((sayac_320_r == 16'd319) ? 0 : ( addr_i_w[2] + 1)): addr_i_w[2];
    
    wire[8:0] addr1_i_sram0;
    assign addr1_i_sram0 = stal_i ? ((sayac_320_r == 16'd319) ? 9'b100111111 : ( addr_i_w[0] - 1)) : addr_i_w[0];
    wire[8:0] addr1_i_sram1;
    assign addr1_i_sram1 = stal_i ? ((sayac_320_r == 16'd319) ? 9'b100111111 : ( addr_i_w[1] - 1)) : addr_i_w[1];
    wire[8:0] addr1_i_sram2;
    assign addr1_i_sram2 = stal_i ? ((sayac_320_r == 16'd319) ? 9'b100111111 : ( addr_i_w[2] - 1)) : addr_i_w[2];
    
    wire[10:0] data_o_sram0;
    wire[10:0] data_o_sram1;
    wire[10:0] data_o_sram2;
    
    assign data_o_w[0] = (stal_i && sayac_320_r==16'd0) ? data_o_sram1 : data_o_sram0;
    assign data_o_w[1] = (stal_i && sayac_320_r==16'd0) ? data_o_sram2 : data_o_sram1;
    assign data_o_w[2] = (stal_i && sayac_320_r==16'd0) ? data_o_sram0 : data_o_sram2;

    sram_evrisim sram_0 (
    .clk0 (clk_i),
    .csb0 (!wr_en_sram0),
    .addr0 (addr0_i_sram0),
    .din0 (data_i_sram0),
    .clk1 (clk_i),
    .csb1 (!rd_en_sram0),
    .addr1 (addr1_i_sram0),
    .dout1 (data_o_sram0)
    );

    sram_evrisim sram_1 (
    .clk0 (clk_i),
    .csb0 (!wr_en_sram1),
    .addr0 (addr0_i_sram1),
    .din0 (data_i_sram1),
    .clk1 (clk_i),
    .csb1 (!rd_en_sram1),
    .addr1 (addr1_i_sram1),
    .dout1 (data_o_sram1)
    );

    sram_evrisim sram_2 (
    .clk0 (clk_i),
    .csb0 (!wr_en_sram2),
    .addr0 (addr0_i_sram2),
    .din0 (data_i_sram2),
    .clk1 (clk_i),
    .csb1 (!rd_en_sram2),
    .addr1 (addr1_i_sram2),
    .dout1 (data_o_sram2)
    );
    /*
    wire wr_en_sram0;
    assign wr_en_sram0 = cmd_en_i_w[0] & wr_en_i_w[0];
    wire wr_en_sram1;
    assign wr_en_sram1 = cmd_en_i_w[1] & wr_en_i_w[1];
    wire wr_en_sram2;
    assign wr_en_sram2 = cmd_en_i_w[2] & wr_en_i_w[2];
    
    wire rd_en_sram0;
    assign rd_en_sram0 = cmd_en_i_w[0] & (cmd_en_i_w[0] ^  wr_en_i_w[0]);
    wire rd_en_sram1;
    assign rd_en_sram1 = cmd_en_i_w[1] & (cmd_en_i_w[1] ^  wr_en_i_w[1]); 
    wire rd_en_sram2;
    assign rd_en_sram2 = cmd_en_i_w[2] & (cmd_en_i_w[2] ^  wr_en_i_w[2]);

    sram_evrisim sram_0 (
    .clk0 (clk_i),
    .csb0 (!wr_en_sram0),
    .addr0 ((stal_i ? addr_i_w[0] +1 :addr_i_w[0] )),
    .din0 (data_i_w[0]),
    .clk1 (clk_i),
    .csb1 (!rd_en_sram0),
    .addr1 ((stal_i ? addr_i_w[0] -1 :addr_i_w[0] )),
    .dout1 (data_o_w[0])
    );

    sram_evrisim sram_1 (
    .clk0 (clk_i),
    .csb0 (!wr_en_sram1),
    .addr0 ((stal_i ? addr_i_w[1] +1 :addr_i_w[1] )),
    .din0 (data_i_w[1]),
    .clk1 (clk_i),
    .csb1 (!rd_en_sram1),
    .addr1 ((stal_i ? addr_i_w[1] -1 :addr_i_w[1] )),
    .dout1 (data_o_w[1])
    );

    sram_evrisim sram_2 (
    .clk0 (clk_i),
    .csb0 (!wr_en_sram2),
    .addr0 ((stal_i ? addr_i_w[2] +1 :addr_i_w[2] )),
    .din0 (data_i_w[2]),
    .clk1 (clk_i),
    .csb1 (!rd_en_sram2),
    .addr1 ((stal_i ? addr_i_w[2] -1 :addr_i_w[2] )),
    .dout1 (data_o_w[2])
    );*/
    /*
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
    );*/
    
    integer i;
    always @* begin
        for(i=0;i<9;i=i+1) begin
            resim1_r_ns[i] = resim_r[i];
        end
        veri1_etkin_o_ns = veri_etkin_o_r;
    end
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
        resim_r[8] = 0;
        resim_r[5] = 0;
        resim_r[2] = 0;
        cmd_en_i_cmb[0] = 0;
        wr_en_i_cmb[0] = 0;
        addr_i_cmb[0] = 0;
        data_i_cmb[0] = 0;
        cmd_en_i_cmb[1] = 0;
        wr_en_i_cmb[1] = 0;
        addr_i_cmb[1] = 0;
        data_i_cmb[1] = 0;
        cmd_en_i_cmb[2] = 0;
        wr_en_i_cmb[2] = 0;
        addr_i_cmb[2] = 0;
        data_i_cmb[2] = 0;
        veri_etkin_o_r = 0;
        ilk_veri_ns = ilk_veri;
        gaus_ns = gaus_r;
        laplacian_ns = laplacian_r;
        gr2bw_erosion_ns = gr2bw_erosion_r;
        tasma_ns = tasma_r;
        for(i=0;i<9;i=i+1) begin
            filtre_r_ns[i] = filtre_r[i];
        end
        if(filtre_etkin_i) begin
            for(i=9;i>0;i=i-1) begin
                filtre_r_ns[9-i] = filtre_i[(i*8-1)-:8];
            end
            gaus_ns = gaus_i;
            laplacian_ns = laplacian_i;
            gr2bw_erosion_ns = gr2bw_erosion_i;
            tasma_ns = tasma_i;
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


        if(sayac_320_r==0 && sayac_240_r==0) begin
            ilk_veri_ns = veri_i;
            veri_etkin_o_r=0;
        end

        if(sayac_320_r==319 && sayac_240_r==1) begin

            veri_etkin_o_r = 1;
            
            resim_r[2] = 0;
            resim_r[5] = data_o_w[(yaz_index+2)%3];
            resim_r[8] = veri_i;

            resim_r_ns[0] = 0;
            resim_r_ns[1] = 0;
            resim_r_ns[3] = resim_r[4];
            resim_r_ns[4] = data_o_w[(yaz_index+2)%3];
            resim_r_ns[6] = resim_r[7];
            resim_r_ns[7] = veri_i;

            addr_i_cmb[(yaz_index+2)%3] = 0;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;
        end

        if(sayac_320_r==319 && sayac_240_r>1 && sayac_240_r<239) begin

            veri_etkin_o_r = 1;

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

        if(sayac_320_r==319 && sayac_240_r==239) begin

            veri_etkin_o_r = 1;

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
            
            veri_etkin_o_r = 0;

            resim_r[2]=0;
            resim_r[5]=0;
            resim_r[8]=0;

            resim_r_ns[0] = 0;
            resim_r_ns[1] = 0;
            resim_r_ns[3] = 0;
            resim_r_ns[4] = ilk_veri;
            resim_r_ns[6] = 0;
            resim_r_ns[7] = veri_i;

            ilk_veri_ns=veri_i;
            

            addr_i_cmb[(yaz_index+2)%3] = 1;
            wr_en_i_cmb[(yaz_index+2)%3] = 0;
            cmd_en_i_cmb[(yaz_index+2)%3] = 1;


        end

        if(sayac_320_r == 0 && sayac_240_r > 1 && sayac_240_r <= 239) begin
            
            veri_etkin_o_r = 1;

            resim_r[2]=0;
            resim_r[5]=0;
            resim_r[8]=0;

            resim_r_ns[0] = 0;
            resim_r_ns[1] = data_o_w[(yaz_index+1)%3];
            resim_r_ns[3] = 0;
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
            
            veri_etkin_o_r = 1;

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

                veri_etkin_o_r = 1;

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

                veri_etkin_o_r = 1;

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

                veri_etkin_o_r = 1;

                resim_r[2]=0;
                resim_r[5]=0;
                resim_r[8]=0;
                sayac_240_r_ns=0;
                sayac_320_r_ns=0;
            end

            
        end

        mul_cmb = 0;

        if(gaus_r) begin
            
            for (i = 0; i < 9; i = i + 1) begin
                mul_cmb = $signed(mul_cmb) + ($signed(filtre_r[i]) * $signed({1'b0, resim1_r[i]}));
            end
            
            veri_o_r = (mul_cmb >> 4) + mul_cmb[3];
            
        
        end else if(laplacian_r) begin

            for (i = 0; i < 9; i = i + 1) begin
                mul_cmb = $signed(mul_cmb)  + ($signed(filtre_r[i]) * $signed({resim1_r[i]})) ;
            end
    
            

            if(tasma_r) begin
                if ($signed(mul_cmb) < 0) begin
                    mul_cmb = 0;
                end
                else if ( $signed(mul_cmb)  > 255) begin
                    mul_cmb = 255;
                end 
            end  
            mul_cmb = mul_cmb +  $signed({24'd0, laplacian_pixel_i}); 
            if ($signed(mul_cmb) < 0) begin
                mul_cmb = 0;
            end
            else if ( $signed(mul_cmb)  > 255) begin
                mul_cmb = 255;
            end 
            veri_o_r = mul_cmb;

        end else if(gr2bw_erosion_r) begin
            
            veri_o_r = sonuc_BW_w ? 8'b11111111 : resim1_r[4];

        end else begin

            for (i = 0; i < 9; i = i + 1) begin
                mul_cmb = $signed(mul_cmb) + ($signed(filtre_r[i]) * $signed({resim1_r[i]}));
            end

            
            if(tasma_r) begin
                if ($signed(mul_cmb) < 0) begin
                    veri_o_r = 0;
                end
                else if ( mul_cmb > 255) begin
                    veri_o_r = 255;
                end else begin
                    veri_o_r = mul_cmb;
                end
            end else begin
                veri_o_r = mul_cmb; 
            end
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
            gaus_r <= 0;
            laplacian_r <= 0;
            gr2bw_erosion_r <= 0;
            tasma_r <= 0;
        end
        else begin
            if(!stal_i) begin
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
                gaus_r <= gaus_ns;
                laplacian_r <= laplacian_ns;
                gr2bw_erosion_r <= gr2bw_erosion_ns;
                tasma_r <= tasma_ns;
                for(i=0;i<9;i=i+1) begin
                    resim1_r[i] <= resim1_r_ns[i];
                end
                veri1_etkin_o_r <= veri1_etkin_o_ns;
            end
        end
    end    


endmodule