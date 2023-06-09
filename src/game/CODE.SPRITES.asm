.segment BANK(BK_GAME_CODE)


SPR_INDEX_BOMB   = $C0
SPR_INDEX_MEDKIT = $C2
SPR_INDEX_MAGNET = $C4
SPR_INDEX_EMP    = $C6
SPR_INDEX_PISTOL = $C8
SPR_INDEX_PLASMA = $CA
SPR_INDEX_MAGN_L = $E0
SPR_INDEX_HAND_0 = $E2
SPR_INDEX_HAND_1 = $E4

SPR_INDEX_EMPTY  = $0E
SPR_INDEX_SELECT = $E6
SPR_INDEX_MOVE   = $CC
SPR_INDEX_SEARCH = $CD
SPR_INDEX_ITEM   = $CE
SPR_INDEX_WPN_0  = $DC
SPR_INDEX_WPN_1  = $DD
SPR_INDEX_MAP    = $CF
SPR_INDEX_DOT    = $E7

SPR_INDEX_KEY_0  = $EA
SPR_INDEX_KEY_1  = $EC
SPR_INDEX_KEY_2  = $EE


; ------------------------------------------------------------------------------

.proc INIT_PLAYER
	; clear player sprite memory
	LDA	#0
	LDX	#4*9
@loop:	DEX
	STA	OAM+4*4,X
	BNE	@loop

	; set positions
	LDA	#11*8-2
	OAM_SET_SPRITE_Y_A   4
	OAM_SET_SPRITE_Y_A   5
	OAM_SET_SPRITE_Y_A   6
	LDA	#12*8-2
	OAM_SET_SPRITE_Y_A   7
	OAM_SET_SPRITE_Y_A   8
	OAM_SET_SPRITE_Y_A   9
	LDA	#13*8-2
	OAM_SET_SPRITE_Y_A  10
	OAM_SET_SPRITE_Y_A  11
	OAM_SET_SPRITE_Y_A  12
	LDA	#14*8+4
	OAM_SET_SPRITE_X_A   4
	OAM_SET_SPRITE_X_A   7
	OAM_SET_SPRITE_X_A  10
	LDA	#15*8+4
	OAM_SET_SPRITE_X_A   5
	OAM_SET_SPRITE_X_A   8
	OAM_SET_SPRITE_X_A  11
	LDA	#16*8+4
	OAM_SET_SPRITE_X_A   6
	OAM_SET_SPRITE_X_A   9
	OAM_SET_SPRITE_X_A  12
	RTS
.endproc

.proc HIDE_PLAYER
	LDA	#$FF
	OAM_SET_SPRITE_Y_A   4
	OAM_SET_SPRITE_Y_A   5
	OAM_SET_SPRITE_Y_A   6
	OAM_SET_SPRITE_Y_A   7
	OAM_SET_SPRITE_Y_A   8
	OAM_SET_SPRITE_Y_A   9
	OAM_SET_SPRITE_Y_A  10
	OAM_SET_SPRITE_Y_A  11
	OAM_SET_SPRITE_Y_A  12
	RTS
.endproc

.proc ANIMATE_PLAYER
	LDX	UNIT_TILE
	LDA	PLAYER_NEXT_FRAME,X
	STA	UNIT_TILE
	CLC
	TAX
	LDA	PLAYER_TILE_INDEX, X
	OAM_SET_SPRITE_TILE_A   4
	ADC	#$01
	OAM_SET_SPRITE_TILE_A   5
	ADC	#$01
	OAM_SET_SPRITE_TILE_A   6
	ADC	#$0E
	OAM_SET_SPRITE_TILE_A   7
	ADC	#$01
	OAM_SET_SPRITE_TILE_A   8
	ADC	#$01
	OAM_SET_SPRITE_TILE_A   9
	ADC	#$0E
	OAM_SET_SPRITE_TILE_A  10
	ADC	#$01
	OAM_SET_SPRITE_TILE_A  11
	ADC	#$01
	OAM_SET_SPRITE_TILE_A  12
	RTS
.endproc


PLAYER_NEXT_FRAME:
	.BYTE  $01,$02,$03,$00 ; DOWN
	.BYTE  $05,$06,$07,$04 ; LEFT
	.BYTE  $09,$0A,$0B,$08 ; UP
	.BYTE  $0D,$0E,$0F,$0C ; RIGHT

