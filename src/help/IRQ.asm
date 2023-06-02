.segment BANK(BK_HELP)

IRQ_HELP:
	; Acknowledge irq
	MMC3_IRQ_DISABLE
	MMC3_IRQ_ENABLE
	
	; wait until we reach the end of the scanline
	DELAY	61

	RTS
