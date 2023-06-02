; SNES_BUTTON_B      = $8000 ; action down + cancel
; SNES_BUTTON_Y      = $4000 ; action left
; SNES_BUTTON_SELECT = $2000 ; select
; SNES_BUTTON_START  = $1000 ; start
; SNES_BUTTON_UP     = $0800 ; up
; SNES_BUTTON_DOWN   = $0400 ; down
; SNES_BUTTON_LEFT   = $0200 ; left
; SNES_BUTTON_RIGHT  = $0100 ; right
; SNES_BUTTON_A      = $0080 ; action right + confirm
; SNES_BUTTON_X      = $0040 ; action up
; SNES_BUTTON_L      = $0020 ; shoulder left
; SNES_BUTTON_R      = $0010 ; shoulder right
; SNES_BUTTON_ID     = $0008
; SNES_BUTTON_ID     = $0004
; SNES_BUTTON_ID     = $0002
; SNES_BUTTON_ID     = $0001

; NES1_BUTTON_A      = $8000 ; action down + cancel
; NES1_BUTTON_B      = $4000 ; action left
; NES1_BUTTON_SELECT = $2000 ; select
; NES1_BUTTON_START  = $1000 ; start
; NES1_BUTTON_UP     = $0800 ; up
; NES1_BUTTON_DOWN   = $0400 ; down
; NES1_BUTTON_LEFT   = $0200 ; left
; NES1_BUTTON_RIGHT  = $0100 ; right
; NES2_BUTTON_A      = $0080 ; action right + confirm
; NES2_BUTTON_B      = $0040 ; action up
; NES2_BUTTON_SELECT = $0020 ; shoulder left
; NES2_BUTTON_START  = $0010 ; shoulder right
; NES2_BUTTON_UP     = $0008
; NES2_BUTTON_DOWN   = $0004
; NES2_BUTTON_LEFT   = $0002
; NES2_BUTTON_RIGHT  = $0001


JOYPAD_NES	= $00
JOYPAD_SNES	= $01
JOYPAD_UNKNOWN	= $02

.segment BANK(BK_MAIN_CODE)
.proc DETECT_JOYPAD
	; Strobe controller
	LDA	#1
	STA	JOY1
	LDA	#0
	STA	JOY1

	; Fetch first byte
	LDA	#1
	STA	JOYPAD_HELD+1
	LDA	#0
 :
	LDA	JOY1
	AND	#$03
	CMP	#$01
	ROL	JOYPAD_HELD+1
	BCC	:-
	
	; Fetch second byte
	LDA	#1
	STA	JOYPAD_HELD+1
	LDA	#0
 :
	LDA	JOY1
	AND	#$03
	CMP	#$01
	ROL	JOYPAD_HELD+1
	BCC	:-

	; Fetch third byte
	LDA	#1
	STA	JOYPAD_HELD+0
	LDA	#0
 :
	LDA	JOY1
	AND	#$03
	CMP	#$01
	ROL	JOYPAD_HELD+0
	BCC	:-

	; we only care for 2nd and 3rd byte
	; if 3rd byte is $00 then there is no controller connected
	; if 3rd byte is $FF then there is a controller connected
	; otherwise its an invalid input
	; if 2nd byte is $FF then its an NES controller
	; if 2nd byte is $x0 then its an SNES controller
	; otherwise its an invalid input
	LDA	JOYPAD_HELD+0
	CMP	#$FF
	BEQ	:+
	LDA	#JOYPAD_UNKNOWN
		RTS
:
	LDA	JOYPAD_HELD+1
	CMP	#$FF
	BNE	:+
	LDA	#JOYPAD_NES
		RTS
:
	AND	#$0F
	CMP	#$00
	BNE	:+
	LDA	#JOYPAD_SNES
		RTS
:
	LDA	#JOYPAD_UNKNOWN
		RTS
.endproc