PLAYER_TILE_INDEX:	
	.BYTE  $00,$03,$06,$09 ; DOWN
	.BYTE  $30,$33,$36,$39 ; LEFT
	.BYTE  $60,$63,$66,$69 ; UP
	.BYTE  $90,$93,$96,$99 ; RIGHT


; ------------------------------------------------------------------------------

.proc INIT_PLAYER_HEALTH
	; HEALTH
	LDA	#SPR_INDEX_EMPTY
	OAM_SET_SPRITE_TILE_A  33
	OAM_SET_SPRITE_TILE_A  34
	OAM_SET_SPRITE_TILE_A  35
	OAM_SET_SPRITE_TILE_A  36
	OAM_SET_SPRITE_TILE_A  37
	
	LDA	#SPR_ATTR_PAL_3 | SPR_ATTR_TO_BG
	OAM_SET_SPRITE_ATTR_A  33
	OAM_SET_SPRITE_ATTR_A  34
	OAM_SET_SPRITE_ATTR_A  35
	OAM_SET_SPRITE_ATTR_A  36
	OAM_SET_SPRITE_ATTR_A  37

	OAM_SET_SPRITE_X  33, #207
	OAM_SET_SPRITE_X  34, #215
	OAM_SET_SPRITE_X  35, #223
	OAM_SET_SPRITE_X  36, #231
	OAM_SET_SPRITE_X  37, #239
	
	LDA	#213-1
	OAM_SET_SPRITE_Y_A  33
	OAM_SET_SPRITE_Y_A  34
	OAM_SET_SPRITE_Y_A  35
	OAM_SET_SPRITE_Y_A  36
	OAM_SET_SPRITE_Y_A  37
	RTS
.endproc

.proc DISPLAY_PLAYER_HEALTH
	LDY	UNIT_HEALTH
	LDX	HP_BLOCKS,Y
	LDY	#0
	LDA	#$0F		; full block
:	CPX	#0
	BEQ	:+
	STA	OAM+33*4+1,Y
	INY
	INY
	INY
	INY
	DEX
	JMP	:-
:
	LDX	UNIT_HEALTH
	LDA	HP_REST,X
	TAX
	LDA	HP_TILE_MAPPER,X
	STA	OAM+33*4+1,Y
	INY
	INY
	INY
	INY

	LDX	UNIT_HEALTH
	LDA	#4
	SEC
	SBC	HP_BLOCKS,X
	TAX
	LDA	#SPR_INDEX_EMPTY	; empty block
:	CPX	#0
	BEQ	:+
	STA	OAM+33*4+1,Y
	INY
	INY
	INY
	INY
	DEX
	JMP	:-
:	RTS
.endproc

HP_BLOCKS:	.BYTE 0,0,0,1,1,1,2,2,3,3,3,4,4
HP_REST:	.BYTE 0,3,6,1,4,7,2,5,0,3,6,1,5
HP_TILE_MAPPER:	.BYTE $0E,$7F,$6F,$5F,$4F,$3F,$2F,$1F,$0F


; ------------------------------------------------------------------------------


.proc INIT_ITEMS
	LDA	#SPR_INDEX_EMPTY
	OAM_SET_SPRITE_TILE_A  17
	OAM_SET_SPRITE_TILE_A  18
	OAM_SET_SPRITE_TILE_A  19
	OAM_SET_SPRITE_TILE_A  20
	
	LDA	#SPR_ATTR_PAL_3
	OAM_SET_SPRITE_ATTR_A  17
	OAM_SET_SPRITE_ATTR_A  18
	OAM_SET_SPRITE_ATTR_A  19
	OAM_SET_SPRITE_ATTR_A  20
	
	OAM_SET_SPRITE_X  17, #161
	OAM_SET_SPRITE_X  18, #169
	OAM_SET_SPRITE_X  19, #161
	OAM_SET_SPRITE_X  20, #169
	
	OAM_SET_SPRITE_Y  17, #205
	OAM_SET_SPRITE_Y  18, #205
	OAM_SET_SPRITE_Y  19, #213
	OAM_SET_SPRITE_Y  20, #213
	RTS
.endproc

.proc DISPLAY_TIMEBOMB
	OAM_SET_SPRITE_TILE  17, #SPR_INDEX_BOMB+$00
	OAM_SET_SPRITE_TILE  18, #SPR_INDEX_BOMB+$01
	OAM_SET_SPRITE_TILE  19, #SPR_INDEX_BOMB+$10
	OAM_SET_SPRITE_TILE  20, #SPR_INDEX_BOMB+$11
	RTS
