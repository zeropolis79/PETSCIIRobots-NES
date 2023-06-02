; ============================
; Entry Point
; ============================
.segment BANK(BK_SYSTEM)
.proc RESET
	SEI
	CLD			; No decimal mode
	LDX	#%01000100
	STX	APUIRQ		; Disable APU frame IRQ

	LDX	#$FF
	TXS			; Set up stack

	; Clear some PPU registers
	LDA	#0
	STA	PPUCTRL		; Disable NMI
	STA	PPUMASK		; Disable rendering
	STA	DMCFREQ		; Disable DMC IRQs

	; Setup the mapper
	MMC3_PRG_RAM_ON
	MMC3_MIRROR_VERTICAL
	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_GENERAL, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, #BK_INTRO_CODE, SAVED_PRG_1
	
	ZP_CLEAR
	
	; setup IRQ and NMI routines
	SET_IRQ_ROUTINE  DUMMY_ROUTINE
	SET_NMI_ROUTINE  DUMMY_ROUTINE

	; The vblank flag is in an unknown state after reset,
	; so it is cleared here to make sure that WAIT_VBLANK
	; does not exit immediately.
	BIT	PPUSTATUS

	; Wait for first vblank
	WAIT_VBLANK

	STACK_OAM_RAM_CLEAR
	WRAM_CLEAR

	BIT	PPUSTATUS
	PPU_FILL_NT  0, ' ', $00
	PPU_FILL_NT  1, ' ', $00

	; One more vblank
	WAIT_VBLANK

	JMP	MAIN
.endproc

.proc DUMMY_ROUTINE
	RTS
.endproc
