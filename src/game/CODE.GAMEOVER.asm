.segment BANK(BK_GAME_CODE)

.proc GAME_OVER
	PPU_DEEMPHASIZE
	;stop game clock
	CLRB	GAME_FLAG, F_CLOCK_ACTIVE
	;disable music
	JSR	SOUND_SYSTEM_MUSIC_STOP
	
	;Did player die or win?
	LDA	UNIT_TYPE
	BNE	@skip
	LDA	#111	;dead player tile
	STA	UNIT_TILE
	LDA	#100
	STA	GP_TIMER
 @skip:
 @GOM0:	
 	JSR	GAME_NEXT_FRAME
	LDA	GP_TIMER
	BNE	@GOM0

	; return to default palette
	SET_GAME_BG_PALETTE  GAME_BG_PALETTE_NORMAL

	; display "game over"/"you win" message
; 	LDX	#0
;  @GOM1:
; 	LDA	GAMEOVER1,X
; 	STA	SCR_BUFFER+C_SCREEN_WIDTH* 6+11,X
; 	LDA	UNIT_TYPE
; 	BNE	:+
; 	LDA	GAMEOVER2,X
; 	STA	SCR_BUFFER+C_SCREEN_WIDTH* 7+11,X
; 	JMP	:++
;  :	LDA	GAMEOVER3,X
; 	STA	SCR_BUFFER+C_SCREEN_WIDTH* 7+11,X
;  :	LDA	GAMEOVER4,X
; 	STA	SCR_BUFFER+C_SCREEN_WIDTH* 8+11,X
; 	INX
; 	CPX	#11
; 	BNE	@GOM1

	LDX	#0
	LDA	UNIT_TYPE
	BEQ	@GOM_L
	JMP	@GOM_W

@GOM_L:
	LDA	GAMEOVER_L0,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 5+13,X
	LDA	GAMEOVER_L1,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 6+13,X
	LDA	GAMEOVER_L2,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 7+13,X
	LDA	GAMEOVER_L3,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 8+13,X
	INX
	CPX	#6
	BNE	@GOM_L
	JMP	@GOM1
@GOM_W:
	LDA	GAMEOVER_W0,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 5+13,X
	LDA	GAMEOVER_W1,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 6+13,X
	LDA	GAMEOVER_W2,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 7+13,X
	LDA	GAMEOVER_W3,X
	STA	SCR_BUFFER+C_SCREEN_WIDTH* 8+13,X
	INX
	CPX	#6
	BNE	@GOM_W

@GOM1:

	; transfer screen buffer to ppu
	SETB	GAME_FLAG, F_TRANSFER_FIELD

	; JSR	BACKGROUND_TASKS
	WAIT_NMI

	; wait for 100 ticks
	LDA	#100
	STA	GP_TIMER
 @GOM2:	LDA	GP_TIMER
	BNE	@GOM2

	; wait for any key pressed
 GAME_OVER_LOOP:
	WAIT_NMI
	JSR	READ_JOYPAD
	JOYPAD_BR_IF_ANY_NOT_PRESSED  GAME_OVER_LOOP
	JMP	INIT_GAME_END

.endproc

GAMEOVER1:	.BYTE $2E,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$2F ; +---------+
GAMEOVER2:	.BYTE $2D,'g','a','m','e',' ','o','v','e','r',$3D ; |GAME OVER|
GAMEOVER3:	.BYTE $2D,' ','y','o','u',' ','w','i','n',' ',$3D ; | YOU WIN |
GAMEOVER4:	.BYTE $3E,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$3F ; +---------+

GAMEOVER_L0:	.BYTE $2E,$1F,$1F,$1F,$1F,$2F ; +----+
GAMEOVER_L1:	.BYTE $2D,'g','a','m','e',$3D ; |GAME|
GAMEOVER_L2:	.BYTE $2D,'o','v','e','r',$3D ; |OVER|
GAMEOVER_L3:	.BYTE $3E,$1D,$1D,$1D,$1D,$3F ; +----+

GAMEOVER_W0:	.BYTE $2E,$1F,$1F,$1F,$1F,$2F ; +---+
GAMEOVER_W1:	.BYTE $2D,'y','o','u',' ',$3D ; |YOU|
GAMEOVER_W2:	.BYTE $2D,' ','w','i','n',$3D ; |WIN|
GAMEOVER_W3:	.BYTE $3E,$1D,$1D,$1D,$1D,$3F ; +---+