.endproc

.proc DISPLAY_EMP
	OAM_SET_SPRITE_TILE  17, #SPR_INDEX_EMP+$00
	OAM_SET_SPRITE_TILE  18, #SPR_INDEX_EMP+$01
	OAM_SET_SPRITE_TILE  19, #SPR_INDEX_EMP+$10
	OAM_SET_SPRITE_TILE  20, #SPR_INDEX_EMP+$11
	RTS
.endproc

.proc DISPLAY_MEDKIT
	OAM_SET_SPRITE_TILE  17, #SPR_INDEX_MEDKIT+$00
	OAM_SET_SPRITE_TILE  18, #SPR_INDEX_MEDKIT+$01
	OAM_SET_SPRITE_TILE  19, #SPR_INDEX_MEDKIT+$10
	OAM_SET_SPRITE_TILE  20, #SPR_INDEX_MEDKIT+$11
	RTS
.endproc

.proc DISPLAY_MAGNET
	OAM_SET_SPRITE_TILE  17, #SPR_INDEX_MAGNET+$00
	OAM_SET_SPRITE_TILE  18, #SPR_INDEX_MAGNET+$01
	OAM_SET_SPRITE_TILE  19, #SPR_INDEX_MAGNET+$10
	OAM_SET_SPRITE_TILE  20, #SPR_INDEX_MAGNET+$11
	RTS
.endproc

.proc DISPLAY_BLANK_ITEM
	LDA	#SPR_INDEX_EMPTY
	OAM_SET_SPRITE_TILE_A  17
	OAM_SET_SPRITE_TILE_A  18
	OAM_SET_SPRITE_TILE_A  19
	OAM_SET_SPRITE_TILE_A  20
	RTS
.endproc


; ------------------------------------------------------------------------------

.proc INIT_WEAPONS
	; WPN
	LDA	#SPR_INDEX_EMPTY
	OAM_SET_SPRITE_TILE_A  13
	OAM_SET_SPRITE_TILE_A  14
	OAM_SET_SPRITE_TILE_A  15
	OAM_SET_SPRITE_TILE_A  16
	
	LDA	#SPR_ATTR_PAL_3
	OAM_SET_SPRITE_ATTR_A  13
	OAM_SET_SPRITE_ATTR_A  14
	OAM_SET_SPRITE_ATTR_A  15
	OAM_SET_SPRITE_ATTR_A  16
	
	OAM_SET_SPRITE_X  13, #161
	OAM_SET_SPRITE_X  14, #169
	OAM_SET_SPRITE_X  15, #161
	OAM_SET_SPRITE_X  16, #169
	
	OAM_SET_SPRITE_Y  13, #189
	OAM_SET_SPRITE_Y  14, #189
	OAM_SET_SPRITE_Y  15, #197
	OAM_SET_SPRITE_Y  16, #197
	
	RTS
.endproc

.proc DISPLAY_PLASMA_GUN
	OAM_SET_SPRITE_TILE  13, #SPR_INDEX_PLASMA+$00
	OAM_SET_SPRITE_TILE  14, #SPR_INDEX_PLASMA+$01
	OAM_SET_SPRITE_TILE  15, #SPR_INDEX_PLASMA+$10
	OAM_SET_SPRITE_TILE  16, #SPR_INDEX_PLASMA+$11
	RTS
.endproc

.proc DISPLAY_PISTOL
	OAM_SET_SPRITE_TILE  13, #SPR_INDEX_PISTOL+$00
	OAM_SET_SPRITE_TILE  14, #SPR_INDEX_PISTOL+$01
	OAM_SET_SPRITE_TILE  15, #SPR_INDEX_PISTOL+$10
	OAM_SET_SPRITE_TILE  16, #SPR_INDEX_PISTOL+$11
	RTS
.endproc

.proc DISPLAY_BLANK_WEAPON
	LDA	#SPR_INDEX_EMPTY
	OAM_SET_SPRITE_TILE_A  13
	OAM_SET_SPRITE_TILE_A  14
	OAM_SET_SPRITE_TILE_A  15
	OAM_SET_SPRITE_TILE_A  16
	RTS
.endproc


; ------------------------------------------------------------------------------

