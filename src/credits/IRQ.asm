.segment BANK(BK_CREDITS)

IRQ_MUSICPLAYER:
	; Acknowledge irq
	MMC3_IRQ_DISABLE
	MMC3_IRQ_ENABLE
	
	; wait until we reach the end of the scanline
	DELAY	61

	PPU_SCROLL_XY  1, 0, 2

	RTS
