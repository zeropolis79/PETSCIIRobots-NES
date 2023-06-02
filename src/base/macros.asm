PPUCTRL		= $2000
PPUMASK		= $2001
PPUSTATUS	= $2002
OAMADDR		= $2003
OAMDATA		= $2004
OAMDMA		= $4014
PPUSCROLL	= $2005
PPUADDR		= $2006
PPUDATA		= $2007

SQ1VOL		= $4000
SQ1SWP		= $4001
SQ1FREQ		= $4002
SQ1LEN		= $4003
SQ2VOL		= $4004
SQ2SWP		= $4005
SQ2FREQ		= $4006
SQ2LEN		= $4007
TRICNTR		= $4008
TRIFREQ		= $400a
TRILEN		= $400b
NOISEVOL	= $400c
NOISEFREQ	= $400e
NOISELEN	= $400f
DMCFREQ		= $4010
DMCDELTA	= $4011
DMCADDR		= $4012
DMCLEN		= $4013
CHANCTRL	= $4015
JOY1		= $4016 ; when reading
JOYSTROBE	= $4016 ; when writing
JOY2		= $4017 ; when reading
APUIRQ		= $4017 ; when writing


COLOR_BLACK 	= $1D
COLOR_GRAY_4	= $2D
COLOR_GRAY_6	= $00
COLOR_GRAY_A	= $10
COLOR_GRAY_B	= $3D
COLOR_WHITE 	= $30 ; $20

COLOR_DARKER	= $00
COLOR_SATURATED	= $10
COLOR_LIGHTER	= $20
COLOR_LIGHTER2	= $30

COLOR_AZURE	= $01
COLOR_BLUE	= $02
COLOR_VIOLET	= $03
COLOR_MAGENTA	= $04
COLOR_ROSE	= $05
COLOR_RED	= $06
COLOR_ORANGE	= $07
COLOR_OLIVE	= $08
COLOR_LIME	= $09
COLOR_GREEN	= $0A
COLOR_SPRING	= $0B
COLOR_CYAN	= $0C


; Turn off rendering
.macro PPU_DISABLE
	; Disable rendering
	LDA	#$00
	STA	PPUMASK
.endmacro

; Turn off background rendering
; use this to prevent the OAM to decay
.macro PPU_DISABLE_BG
	LDA	PPUMASK_CONFIG
	AND 	#%11110111
	STA	PPUMASK
.endmacro

; Turn on rendering
.macro PPU_ENABLE
	; Restore PPUMASK configration.
	LDA	PPUMASK_CONFIG
	STA	PPUMASK
.endmacro

.macro PPU_START_OAM_DMA
	LDA	#0
	STA	OAMADDR
	LDA	#>OAM
	STA	OAMDMA
.endmacro

; Latch the PPU address
.macro PPU_LOAD_ADDR  addr
	LDA	#>(addr)
	STA	PPUADDR
	LDA	#<(addr)
	STA	PPUADDR
.endmacro

.macro PPU_LOAD_ADDR_XY  nt, px, py
	LDA	#>($2000+$0400*nt+$0020*py+px)
	STA	PPUADDR
	LDA	#<($2000+$0400*nt+$0020*py+px)
	STA	PPUADDR
.endmacro

; Load a full palette
.macro PPU_LOAD_FULL_PALETTE  pal_data
	PPU_LOAD_ADDR $3f00
	LDX	#$00
 :
	LDA	pal_data, x
	STA	PPUDATA
	INX
	CPX	#$20
	BNE	:-
.endmacro

; Load a full BG palette
.macro PPU_LOAD_BG_PALETTE  pal_data
	PPU_LOAD_ADDR $3f00
	LDX	#$00
 :
	LDA	pal_data, x
	STA	PPUDATA
	INX
	CPX	#$10
	BNE	:-
.endmacro

; Load a full SPR palette
.macro PPU_LOAD_SPR_PALETTE  pal_data
	PPU_LOAD_ADDR $3f10
	LDX	#$00
 :
	LDA	pal_data, x
	STA	PPUDATA
	INX
	LDA	pal_data, x
	STA	PPUDATA
	INX
	LDA	pal_data, x
	STA	PPUDATA
	INX
	LDA	pal_data, x
	STA	PPUDATA
	INX
	CPX	#$10
	BNE	:-