.proc INIT_KEYS
	; KEY 1
	OAM_SET_SPRITE  21, #204+14*0, #193, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  22, #212+14*0, #193, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  23, #204+14*0, #201, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  24, #212+14*0, #201, #$0E, #SPR_ATTR_PAL_1
	; KEY 2
	OAM_SET_SPRITE  25, #204+14*1, #193, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  26, #212+14*1, #193, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  27, #204+14*1, #201, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  28, #212+14*1, #201, #$0E, #SPR_ATTR_PAL_1
	; KEY 3
	OAM_SET_SPRITE  29, #204+14*2, #193, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  30, #212+14*2, #193, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  31, #204+14*2, #201, #$0E, #SPR_ATTR_PAL_1
	OAM_SET_SPRITE  32, #212+14*2, #201, #$0E, #SPR_ATTR_PAL_1
	RTS
.endproc

.proc DISPLAY_KEYS
	; Spade key
	LDA	KEYS
	AND	#%00000001
	BEQ	:+
	OAM_SET_SPRITE_TILE  21, #SPR_INDEX_KEY_0+$00
	OAM_SET_SPRITE_TILE  22, #SPR_INDEX_KEY_0+$01
	OAM_SET_SPRITE_TILE  23, #SPR_INDEX_KEY_0+$10
	OAM_SET_SPRITE_TILE  24, #SPR_INDEX_KEY_0+$11
:
	; Heart key
	LDA	KEYS
	AND	#%00000010
	BEQ	:+
	OAM_SET_SPRITE_TILE  25, #SPR_INDEX_KEY_1+$00
	OAM_SET_SPRITE_TILE  26, #SPR_INDEX_KEY_1+$01
	OAM_SET_SPRITE_TILE  27, #SPR_INDEX_KEY_1+$10
	OAM_SET_SPRITE_TILE  28, #SPR_INDEX_KEY_1+$11
:
	; Star key
	LDA	KEYS
	AND	#%00000100
	BEQ	:+
	OAM_SET_SPRITE_TILE  29, #SPR_INDEX_KEY_2+$00
	OAM_SET_SPRITE_TILE  30, #SPR_INDEX_KEY_2+$01
	OAM_SET_SPRITE_TILE  31, #SPR_INDEX_KEY_2+$10
	OAM_SET_SPRITE_TILE  32, #SPR_INDEX_KEY_2+$11
:
	RTS
.endproc


; ------------------------------------------------------------------------------

