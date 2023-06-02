.segment BANK(BK_INTRO_CODE)

IRQ_INTRO:
	; Acknowledge irq
	MMC3_IRQ_DISABLE
	MMC3_IRQ_ENABLE
	
	; wait until we reach the end of the scanline
	DELAY	61
	
	; swap the charachters
	MMC3_BANK_SELECT  MMC3_CHR_0, #TS_INTRO_2+0
	MMC3_BANK_SELECT  MMC3_CHR_1, #TS_INTRO_2+2

; 	; 1 scabline NTSC = 113 2/3  CPU cycles
; 	; 1 scabline PAL  = 106 9/16 CPU cycles
; 	; BIT	PPUSTATUS
; 	; LDA	#8
; 	; STA	PPUSCROLL	; 10

	RTS