.endmacro

; Latch the PPU scroll; mangles A
; .macro PPU_LOAD_SCROLL cam_x, cam_y
; 	BIT	PPUSTATUS
; 	LDA	cam_x
; 	STA	PPUSCROLL
; 	LDA	cam_y
; 	STA	PPUSCROLL
; 	; Clamp scroll values
; 	LDA	xscroll+1
; 	AND	#%00000001
; 	STA	xscroll+1
; 	LDA	yscroll+1
; 	AND	#%00000001
; 	STA	yscroll+1

; 	LDA	PPUCTRL_CONFIG
; 	ORA	xscroll+1		; Bring in X scroll coarse bit
; 	ORA	yscroll+1		; Y scroll coarse bit
; 	STA	PPUCTRL		; Re-enable NMI
; .endmacro


; Scrolls the screen to any location mid-frame
.macro PPU_SCROLL_XY  nt, px, py
	LDA	#(nt << 2)
	STA	PPUADDR
	LDA	#py
	STA	PPUSCROLL
	LDA	#px
	STA	PPUSCROLL
	LDA	#(((py & $38) << 2) | (px >> 3))
	STA	PPUADDR 
.endmacro


.macro PPU_SCROLL_XY_FINE_X  nt, px, py
	LDA	#(nt << 2)
	STA	PPUADDR
	LDA	#py
	STA	PPUSCROLL
	LDA	px
	STA	PPUSCROLL
	LDA	#((py & $38) << 2)
	STA	PPUADDR 
.endmacro

; Fills the nametable with the given screen and attribute values
.macro PPU_FILL_NT  nt, svalue, avalue
	PPU_LOAD_ADDR_XY  nt, 0, 0

	LDX	#0
	LDA	#svalue
 :	STA	PPUDATA
	STA	PPUDATA
	STA	PPUDATA
	INX
	BNE	:-

 :	STA	PPUDATA
	CPX	#191
	BNE	:+
	LDA	#avalue
 :	INX
	BNE	:--

.endmacro


; Copy binary nametable + attribute data into VRAM
.macro PPU_WRITE_NT  nt, src
	PPU_LOAD_ADDR_XY  nt, 0, 0

	LDX	#0
	.repeat 4, I
 :	LDA	src + $100*I, X
	STA	PPUDATA
	INX
	BNE	:-
	.endrepeat

.endmacro


.macro PPU_WRITE_32KBIT  nt, src
	LDY	#($2000+$0400*nt)	; Upper byte of VRAM Address
	LDX	#$00			; Lower byte of VRAM Address

	BIT	PPUSTATUS
	STY	PPUADDR
	STX	PPUADDR

	.repeat 16, I
 :	LDA	src + $100*I, X
	STA	PPUDATA
	INX
	BNE	:-
	.endrepeat
.endmacro



; .macro PPU_NT_PALETTE_ENTRY pl00, pl01, pl02, pl03
; 	.byte (((pl00&3)<<0) | ((pl01&3)<<2) | ((pl02&3)<<4) | ((pl03&3)<<6))
; .endmacro