.proc DISPLAY_BLACK

	LDA	#' '
	STA	SCR_BUFFER+12+32*6 + (32*3+3)
	STA	SCR_BUFFER+12+32*6 + (32*3+4)
	STA	SCR_BUFFER+12+32*6 + (32*3+5)
	STA	SCR_BUFFER+12+32*6 + (32*4+3)
	STA	SCR_BUFFER+12+32*6 + (32*4+4)
	STA	SCR_BUFFER+12+32*6 + (32*4+5)
	STA	SCR_BUFFER+12+32*6 + (32*5+3)
	STA	SCR_BUFFER+12+32*6 + (32*5+4)
	STA	SCR_BUFFER+12+32*6 + (32*5+5)
	SETB	GAME_FLAG, F_TRANSFER_FIELD
	WAIT_NMI

	LDA	#' '
	STA	SCR_BUFFER+12+32*6 + (32*2+3)
	STA	SCR_BUFFER+12+32*6 + (32*2+4)
	STA	SCR_BUFFER+12+32*6 + (32*2+5)
	STA	SCR_BUFFER+12+32*6 + (32*3+2)
	STA	SCR_BUFFER+12+32*6 + (32*3+6)
	STA	SCR_BUFFER+12+32*6 + (32*4+2)
	STA	SCR_BUFFER+12+32*6 + (32*4+6)
	STA	SCR_BUFFER+12+32*6 + (32*5+2)
	STA	SCR_BUFFER+12+32*6 + (32*5+6)
	STA	SCR_BUFFER+12+32*6 + (32*6+3)
	STA	SCR_BUFFER+12+32*6 + (32*6+4)
	STA	SCR_BUFFER+12+32*6 + (32*6+5)
	SETB	GAME_FLAG, F_TRANSFER_FIELD
	WAIT_NMI

	LDA	#' '
	STA	SCR_BUFFER+12+32*6 + (32*1+3)
	STA	SCR_BUFFER+12+32*6 + (32*1+4)
	STA	SCR_BUFFER+12+32*6 + (32*1+5)
	STA	SCR_BUFFER+12+32*6 + (32*2+2)
	STA	SCR_BUFFER+12+32*6 + (32*2+6)
	STA	SCR_BUFFER+12+32*6 + (32*3+1)
	STA	SCR_BUFFER+12+32*6 + (32*3+7)
	STA	SCR_BUFFER+12+32*6 + (32*4+1)
	STA	SCR_BUFFER+12+32*6 + (32*4+7)
	STA	SCR_BUFFER+12+32*6 + (32*5+1)
	STA	SCR_BUFFER+12+32*6 + (32*5+7)
	STA	SCR_BUFFER+12+32*6 + (32*6+2)
	STA	SCR_BUFFER+12+32*6 + (32*6+6)
	STA	SCR_BUFFER+12+32*6 + (32*7+3)
	STA	SCR_BUFFER+12+32*6 + (32*7+4)
	STA	SCR_BUFFER+12+32*6 + (32*7+5)
	SETB	GAME_FLAG, F_TRANSFER_FIELD
	WAIT_NMI
	
	LDA	#' '

	STA	SCR_BUFFER+12+32*6 + (32*0+3)
	STA	SCR_BUFFER+12+32*6 + (32*0+4)
	STA	SCR_BUFFER+12+32*6 + (32*0+5)
	STA	SCR_BUFFER+12+32*6 + (32*1+2)
	STA	SCR_BUFFER+12+32*6 + (32*1+6)
	STA	SCR_BUFFER+12+32*6 + (32*2+1)
	STA	SCR_BUFFER+12+32*6 + (32*2+7)
	STA	SCR_BUFFER+12+32*6 + (32*3+0)
	STA	SCR_BUFFER+12+32*6 + (32*3+8)
	STA	SCR_BUFFER+12+32*6 + (32*4+0)
	STA	SCR_BUFFER+12+32*6 + (32*4+8)
	STA	SCR_BUFFER+12+32*6 + (32*5+0)
	STA	SCR_BUFFER+12+32*6 + (32*5+8)
	STA	SCR_BUFFER+12+32*6 + (32*6+1)
	STA	SCR_BUFFER+12+32*6 + (32*6+7)
	STA	SCR_BUFFER+12+32*6 + (32*7+2)
	STA	SCR_BUFFER+12+32*6 + (32*7+6)
	STA	SCR_BUFFER+12+32*6 + (32*8+3)
	STA	SCR_BUFFER+12+32*6 + (32*8+4)
	STA	SCR_BUFFER+12+32*6 + (32*8+5)
	SETB	GAME_FLAG, F_TRANSFER_FIELD

	OAM_SET_SPRITE   $28, #92+8*2, #64+8*0, #$8F, #SPR_ATTR_PAL_2 | SPR_ATTR_NO_FLIP
	OAM_SET_SPRITE   $29, #92+8*6, #64+8*0, #$8F, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_H
	OAM_SET_SPRITE   $2A, #92+8*1, #64+8*1, #$AF, #SPR_ATTR_PAL_2 | SPR_ATTR_NO_FLIP
	OAM_SET_SPRITE   $2B, #92+8*7, #64+8*1, #$AF, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_H
	OAM_SET_SPRITE   $2C, #92+8*0, #64+8*2, #$9F, #SPR_ATTR_PAL_2 | SPR_ATTR_NO_FLIP
	OAM_SET_SPRITE   $2D, #92+8*8, #64+8*2, #$9F, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_H
	OAM_SET_SPRITE   $2E, #92+8*0, #64+8*6, #$9F, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_V
	OAM_SET_SPRITE   $2F, #92+8*8, #64+8*6, #$9F, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_HV
	OAM_SET_SPRITE   $30, #92+8*1, #64+8*7, #$AF, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_V 
	OAM_SET_SPRITE   $31, #92+8*7, #64+8*7, #$AF, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_HV
	OAM_SET_SPRITE   $32, #92+8*2, #64+8*8, #$8F, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_V
	OAM_SET_SPRITE   $33, #92+8*6, #64+8*8, #$8F, #SPR_ATTR_PAL_2 | SPR_ATTR_FLIP_HV

	WAIT_NMI

	; .repeat 9,I
	; .repeat 9,J
	; STA	SCR_BUFFER+12+32*(6+J)+I
	; .endrepeat
	; .endrepeat
	; SETB	GAME_FLAG, F_TRANSFER_FIELD
	RTS
.endproc

