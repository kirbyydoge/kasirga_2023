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

// Huffman Cozucu
`define HD_AC_TABLO_BIT     16
`define HD_AC_TABLO_ROW     162

`define HD_BUF_DEPTH        8   // ikinin kati olmasi donanim karmasikligini azaltir
`define HD_BUF_BIT          (`HD_BUF_DEPTH * `WB_BIT)

`define HD_COZ_ADIM         4

// Nicemleme Tablosu
`define DQ_TABLO_BIT        8