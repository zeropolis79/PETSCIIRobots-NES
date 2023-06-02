C_SCREEN_WIDTH	= 32
C_SCREEN_HEIGHT	= 30
C_MAP_WIDTH	= 128
C_MAP_HEIGHT	= 64
C_INFO_WIDTH	= 18


PLAYER_DIR_D = 0
PLAYER_DIR_L = 1
PLAYER_DIR_U = 2
PLAYER_DIR_R = 3


.segment BANK(BK_GAME_CODE)
SCR_GAME_MAIN:
	.repeat $300
		.byte ' '
	.endrepeat
	.incbin "resources/screen/game_map.nt",$300
	.repeat $30
		.byte 0
	.endrepeat
	.incbin "resources/screen/game_map.nt_atr",$30

SCR_GAME_MAP:
	.incbin "resources/screen/game_map.nt"
	.incbin "resources/screen/game_map.nt_atr"


.proc INIT_GAME_SCREEN
	BIT	PPUSTATUS
	; PPU_FILL_NT   0, ' ', $00
	PPU_WRITE_NT  0, SCR_GAME_MAIN
	PPU_WRITE_NT  1, SCR_GAME_MAP
	RTS
.endproc



.define GAME_BG_PALETTE_NORMAL	COLOR_BLACK
.define GAME_BG_PALETTE_DARKEN	COLOR_BLACK
.define GAME_BG_PALETTE_INVERT	COLOR_WHITE
.define GAME_BG_PALETTE_RED	COLOR_RED

GAME_BG_PALETTE_DATA:
	.BYTE	COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_BLACK	; Normal 
	.BYTE	COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_BLACK	; UI 
	.BYTE	COLOR_BLACK, COLOR_GREEN, COLOR_GREEN|COLOR_SATURATED, COLOR_GREEN|COLOR_LIGHTER	; Map 
	.BYTE	COLOR_BLACK, COLOR_GRAY_6, COLOR_GRAY_A, COLOR_WHITE	; Unused 
GAME_SPR_PALETTE_DATA:
	.BYTE	COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_BLACK	; Player
	.BYTE	COLOR_BLACK, COLOR_RED|COLOR_SATURATED, COLOR_LIME|COLOR_LIGHTER, COLOR_AZURE|COLOR_LIGHTER ; Keys
	.BYTE	COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_WHITE ; Map
	.BYTE	COLOR_BLACK, COLOR_RED|COLOR_SATURATED, COLOR_RED|COLOR_LIGHTER2, COLOR_WHITE ; Inventar

.proc INIT_GAME_PALETTE
	PPU_LOAD_BG_PALETTE   GAME_BG_PALETTE_DATA
	PPU_LOAD_SPR_PALETTE  GAME_SPR_PALETTE_DATA

	PPU_LOAD_ADDR $3f00
	; Gamefield
	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_GF+0
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_GF+1
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_GF+2
	STA	PPUDATA
	; UI
	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_UI+0
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_UI+1
	STA	PPUDATA
	LDA	#COLOR_WHITE
	STA	PPUDATA

	PPU_LOAD_ADDR $3f10
	; Player
	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+0
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+1
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+2
	STA	PPUDATA

	RTS
.endproc



.macro SET_GAME_BG_PALETTE  palette
	LDA	#palette
	STA	GAME_BG_PALETTE
.endmacro


.segment BANK(BK_MAIN_CODE)
.define  C_SET_X   $F8
.define  C_SET_D   $F9
.define  C_CLR     $FA
.define  C_XXX_FB  $FB
.define  C_XXX_FC  $FC
.define  C_WAIT    $FD
.define  C_NL      $FE
.define  C_END     $FF

.define  C_BTN_A   $80,$81
.define  C_BTN_B   $90,$91
.define  C_BTN_Y   $82,$83
.define  C_BTN_X   $92,$93
.define  C_BTN_L   $A0,$A1
.define  C_BTN_R   $B0,$B1
.define  C_BTN_DP  $A2,$A3
.define  C_BTN_DU  $84,$85
.define  C_BTN_DD  $94,$95
.define  C_BTN_DL  $A4,$A5
.define  C_BTN_DR  $B4,$B5
.define  C_BTN_SL  $C0,$C1,$C2
.define  C_BTN_ST  $D0,$D1,$D2

MSG_WELCOME:	;      ##################
		.BYTE C_CLR,C_SET_D,3
		.BYTE "    welcome to",C_NL
		.BYTE "    nes-robots",C_NL,C_END
