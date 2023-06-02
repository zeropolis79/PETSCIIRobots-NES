.segment "HEADER"

INES_2_ID	= $08	; Indicator that this is an iNES 2.0 header

INES_MAPPER	= 4	; 4 = MMC3
INES_MIRROR	= 0	; 0 = horizontal mirroring/mapper-controlled, 1 = vertical mirroring
INES_TV_SYS	= 2	; 0 = NTSC, 1 = PAL, 2 = NTSC&PAL, 3 = Dendy
INES_CTRL_TYPE	= $00	; $01 = NES Controller, $2B = SNES Controller

INES_PRG_NUM	= 16	; 16k PRG chunk count
INES_CHR_NUM	= 16	;  8k CHR chunk count
INES_RAM_SHIFT	= 7	; (64 << x) PRG RAM chunk count



;Flag 0-3
.BYTE	'N', 'E', 'S', $1A ; ID
;Flag 4
.BYTE	.lobyte(INES_PRG_NUM)
;Flag 5
.BYTE	.lobyte(INES_CHR_NUM)
;Flag 6
.BYTE	INES_MIRROR | ((INES_MAPPER & $0f) << 4)
;Flag 7
.BYTE	(INES_MAPPER & $f0) | INES_2_ID
;Flag 8
.BYTE	$00
;Flag 9
.BYTE	(^INES_PRG_NUM) | ((^INES_CHR_NUM) << 4)
;Flag 10
.BYTE	INES_RAM_SHIFT
;Flag 11
.BYTE	$00
;Flag 12
.BYTE	(INES_TV_SYS & $03)
;Flag 13
.BYTE	$00
;Flag 14
.BYTE	$00 ; $008??
;Flag 15
.BYTE	INES_CTRL_TYPE
