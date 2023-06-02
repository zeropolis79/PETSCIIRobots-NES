
_MMC3_BANK_SELECT	=$8000 ; ($8000-$9FFE, even) %100- ---- ---- ---0
_MMC3_BANK_DATA		=$8001 ; ($8001-$9FFF, odd)  %100- ---- ---- ---1

_MMC3_MIRRORING		=$A000 ; ($A000-$BFFE, even) %101- ---- ---- ---0
_MMC3_PRG_RAM_CONF	=$A001 ; ($A001-$BFFF, odd)  %101- ---- ---- ---1

_MMC3_IRQ_LATCH		=$C000 ; ($C000-$DFFE, even) %110- ---- ---- ---0
_MMC3_IRQ_RELOAD	=$C001 ; ($C001-$DFFF, odd)  %110- ---- ---- ---1
_MMC3_IRQ_DISABLE	=$E000 ; ($E000-$FFFE, even) %111- ---- ---- ---0
_MMC3_IRQ_ENABLE	=$E001 ; ($E001-$FFFF, odd)  %111- ---- ---- ---1


MMC3_CHR_0 = 0 ; Select 2 KB CHR bank at PPU $0000-$07FF - index: xxxxxxx-
MMC3_CHR_1 = 1 ; Select 2 KB CHR bank at PPU $0800-$0FFF - index: xxxxxxx-
MMC3_CHR_2 = 2 ; Select 1 KB CHR bank at PPU $1000-$13FF - index: xxxxxxxx
MMC3_CHR_3 = 3 ; Select 1 KB CHR bank at PPU $1400-$17FF - index: xxxxxxxx
MMC3_CHR_4 = 4 ; Select 1 KB CHR bank at PPU $1800-$1BFF - index: xxxxxxxx
MMC3_CHR_5 = 5 ; Select 1 KB CHR bank at PPU $1C00-$1FFF - index: xxxxxxxx
MMC3_PRG_0 = 6 ; Select 8 KB PRG ROM bank at $8000-$9FFF - index: --xxxxxx
MMC3_PRG_1 = 7 ; Select 8 KB PRG ROM bank at $A000-$BFFF - index: --xxxxxx

.macro MMC3_BANK_SELECT bank_register, bank_index, opt_reg
	LDA	bank_index
	MMC3_BANK_SELECT_A  bank_register, opt_reg
.endmacro

.macro MMC3_BANK_SELECT_A bank_register, opt_reg
	LDX	#(bank_register & %111)
	.ifnblank opt_reg
	STA	opt_reg
	.endif
	STX	_MMC3_BANK_SELECT
	STA	_MMC3_BANK_DATA
.endmacro


.macro MMC3_MIRROR_HORIZONTAL
	LDA	#1
	STA	_MMC3_MIRRORING
.endmacro

.macro MMC3_MIRROR_VERTICAL
	LDA	#0
	STA	_MMC3_MIRRORING
.endmacro


.macro MMC3_PRG_RAM_OFF
	LDA	#%00000000
	STA	_MMC3_PRG_RAM_CONF
.endmacro

.macro MMC3_PRG_RAM_ON
	LDA 	#%10000000
	STA	_MMC3_PRG_RAM_CONF
.endmacro

.macro MMC3_PRG_RAM_ON_PROTECTED
	LDA	#%11000000
	STA	_MMC3_PRG_RAM_CONF
.endmacro

; rising edge every scanline @ dot 255->256
; @rising_edge
;   if (counter == 0 or IRQ_RELOAD == 1) 
;     counter = IRQ_LATCH
;   else
;     counter--
;   IRQ_RELOAD = 0
;   if (counter == 0 and IRQ_ENABLED == 1)
;     trigger irq

.macro MMC3_IRQ_LATCH  latch_value
	LDA	#latch_value
	STA	_MMC3_IRQ_LATCH
.endmacro

.macro MMC3_IRQ_RELOAD
	STA	_MMC3_IRQ_RELOAD
.endmacro

.macro MMC3_IRQ_DISABLE
	STA	_MMC3_IRQ_DISABLE
.endmacro

.macro MMC3_IRQ_ENABLE
	STA	_MMC3_IRQ_ENABLE
.endmacro
