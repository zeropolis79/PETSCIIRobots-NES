.segment BANK(BK_GAME_CODE)

; ------------------------------------------------------------------------------
;PART OF BACKGROUND_TASKS.ASM
;This is the routine that allows a person to select
;a level and highlights the selection in the information
;display. It is unique to each computer since it writes
;to the screen directly.
.proc ELEVATOR_SELECT
	JSR	DRAW_MAP_WINDOW
	LDX	UNIT
	LDA	UNIT_A,X	;get max levels
	STA	ELEVATOR_MAX_FLOOR
	;Now draw available levels on screen
	LDY	#0
	LDA	#$4B
@ELS1:	STA	UI_BUFFER+C_INFO_WIDTH*2+ 7,Y
	CLC
	ADC	#01
	INY
	CPY	ELEVATOR_MAX_FLOOR
	BNE	@ELS1
	LDA	UNIT_C,X		;what level are we on now?
	STA	ELEVATOR_CURRENT_FLOOR
	;Now highlight current level
	JSR	ELEVATOR_INVERT
	;Now get user input
@SELS5:
	WAIT_NMI
	JSR	READ_JOYPAD
	JOYPAD_BR_IF_L_NOT_PRESSED  @SELS6
	JSR	ELEVATOR_DEC
	JMP	@SELS5
@SELS6:	JOYPAD_BR_IF_R_NOT_PRESSED  @SELS7
	JSR	ELEVATOR_INC
	JMP	@SELS5
@SELS7:	JOYPAD_BR_IF_D_NOT_PRESSED  @SELS8
	JSR	CLEAR_INFO
	LDA	#15
	STA	KEY_TIMER
	RTS
@SELS8:	JMP	@SELS5
.endproc

.pushseg
.segment "RAM"
ELEVATOR_MAX_FLOOR:	.RES 1
ELEVATOR_CURRENT_FLOOR:	.RES 1
.popseg

.proc ELEVATOR_INVERT
	LDY	ELEVATOR_CURRENT_FLOOR
	LDA	UI_BUFFER+C_INFO_WIDTH*2+ 6,Y
	EOR	#$10
	STA	UI_BUFFER+C_INFO_WIDTH*2+ 6,Y
	RTS
.endproc

.proc ELEVATOR_INC
	LDA	ELEVATOR_CURRENT_FLOOR
	CMP	ELEVATOR_MAX_FLOOR
	BNE	@ELVI1
	RTS
@ELVI1:	JSR	ELEVATOR_INVERT
	INC	ELEVATOR_CURRENT_FLOOR
	JSR	ELEVATOR_INVERT
	JSR	ELEVATOR_FIND_XY
	RTS
.endproc

.proc ELEVATOR_DEC
	LDA	ELEVATOR_CURRENT_FLOOR
	CMP	#1
	BNE	@ELVD1
	RTS
@ELVD1:	JSR	ELEVATOR_INVERT
	DEC	ELEVATOR_CURRENT_FLOOR
	JSR	ELEVATOR_INVERT
	JSR	ELEVATOR_FIND_XY
	RTS
.endproc

.proc ELEVATOR_FIND_XY
	LDX	#32	;start of doors
@ELXY1:	LDA	UNIT_TYPE,X
	CMP	#19	;elevator
	BNE	@ELXY5
	LDA	UNIT_C,X
	CMP	ELEVATOR_CURRENT_FLOOR
	BNE	@ELXY5
	JMP	@ELXY9
@ELXY5:	INX
	CPX	#48
	BNE	@ELXY1
	RTS
@ELXY9:	LDA	UNIT_LOC_X,X	;new elevator location
	STA	UNIT_LOC_X	;player location
	SEC
	SBC	#5
	STA	MAP_WINDOW_X
	LDA	UNIT_LOC_Y,X	;new elevator location
	STA	UNIT_LOC_Y	;player location
	DEC	UNIT_LOC_Y
	SEC
	SBC	#4
	STA	MAP_WINDOW_Y
	JSR	DRAW_MAP_WINDOW
	LDA	#17	;elevator sound
	JSR	SOUND_SYSTEM_SFX_PLAY	;SOUND PLAY
	RTS
.endproc
