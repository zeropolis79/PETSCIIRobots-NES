.segment BANK(BK_GAME_CODE)


C_VIEW_WIDTH  = 11
C_VIEW_HEIGHT = 7
C_VIEW_LENGTH = C_VIEW_WIDTH*C_VIEW_HEIGHT


;This routine checks all units from 0 to 31 and figures out if it should be displayed
;on screen, and then grabs that unit's tile and stores it in the MAP_PRECALC array
;so that when the window is drawn, it does not have to search for units during the
;draw, speeding up the display routine.
.proc MAP_PLOT_BG

	; Calculate pointer to the map data
	; PTR_1 = MAP + (MAP_WINDOW_Y << 7) + (MAP_WINDOW_X)
	; =>  H = (MAP >> 8) + (MAP_WINDOW_Y >> 1)
	;     L = (MAP_WINDOW_Y & 0x01 << 7) + MAP_WINDOW_X
	LDA	MAP_WINDOW_Y
	LSR
	PHP
	CLC
	ADC	#>MAP
	STA	PTR_1_H	;HIGH BYTE OF MAP SOURCE
	LDA	#$0
	PLP
	ROR
	ADC	MAP_WINDOW_X
	STA	PTR_1_L	;LOW BYTE OF MAP SOURCE

	; iterate over map window area
	LDY	#$0	; elem counter
@loop:	
	LDA	(PTR_1), Y
	TAX
	LDA	MAP_CHART_H, Y
	STA	PTR_0_H	;HIGH BYTE OF SCREEN AREA
	LDA	MAP_CHART_L, Y
	STA	PTR_0_L	;LOW BYTE OF SCREEN AREA
	JSR	PLOT_TILE

	LDA	MAP_END_OF_ROW,Y	; reached end of the row
	BNE	@skip_reset
	ADDI16	PTR_1, (C_MAP_WIDTH-C_VIEW_WIDTH)	; PTR_1 += (C_MAP_WIDTH - C_VIEW_WIDTH)
@skip_reset:
	INY
	CPY	#C_VIEW_LENGTH
	BNE	@loop

	RTS
.endproc

MAP_END_OF_ROW:
.repeat C_VIEW_LENGTH, I
	.BYTE  (I-(I/C_VIEW_WIDTH)*C_VIEW_WIDTH) < (C_VIEW_WIDTH-1)
.endrepeat


.proc MAP_PLOT_FG
	; clear buffer
	LDA	#$FF
	LDY	#0
@loop_clear:
	STA	MAP_PRECALC_OBJ,Y
	INY
	CPY	#32
	BNE	@loop_clear


	; filter visible units
	LDX	#0	; loop index
	LDY	#0	; entry index
@loop_visible:
	;CHECK IF ITS THE PLAYER
	CPX	#0
	BEQ	@loop_visible_cont
	;CHECK THAT UNIT EXISTS
	LDA	UNIT_TYPE,X
	CMP	#0
	BEQ	@loop_visible_cont
	;CHECK HORIZONTAL POSITION
	LDA	UNIT_LOC_X,X
	CMP	MAP_WINDOW_X
	BLT	@loop_visible_cont
	LDA	MAP_WINDOW_X
	CLC
	ADC	#(C_VIEW_WIDTH-1)
	CMP	UNIT_LOC_X,X
	BLT	@loop_visible_cont
	;CHECK VERTICAL POSITION
	LDA	UNIT_LOC_Y,X
	CMP	MAP_WINDOW_Y
	BLT	@loop_visible_cont
	LDA	MAP_WINDOW_Y
	CLC
	ADC	#(C_VIEW_HEIGHT-1)
	CMP	UNIT_LOC_Y,X
	BLT	@loop_visible_cont
	;Unit found in map window, now add that unit's
	;tile to the precalc map.
	TXA
	STA	MAP_PRECALC_OBJ,Y
	INY
@loop_visible_cont:
	;continue search
	INX
	CPX	#32
	BNE	@loop_visible

	; draw magnets and bombs
	LDX	#0
@loop_mb:
	LDY	MAP_PRECALC_OBJ,X
	CPY	#$FF	; reached end of buffer
	BEQ	@loop_mb_end

	LDA	UNIT_TILE,Y
	CMP	#130	;is it a bomb
	BEQ	@loop_mb_draw
	CMP	#134	;is it a magnet?
	BEQ	@loop_mb_draw
	JMP	@loop_mb_cont

@loop_mb_draw:
	;What to do in case of bomb or magnet that should
	;go underneath the unit or robot.
	STA	TILE
	LDA	#0
	STA	MAP_PRECALC_OBJ,X
	
	LDA	UNIT_LOC_X,Y
	PHA	; UNIT_LOC_X
	LDA	UNIT_LOC_Y,Y
	SEC
	SBC	MAP_WINDOW_Y
	TAY

	PLA	; UNIT_LOC_X
	SEC
	SBC	MAP_WINDOW_X
	CLC
	ADC	PRECALC_ROWS,Y
	TAY
	
	LDA	MAP_CHART_H, Y
	STA	PTR_0_H	;HIGH BYTE OF SCREEN AREA
	LDA	MAP_CHART_L, Y
	STA	PTR_0_L	;LOW BYTE OF SCREEN AREA
	JSR	PLOT_TRANSPARENT_TILE

@loop_mb_cont:
	INX
	CPX	#32
	BNE	@loop_mb
@loop_mb_end:


	; draw others
	LDX	#0
@loop_others:
	LDY	MAP_PRECALC_OBJ,X
	BEQ	@loop_others_cont	; skip zero entries
	CPY	#$FF	; reached end of buffer
	BEQ	@loop_others_end

