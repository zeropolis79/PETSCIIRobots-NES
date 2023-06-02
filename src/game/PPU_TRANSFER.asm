.segment BANK(BK_PPU_TRANS)

_nmi_transfer_lines = 6

; Transfer first lines of game field (IRQ)
.proc NMI_TRANSFER_GAME_FIELD_0
	; PPU_LOAD_ADDR_XY  0, 0, 0
	; 1st
	; LDA	#' '
	; STA	PPUDATA
	; .repeat 31, J
	; LDA	SCR_BUFFER+C_SCREEN_WIDTH*(I)+1+J
	; STA	PPUDATA
	; .endrepeat
	
	PPU_LOAD_ADDR_XY  0, 0, 1
	; 2nd to mid
	.repeat ::_nmi_transfer_lines, I
	LDA	#' '
	STA	PPUDATA
	.repeat 31, J
	LDA	SCR_BUFFER+C_SCREEN_WIDTH*(I+1)+1+J
	STA	PPUDATA
	.endrepeat
	.endrepeat

	RTS
.endproc

; Transfer reset of game field (NMI)
.proc NMI_TRANSFER_GAME_FIELD_1
	PPU_LOAD_ADDR_XY  0, 0, {(::_nmi_transfer_lines+1)}
	; mid+1 to last-1
	.repeat 19-::_nmi_transfer_lines, I
	LDA	#' '
	STA	PPUDATA
	.repeat 31, J
	LDA	SCR_BUFFER+C_SCREEN_WIDTH*(::_nmi_transfer_lines+1+I)+1+J
	STA	PPUDATA
	.endrepeat
	.endrepeat
	; last
	; LDA	#' '
	; STA	PPUDATA
	; .repeat 31, J
	; LDA	SCR_BUFFER+C_SCREEN_WIDTH*(I)+1+J
	; STA	PPUDATA
	; .endrepeat

	RTS
.endproc

.align $0100
.proc NMI_TRANSFER_GAME_FIELD_0_NULL
	DELAY	1536
	RTS
.endproc

.align $0100
.proc NMI_TRANSFER_GAME_FIELD_1_NULL
	DELAY	3314
	RTS
.endproc

.align $0100
.proc NMI_TRANSFER_GAME_FIELD_ATTR_NULL
	DELAY	396
	RTS
.endproc

; Transfer UI (NMI)
.proc NMI_TRANSFER_GAME_UI
	.repeat 3, J
	PPU_LOAD_ADDR_XY  0, 2, {(26+J)}
	.repeat ::C_INFO_WIDTH, I
	LDA	UI_BUFFER+(J*::C_INFO_WIDTH)+I
	STA	PPUDATA
	.endrepeat
	.endrepeat
	
	PPU_LOAD_ADDR_XY  0, 23, 28
	LDA	ITM_NUM_BUFFER+2
	STA	PPUDATA
	LDA	ITM_NUM_BUFFER+1
	STA	PPUDATA
	LDA	ITM_NUM_BUFFER+0
	STA	PPUDATA

	PPU_LOAD_ADDR_XY  0, 23, 26
	LDA	WPN_NUM_BUFFER+2
	STA	PPUDATA
	LDA	WPN_NUM_BUFFER+1
	STA	PPUDATA
	LDA	WPN_NUM_BUFFER+0
	STA	PPUDATA

	RTS
.endproc
