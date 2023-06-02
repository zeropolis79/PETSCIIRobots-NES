.pushseg
.segment "ZP1"
MP_VIZ_BUFFER:  .RES 32*5 ; buffer for the bars
MP_SONG_BUFFER: .RES 16   ; name of the song
MP_LINE_BUFFER: .RES 32   ; next credit line
MP_LINE_PAL:    .RES 1    ; palette of the next line
MP_LINE_Y:      .RES 1    ; y coord of the next line
SELECTED_SONG:  .RES 1    ; currently selected song
MP_WAIT_FRAMES: .RES 1    ; timer to pause scrolling
MP_C_SCROLL:    .RES 1    ; counter to slow down y scroll
MP_Y_SCROLL:    .RES 1    ; y scroll counter
MP_P_SCROLL:    .RES 1    ; page counter (1 P = 240 Y)

.segment "WRAM1"
MP_FRAME_BUFFER: .RES 32
.popseg

.include "DATA.asm"
.include "IRQ.asm"
.include "NMI.asm"
.include "NOTE_INDEX.asm"

.segment BANK(BK_MAIN_CODE)

.proc INIT_MUSICPLAYER
	WAIT_NMI
	PPU_DISABLE

	SEI	; disable IRQs
	SET_IRQ_ROUTINE  DUMMY_ROUTINE
	SET_NMI_ROUTINE  DUMMY_ROUTINE
	WAIT_NMI

	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_GENERAL, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, #BK_CREDITS, SAVED_PRG_1

	JMP	ENTRY_MUSICPLAYER
.endproc


.segment BANK(BK_CREDITS)

.proc ENTRY_MUSICPLAYER
	BIT	PPUSTATUS

	PPU_LOAD_BG_PALETTE   MUSICPLAYER_BG_PALETTE_DATA
	PPU_LOAD_SPR_PALETTE  MUSICPLAYER_SPR_PALETTE_DATA

	MMC3_BANK_SELECT  MMC3_CHR_0, #TS_CREDITS+0
	MMC3_BANK_SELECT  MMC3_CHR_1, #TS_CREDITS+2
	MMC3_BANK_SELECT  MMC3_CHR_2, #TS_INTRO_SPRITES+0
	MMC3_BANK_SELECT  MMC3_CHR_3, #TS_INTRO_SPRITES+1
	MMC3_BANK_SELECT  MMC3_CHR_4, #TS_INTRO_SPRITES+2
	MMC3_BANK_SELECT  MMC3_CHR_5, #TS_INTRO_SPRITES+3

	OAM_HIDE_ALL_SPRITE

	LDX	#0
	LDA	#0
@loop:	STA	MP_FRAME_BUFFER,X
	INX
	CPX	#64
	BNE	@loop

	JSR	DISPLAY_MUSICPLAYER

	LDA	#100
	STA	MP_WAIT_FRAMES
	LDA	#0
	STA	MP_C_SCROLL
	STA	MP_Y_SCROLL
	STA	MP_P_SCROLL

	JSR	MP_UPDATE

	SET_NMI_ROUTINE  NMI_MUSICPLAYER
	WAIT_NMI
	PPU_DISABLE
	
	SET_IRQ_ROUTINE  IRQ_MUSICPLAYER
	MMC3_IRQ_DISABLE
	CLI
	
	WAIT_FRAMES  30, MP_UPDATE
.endproc


.proc MUSICPLAYER_LOOP
	WAIT_NMI

	JSR	MP_UPDATE

	JSR	READ_JOYPAD
	JOYPAD_BR_IF_R_NOT_PRESSED :+
	JMP	MP_EXEC_COMMAND_NEXT
:
	JOYPAD_BR_IF_L_NOT_PRESSED :+
	JMP	MP_EXEC_COMMAND_PREV
:
	JOYPAD_BR_IF_START_NOT_PRESSED :+
	JMP	MP_EXEC_COMMAND_START
:
	JOYPAD_BR_IF_SELECT_NOT_HELD :+
	JMP	MP_EXEC_COMMAND_SELECT
:
	JMP	MUSICPLAYER_LOOP
.endproc



.proc MP_EXEC_COMMAND_START
	JMP	INIT_INTRO_
.endproc

.proc MP_EXEC_COMMAND_SELECT
	JSR	SOUND_SYSTEM_UPDATE
	; JSR	SOUND_SYSTEM_UPDATE
	; JSR	SOUND_SYSTEM_UPDATE
	JMP	MUSICPLAYER_LOOP
.endproc


.proc MP_EXEC_COMMAND_NEXT
	INC	SELECTED_SONG
	LDA	SELECTED_SONG
	CMP	#5	;if max
	BNE	@skip
	LDA	#0
	STA	SELECTED_SONG
@skip:	
	JMP	MP_PLAY_SELECTED_SONG
.endproc

