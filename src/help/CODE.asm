.include "DATA.asm"
.include "IRQ.asm"
.include "NMI.asm"

.segment BANK(BK_MAIN_CODE)

.proc INIT_HELP
	WAIT_NMI
	PPU_DISABLE

	SEI	; disable IRQs
	SET_IRQ_ROUTINE  DUMMY_ROUTINE
	SET_NMI_ROUTINE  DUMMY_ROUTINE
	WAIT_NMI

	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_GENERAL, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, #BK_HELP, SAVED_PRG_1

	JMP	ENTRY_HELP
.endproc


.segment BANK(BK_HELP)

.proc ENTRY_HELP
	BIT	PPUSTATUS

	PPU_LOAD_BG_PALETTE   HELP_BG_PALETTE_DATA
	PPU_LOAD_SPR_PALETTE  HELP_SPR_PALETTE_DATA

	MMC3_BANK_SELECT  MMC3_CHR_0, #TS_HELP+0
	MMC3_BANK_SELECT  MMC3_CHR_1, #TS_HELP+2
	MMC3_BANK_SELECT  MMC3_CHR_2, #TS_HELP+0
	MMC3_BANK_SELECT  MMC3_CHR_3, #TS_HELP+1
	MMC3_BANK_SELECT  MMC3_CHR_4, #TS_HELP+2
	MMC3_BANK_SELECT  MMC3_CHR_5, #TS_HELP+3

	OAM_HIDE_ALL_SPRITE

	JOYPAD_BR_IF_IS_NES @nes
@snes:
	JSR	DISPLAY_HELP_SNES
	JMP	@after
@nes:
	JSR	DISPLAY_HELP_NES
@after:

	SET_NMI_ROUTINE  NMI_HELP
	WAIT_NMI
	PPU_DISABLE
	
	SET_IRQ_ROUTINE  IRQ_HELP
	MMC3_IRQ_DISABLE
	CLI
	
	WAIT_FRAMES  30, MP_UPDATE
.endproc


.proc HELP_LOOP
	WAIT_NMI
	
	JSR	READ_JOYPAD
	
	JOYPAD_BR_IF_U_NOT_PRESSED :+
	JMP	HELP_LOOP
:
	JOYPAD_BR_IF_D_NOT_PRESSED :+
	JMP	HELP_LOOP
:
	JOYPAD_BR_IF_R_NOT_PRESSED :+
	JMP	HELP_LOOP
:
	JOYPAD_BR_IF_L_NOT_PRESSED :+
	JMP	HELP_LOOP
:
	JOYPAD_BR_IF_START_NOT_PRESSED :+
	JMP	INIT_INTRO_
:
	JOYPAD_BR_IF_SELECT_NOT_HELD :+
	JMP	HELP_LOOP
:
	JMP	HELP_LOOP
.endproc

.proc DISPLAY_HELP_NES
	BIT	PPUSTATUS

	PPU_WRITE_NT  0, HELP_NES_SCREEN_DATA
	PPU_FILL_NT   1, ' ', $00
	
	PPU_LOAD_ADDR_XY  0, 0, 0

	RTS
.endproc

.proc DISPLAY_HELP_SNES
	BIT	PPUSTATUS

	PPU_WRITE_NT  0, HELP_SNES_SCREEN_DATA
	PPU_FILL_NT   1, ' ', $00
	
	PPU_LOAD_ADDR_XY  0, 0, 0

	RTS
.endproc