; .linecont	+ 
; .macro PPU_NT_PALETTE \
; pl00, pl01, pl02, pl03, pl04, pl05, pl06, pl07, pl08, pl09, pl0A, pl0B, pl0C, pl0D, pl0E, pl0F, \
; pl10, pl11, pl12, pl13, pl14, pl15, pl16, pl17, pl18, pl19, pl1A, pl1B, pl1C, pl1D, pl1E, pl1F, \
; pl20, pl21, pl22, pl23, pl24, pl25, pl26, pl27, pl28, pl29, pl2A, pl2B, pl2C, pl2D, pl2E, pl2F, \
; pl30, pl31, pl32, pl33, pl34, pl35, pl36, pl37, pl38, pl39, pl3A, pl3B, pl3C, pl3D, pl3E, pl3F, \
; pl40, pl41, pl42, pl43, pl44, pl45, pl46, pl47, pl48, pl49, pl4A, pl4B, pl4C, pl4D, pl4E, pl4F, \
; pl50, pl51, pl52, pl53, pl54, pl55, pl56, pl57, pl58, pl59, pl5A, pl5B, pl5C, pl5D, pl5E, pl5F, \
; pl60, pl61, pl62, pl63, pl64, pl65, pl66, pl67, pl68, pl69, pl6A, pl6B, pl6C, pl6D, pl6E, pl6F, \
; pl70, pl71, pl72, pl73, pl74, pl75, pl76, pl77, pl78, pl79, pl7A, pl7B, pl7C, pl7D, pl7E, pl7F, \
; pl80, pl81, pl82, pl83, pl84, pl85, pl86, pl87, pl88, pl89, pl8A, pl8B, pl8C, pl8D, pl8E, pl8F, \
; pl90, pl91, pl92, pl93, pl94, pl95, pl96, pl97, pl98, pl99, pl9A, pl9B, pl9C, pl9D, pl9E, pl9F, \
; plA0, plA1, plA2, plA3, plA4, plA5, plA6, plA7, plA8, plA9, plAA, plAB, plAC, plAD, plAE, plAF, \
; plB0, plB1, plB2, plB3, plB4, plB5, plB6, plB7, plB8, plB9, plBA, plBB, plBC, plBD, plBE, plBF, \
; plC0, plC1, plC2, plC3, plC4, plC5, plC6, plC7, plC8, plC9, plCA, plCB, plCC, plCD, plCE, plCF, \
; plD0, plD1, plD2, plD3, plD4, plD5, plD6, plD7, plD8, plD9, plDA, plDB, plDC, plDD, plDE, plDF, \
; plE0, plE1, plE2, plE3, plE4, plE5, plE6, plE7, plE8, plE9, plEA, plEB, plEC, plED, plEE, plEF

; 	PPU_NT_PALETTE_ENTRY  pl00, pl01, pl10, pl11
; 	PPU_NT_PALETTE_ENTRY  pl02, pl03, pl12, pl13
; 	PPU_NT_PALETTE_ENTRY  pl04, pl05, pl14, pl15
; 	PPU_NT_PALETTE_ENTRY  pl06, pl07, pl16, pl17
; 	PPU_NT_PALETTE_ENTRY  pl08, pl09, pl18, pl19
; 	PPU_NT_PALETTE_ENTRY  pl0A, pl0B, pl1A, pl1B
; 	PPU_NT_PALETTE_ENTRY  pl0C, pl0D, pl1C, pl1D
; 	PPU_NT_PALETTE_ENTRY  pl0E, pl0E, pl1E, pl1E

; 	PPU_NT_PALETTE_ENTRY  pl20, pl21, pl30, pl31
; 	PPU_NT_PALETTE_ENTRY  pl22, pl23, pl32, pl33
; 	PPU_NT_PALETTE_ENTRY  pl24, pl25, pl34, pl35
; 	PPU_NT_PALETTE_ENTRY  pl26, pl27, pl36, pl37
; 	PPU_NT_PALETTE_ENTRY  pl28, pl29, pl38, pl39
; 	PPU_NT_PALETTE_ENTRY  pl2A, pl2B, pl3A, pl3B
; 	PPU_NT_PALETTE_ENTRY  pl2C, pl2D, pl3C, pl3D
; 	PPU_NT_PALETTE_ENTRY  pl2E, pl2E, pl3E, pl3E
	
; 	PPU_NT_PALETTE_ENTRY  pl40, pl41, pl50, pl51
; 	PPU_NT_PALETTE_ENTRY  pl42, pl43, pl52, pl53
; 	PPU_NT_PALETTE_ENTRY  pl44, pl45, pl54, pl55
; 	PPU_NT_PALETTE_ENTRY  pl46, pl47, pl56, pl57
; 	PPU_NT_PALETTE_ENTRY  pl48, pl49, pl58, pl59
; 	PPU_NT_PALETTE_ENTRY  pl4A, pl4B, pl5A, pl5B
; 	PPU_NT_PALETTE_ENTRY  pl4C, pl4D, pl5C, pl5D
; 	PPU_NT_PALETTE_ENTRY  pl4E, pl4E, pl5E, pl5E
	