MSG_CANTMOVE:	.BYTE C_SET_D,1,"can't move that",C_END
MSG_BLOCKED:	.BYTE C_SET_D,1,"blocked",C_END
MSG_SEARCHING:	.BYTE C_SET_D,2,"searching",C_END
MSG_DOT:	.BYTE ".",C_END
MSG_NOTFOUND:	.BYTE C_SET_D,1,"nothing found here",C_END
MSG_FOUNDKEY:	.BYTE C_SET_D,1,"you found key card",C_END
MSG_FOUNDGUN:	.BYTE C_SET_D,1,"you found pistol  ",C_END
MSG_FOUNDEMP:	.BYTE C_SET_D,1,"you found emp     ",C_END
MSG_FOUNDBOMB:	.BYTE C_SET_D,1,"you found timebomb",C_END
MSG_FOUNDPLAS:	.BYTE C_SET_D,1,"you found plasma  ",C_END
MSG_FOUNDMED:	.BYTE C_SET_D,1,"you found medkit  ",C_END
MSG_FOUNDMAG:	.BYTE C_SET_D,1,"you found magnet  ",C_END
MSG_MUCHBET:	.BYTE C_SET_D,1,"ahhh, much better ",C_END
MSG_EMPUSED:	.BYTE C_CLR
		.BYTE C_SET_D,15
		.BYTE C_SET_D,1
		.BYTE C_SET_X,0
		.BYTE "emp activated!",C_NL
		.BYTE "nearby robots are",C_NL
		.BYTE "rebooting.",C_END
MSG_TERMINATED:	.BYTE "you're terminated.",C_END
MSG_TRANS1:	.BYTE C_CLR
		.BYTE C_SET_D,5
		.BYTE C_SET_D,1
		.BYTE "transporter won't "
		.BYTE "activate until all"
		.BYTE "robots destroyed.",C_END
		;      ##################
MSG_ELEVATOR:	.BYTE C_CLR
		; .BYTE C_SET_D,1
		.BYTE C_SET_X,C_INFO_WIDTH*0
		.BYTE " [   elevator   ] "
		.BYTE C_SET_X,C_INFO_WIDTH*1
		; .BYTE C_SET_D,0
		.BYTE " [     level    ]",C_END
MSG_LEVELS:	.BYTE C_SET_X,C_INFO_WIDTH*2
		.BYTE " [              ] ",C_END
		;      ##################
MSG_PAUSED:	.BYTE "    exit game?",C_NL,C_NL
		.BYTE "   ",C_BTN_A,"yes  ",C_BTN_B,"no",C_END
		;      ##################
MSG_DEBUG:	.BYTE C_CLR, " debug mode", C_NL
		.BYTE " ",C_BTN_DP,"  move player", C_NL
		.BYTE " ",C_BTN_ST," cheater", C_END
MSG_ROTATE_M:	.BYTE C_CLR, " rotate player", C_NL,C_END
MSG_SEARCH_M:	.BYTE C_CLR, " search mode", C_NL,C_END
MSG_MOVE_M:	.BYTE C_CLR, " move mode",C_NL,C_END
MSG_ITEM_M:	.BYTE C_CLR, " item mode",C_NL,C_END
MSG_ROTATE:	.BYTE " ",C_BTN_DP,"  rotate player",C_NL,C_END
MSG_MAP:	.BYTE " ",C_BTN_ST," show map",C_NL,C_END
MSG_SELECT:	.BYTE " ",C_BTN_DP," select",C_NL,C_END
MSG_MOVE:	.BYTE " ",C_BTN_DP," move",C_NL,C_END
MSG_PLACE:	.BYTE " ",C_BTN_DP," place",C_NL,C_END
MSG_CANCEL:	.BYTE " ",C_BTN_B," cancel",C_END
MSG_MAP_VIEW:	.BYTE C_NL, C_BTN_ST,"toggle enemies",C_END

; MSG_8BITGUY:	.BYTE $88,$89,$8A,$8B,$8C,$8D,$8E,$8F,C_NL
; 		.BYTE $98,$99,$9A,$9B,$9C,$9D,$9E,$9F,C_END

		;      ##################
MSG_TUT_NES_1:	.BYTE "tutorial:", C_NL
		.BYTE "hold ",C_BTN_ST," then ", C_BTN_DD, C_NL
		.BYTE "to read the sign", C_WAIT, C_END

MSG_TUT_SNES_1:	.BYTE " tutorial:", C_NL
		.BYTE " press ",C_BTN_L," to read", C_NL, C_WAIT, C_END

MSG_TUT_SNES_0:
MSG_TUT_NES_0:
		;      ##################
		.BYTE C_SET_D, 1
		.BYTE C_SET_X, C_INFO_WIDTH*0+4, "welcome to"
		.BYTE C_SET_X, C_INFO_WIDTH*1+4, "nes-robots"
		; .BYTE C_END
		.BYTE C_WAIT, C_CLR
		.BYTE "This is a tutorial"
		.BYTE C_WAIT, C_CLR
		.BYTE " hold ",C_BTN_ST," then ", C_BTN_DD, C_NL
		.BYTE " to read the sign"
		.BYTE C_WAIT, C_CLR
		.BYTE " press ",C_BTN_L," to read", C_NL
		.BYTE " the sign"
		.BYTE C_WAIT, C_CLR
		.BYTE C_END