.proc READ_JOYPAD_RAW
	; Strobe controller
	LDA	#1
	STA	JOY1
	STA	JOYPAD_HELD+1
	LSR		; = lda #0
	STA	JOY1
 :
	LDA	JOY1
	AND	#$03
	CMP	#$01
	ROL	JOYPAD_HELD+1
	BCC	:-

	LDA	#1
	STA	JOYPAD_HELD+0
	LSR		; = lda #0
 :
	LDA	JOY1
	AND	#$03
	CMP	#$01
	ROL	JOYPAD_HELD+0
	BCC	:-

	RTS
.endproc

.proc READ_JOYPAD
	; Back up previous ones for edge comparisons
	LDA	JOYPAD_HELD+0
	STA	JOYPAD_PRESSED+0
	LDA	JOYPAD_HELD+1
	STA	JOYPAD_PRESSED+1

	JSR	READ_JOYPAD_RAW
@reread:
	LDX	JOYPAD_HELD+0
	LDY	JOYPAD_HELD+1
	JSR	READ_JOYPAD_RAW
	CPX	JOYPAD_HELD+0
	BNE	@reread
	CPY	JOYPAD_HELD+1
	BNE	@reread

	;
	LDA	JOYPAD_HELD+0
	EOR	JOYPAD_PRESSED+0
	AND	JOYPAD_HELD+0
	STA	JOYPAD_PRESSED+0
	
	LDA	JOYPAD_HELD+1
	EOR	JOYPAD_PRESSED+1
	AND	JOYPAD_HELD+1
	STA	JOYPAD_PRESSED+1

	RTS
.endproc

; NES_BUTTON_UP     = SNES_BUTTON_UP     = $08, 1
; NES_BUTTON_DOWN   = SNES_BUTTON_DOWN   = $04, 1
; NES_BUTTON_LEFT   = SNES_BUTTON_LEFT   = $02, 1
; NES_BUTTON_RIGHT  = SNES_BUTTON_RIGHT  = $01, 1
; NES_BUTTON_SELECT = SNES_BUTTON_SELECT = $20, 1
; NES_BUTTON_START  = SNES_BUTTON_START  = $10, 1

.define JOYPAD_BR_IF_U_HELD(label)			JOYPAD_BR_IF_HELD 	   $08, label, 1
.define JOYPAD_BR_IF_U_NOT_HELD(label)			JOYPAD_BR_IF_NOT_HELD 	   $08, label, 1
.define JOYPAD_BR_IF_U_PRESSED(label)			JOYPAD_BR_IF_PRESSED 	   $08, label, 1
.define JOYPAD_BR_IF_U_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $08, label, 1
.define JOYPAD_BR_IF_D_HELD(label)			JOYPAD_BR_IF_HELD 	   $04, label, 1
.define JOYPAD_BR_IF_D_NOT_HELD(label)			JOYPAD_BR_IF_NOT_HELD 	   $04, label, 1
.define JOYPAD_BR_IF_D_PRESSED(label)			JOYPAD_BR_IF_PRESSED 	   $04, label, 1
.define JOYPAD_BR_IF_D_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $04, label, 1
.define JOYPAD_BR_IF_L_HELD(label)			JOYPAD_BR_IF_HELD 	   $02, label, 1
.define JOYPAD_BR_IF_L_NOT_HELD(label)			JOYPAD_BR_IF_NOT_HELD 	   $02, label, 1
.define JOYPAD_BR_IF_L_PRESSED(label)			JOYPAD_BR_IF_PRESSED 	   $02, label, 1
.define JOYPAD_BR_IF_L_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $02, label, 1
.define JOYPAD_BR_IF_R_HELD(label)			JOYPAD_BR_IF_HELD 	   $01, label, 1
.define JOYPAD_BR_IF_R_NOT_HELD(label)			JOYPAD_BR_IF_NOT_HELD 	   $01, label, 1
.define JOYPAD_BR_IF_R_PRESSED(label)			JOYPAD_BR_IF_PRESSED 	   $01, label, 1
.define JOYPAD_BR_IF_R_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $01, label, 1
.define JOYPAD_BR_IF_START_HELD(label)			JOYPAD_BR_IF_HELD	   $10, label, 1
.define JOYPAD_BR_IF_START_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $10, label, 1
.define JOYPAD_BR_IF_START_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $10, label, 1
.define JOYPAD_BR_IF_START_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $10, label, 1
.define JOYPAD_BR_IF_SELECT_HELD(label)			JOYPAD_BR_IF_HELD	   $20, label, 1
.define JOYPAD_BR_IF_SELECT_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $20, label, 1
.define JOYPAD_BR_IF_SELECT_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $20, label, 1
.define JOYPAD_BR_IF_SELECT_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $20, label, 1


