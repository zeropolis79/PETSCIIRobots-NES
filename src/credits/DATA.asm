.segment BANK(BK_CREDITS)

.define T8B0  $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
.define T8B1  $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7

.define ATT_OF_THE_0  $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F
.define ATT_OF_THE_1  $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F
.define ATT_OF_THE_2  $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$7F

.define PETSCIIROB_0  $20,$20,$20,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$20,$20,$20
.define PETSCIIROB_1  $20,$20,$20,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$20,$20,$20
.define PETSCIIROB_2  $20,$20,$20,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$20,$20,$20
.define PETSCIIROB_3  $20,$20,$20,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$20,$20,$20


; 0 -> $00, 1 -> $55, 2 -> $AA, 3 -> $FF
MUSICPLAYER_PALETTE_DATA:
	.BYTE  $00, $00, $55, $55, $AA, $AA, $00, $00
	.BYTE  $FF, $FF, $00, $00, $00, $00, $00, $00
	.BYTE  $00, $00, $00, $00, $00, $00, $00, $00
	.BYTE  $00, $00, $00, $00, $00, $00
@PADDING:	
	.BYTE  $00, $00

MUSICPLAYER_ROW_LOAD:
	.BYTE  24, 25, 26, 27, 28, 29, 30, 31
	.BYTE  32, 33, 34, 35, 36, 37, 38, 39
	.BYTE  40, 41, 42, 43, 44, 45, 46, 47
	.BYTE  48, 49, 50, 51, 52, 53, 54, 55
	.BYTE  56, 57, 58, 59,  0,  1,  2,  3
	.BYTE   4,  5,  6,  7,  8,  9, 10, 11
	.BYTE  12, 13, 14, 15, 16, 17, 18, 19
	.BYTE  20, 21, 22, 23
@PADDING:	
	.BYTE  $00, $00, $00, $00

MUSICPLAYER_ROW_TARGET_Y:
	.BYTE  24, 25, 26, 27, 28, 29,  0,  1
	.BYTE   2,  3,  4,  5,  6,  7,  8,  9
	.BYTE  10, 11, 12, 13, 14, 15, 16, 17
	.BYTE  18, 19, 20, 21, 22, 23, 24, 25
	.BYTE  26, 27, 28, 29,  0,  1,  2,  3
	.BYTE   4,  5,  6,  7,  8,  9, 10, 11
	.BYTE  12, 13, 14, 15, 16, 17, 18, 19
	.BYTE  20, 21, 22, 23
@PADDING:	
	.BYTE  $00, $00, $00, $00


MUSICPLAYER_SCREEN_DATA:
	.BYTE "                                " ;  0 
	.BYTE "                                " ;    
	.BYTE "                                " ;  1 
	.BYTE "                                " ;    
	.BYTE "                                " ;  2 
	.BYTE "        ",ATT_OF_THE_0,"        " ;    
	.BYTE "        ",ATT_OF_THE_1,"        " ;  3 
	.BYTE "        ",ATT_OF_THE_2,"        " ;    
	.BYTE "        ",PETSCIIROB_0,"        " ;  4 
	.BYTE "        ",PETSCIIROB_1,"        " ;    
	.BYTE "        ",PETSCIIROB_2,"        " ;  5 
	.BYTE "        ",PETSCIIROB_3,"        " ;    
	.BYTE "                                " ;  6 
	.BYTE "                                " ;    
	.BYTE "               BY               " ;  7 
	.BYTE "                                " ;    
	.BYTE "                                " ;  8 
	.BYTE "            ",T8B0,"            " ;    
	.BYTE "            ",T8B1,"            " ;  9 
	.BYTE "                                " ;    
	.BYTE "                                " ; 10 
	.BYTE "                                " ;    
	.BYTE "                                " ; 11 
	.BYTE "                                " ;    
	.BYTE "                                " ; 12 
	.BYTE "                                " ;    
	.BYTE "                                " ; 13 
	.BYTE "                                " ;    
	.BYTE "                                " ; 14 
	.BYTE "                                " ;    
	.BYTE "           PROGRAMMER           " ; 15 
	.BYTE "           ----------           " ;    
	.BYTE "          DAVID MURRAY          " ; 16 
	.BYTE "            WAIEL AL            " ;    
	.BYTE "                                " ; 17 
	.BYTE "                                " ;    
	.BYTE "             ARTIST             " ; 18 
	.BYTE "             ------             " ;    
	.BYTE "          DAVID MURRAY          " ; 19 
	.BYTE "                                " ;    
	.BYTE "                                " ; 20 
	.BYTE "        MUSIC & SOUND FX        " ;    
	.BYTE "        ----------------        " ; 21 
	.BYTE "           NOELLE AMAN          " ;    
	.BYTE "                                " ; 22 
	.BYTE "                                " ;    
	.BYTE "         SPECIAL THANKS         " ; 23 
	.BYTE "         --------------         " ;    
	.BYTE "         SHIRU aka              " ; 24 
	.BYTE "           ALEX SEMENOV         " ;    
	.BYTE "                                " ; 25 
	.BYTE "                                " ;    
	.BYTE "        IN MEMORY OF            " ; 26 
	.BYTE "          SCOTT ROBISON         " ;    
	.BYTE "                                " ; 27 
	.BYTE "                                " ;    
	.BYTE "                                " ; 28 
	.BYTE "                                " ;    
	.BYTE "                                " ; 29 
	.BYTE "                                " ;    


MUSICPLAYER_BG_PALETTE_DATA:
	.BYTE	COLOR_BLACK, COLOR_GRAY_6, COLOR_GRAY_A, COLOR_WHITE
	.BYTE	COLOR_BLACK, COLOR_GRAY_6, COLOR_RED|COLOR_SATURATED, COLOR_ORANGE|COLOR_LIGHTER
	.BYTE	COLOR_BLACK, COLOR_GRAY_6, COLOR_GRAY_A, COLOR_WHITE
	.BYTE	COLOR_BLACK, COLOR_BLUE|COLOR_LIGHTER, COLOR_GRAY_A, COLOR_WHITE

MUSICPLAYER_SPR_PALETTE_DATA:
	.BYTE	COLOR_BLACK, COLOR_BLACK,  COLOR_BLACK, COLOR_WHITE
	.BYTE	COLOR_BLACK, COLOR_BLACK,  COLOR_BLACK, COLOR_WHITE
	.BYTE	COLOR_BLACK, COLOR_BLACK,  COLOR_BLACK, COLOR_WHITE
	.BYTE	COLOR_BLACK, COLOR_BLACK,  COLOR_BLACK, COLOR_WHITE
