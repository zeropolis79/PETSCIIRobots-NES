.include "DATA.asm"
.include "IRQ.asm"
.include "NMI.asm"

.segment BANK(BK_MAIN_CODE)

.proc INIT_SETTINGS
	WAIT_NMI
	PPU_DISABLE

	SEI	; disable IRQs
	SET_IRQ_ROUTINE  DUMMY_ROUTINE
	SET_NMI_ROUTINE  DUMMY_ROUTINE
	WAIT_NMI

	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_GENERAL, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, #BK_SETTINGS, SAVED_PRG_1

	JMP	ENTRY_SETTINGS
.endproc


.segment BANK(BK_SETTINGS)

.proc ENTRY_SETTINGS
	BIT	PPUSTATUS

	PPU_LOAD_BG_PALETTE   SETTINGS_BG_PALETTE_DATA
	PPU_LOAD_SPR_PALETTE  SETTINGS_SPR_PALETTE_DATA

	MMC3_BANK_SELECT  MMC3_CHR_0, #TS_SETTINGS+0
	MMC3_BANK_SELECT  MMC3_CHR_1, #TS_SETTINGS+2
	MMC3_BANK_SELECT  MMC3_CHR_2, #TS_SETTINGS+0
	MMC3_BANK_SELECT  MMC3_CHR_3, #TS_SETTINGS+1
	MMC3_BANK_SELECT  MMC3_CHR_4, #TS_SETTINGS+2
	MMC3_BANK_SELECT  MMC3_CHR_5, #TS_SETTINGS+3

	OAM_HIDE_ALL_SPRITE
	OAM_COPY_SPRITE_ENTRIES  SETTINGS_SPR_DATA, 0, 10

	JSR	DISPLAY_SETTINGS
	
	LDA	#0
	STA	SETTINGS_MENU

	SET_NMI_ROUTINE  NMI_SETTINGS
	WAIT_NMI
	PPU_DISABLE

	SET_IRQ_ROUTINE  IRQ_SETTINGS
	MMC3_IRQ_DISABLE
	CLI

	JMP	SETTINGS_LOOP

	; WAIT_FRAMES  30, MP_UPDATE
.endproc

SETTINGS_MENU_U: .BYTE 0, 0, 0, 0, 1, 2, 3, 4, 5
SETTINGS_MENU_R: .BYTE 0, 2, 3, 3, 5, 6, 6, 8, 8
SETTINGS_MENU_D: .BYTE 1, 4, 5, 6, 7, 8, 8, 7, 8
SETTINGS_MENU_L: .BYTE 0, 1, 1, 2, 4, 4, 5, 7, 7

SETTINGS_MENU_X: .BYTE 0, 184, 192, 200, 184, 192, 200, 184, 192
SETTINGS_MENU_Y: .BYTE 255, 47, 47, 47, 63, 63, 63, 79, 79

SETTINGS_JOYPAD_TYPE: .BYTE JOYPAD_SNES, JOYPAD_NES, JOYPAD_SNES

.proc SETTINGS_LOOP
	WAIT_NMI

	JSR	READ_JOYPAD

	LDA	SETTINGS_MENU
	AND	#$7F
	TAX

	B7C	SETTINGS_MENU, @not_selected
	JMP	@selected

@not_selected:
	JOYPAD_BR_IF_A_NOT_PRESSED :+
	LDA	SETTINGS_MENU
	BEQ	:+
	ORA	#$80
	STA	SETTINGS_MENU
	OAM_SET_SPRITE_TILE  9, #$4F
	JMP	SETTINGS_LOOP
:
	JOYPAD_BR_IF_U_NOT_PRESSED :+
	LDA	SETTINGS_MENU_U,X
	STA	SETTINGS_MENU
	JMP	@update_menu_pos
:
	JOYPAD_BR_IF_D_NOT_PRESSED :+
	LDA	SETTINGS_MENU_D,X
	STA	SETTINGS_MENU
	JMP	@update_menu_pos
:
	JOYPAD_BR_IF_R_NOT_PRESSED :+
	LDA	SETTINGS_MENU_R,X
	BEQ	@change_control
	STA	SETTINGS_MENU
	JMP	@update_menu_pos
:
	JOYPAD_BR_IF_L_NOT_PRESSED :+
	LDA	SETTINGS_MENU_L,X
	BEQ	@change_control
	STA	SETTINGS_MENU
	JMP	@update_menu_pos
:
	JMP	@cont

@update_menu_pos:
	LDA	SETTINGS_MENU
	AND	#$7F
	TAX
	LDA	SETTINGS_MENU_X,X
	OAM_SET_SPRITE_X_A  9
	LDA	SETTINGS_MENU_Y,X
	OAM_SET_SPRITE_Y_A  9
	JMP	SETTINGS_LOOP