; NES_BUTTON_A      = SNES_BUTTON_B      = $80, 1
; NES_BUTTON_B      = SNES_BUTTON_Y      = $40, 1
;                   = SNES_BUTTON_A      = $80, 0
;                   = SNES_BUTTON_X      = $40, 0
;                   = SNES_BUTTON_L      = $20, 0
;                   = SNES_BUTTON_R      = $10, 0


.define JOYPAD_BR_IF_NES_A_HELD(label)			JOYPAD_BR_IF_HELD	   $80, label, 1
.define JOYPAD_BR_IF_NES_A_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $80, label, 1
.define JOYPAD_BR_IF_NES_A_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $80, label, 1
.define JOYPAD_BR_IF_NES_A_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $80, label, 1
.define JOYPAD_BR_IF_NES_B_HELD(label)			JOYPAD_BR_IF_HELD	   $40, label, 1
.define JOYPAD_BR_IF_NES_B_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $40, label, 1
.define JOYPAD_BR_IF_NES_B_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $40, label, 1
.define JOYPAD_BR_IF_NES_B_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $40, label, 1


.define JOYPAD_BR_IF_SNES_B_HELD(label)			JOYPAD_BR_IF_HELD	   $80, label, 1
.define JOYPAD_BR_IF_SNES_B_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $80, label, 1
.define JOYPAD_BR_IF_SNES_B_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $80, label, 1
.define JOYPAD_BR_IF_SNES_B_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $80, label, 1
.define JOYPAD_BR_IF_SNES_Y_HELD(label)			JOYPAD_BR_IF_HELD	   $40, label, 1
.define JOYPAD_BR_IF_SNES_Y_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $40, label, 1
.define JOYPAD_BR_IF_SNES_Y_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $40, label, 1
.define JOYPAD_BR_IF_SNES_Y_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $40, label, 1
.define JOYPAD_BR_IF_SNES_A_HELD(label)			JOYPAD_BR_IF_HELD	   $80, label, 0
.define JOYPAD_BR_IF_SNES_A_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $80, label, 0
.define JOYPAD_BR_IF_SNES_A_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $80, label, 0
.define JOYPAD_BR_IF_SNES_A_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $80, label, 0
.define JOYPAD_BR_IF_SNES_X_HELD(label)			JOYPAD_BR_IF_HELD	   $40, label, 0
.define JOYPAD_BR_IF_SNES_X_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $40, label, 0
.define JOYPAD_BR_IF_SNES_X_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $40, label, 0
.define JOYPAD_BR_IF_SNES_X_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $40, label, 0

.define JOYPAD_BR_IF_SNES_L_HELD(label)			JOYPAD_BR_IF_HELD	   $20, label, 0
.define JOYPAD_BR_IF_SNES_L_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $20, label, 0
.define JOYPAD_BR_IF_SNES_L_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $20, label, 0
.define JOYPAD_BR_IF_SNES_L_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $20, label, 0
.define JOYPAD_BR_IF_SNES_R_HELD(label)			JOYPAD_BR_IF_HELD	   $10, label, 0
.define JOYPAD_BR_IF_SNES_R_NOT_HELD(label)		JOYPAD_BR_IF_NOT_HELD	   $10, label, 0
.define JOYPAD_BR_IF_SNES_R_PRESSED(label)		JOYPAD_BR_IF_PRESSED	   $10, label, 0
.define JOYPAD_BR_IF_SNES_R_NOT_PRESSED(label)		JOYPAD_BR_IF_NOT_PRESSED   $10, label, 0


.macro JOYPAD_BR_IF_NOT_HELD button, label, offset
	LDA	JOYPAD_HELD+offset
	AND	#button
	BEQ	label
.endmacro

