.segment BANK(BK_GENERAL)
MAP_NAMES:	
	.BYTE "01-research lab "
	.BYTE "02-headquarters "
	.BYTE "03-the village  "
	.BYTE "04-the islands  "
	.BYTE "05-downtown     "
	.BYTE "06-pi university"
	.BYTE "07-more islands "
	.BYTE "08-robot hotel  "
	.BYTE "09-forest moon  "
	.BYTE "10-death tower  "
	.BYTE "11-bunker       "
	.BYTE "12-castle robot "
	.BYTE "13-rocket center"
	.BYTE "14-             "
	.BYTE "15-             "
	.BYTE "16-             "
MAP_BANKS:
	.BYTE $00, $01, $02, $03
	.BYTE $04, $05, $06, $07
	.BYTE $08, $09, $0A, $0B
	.BYTE $0C, $0D, $0E, $0F
MAP_NUM:
	.BYTE 13


.segment "BANK00"
	.incbin "resources/level/level-a.unit"
	.incbin "resources/level/level-a.map.rle"

.segment "BANK01"
	.incbin "resources/level/level-b.unit"
	.incbin "resources/level/level-b.map.rle"

.segment "BANK02"
	.incbin "resources/level/level-c.unit"
	.incbin "resources/level/level-c.map.rle"

.segment "BANK03"
	.incbin "resources/level/level-d.unit"
	.incbin "resources/level/level-d.map.rle"

.segment "BANK04"
	.incbin "resources/level/level-e.unit"
	.incbin "resources/level/level-e.map.rle"

.segment "BANK05"
	.incbin "resources/level/level-f.unit"
	.incbin "resources/level/level-f.map.rle"

.segment "BANK06"
	.incbin "resources/level/level-g.unit"
	.incbin "resources/level/level-g.map.rle"

.segment "BANK07"
	.incbin "resources/level/level-h.unit"
	.incbin "resources/level/level-h.map.rle"

.segment "BANK08"
	.incbin "resources/level/level-i.unit"
	.incbin "resources/level/level-i.map.rle"

.segment "BANK09"
	.incbin "resources/level/level-j.unit"
	.incbin "resources/level/level-j.map.rle"

.segment "BANK0A"
	.incbin "resources/level/level-k.unit"
	.incbin "resources/level/level-k.map.rle"
	
.segment "BANK0B"
	.incbin "resources/level/level-l.unit"
	.incbin "resources/level/level-l.map.rle"
	
.segment "BANK0C"
	.incbin "resources/level/level-m.unit"
	.incbin "resources/level/level-m.map.rle"
	
.segment "BANK0D"
	; .incbin "resources/level/level-n.unit"
	; .incbin "resources/level/level-n.map.rle"
	
.segment "BANK0E"
	; .incbin "resources/level/level-o.unit"
	; .incbin "resources/level/level-o.map.rle"
	
.segment "BANK0F"
	; .incbin "resources/level/level-p.unit"
	; .incbin "resources/level/level-p.map.rle"


MAP_DATA_UNIT_TYPE	= $A000 ; .RES 64 ; Unit type 0=none (64 bytes)
MAP_DATA_UNIT_LOC_X	= $A040 ; .RES 64 ; Unit X location (64 bytes)
MAP_DATA_UNIT_LOC_Y	= $A080 ; .RES 64 ; Unit Y location (64 bytes)
MAP_DATA_UNIT_A		= $A0C0 ; .RES 64 ; Unit attribute A (64 bytes)
MAP_DATA_UNIT_B		= $A100 ; .RES 64 ; Unit attribute B (64 bytes)
MAP_DATA_UNIT_C		= $A140 ; .RES 64 ; Unit attribute C (64 bytes)
MAP_DATA_UNIT_D		= $A180 ; .RES 64 ; Unit attribute D (64 bytes)
MAP_DATA_UNIT_HEALTH	= $A1C0 ; .RES 64 ; Unit health (0 to 11) (64 bytes)
MAP_DATA		= $A200


.segment BANK(BK_MAIN_CODE)
.proc LOAD_MAP
	LDX	SELECTED_MAP
	LDA	MAP_BANKS,X
	MMC3_BANK_SELECT_A  MMC3_PRG_1, SAVED_PRG_1

	LDADDR	PTR_0, MAP_DATA
	LDADDR	PTR_1, MAP
	JSR	DECOMPRESS_RLE_DATA

	; clear data
	LDX	#0
	LDA	#0
:	STA	UNIT_TYPE, X
	STA	UNIT_LOC_X, X
	STA	UNIT_LOC_Y, X
	STA	UNIT_A, X
	STA	UNIT_B, X
	STA	UNIT_C, X
	INX
	CPX	#64
	BNE	:-

	; copy heath
	LDX	#0
:	LDA	MAP_DATA_UNIT_HEALTH, X
	STA	UNIT_HEALTH, X
	INX
	CPX	#28
	BNE	:-

	; map data of all units
	LDX	#0
@LOOP:
	LDA	MAP_DATA_UNIT_TYPE, X
	STA	UNIT_TYPE, X
	LDA	MAP_DATA_UNIT_LOC_X, X
	STA	UNIT_LOC_X, X
	LDA	MAP_DATA_UNIT_LOC_Y, X
	STA	UNIT_LOC_Y, X
	
	; is it an item
	LDA	MAP_DATA_UNIT_TYPE, X
	AND	#128
	BEQ	:+
	JMP	@MAP_TRANSFORM_HIDDEN_ITEM
:	
	LDY	MAP_DATA_UNIT_TYPE, X
	LDA	@MAP_TRANSFORM_MAPPER,Y
	CMP	#0
	BNE	:+
	JMP	@MAP_TRANSFORM_RET
