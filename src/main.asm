.include "base/header.asm"
.include "base/ascii_charmap.inc"

.include "CONFIG.asm"

.segment "ZEROPAGE"
PTR_0:	.RES 2
PTR_0_L	=(PTR_0+0)
PTR_0_H	=(PTR_0+1)

PTR_1:	.RES 2
PTR_1_L	=(PTR_1+0)
PTR_1_H	=(PTR_1+1)

NMI_ROUTINE:		.RES 2
IRQ_ROUTINE:		.RES 2

PPUMASK_CONFIG:		.RES 1
VBLANK_FLAG:		.RES 1

TV_SYSTEM:		.RES 1

JOYPAD_TYPE:		.RES 1
JOYPAD_HELD:		.RES 2
JOYPAD_PRESSED:		.RES 2

TEMP_A:			.RES 1
TEMP_B:			.RES 1
TEMP_C:			.RES 1

SAVED_PRG_0:		.RES 1
SAVED_PRG_1:		.RES 1

SELECTED_MAP:		.RES 1
DIFF_LEVEL:		.RES 1

CUSTOM_PALETTES:	.RES 8
CUSTOM_PALETTES_GF = (CUSTOM_PALETTES+0)
CUSTOM_PALETTES_PL = (CUSTOM_PALETTES+3)
CUSTOM_PALETTES_UI = (CUSTOM_PALETTES+6)

.segment BANK(BK_MAIN_CODE)

.include "sound/famistudio.asm"
.include "sound/VAR.asm"

.include "base/6502_macros.asm"
.include "base/detect_tv_system.asm"
.include "base/joypad.asm"
.include "base/mmc3.asm"
.include "base/macros.asm"
.include "base/oam.asm"

.include "base/vector_nmi.asm"
.include "base/vector_irq.asm"
.include "base/vector_reset.asm"
.include "base/vectors.asm"

.include "misc/DELAY.asm"
.include "misc/METATILESET.asm"
.include "misc/TILESET.asm"
.include "misc/UTILS.asm"

.segment BANK(BK_MAIN_CODE)

.proc MAIN
	; PPU configuration for actual use
	LDA	#%10001000
	;         VPHBSINN
	;         ||||||++- Base nametable address (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
	;         |||||+--- VRAM address increment per CPU read/write of PPUDATA (0: add 1, going across; 1: add 32, going down)
	;         ||||+---- Sprite pattern table address for 8x8 sprites (0: $0000; 1: $1000; ignored in 8x16 mode)
	;         |||+----- Background pattern table address (0: $0000; 1: $1000)
	;         ||+------ Sprite size (0: 8x8 pixels; 1: 8x16 pixels)
	;         |+------- PPU master/slave select (0: read backdrop from EXT pins; 1: output color on EXT pins)
	;         +-------- Generate an NMI at the start of the vertical blanking interval (0: off; 1: on)
	STA	PPUCTRL

	LDA	#%00011110
	;         BGRsbMmG
	;         |||||||+- Greyscale (0: normal color, 1: produce a greyscale display)
	;         ||||||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
	;         |||||+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
	;         ||||+---- 1: Show background
	;         |||+----- 1: Show sprites
	;         ||+------ Emphasize red (green on PAL/Dendy)
	;         |+------- Emphasize green (red on PAL/Dendy)
	;         +-------- Emphasize blue
	STA	PPUMASK_CONFIG

	; Bring the PPU back up.
	WAIT_NMI

	JSR	DETECT_TV_SYSTEM
	STA	TV_SYSTEM
	JSR	DETECT_JOYPAD
	STA	JOYPAD_TYPE

	WAIT_NMI

	JMP	PRE_INIT_INTRO
.endproc

.include "intro/CODE.asm"
.include "game/CODE.asm"
.include "misc/MAPS.asm"
.include "misc/RLE.asm"
.include "end/CODE.asm"
.include "sound/CODE.asm"
.include "credits/CODE.asm"
.include "settings/CODE.asm"
.include "help/CODE.asm"

.include "build_time.asm"