.macro JOYPAD_BR_IF_HELD button, label, offset
	LDA	JOYPAD_HELD+offset
	AND	#button
	BNE	label
.endmacro

.macro JOYPAD_BR_IF_NOT_PRESSED button, label, offset
	LDA	JOYPAD_PRESSED+offset
	AND	#button
	BEQ	label
.endmacro

.macro JOYPAD_BR_IF_PRESSED button, label, offset
	LDA	JOYPAD_PRESSED+offset
	AND	#button
	BNE	label
.endmacro



.macro JOYPAD_BR_IF_ANY_HELD label
	LDA	JOYPAD_HELD+0
	ORA	JOYPAD_HELD+1
	BNE	label
.endmacro

.macro JOYPAD_BR_IF_ANY_NOT_HELD label
	LDA	JOYPAD_HELD+0
	ORA	JOYPAD_HELD+1
	BEQ	label
.endmacro

.macro JOYPAD_BR_IF_ANY_PRESSED label
	LDA	JOYPAD_PRESSED+0
	ORA	JOYPAD_PRESSED+1
	BNE	label
.endmacro

.macro JOYPAD_BR_IF_ANY_NOT_PRESSED label
	LDA	JOYPAD_PRESSED+0
	ORA	JOYPAD_PRESSED+1
	BEQ	label
.endmacro


; NES_A  -> btn: $80, off: 1
; SNES_A -> btn: $80, off: 0

.macro _JOYPAD_GET_A  reg
	.local @nes
	.local @snes
	.local @skip
	LDA	JOYPAD_TYPE
	CMP	#JOYPAD_SNES
	BEQ	@snes
@nes:	LDA	reg+1
	JMP	@skip
@snes:	LDA	reg+0
@skip:	AND	#$80
.endmacro

.macro JOYPAD_BR_IF_A_NOT_HELD  label
	_JOYPAD_GET_A  JOYPAD_HELD
	BEQ	label
.endmacro

.macro JOYPAD_BR_IF_A_HELD  label
	_JOYPAD_GET_A  JOYPAD_HELD
	BNE	label
.endmacro

.macro JOYPAD_BR_IF_A_NOT_PRESSED  label
	_JOYPAD_GET_A  JOYPAD_PRESSED
	BEQ	label
.endmacro

.macro JOYPAD_BR_IF_A_PRESSED  label
	_JOYPAD_GET_A  JOYPAD_PRESSED
	BNE	label
.endmacro


; NES_B  -> btn: $40, off: 1
; SNES_B -> btn: $80, off: 1
.macro _JOYPAD_GET_B  reg
	.local @nes
	.local @snes
	.local @skip
	LDA	JOYPAD_TYPE
	CMP	#JOYPAD_SNES
	BEQ	@snes
@nes:	LDA	#$40
	JMP	@skip
@snes:	LDA	#$80
@skip:	AND	reg+1
.endmacro

.macro JOYPAD_BR_IF_B_NOT_HELD  label
	_JOYPAD_GET_B  JOYPAD_HELD
	BEQ	label
.endmacro

.macro JOYPAD_BR_IF_B_HELD  label
	_JOYPAD_GET_B  JOYPAD_HELD
	BNE	label
.endmacro

.macro JOYPAD_BR_IF_B_NOT_PRESSED  label
	_JOYPAD_GET_B  JOYPAD_PRESSED
	BEQ	label
.endmacro

.macro JOYPAD_BR_IF_B_PRESSED  label
	_JOYPAD_GET_B  JOYPAD_PRESSED
	BNE	label
.endmacro


.macro JOYPAD_BR_IF_IS_NES label, elseLabel
	LDA	JOYPAD_TYPE
	; CMP	#JOYPAD_NES ; == 0
	BEQ	label
	.ifnblank elseLabel
	JMP	elseLabel
	.endif
.endmacro

.macro JOYPAD_BR_IF_IS_SNES label, elseLabel
	LDA	JOYPAD_TYPE
	CMP	#JOYPAD_SNES
	BEQ	label
	.ifnblank elseLabel
	JMP	elseLabel
	.endif
.endmacro