:
	CMP	#1
	BNE	:+
	JMP	@MAP_TRANSFORM_RET
:
	CMP	#2
	BNE	:+
	JMP	@MAP_TRANSFORM_TRANSPORTER
:
	CMP	#3
	BNE	:+
	JMP	@MAP_TRANSFORM_DOOR
:
	CMP	#4
	BNE	:+
	JMP	@MAP_TRANSFORM_ELEVATOR
:
	CMP	#5
	BNE	:+
	JMP	@MAP_TRANSFORM_WATER_RAFT
:
@MAP_TRANSFORM_RET:
	; ...
	INX
	CPX	#64
	BNE	@LOOP

	RTS

@MAP_TRANSFORM_MAPPER:
	.BYTE 0  ;  00: no unit
	.BYTE 1  ;  01: player unit
	.BYTE 1  ;  02: hoverbot lr
	.BYTE 1  ;  03: hoverbot ur
	.BYTE 1  ;  04: hoverbot attack
	.BYTE 1  ;  05: hoverbot water
	.BYTE 0  ;  06: time bomb
	.BYTE 2  ;  07: transporter
	.BYTE 0  ;  08: robot dead
	.BYTE 1  ;  09: evilbot
	.BYTE 3  ;  10: door
	.BYTE 0  ;  11: small explosion
	.BYTE 0  ;  12: pistol fire up
	.BYTE 0  ;  13: pistol fire down
	.BYTE 0  ;  14: pistol fire left
	.BYTE 0  ;  15: pistol fire right
	.BYTE 1  ;  16: trash compactor
	.BYTE 1  ;  17: rollerbot ud
	.BYTE 1  ;  18: rollerbot lr
	.BYTE 4  ;  19: elevator
	.BYTE 0  ;  20: magnet
	.BYTE 0  ;  21: robot magnetized
	.BYTE 5  ;  22: water raft lr
	.BYTE 0  ;  23: transporter dem

@MAP_TRANSFORM_TRANSPORTER:
	;  07: transporter
	; UNIT_A:  0=always active, 1=only active when all robots are dead
	; UNIT_B:  0=completes level, 1=send to coordinates
	; UNIT_C:  X-coordinate
	; UNIT_D:  Y-coordinate
	LDA	MAP_DATA_UNIT_B, X
	ASL
	ORA	MAP_DATA_UNIT_A, X
	STA	UNIT_A, X
	LDA	MAP_DATA_UNIT_C, X
	STA	UNIT_B, X
	LDA	MAP_DATA_UNIT_D, X
	STA	UNIT_C, X
	JMP	@MAP_TRANSFORM_RET

@MAP_TRANSFORM_DOOR:
	;  10: door
	; UNIT_A:  0=horizonal, 1=vertical
	; UNIT_B:  0=opening-A, 1=opening-B, 2=OPEN, 3=closing-A, 4=closing-B, 5-CLOSED
	; UNIT_C:  0=unlocked, 1=locked spade, 2=locked heart, 3=locked star
	; UNIT_D:  unused
	LDA	MAP_DATA_UNIT_A, X
	STA	UNIT_A, X
	LDA	MAP_DATA_UNIT_C, X
	STA	UNIT_C, X
	BNE	:+
	LDA	#4
	STA	UNIT_B, X
	JMP	@MAP_TRANSFORM_RET
:	LDA	MAP_DATA_UNIT_B, X
	STA	UNIT_B, X
	JMP	@MAP_TRANSFORM_RET

@MAP_TRANSFORM_ELEVATOR:
	;  19: elevator
	; UNIT_A:  unused
	; UNIT_B:  0=opening-A, 1=opening-B, 2=OPEN, 3=closing-A, 4=closing-B, 5-CLOSED
	; UNIT_C:  current floor
	; UNIT_D:  max floor
	LDA	MAP_DATA_UNIT_D, X
	STA	UNIT_A, X
	LDA	#4
	STA	UNIT_B, X
	LDA	MAP_DATA_UNIT_C, X
	STA	UNIT_C, X
	JMP	@MAP_TRANSFORM_RET

@MAP_TRANSFORM_WATER_RAFT:
	;  22: water raft lr
	; UNIT_A:  moving direction: 0=left, 1=right
	; UNIT_B:  compare x left
	; UNIT_C:  compare x right
	; UNIT_D:  unused
	LDA	MAP_DATA_UNIT_A, X
	STA	UNIT_A, X
	LDA	MAP_DATA_UNIT_B, X
	STA	UNIT_B, X
	LDA	MAP_DATA_UNIT_C, X
	STA	UNIT_C, X
	JMP	@MAP_TRANSFORM_RET

@MAP_TRANSFORM_HIDDEN_ITEM:
	;  128...: hidden items
	; UNIT_A:  quantity or key type (0=SPADE, 1=HEART, 2=STAR)
	; UNIT_B:  unused
	; UNIT_C:  search width
	; UNIT_D:  search height
	LDA	MAP_DATA_UNIT_A, X
	STA	UNIT_A, X
	LDA	MAP_DATA_UNIT_C, X
	STA	UNIT_B, X
	LDA	MAP_DATA_UNIT_D, X
	STA	UNIT_C, X
	JMP	@MAP_TRANSFORM_RET
.endproc


.proc CALC_MAP_NAME
	; MAP_NAME = MAP_NAMES + SELECTED_MAP*16
	LDA	SELECTED_MAP
	REPEAT  4, ASL
	STA	PTR_0_L
	LDA	#0
	ADC	#0
	STA	PTR_0_H
	ADDI16	PTR_0, MAP_NAMES
	LDY	#0
	RTS
.endproc