@change_control:
	LDX	JOYPAD_TYPE
	LDA	SETTINGS_JOYPAD_TYPE,X
	STA	JOYPAD_TYPE
	JMP	SETTINGS_LOOP

@selected:
	DEX

	JOYPAD_BR_IF_A_NOT_PRESSED :+
	LDA	SETTINGS_MENU
	AND	#$7F
	STA	SETTINGS_MENU
	OAM_SET_SPRITE_TILE  9, #$4E
	JMP	SETTINGS_LOOP
:

	JOYPAD_BR_IF_U_NOT_PRESSED :+
	LDA	CUSTOM_PALETTES,X
	SEC
	SBC	#$10
	JMP	@correct_color
:
	JOYPAD_BR_IF_D_NOT_PRESSED :+
	LDA	CUSTOM_PALETTES,X
	CLC
	ADC	#$10
	JMP	@correct_color
:
	JOYPAD_BR_IF_R_NOT_PRESSED :+
	LDA	CUSTOM_PALETTES,X
	CLC
	ADC	#$01
	JMP	@correct_color
:
	JOYPAD_BR_IF_L_NOT_PRESSED :+
	LDA	CUSTOM_PALETTES,X
	SEC
	SBC	#$01
	JMP	@correct_color
:
	JMP	@cont

@correct_color:
	AND	#$3F
	TAY
	; $30 -> $20
	CMP	#$30
	BNE	:+
	LDY	#$20
:
	; $0D -> $1D
	CMP	#$0D
	BNE	:+
	LDY	#$1D
:
	; $xE,$xF -> $1D
	AND	#$0E
	CMP	#$0E
	BNE	:+
	LDY	#$1D
:
	STY	CUSTOM_PALETTES,X
	JMP	SETTINGS_LOOP

@cont:

	JOYPAD_BR_IF_START_NOT_PRESSED :+
	JMP	INIT_INTRO_
:
	JOYPAD_BR_IF_SELECT_NOT_HELD :+
	JMP	SETTINGS_LOOP
:
	JMP	SETTINGS_LOOP
.endproc



SETTINGS_JOYPAD_NAMES_OFFSET: .BYTE 0, 4, 8
SETTINGS_JOYPAD_NAMES: 
	.BYTE "NES "
	.BYTE "SNES"
	.BYTE "??? "

.proc SETTINGS_UPDATE_PALETTE
	LDA	SETTINGS_MENU
	BEQ	:+

	PPU_LOAD_ADDR_XY  0, 21, 4
	LDA	#' '
	STA	PPUDATA
	PPU_LOAD_ADDR_XY  0, 28, 4
	LDA	#' '
	STA	PPUDATA
	JMP	:++
:
	PPU_LOAD_ADDR_XY  0, 21, 4
	LDA	#$3F
	STA	PPUDATA
	PPU_LOAD_ADDR_XY  0, 28, 4
	LDA	#$3E
	STA	PPUDATA
:

	PPU_LOAD_ADDR_XY  0, 23, 4
	LDX	JOYPAD_TYPE
	LDY	SETTINGS_JOYPAD_NAMES_OFFSET,X
	.repeat 4, I
	LDA	SETTINGS_JOYPAD_NAMES+I,Y
	STA	PPUDATA
	.endrepeat

	PPU_LOAD_ADDR $3f00
	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	#COLOR_GRAY_6
	STA	PPUDATA
	LDA	#COLOR_GRAY_A
	STA	PPUDATA
	LDA	#COLOR_WHITE
	STA	PPUDATA

	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_UI+0
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_UI+1
	STA	PPUDATA
	LDA	#COLOR_WHITE
	STA	PPUDATA

	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_GF+0
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_GF+1
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_GF+2
	STA	PPUDATA

	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+0
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+1
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+2
	STA	PPUDATA

	LDA	#COLOR_BLACK
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+0
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+1
	STA	PPUDATA
	LDA	CUSTOM_PALETTES_PL+2
	STA	PPUDATA
	
	LDA	#COLOR_BLACK
	STA	PPUDATA
	STA	PPUDATA
	
	LDA	SETTINGS_MENU
	AND	#$7F
	TAX
	DEX
	LDA	CUSTOM_PALETTES,X
	CMP	#COLOR_BLACK
	BNE	:+
	LDA	#COLOR_GRAY_6
:
	; LDA	CUSTOM_PALETTES_PL+0 ; selected element
	STA	PPUDATA
	LDA	#COLOR_WHITE
	STA	PPUDATA

	RTS
.endproc

.proc DISPLAY_SETTINGS
	BIT	PPUSTATUS
	
	PPU_WRITE_NT  0, SETTINGS_SCREEN_DATA
	PPU_FILL_NT   1, ' ', $00

	PPU_LOAD_ADDR_XY  0, 0, 0

	RTS
.endproc