; 	PPU_NT_PALETTE_ENTRY  pl60, pl61, pl70, pl71
; 	PPU_NT_PALETTE_ENTRY  pl62, pl63, pl72, pl73
; 	PPU_NT_PALETTE_ENTRY  pl64, pl65, pl74, pl75
; 	PPU_NT_PALETTE_ENTRY  pl66, pl67, pl76, pl77
; 	PPU_NT_PALETTE_ENTRY  pl68, pl69, pl78, pl79
; 	PPU_NT_PALETTE_ENTRY  pl6A, pl6B, pl7A, pl7B
; 	PPU_NT_PALETTE_ENTRY  pl6C, pl6D, pl7C, pl7D
; 	PPU_NT_PALETTE_ENTRY  pl6E, pl6E, pl7E, pl7E

; 	PPU_NT_PALETTE_ENTRY  pl80, pl81, pl90, pl91
; 	PPU_NT_PALETTE_ENTRY  pl82, pl83, pl92, pl93
; 	PPU_NT_PALETTE_ENTRY  pl84, pl85, pl94, pl95
; 	PPU_NT_PALETTE_ENTRY  pl86, pl87, pl96, pl97
; 	PPU_NT_PALETTE_ENTRY  pl88, pl89, pl98, pl99
; 	PPU_NT_PALETTE_ENTRY  pl8A, pl8B, pl9A, pl9B
; 	PPU_NT_PALETTE_ENTRY  pl8C, pl8D, pl9C, pl9D
; 	PPU_NT_PALETTE_ENTRY  pl8E, pl8E, pl9E, pl9E

; 	PPU_NT_PALETTE_ENTRY  plA0, plA1, plB0, plB1
; 	PPU_NT_PALETTE_ENTRY  plA2, plA3, plB2, plB3
; 	PPU_NT_PALETTE_ENTRY  plA4, plA5, plB4, plB5
; 	PPU_NT_PALETTE_ENTRY  plA6, plA7, plB6, plB7
; 	PPU_NT_PALETTE_ENTRY  plA8, plA9, plB8, plB9
; 	PPU_NT_PALETTE_ENTRY  plAA, plAB, plBA, plBB
; 	PPU_NT_PALETTE_ENTRY  plAC, plAD, plBC, plBD
; 	PPU_NT_PALETTE_ENTRY  plAE, plAE, plBE, plBE
	
; 	PPU_NT_PALETTE_ENTRY  plC0, plC1, plD0, plD1
; 	PPU_NT_PALETTE_ENTRY  plC2, plC3, plD2, plD3
; 	PPU_NT_PALETTE_ENTRY  plC4, plC5, plD4, plD5
; 	PPU_NT_PALETTE_ENTRY  plC6, plC7, plD6, plD7
; 	PPU_NT_PALETTE_ENTRY  plC8, plC9, plD8, plD9
; 	PPU_NT_PALETTE_ENTRY  plCA, plCB, plDA, plDB
; 	PPU_NT_PALETTE_ENTRY  plCC, plCD, plDC, plDD
; 	PPU_NT_PALETTE_ENTRY  plCE, plCE, plDE, plDE
	
; 	PPU_NT_PALETTE_ENTRY  plE0, plE1, 0, 0
; 	PPU_NT_PALETTE_ENTRY  plE2, plE3, 0, 0
; 	PPU_NT_PALETTE_ENTRY  plE4, plE5, 0, 0
; 	PPU_NT_PALETTE_ENTRY  plE6, plE7, 0, 0
; 	PPU_NT_PALETTE_ENTRY  plE8, plE9, 0, 0
; 	PPU_NT_PALETTE_ENTRY  plEA, plEB, 0, 0
; 	PPU_NT_PALETTE_ENTRY  plEC, plED, 0, 0
; 	PPU_NT_PALETTE_ENTRY  plEE, plEE, 0, 0
; .endmacro
; .linecont	-



