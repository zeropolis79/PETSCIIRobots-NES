.segment "RAM"
MAP_TEMP:	.RES 1
MAP_MODE:	.RES 1

.segment BANK(BK_GAME_CODE)
.proc SHOW_GAME_MAP
	PPU_DISABLE
	; reset any palette changes
	SET_GAME_BG_PALETTE  GAME_BG_PALETTE_NORMAL
	
	; hide the player and the helper icons
	JSR	HIDE_HELPER_ICONS
	JSR	HIDE_PLAYER
	; display message to user
	JSR	CLEAR_INFO
	LDADDR	PTR_0, MSG_MAP_VIEW
	JSR	PRINT_INFO
	; play click sound
	LDA	#15
	JSR	SOUND_SYSTEM_SFX_PLAY

	; set show map flag
	SETB	GAME_FLAG, F_SHOW_MAP
	WAIT_NMI

	; wait for 1 bg update
	; to prevent double-tap of run/stop
	; and to let the info update
; 	LDA	#1
; 	STA	BG_TIMER
;  @wait:	LDA	BG_TIMER
; 	BNE	@wait
	WAIT_NMI

	; prepare sprites
	JSR	SHOW_GAME_MAP__PREPARE_SPRITES
	LDA	#$00
	STA	MAP_TEMP
	LDA	#1
	STA	MAP_MODE


	; main loop
 @loop:	
	JSR	GAME_NEXT_FRAME
	JSR	READ_JOYPAD
	LDA	UNIT_TYPE
	CMP	#1	;Is player unit alive
	BEQ	:+
	; clear show map flag
	CLRB	GAME_FLAG, F_SHOW_MAP
	JMP	GAME_OVER
 :
	JOYPAD_BR_IF_START_PRESSED  @swap
	JOYPAD_BR_IF_ANY_NOT_PRESSED  @skip
	JMP	@end
@swap:
	LDA	MAP_MODE
	EOR	#1
	STA	MAP_MODE
	JSR	SHOW_GAME_MAP__HIDE_ALL
@skip:
	JSR	SHOW_GAME_MAP__PLAYER

	LDA	MAP_MODE
	BNE	@loop
	JSR	SHOW_GAME_MAP__ENEMIES
	JMP	@loop
 @end:
	; PLA

	; hide sprites
	JSR	SHOW_GAME_MAP__HIDE_ALL

	; update info field
	JSR	CLEAR_INFO
	; play click sound
	LDA	#15
	JSR	SOUND_SYSTEM_SFX_PLAY
	; show player
	JSR	INIT_PLAYER
	JSR	ANIMATE_PLAYER
	; clear show map flag
	CLRB	GAME_FLAG, F_SHOW_MAP
	; back to the game
	LDA	#20
	STA	KEY_TIMER
	JMP	MAIN_GAME_LOOP
.endproc




.proc SHOW_GAME_MAP__PREPARE_SPRITES
	LDA	#SPR_INDEX_DOT
	.repeat 16, I
	OAM_SET_SPRITE_TILE_A  {($30+I)}
	.endrepeat
	LDA	#SPR_ATTR_PAL_2
	.repeat 16, I
	OAM_SET_SPRITE_ATTR_A  {($30+I)}
	.endrepeat
	RTS
.endproc


.proc SHOW_GAME_MAP__HIDE_ALL
	LDA	#$FF
	.repeat 9, I
	OAM_SET_SPRITE_Y_A  {($37+I)}
	.endrepeat
	RTS
.endproc


.proc SHOW_GAME_MAP__PLAYER
	LDA	COUNTER
	AND	#63
	CMP	#32
	BGE	@dont_hide_player
	LDA	#$FF
	OAM_SET_SPRITE_Y_A  {($37)}
	RTS

@dont_hide_player:
	LDA	UNIT_LOC_X
	CLC
	ADC	#64
	OAM_SET_SPRITE_X_A  {($37)}
	LDA	UNIT_LOC_Y
	CLC
	ADC	#63
	OAM_SET_SPRITE_Y_A  {($37)}
	RTS
.endproc


.proc SHOW_GAME_MAP__ENEMIES

	; are any units alive?
	LDX	#1
@any_alive_loop:
	LDA	UNIT_TYPE,X
	BNE	@any_alive
	; skip the unit and try again
	INX
	CPX	#28
	BNE	@any_alive_loop
	RTS

@any_alive:

	LDX	MAP_TEMP

	.repeat 8, I
	:
		LDA	UNIT_TYPE,X
		BNE	:++		; is unit alive?
		; skip the unit and try again
		INX
		CPX	#28
		BNE	:+
		LDX	#1
	:	JMP	:--
		; unit is alive
	:	LDA	COUNTER
		AND	#$07
		CMP	#4
		BLT	:+
		LDA	#$FF
		OAM_SET_SPRITE_Y_A  {($38+I)}
		JMP	:++
	:
		LDA	UNIT_LOC_X,X
		CLC
		ADC	#64
		OAM_SET_SPRITE_X_A  {($38+I)}
		LDA	UNIT_LOC_Y,X
		CLC
		ADC	#63
		OAM_SET_SPRITE_Y_A  {($38+I)}
	:	INX
		CPX	#28
		BNE	:+
		LDX	#1
	:
	.endrepeat
	
	STX	MAP_TEMP
	
	RTS
.endproc
