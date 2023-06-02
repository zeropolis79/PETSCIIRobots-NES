.segment "OAM"
OAM:	.RES 256

; Byte 0 - Y position
; Byte 1 - Tile index
; Byte 2 - Attributes
; Byte 3 - X position
; 76543210
; |||   ||
; |||   ++- Palette (4 to 7) of sprite
; ||+------ Priority (0: in front of background; 1: behind background)
; |+------- Flip sprite horizontally
; +-------- Flip sprite vertically
; Hide a sprite by writing any values in $EF-$FF to Y-scroll. Sprites are never displayed on the first line of the picture, and it is impossible to place a sprite partially off the top of the screen.
; X-scroll values of $F9-FF results in parts of the sprite to be past the right edge of the screen, thus invisible. It is not possible to have a sprite partially visible on the left edge. Instead, left-clipping through PPUMASK ($2001) can be used to simulate this effect.

C_OAM_OFFSET_Y		= 0
C_OAM_OFFSET_TILE	= 1
C_OAM_OFFSET_ATTR	= 2
C_OAM_OFFSET_X		= 3

SPR_ATTR_PAL_0	 = %00000000
SPR_ATTR_PAL_1	 = %00000001
SPR_ATTR_PAL_2	 = %00000010
SPR_ATTR_PAL_3	 = %00000011
SPR_ATTR_TO_BG	 = %00100000
SPR_ATTR_NO_FLIP = %00000000
SPR_ATTR_FLIP_H	 = %01000000
SPR_ATTR_FLIP_V	 = %10000000
SPR_ATTR_FLIP_HV = %11000000

.macro OAM_HIDE_SPRITE  id
	OAM_SET_SPRITE_Y  id, #0
.endmacro

.macro OAM_HIDE_ALL_SPRITE
	LDA	#$EF
	LDX	#$00
:	STA	OAM, X
	INX
	INX
	INX
	INX
	BNE	:-
.endmacro

.macro OAM_SPRITE_ENTRY  tx, ty, tile, attr
	.BYTE  ty-1, tile, attr, tx
.endmacro

.macro OAM_COPY_SPRITE_ENTRIES  addr, index, length
	LDX	#0
:	LDA	addr,X
	STA	OAM+index*4,X
	INX
	CPX	#length*4
	BNE	:-
.endmacro

.macro OAM_SET_SPRITE  id, tx, ty, tile, attr
	OAM_SET_SPRITE_X	id, tx
	OAM_SET_SPRITE_Y	id, ty
	OAM_SET_SPRITE_TILE	id, tile
	OAM_SET_SPRITE_ATTR	id, attr
.endmacro

.macro OAM_SET_SPRITE_X  id, tx
	LDA	tx
	STA	OAM+id*4+C_OAM_OFFSET_X
.endmacro

.macro OAM_SET_SPRITE_Y  id, ty
	LDA	ty-1
	STA	OAM+id*4+C_OAM_OFFSET_Y
.endmacro

.macro OAM_SET_SPRITE_XY  id, tx, ty
	LDA	tx
	STA	OAM+id*4+C_OAM_OFFSET_X
	LDA	ty-1
	STA	OAM+id*4+C_OAM_OFFSET_Y
.endmacro

.macro OAM_SET_SPRITE_TILE  id, tile
	LDA	tile
	STA	OAM+id*4+C_OAM_OFFSET_TILE
.endmacro

.macro OAM_SET_SPRITE_ATTR  id, attr
	LDA	attr
	STA	OAM+id*4+C_OAM_OFFSET_ATTR
.endmacro


.macro OAM_SET_SPRITE_X_A  id
	STA	OAM+id*4+C_OAM_OFFSET_X
.endmacro

.macro OAM_SET_SPRITE_Y_A  id
	STA	OAM+id*4+C_OAM_OFFSET_Y
.endmacro

.macro OAM_SET_SPRITE_TILE_A  id
	STA	OAM+id*4+C_OAM_OFFSET_TILE
.endmacro

.macro OAM_SET_SPRITE_ATTR_A  id
	STA	OAM+id*4+C_OAM_OFFSET_ATTR
.endmacro
