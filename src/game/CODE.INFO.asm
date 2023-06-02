.segment "ZEROPAGE"
PRINTX:	.RES 1		;used to store X-cursor location
PRINTD:	.RES 1		;used to store X-cursor location

.segment BANK(BK_GAME_CODE)

.proc INIT_INFO
	LDA	#0
	STA	PRINTX
	STA	PRINTD
	RTS
.endproc

; ------------------------------------------------------------------------------
;This routine will print something to the "information" window
;at the bottom left of the screen.  You must first define the
;source of the text in PTR_0. The text should terminate with
;an end character.
.proc PRINT_INFO
	; LDA	PRINTX
	; BEQ	:+
	; JSR	SCROLL_INFO	;New text always causes a scroll
	LDY	#0

@loop:	LDA	(PTR_0),Y
	
	CMP	#$F8		; print char
	BGE	:+
	LDX	PRINTX
	CPX	#C_INFO_WIDTH*3
	BNE	@skip_reset
	JSR	SCROLL_INFO
	LDA	(PTR_0),Y
	LDX	PRINTX
@skip_reset:
	STA	UI_BUFFER,X
	INC	PRINTX
	CMP	#' '
	BEQ	@next
	LDA	PRINTD
	CMP	#0
	BEQ	@next
	CMP	#1
	BNE	@skip
	TXA
	AND	#1
	BEQ	@next
@skip:	JSR	_PRINT_DELAY
	JMP	@next

:	CMP	#C_END		; end
	BNE	:+
	LDA	#0
	STA	PRINTD
	RTS

:	CMP	#C_NL		; new line
	BNE	:+
	JSR	SCROLL_INFO
	JMP	@next

:	CMP	#C_CLR		; clear info
	BNE	:+
	JSR	CLEAR_INFO
	JMP	@next

:	CMP	#C_SET_X	; set pos x
	BNE	:+
	INY
	LDA	(PTR_0),Y
	STA	PRINTX
	JMP	@next
	
:	CMP	#C_SET_D	; set delay
	BNE	:+
	INY
	LDA	(PTR_0),Y
	STA	PRINTD
	CMP	#0
	BEQ	@next
	JSR	_PRINT_DELAY
	JMP	@next

:	CMP	#C_WAIT		; wait for input
	BNE	:+
	JSR	_PRINT_WAIT
	JMP	@next

:

@next:	INY
	JMP	@loop
.endproc


.proc _PRINT_DELAY
	PHY
	PHPTR	PTR_0
		LDY	PRINTD
		CPY	#1
		BEQ	@skip
		DEY
	@skip:	STY	GP_TIMER
	@GOM2:	WAIT_NMI
		LDY	GP_TIMER
		BNE	@GOM2
	PLPTR	PTR_0
	PLY
	RTS
.endproc

.proc _PRINT_WAIT
	PHY
	PHPTR	PTR_0
	@wait:	LDA	COUNTER
		AND	#$10
		CMP	#$10	; c clear -> lt, c set -> ge 
		LDA	#$F0
		ADC	#0
		STA	UI_BUFFER+C_INFO_WIDTH*3-1
		
		WAIT_NMI
		JSR	READ_JOYPAD
		JOYPAD_BR_IF_A_NOT_PRESSED @wait
		
		LDA	#' '
		STA	UI_BUFFER+C_INFO_WIDTH*3-1

	PLPTR	PTR_0
	PLY
	RTS
.endproc

;This routine scrolls the info screen by one row, clearing
;a new row at the bottom.
.proc SCROLL_INFO
	LDA	PRINTX
	CMP	#C_INFO_WIDTH*1
	BGE	:+
	LDA	#C_INFO_WIDTH*1
	STA	PRINTX
	RTS

:	CMP	#C_INFO_WIDTH*2
	BGE	:+
	LDA	#C_INFO_WIDTH*2
	STA	PRINTX
	RTS

:	LDA	#C_INFO_WIDTH*2
	STA	PRINTX

	; MOVE ROWS ONE UP
	LDX	#0
@SCI1:	LDA	UI_BUFFER+C_INFO_WIDTH*1,X
	STA	UI_BUFFER+C_INFO_WIDTH*0,X
	LDA	UI_BUFFER+C_INFO_WIDTH*2,X
	STA	UI_BUFFER+C_INFO_WIDTH*1,X
	LDA	#' '
	STA	UI_BUFFER+C_INFO_WIDTH*2,X;
	INX
	CPX	#(C_INFO_WIDTH)
	BNE	@SCI1

	RTS
.endproc

.proc CLEAR_INFO
	LDX	#0
	STX	PRINTX
	LDA	#' '
@CLI2:	STA	UI_BUFFER+C_INFO_WIDTH*0,X
	STA	UI_BUFFER+C_INFO_WIDTH*1,X
	STA	UI_BUFFER+C_INFO_WIDTH*2,X
	INX
	CPX	#(C_INFO_WIDTH)
	BNE	@CLI2
	RTS
.endproc