@loop_others_draw:
	;What to do in case of bomb or magnet that should
	;go underneath the unit or robot.
	LDA	UNIT_TILE,Y
	STA	TILE
	
	LDA	UNIT_LOC_X,Y
	PHA	; UNIT_LOC_X
	LDA	UNIT_LOC_Y,Y
	SEC
	SBC	MAP_WINDOW_Y
	TAY

	PLA	; UNIT_LOC_X
	SEC
	SBC	MAP_WINDOW_X
	CLC
	ADC	PRECALC_ROWS,Y
	TAY
	
	LDA	MAP_CHART_H, Y
	STA	PTR_0_H	;HIGH BYTE OF SCREEN AREA
	LDA	MAP_CHART_L, Y
	STA	PTR_0_L	;LOW BYTE OF SCREEN AREA
	JSR	PLOT_TRANSPARENT_TILE

@loop_others_cont:
	INX
	CPX	#32
	BNE	@loop_others
@loop_others_end:

	RTS
.endproc

PRECALC_ROWS:
	.BYTE 0,11,22,33,44,55,66

;This chart contains the left-most staring position for each
;row of tiles on the map-editor. 7 Rows.
MAP_CHART_L:
	.repeat  7, J
	.repeat 11, I
		.BYTE <(SCR_BUFFER+C_SCREEN_WIDTH*(J*3)+(I*3))
	.endrepeat
	.endrepeat

MAP_CHART_H:
	.repeat  7, J
	.repeat 11, I
		.BYTE >(SCR_BUFFER+C_SCREEN_WIDTH*(J*3)+(I*3))
	.endrepeat
	.endrepeat


;This routine plots a 3x3 tile from the tile database anywhere on screen.
; reg X: tile number
; PTR_0: starting screen address
.proc PLOT_TILE
	TYA
	PHA
	
	;DRAW THE TOP 3 CHARACTERS
	LDY	#0
	LDA	TILE_DATA_TL,X
	STA	(PTR_0),Y
	
	INY
	LDA	TILE_DATA_TM,X
	STA	(PTR_0),Y
	
	INY
	LDA	TILE_DATA_TR,X
	STA	(PTR_0),Y
	
	;DRAW THE MIDDLE 3 CHARACTERS
	LDY	#(C_SCREEN_WIDTH)
	LDA	TILE_DATA_ML,X
	STA	(PTR_0),Y
	
	INY
	LDA	TILE_DATA_MM,X
	STA	(PTR_0),Y
	
	INY
	LDA	TILE_DATA_MR,X
	STA	(PTR_0),Y
	
	;DRAW THE BOTTOM 3 CHARACTERS
	LDY	#(2*C_SCREEN_WIDTH)
	LDA	TILE_DATA_BL,X
	STA	(PTR_0),Y
	
	INY
	LDA	TILE_DATA_BM,X
	STA	(PTR_0),Y
	
	INY
	LDA	TILE_DATA_BR,X
	STA	(PTR_0),Y

	PLA
	TAY
	RTS
.endproc


;This routine plots a transparent tile from the tile database
;anywhere on screen.  But first you must define the tile number
;in the TILE variable, as well as the starting screen address must
;be defined in PTR_0.  Also, this routine is slower than the usual
;tile routine, so is only used for sprites.  The ":" character
;is not drawn.
.proc PLOT_TRANSPARENT_TILE
	_transparent_char = ':'
	
	TYA
	PHA
	TXA
	PHA

	LDX	TILE
	;DRAW THE TOP 3 CHARACTERS
	LDA	TILE_DATA_TL,X
	LDY	#0
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:
	LDA	TILE_DATA_TM,X
	INY
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:
	LDA	TILE_DATA_TR,X
	INY
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:	
	;DRAW THE MIDDLE 3 CHARACTERS
	LDA	TILE_DATA_ML,X
	LDY	#C_SCREEN_WIDTH
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:
	LDA	TILE_DATA_MM,X
	INY
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:
	LDA	TILE_DATA_MR,X
	INY
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:	
	;DRAW THE BOTTOM 3 CHARACTERS
	LDA	TILE_DATA_BL,X
	LDY	#2*C_SCREEN_WIDTH
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:
	LDA	TILE_DATA_BM,X
	INY
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:
	LDA	TILE_DATA_BR,X
	INY
	CMP	#_transparent_char
	BEQ	:+
	STA	(PTR_0),Y
:	
	PLA
	TAX
	PLA
	TAY
	RTS
.endproc


;This routine checks to see if UNIT is occupying any space
;that is currently visible in the window.  If so, the
;flag for redrawing the window will be set.
.proc CHECK_FOR_WINDOW_REDRAW
	LDX	UNIT
	;FIRST CHECK HORIZONTAL
	LDA	UNIT_LOC_X,X
	CMP	MAP_WINDOW_X
	BLT	@CFR1
	LDA	MAP_WINDOW_X
	CLC
	ADC	#(C_VIEW_WIDTH-1)
	CMP	UNIT_LOC_X,X
	BLT	@CFR1
	;CHECK VERTICAL
	LDA	UNIT_LOC_Y,X
	CMP	MAP_WINDOW_Y
	BLT	@CFR1
	LDA	MAP_WINDOW_Y
	CLC
	ADC	#(C_VIEW_HEIGHT-1)
	CMP	UNIT_LOC_Y,X
	BLT	@CFR1
	SETB	GAME_FLAG, F_REDRAW_FIELD
@CFR1:	RTS
.endproc