.macro WAIT_SPRITE_0_HIT
 :	
	.repeat 16
	BIT	PPUSTATUS
	BVS	:+
	.endrepeat
	BIT	PPUSTATUS
	BVC	:-
 :
.endmacro

.macro WAIT_VBLANK
 :	BIT	PPUSTATUS
	BMI	:-
.endmacro

.macro WAIT_NMI
 :	LDA	VBLANK_FLAG
	BNE	:-
	INC	VBLANK_FLAG
	JSR	SOUND_SYSTEM_UPDATE
.endmacro

.macro WAIT_FRAMES num, update_proc
.local loop
	LDX	#num
 loop:	PHX
 	WAIT_NMI
	.ifnblank update_proc
	JSR	update_proc
	.endif
	PLX
	DEX
	BNE	loop
.endmacro


.macro ZP_CLEAR  offset
.ifnblank offset
	LDX	#offset
	LDA	#0
.else
	LDX	#$00
	TXA
.endif
 :	STA	$0000, x ; zp
	INX
	BNE	:-
.endmacro

.macro STACK_CLEAR
	LDX	#$00
	TXA
 :	STA	$0100, x ; stack
	INX
	BNE	:-
.endmacro

.macro OAM_CLEAR
	LDX	#$00
	TXA
 :	STA	$0200, x ; oam
	INX
	BNE	:-
.endmacro

.macro RAM_CLEAR
	LDX	#$00
	TXA
 :	STA	$0300, x ; ram
	STA	$0400, x
	STA	$0500, x
	STA	$0600, x
	STA	$0700, x
	INX
	BNE	:-
.endmacro

.macro STACK_OAM_RAM_CLEAR
	LDX	#$00
	TXA
 :	STA	$0100, x ; stack
	STA	$0200, x ; oam
	STA	$0300, x ; ram
	STA	$0400, x
	STA	$0500, x
	STA	$0600, x
	STA	$0700, x
	INX
	BNE	:-
.endmacro

.macro WRAM_CLEAR
	LDX	#$00
	TXA
 :	
	.repeat 32, I
 	STA	$6000 + $0100*I, x
	.endrepeat
	INX
	BNE	:-
.endmacro

.macro WRAM_COPY  src
	LDX	#$00
 :
 	.repeat 16, I
	LDA	src   + $0000+ $0100*I, x
	STA	$6000 + $0000+ $0100*I, x
	.endrepeat
	INX
	BNE	:-
 :
 	.repeat 16, I
	LDA	src   + $1000 + $0100*I, x
	STA	$6000 + $1000 + $0100*I, x
	.endrepeat
	INX
	BNE	:-
.endmacro


.macro RAM_FILL  dst, value, times
	LDA	#value
	LDX	#$00
 :	STA	dst, x
	INX
	CPX	#times
	BNE	:-
.endmacro

.macro RAM_COPY_256  src, dst
	LDX	#$00
 :
	LDA	src + $0000, x
	STA	dst + $0000, x
	INX
	BNE	:-
.endmacro

.macro RAM_COPY_512  src, dst
	LDX	#$00
 :
 	.repeat 2, I
	LDA	src + $0100*I, x
	STA	dst + $0100*I, x
	.endrepeat
	INX
	BNE	:-
.endmacro

.macro RAM_COPY_1K  src, dst
	LDX	#$00
 :
 	.repeat 4, I
	LDA	src + $0100*I, x
	STA	dst + $0100*I, x
	.endrepeat
	INX
	BNE	:-
.endmacro

.macro RAM_COPY_4K  src, dst
	LDX	#$00
 :
 	.repeat 16, I
	LDA	src + $0100*I, x
	STA	dst + $0100*I, x
	.endrepeat
	INX
	BNE	:-
.endmacro

.macro RAM_COPY_8K  src, dst
	RAM_COPY_4K  src + $0000, dst + $0000
	RAM_COPY_4K  src + $1000, dst + $1000
.endmacro


.macro REPEAT  num, instr
 	.repeat num, I
	instr
	.endrepeat
.endmacro