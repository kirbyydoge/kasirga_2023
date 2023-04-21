`define FPGA
//`define CARAVEL

`define CLK_HZ              100_000_000
`define BAUD_RATE           9600

`define HIGH                1'b1
`define LOW                 1'b0

`define WB_BIT              32
`define WB_BYTE             (`WB_BIT / 8)

`define RUN_BIT             4
`define CAT_BIT             4

`define PIXEL_BIT           8

`define BLOCK_SIZE          8
`define BLOCK_BIT           $clog2(`BLOCK_SIZE)
`define BLOCK_AREA          (`BLOCK_SIZE * `BLOCK_SIZE)
`define BLOCK_AREA_BIT      $clog2(`BLOCK_AREA)

`define IMG_WIDTH           320
`define IMG_WIDTH_BIT       $clog2(`IMG_WIDTH)
`define IMG_HEIGHT          240
`define IMG_HEIGHT_BIT      $clog2(`IMG_HEIGHT)
`define IMG_AREA            (`IMG_WIDTH * `IMG_HEIGHT)
`define IMG_AREA_BIT        $clog2(`IMG_AREA)

`define IMG_ROW_BLOCKS      (`IMG_HEIGHT / `BLOCK_SIZE)
`define IMG_COL_BLOCKS      (`IMG_WIDTH / `BLOCK_SIZE)
`define IMG_BLOCKS          (`IMG_ROW_BLOCKS * `IMG_COL_BLOCKS)
`define IMG_BLOCKS_BIT      $clog2(`IMG_BLOCKS)

// Huffman Cozucu
`define HD_AC_TABLO_BIT     16
`define HD_AC_TABLO_ROW     162

`define HD_BUF_DEPTH        8   // ikinin kati olmasi donanim karmasikligini azaltir
`define HD_BUF_BIT          (`HD_BUF_DEPTH * `WB_BIT)

`define HD_COZ_ADIM         4

// Nicemleme Tablosu
`define DQ_TABLO_BIT        8

// Inverse Cosine-II Transformer
`define Q_INT_BIT           15
`define Q_FRAC_BIT          3
`define Q_BIT               (`Q_INT_BIT + `Q_FRAC_BIT)
`define Q_INT               `Q_FRAC_BIT +: `Q_INT_BIT
`define Q_FRAC              0 +: `Q_FRAC_BIT
`define Q_MUL_SELECT        `Q_FRAC_BIT +: `Q_BIT

// Gorev Birimi
`define GB_FILTER_SIZE      3
`define GB_FILTER_EDGE      (`GB_FILTER_SIZE / 2)
`define GB_FILTER_WEDGE     (`GB_FILTER_EDGE + 1)
`define GB_FILTER_BIT       $clog2(`GB_FILTER_SIZE)
`define GB_FILTER_AREA      (`GB_FILTER_SIZE * `GB_FILTER_SIZE)
`define GB_FILTER_AREA_BIT  $clog2(`GB_FILTER_AREA)

// Gorevler
`define GRV_BIT 3

`define GRV1_G_SXY  0
`define GRV2_G_L    1
`define GRV3_M      2
`define GRV4_H      3
`define GRV5_HE     4
`define GRV6_G2BW_E 5 

// FILTRELER

`define NON_FLTR        72'h000000000100000000
`define GAUSIAN_FLTR    72'd18591142952998863361
`define SOBEL_X_FLTR    72'd18518522396055503103
`define SOBEL_Y_FLTR    72'd18591140736778895103
`define LAPLACIAN_FLTR  72'd4722366481808788291583  