.proc MP_EXEC_COMMAND_PREV
	DEC	SELECTED_SONG
	LDA	SELECTED_SONG
	CMP	#$FF	;if overflowed
	BNE	@skip
	LDA	#4
	STA	SELECTED_SONG
@skip:
	JMP	MP_PLAY_SELECTED_SONG
.endproc

.proc MP_PLAY_SELECTED_SONG
	LDA	SELECTED_SONG
	CMP	#0
	BNE	:+
	JSR	SOUND_SYSTEM_MUSIC_PLAY__INTRO
	JMP	MUSICPLAYER_LOOP
:
	CMP	#1
	BNE	:+
	JSR	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_0
	JMP	MUSICPLAYER_LOOP
:
	CMP	#2
	BNE	:+
	JSR	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_1
	JMP	MUSICPLAYER_LOOP
:
	CMP	#3
	BNE	:+
	JSR	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_2
	JMP	MUSICPLAYER_LOOP
:
	CMP	#4
	BNE	:+
	JSR	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_3
	JMP	MUSICPLAYER_LOOP
:
	JMP	MUSICPLAYER_LOOP
.endproc



.macro MP_NOTE_AND_VOLUME  reg_l, reg_h, reg_h_mask, idx_off, idx_div, reg_vol, reg_vol_mask, vol_off, vol_div
	LDA	reg_l
	STA	NOTE_L
	LDA	reg_h
	AND	#reg_h_mask
	STA	NOTE_H
	JSR	MAP_TIMER_TO_INDEX
	.if idx_off <> 0
	CLC
	ADC	#idx_off
	.endif
	.repeat idx_div
	LSR
	.endrepeat
	TAY
	LDA	reg_vol
	AND	#reg_vol_mask
	.if vol_off <> 0
	CLC
	ADC	#vol_off
	.endif
	.repeat vol_div
	LSR
	.endrepeat
.endmacro

.macro MP_NOTE_AND_VOLUME_PULSE  idx, idx_off, idx_div, vol_off, vol_div
.if idx=1
	MP_NOTE_AND_VOLUME  FAMISTUDIO_ALIAS_PL1_LO, FAMISTUDIO_ALIAS_PL1_HI, $07, idx_off, idx_div, FAMISTUDIO_ALIAS_PL1_VOL, $0F, vol_off, vol_div
.else
	MP_NOTE_AND_VOLUME  FAMISTUDIO_ALIAS_PL2_LO, FAMISTUDIO_ALIAS_PL2_HI, $07, idx_off, idx_div, FAMISTUDIO_ALIAS_PL2_VOL, $0F, vol_off, vol_div
.endif
.endmacro

.macro MP_NOTE_AND_VOLUME_TRI  idx_off, idx_div, vol_off, vol_div
	MP_NOTE_AND_VOLUME  FAMISTUDIO_ALIAS_TRI_LO, FAMISTUDIO_ALIAS_TRI_HI, $07, idx_off, idx_div, FAMISTUDIO_ALIAS_TRI_LINEAR, $7F, vol_off, vol_div
.endmacro

.macro MP_NOTE_AND_VOLUME_NOISE  idx_map, vol_map
	lda	FAMISTUDIO_ALIAS_NOISE_LO
	AND	#$0F
	EOR	#$0F
	TAX
	LDA	idx_map,X
	CLC
	ADC	#32-8
	TAY
	LDA	FAMISTUDIO_ALIAS_NOISE_VOL
	AND	#$0f
	TAX
	LDA	vol_map,X
.endmacro


.proc MP_UPDATE
	JSR	UPDATE_AUDIOVIZ
	JMP	MP_PRELOAD_CREDIT_ROW
.endproc

.proc UPDATE_AUDIOVIZ

	LDX	#0
@loop:	LDA	MP_FRAME_BUFFER,X
	BEQ	:+
	DEC	MP_FRAME_BUFFER,X
:	INX
	CPX	#64
	BNE	@loop


	MP_NOTE_AND_VOLUME_PULSE 1,  32, 2,  0, 0
	ASL		; times 2
	CMP	MP_FRAME_BUFFER,Y	; calc max
	BLT	:+
	STA	MP_FRAME_BUFFER,Y
:
	MP_NOTE_AND_VOLUME_PULSE 2,  32, 2,  0, 0
	ASL		; times 2
	CMP	MP_FRAME_BUFFER,Y	; calc max
	BLT	:+
	STA	MP_FRAME_BUFFER,Y
:
	MP_NOTE_AND_VOLUME_TRI        4, 2,  0, 1
	ASL		; times 2
	CMP	MP_FRAME_BUFFER,Y	; calc max
	BLT	:+
	STA	MP_FRAME_BUFFER,Y
:
	MP_NOTE_AND_VOLUME_NOISE  @NOISE_IDX_MAP, @NOISE_VOL_MAP
	CMP	MP_FRAME_BUFFER,Y	; calc max
	BLT	:+
	STA	MP_FRAME_BUFFER,Y