.proc DISPLAY_HELPER_ICONS_NES
	JSR	DISPLAY_BLACK
	OAM_SET_SPRITE   0, #15*8+4+2, #14*8+8, #SPR_INDEX_SEARCH, #SPR_ATTR_PAL_0 ; down
	OAM_SET_SPRITE   1, #15*8+4-2, #10*8-8, #SPR_INDEX_MOVE,   #SPR_ATTR_PAL_0 ; up
	OAM_SET_SPRITE   2, #13*8+4-8, #12*8+0, #SPR_INDEX_WPN_0,  #SPR_ATTR_PAL_0 ; left
	OAM_SET_SPRITE   3, #17*8+4+8, #12*8+0, #SPR_INDEX_ITEM,   #SPR_ATTR_PAL_0 ; right
	RTS
.endproc

.proc DISPLAY_HELPER_ICONS_SNES
	JSR	DISPLAY_BLACK
	OAM_SET_SPRITE   0, #15*8+4+2, #14*8+8, #SPR_INDEX_MAP,   #SPR_ATTR_PAL_0 ; down
	OAM_SET_SPRITE   1, #15*8+4-2, #10*8-8, #SPR_INDEX_EMPTY, #SPR_ATTR_PAL_0 ; up
	OAM_SET_SPRITE   2, #13*8+4-8, #12*8+0, #SPR_INDEX_WPN_0, #SPR_ATTR_PAL_0 ; left
	OAM_SET_SPRITE   3, #17*8+4+8, #12*8+0, #SPR_INDEX_ITEM,  #SPR_ATTR_PAL_0 ; right
	RTS
.endproc

.proc HIDE_HELPER_ICONS
	LDA	#$FF
	OAM_SET_SPRITE_Y_A  0
	OAM_SET_SPRITE_Y_A  1
	OAM_SET_SPRITE_Y_A  2
	OAM_SET_SPRITE_Y_A  3
	OAM_SET_SPRITE_Y_A  $28
	OAM_SET_SPRITE_Y_A  $29
	OAM_SET_SPRITE_Y_A  $2A
	OAM_SET_SPRITE_Y_A  $2B
	OAM_SET_SPRITE_Y_A  $2C
	OAM_SET_SPRITE_Y_A  $2D
	OAM_SET_SPRITE_Y_A  $2E
	OAM_SET_SPRITE_Y_A  $2F
	OAM_SET_SPRITE_Y_A  $30
	OAM_SET_SPRITE_Y_A  $31
	OAM_SET_SPRITE_Y_A  $32
	OAM_SET_SPRITE_Y_A  $33
	RTS
.endproc


; ------------------------------------------------------------------------------

.proc DISPLAY_CURSOR
	LDA	#SPR_INDEX_SELECT
	OAM_SET_SPRITE_TILE_A  0
	OAM_SET_SPRITE_TILE_A  1
	OAM_SET_SPRITE_TILE_A  2
	OAM_SET_SPRITE_TILE_A  3

	OAM_SET_SPRITE_ATTR  0, #SPR_ATTR_PAL_0 | SPR_ATTR_NO_FLIP
	OAM_SET_SPRITE_ATTR  1, #SPR_ATTR_PAL_0 | SPR_ATTR_FLIP_H
	OAM_SET_SPRITE_ATTR  2, #SPR_ATTR_PAL_0 | SPR_ATTR_FLIP_V
	OAM_SET_SPRITE_ATTR  3, #SPR_ATTR_PAL_0 | SPR_ATTR_FLIP_HV

	LDY	CURSOR_X
	LDA	CONV_CURSOR_X,Y
	OAM_SET_SPRITE_X_A  0
	OAM_SET_SPRITE_X_A  2
	ADC	#(2*8+5)
	OAM_SET_SPRITE_X_A  1
	OAM_SET_SPRITE_X_A  3

	LDY	CURSOR_Y
	LDA	CONV_CURSOR_Y,Y
	OAM_SET_SPRITE_Y_A  0
	OAM_SET_SPRITE_Y_A  1
	ADC	#(2*8+6)
	OAM_SET_SPRITE_Y_A  2
	OAM_SET_SPRITE_Y_A  3

	RTS
.endproc

CONV_CURSOR_X:
	.repeat 11, I
		.BYTE <(((I*3-1)*8) + 1)
	.endrepeat

CONV_CURSOR_Y:
	.repeat 7, I
		.BYTE <(((I*3+2)*8) - 4)
	.endrepeat

.proc HIDE_CURSOR
	LDA	#$FF
	OAM_SET_SPRITE_Y_A  0
	OAM_SET_SPRITE_Y_A  1
	OAM_SET_SPRITE_Y_A  2
	OAM_SET_SPRITE_Y_A  3
	RTS
.endproc

