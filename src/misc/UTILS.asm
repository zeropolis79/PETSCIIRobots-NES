.segment BANK(BK_MAIN_CODE)

; has to align properly so branches 
; have a predictable behavior
.align $100
; do not optimize this subroutine 
; unless you can ensure that all 
; possible paths are equally long
PPU_DECWRITE:
	CMP	#200		; 2

	BLT	:+		; 2/3
	LDY	#2|$30		; 2
	STY	PPUDATA		; 4
	SBC	#200		; 2
	LDY	0		; 3
	NOP			; 2
	JMP	@cont		; 3    <- 3+2+3+2+4+2+2 = 18
:
	CMP	#100		; 2
	BLT	:+		; 2/3
	LDY	#1|$30		; 2
	STY	PPUDATA		; 4
	SBC	#100		; 2
	JMP	@cont		; 3    <- 3+2+4+2+2+2+3 = 18
:
	NOP			; 2
	NOP			; 2
	LDY	#0|$30		; 2
	STY	PPUDATA		; 4    <- 4+2+2+2+3+2+3 = 18
@cont:
PPU_DECWRITE2:
	TAY			; 2
	LDA	DEC2BCD,Y	; 4+
	TAY			; 2
	REPEAT	4, LSR		; 4*2
	ORA	#$30		; 2
	STA	PPUDATA		; 4
	TYA			; 2
	AND	#$0F		; 2
	ORA	#$30		; 2
	STA	PPUDATA		; 4
	RTS			; 6
; 2+18+2+4+2+2+2+4+2+2+2+2+2+2+4+6 = 58
; .endproc
; maps the number 0-99 to $00 - $99
; ex: 46 -> $46
DEC2BCD:
.repeat 100, I
	; .BYTE ((I / 10) << 4) | (I - ((I/10)*10))
	.BYTE ((I / 10) << 4) | MOD(I, 10)
.endrepeat


.proc DEC2CHAR
	LDY	#2
	CMP	#200
	
	BLT	@lessthan200
	TAX
	LDA	#'2'
	STA	(PTR_0),Y
	TXA
	SBC	#200
	JMP	@cont
@lessthan200:
	CMP	#100
	BLT	@lessthan100
	TAX
	LDA	#'1'
	STA	(PTR_0),Y
	TXA
	SBC	#100
	JMP	@cont
@lessthan100:
	TAX
	LDA	#'0'
	STA	(PTR_0),Y
	TXA
@cont:
	DEY
	TAX
	LDA	DEC2BCD,X
	TAX
	REPEAT	4, LSR
	ORA	#'0'
	STA	(PTR_0),Y
	DEY
	TXA
	AND	#$0F
	ORA	#'0'
	STA	(PTR_0),Y
	RTS
.endproc


PPU_EMPHASIZE_RED_LUT:
	;         0: NTSC,    1: PAL,  2: Dendy, 3: unknown
	.BYTE	%00100000, %01000000, %01000000, %00100000
.macro PPU_EMPHASIZE_RED
	LDX	TV_SYSTEM
	LDA	PPU_EMPHASIZE_RED_LUT,X
	ORA	PPUMASK_CONFIG
	STA	PPUMASK_CONFIG
.endmacro

.macro PPU_DEEMPHASIZE
	LDA	PPUMASK_CONFIG
	AND 	#%00011111
	STA	PPUMASK_CONFIG
.endmacro

.macro PPU_EMPHASIZE_ALL
	LDA	PPUMASK_CONFIG
	ORA 	#%11100000
	STA	PPUMASK_CONFIG
.endmacro