:


	JMP	@after_data
		@NOISE_IDX_MAP:
			.byte	0, 1, 1, 1
			.byte	2, 2, 2, 3
			.byte	3, 3, 4, 4
			.byte	4, 5, 5, 5

		@NOISE_VOL_MAP:
			.byte	 0,  4,  6,  8
			.byte	10, 12, 14, 15
			.byte	15, 15, 15, 15
			.byte	15, 15, 15, 15

		@VIZ_COL:
			.byte	$F9,$20,$20,$20,$20,$20,$20,$20
			.byte	$FA,$20,$20,$20,$20,$20,$20,$20
			.byte	$FB,$20,$20,$20,$20,$20,$20,$20
			.byte	$FB,$FC,$20,$20,$20,$20,$20,$20
			.byte	$FB,$FD,$20,$20,$20,$20,$20,$20
			.byte	$FB,$FE,$20,$20,$20,$20,$20,$20
			.byte	$FB,$FF,$20,$20,$20,$20,$20,$20
			.byte	$FB,$FF,$FC,$20,$20,$20,$20,$20
			.byte	$FB,$FF,$FD,$20,$20,$20,$20,$20
			.byte	$FB,$FF,$FE,$20,$20,$20,$20,$20
			.byte	$FB,$FF,$FF,$20,$20,$20,$20,$20
			.byte	$FB,$FF,$FF,$FC,$20,$20,$20,$20
			.byte	$FB,$FF,$FF,$FD,$20,$20,$20,$20
			.byte	$FB,$FF,$FF,$FE,$20,$20,$20,$20
			.byte	$FB,$FF,$FF,$FF,$20,$20,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FC,$20,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FD,$20,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FE,$20,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$20,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FC,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FD,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FE,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$20,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FC,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FD,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FE,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FF,$20
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FC
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FD
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FE
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FF
			.byte	$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	@after_data:

	LDX	#0
	@loop2:
		LDA	MP_FRAME_BUFFER,X
		REPEAT	3, ASL
		TAY
		.repeat 5,I
		LDA	@VIZ_COL+I,Y
		STA	MP_VIZ_BUFFER + $20*I,X
		.endrepeat
		INX
		CPX	#32
		BEQ	@loop2_end
		JMP	@loop2
	@loop2_end:


	LDADDR	PTR_0, SONG_NAMES
	LDA	SELECTED_SONG
	ASL
	ASL
	ASL
	ASL
	ADD16_A	PTR_0
	LDY	#0
	@loop4:
		LDA	(PTR_0),Y
		STA	MP_SONG_BUFFER,Y
		INY
		CPY	#16
		BNE	@loop4
	@loop4_end:

	RTS
.endproc


.proc MP_PRELOAD_CREDIT_ROW
	; calculate current row at the top
	LDA	MP_Y_SCROLL
	LSR
	LSR
	LSR
	LDX	MP_P_SCROLL
	BEQ	@skip_add
	CLC
	ADC	#30
@skip_add:
	TAY
	; store the ppu row that has to be updated
	LDA	MUSICPLAYER_ROW_TARGET_Y,Y
	STA	MP_LINE_Y
	
	; store the palette for the row
	LDA	MUSICPLAYER_ROW_LOAD,Y
	LSR
	TAX
	LDA	MUSICPLAYER_PALETTE_DATA,X
	STA	MP_LINE_PAL

	; copy the data for the row to the buffer
	LDA	#0
	STA	PTR_0_L
	LDA	MUSICPLAYER_ROW_LOAD,Y
	STA	PTR_0_H
	.repeat 3
	LSR	PTR_0_H
	ROR	PTR_0_L
	.endrepeat
	ADDI16	PTR_0, MUSICPLAYER_SCREEN_DATA

	LDY	#0
	@loop:	
		LDA	(PTR_0),Y
		STA	MP_LINE_BUFFER,Y
		INY
		CPY	#32
		BNE	@loop
	@loop_end:

	RTS
.endproc


.proc DISPLAY_MUSICPLAYER
	BIT	PPUSTATUS
	PPU_WRITE_NT  0, MUSICPLAYER_SCREEN_DATA
	PPU_FILL_NT   1, ' ', $00
	
	PPU_LOAD_ADDR_XY  1, 2, 0
	LDA	#$F9
	.repeat 28
	STA	PPUDATA
	.endrepeat

	PPU_LOAD_ADDR_XY  1, 3, 1
	LDA	#$3F
	STA	PPUDATA
	
	PPU_LOAD_ADDR_XY  1, 28, 1
	LDA	#$3E
	STA	PPUDATA
	
	PPU_LOAD_ADDR_XY  0, 0, 30
	.repeat 8,I
	LDA	MUSICPLAYER_PALETTE_DATA+I*2
	.repeat 8,J
	STA	PPUDATA
	.endrepeat
	.endrepeat

	RTS
.endproc

