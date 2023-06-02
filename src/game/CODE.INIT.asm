
.segment BANK(BK_GAME_CODE)

.proc INIT_GAME_VARS
	LDA	#$00
	STA	KEYS
	STA	AMMO_PISTOL
	STA	AMMO_PLASMA
	STA	INV_BOMBS
	STA	INV_EMP
	STA	INV_MEDKIT
	STA	INV_MAGNET
	STA	SELECTED_WEAPON
	STA	SELECTED_ITEM
	STA	MAGNET_ACT
	STA	PLASMA_ACT
	STA	BIG_EXP_ACT
	RTS
.endproc


;TEMP ROUTINE TO GIVE ME ALL ITEMS AND WEAPONS
.proc INIT_CHEATER
	LDA	#1
	STA	UNIT_TYPE	;revive player
	LDA	#12
	STA	UNIT_HEALTH	;give player max health
	LDA	#%00000111
	STA	KEYS
	LDA	#$FF
	STA	AMMO_PISTOL
	STA	AMMO_PLASMA
	STA	INV_BOMBS
	STA	INV_EMP
	STA	INV_MEDKIT
	STA	INV_MAGNET
	LDA	#1
	STA	SELECTED_WEAPON
	STA	SELECTED_ITEM
	JSR	DISPLAY_PLAYER_HEALTH
	JSR	DISPLAY_KEYS
	JSR	DISPLAY_WEAPON
	JSR	DISPLAY_ITEM
	RTS
.endproc

.proc INIT_CLOCK
	SETB	GAME_FLAG, F_CLOCK_ACTIVE
	LDA	#0
	STA	CYCLES
	STA	SECONDS
	STA	MINUTES
	STA	HOURS
	RTS
.endproc

;This routine spaces out the timers so that not everything
;is running out once.
.proc INIT_UNIT_TIMERS
	LDX	#01
@SIT1:	TXA
	STA	UNIT_TIMER_A,X
	LDA	#0
	STA	UNIT_TIMER_B,X
	INX
	CPX	#48
	BNE	@SIT1
	RTS
.endproc


;This routine is run after the map is loaded, but before the
;game starts.  If the diffulcty is set to normal, nothing
;actually happens.  But if it is set to easy or hard, then
;some changes occur accordingly.
.proc INIT_DIFF_LEVEL
	LDA	DIFF_LEVEL
	CMP	#0	;easy
	BNE	@SDLE1
	JMP	SET_DIFF_EASY
@SDLE1:	CMP	#2	;hard
	BNE	@SDLE2
	JMP	SET_DIFF_HARD
@SDLE2:	RTS

SET_DIFF_EASY:
	;Find all hidden items and double the quantity.
	LDX	#48
@SDE1:	LDA	UNIT_TYPE,X
	CMP	#0
	BEQ	@SDE2
	CMP	#128	;KEY
	BEQ	@SDE2
	ASL	UNIT_A,X	;item qty
@SDE2:	INX
	CPX	#64
	BNE	@SDE1
	RTS

SET_DIFF_HARD:
	;Find all hoverbots and change AI
	LDX	#0
@SDH1:	LDA	UNIT_TYPE,X
	CMP	#2	;hoverbot left/right
	BEQ	@SDH4
	CMP	#3	;hoverbot up/down
	BEQ	@SDH4
@SDH2:	INX
	CPX	#28
	BNE	@SDH1
	RTS
@SDH4:	LDA	#4	;hoverbot attack mode
	STA	UNIT_TYPE,X
	JMP	@SDH2
.endproc
