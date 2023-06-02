.define CUSTOM_AI_NUM	3

.proc CUSTOM_AI
	LDA	UNIT_TYPE,X
	SEC
	SBC	#24
	CMP	#CUSTOM_AI_NUM
	BLT	@valid
	JMP	AILP
@valid:	TAY
	LDA	CUSTOM_AI_ROUTINE_CHART_H,Y
	PHA
	LDA	CUSTOM_AI_ROUTINE_CHART_L,Y
	PHA
	RTS				; indirect JMP
.endproc

CUSTOM_AI_ROUTINE_CHART_L:
	.BYTE <(FLOOR_PANEL_AI-1)	;UNIT TYPE 24
	.BYTE <(AI_DUMMY_ROUTINE-1)	;UNIT TYPE 25
	.BYTE <(AI_DUMMY_ROUTINE-1)	;UNIT TYPE 26

CUSTOM_AI_ROUTINE_CHART_H:
	.BYTE >(FLOOR_PANEL_AI-1)	;UNIT TYPE 24
	.BYTE >(AI_DUMMY_ROUTINE-1)	;UNIT TYPE 25
	.BYTE >(AI_DUMMY_ROUTINE-1)	;UNIT TYPE 26

;------------------------------------------------
; Floor Panel
;  UNIT_A: xxxx xxxx
;          |||| ||||
;          |||| |||+- Bit 0: State (0=off panel, 1=on panel)
;          |||| ||+-- Bit 1: Active
;          |||| |+--- Bit 2: 
;          |||| +---- Bit 3: 
;          |||+------ Bit 4: Run once
;          ||+------- Bit 5: Ran once (0=default)
;          |+-------- Bit 6: Trigger on enter
;          +--------- Bit 7: Trigger on leave
;  UNIT_B: subroutine address low
;  UNIT_C: subroutine address high

.define FP_STATE     0
.define FP_ACTIVE    1
.define FP_RUN_ONCE  4
.define FP_RAN_ONCE  5
.define FP_T_ENTER   6
.define FP_T_LEAVE   7

.proc FLOOR_PANEL_AI
	LDX	UNIT
	LDA	UNIT_A,X
	TAY
	AND	#(1 << FP_ACTIVE)
	BNE	@cont
	JMP	AILP
@cont:

	; set timeout for check
	LDA	#1
	STA	UNIT_TIMER_A,X
	; compare with location of player
	LDA	UNIT_LOC_X,X	; panel x
	CMP	UNIT_LOC_X	; player x
	BNE	@off_panel
	LDA	UNIT_LOC_Y,X	; panel y
	CMP	UNIT_LOC_Y	; player y
	BEQ	@on_panel

; when the player is off the panel
@off_panel:
	TYA
	AND	#(1 << FP_STATE)
	BNE	@skip1	; was player on panel?
	JMP	AILP
@skip1:
	; on leave
	TYA
	AND	#!(1 << FP_STATE)
	STA	UNIT_A,X
	TYA
	AND	#(1 << FP_T_ENTER)
	BEQ	@return
	JMP	@call_trigger

; when the player is on the panel
@on_panel:
	TYA
	AND	#(1 << FP_STATE)
	BEQ	@skip2	; was player off panel?
	JMP	AILP
@skip2:
	; on enter
	TYA
	ORA	#(1 << FP_STATE)
	STA	UNIT_A,X
	TYA
	AND	#(1 << FP_T_ENTER)
	BEQ	@return
	JMP	@call_trigger

@return:
	JMP	AILP

@call_trigger:
	; push return address
	LDA	#>(AILP-1)
	PHA
	LDA	#<(AILP-1)
	PHA
	; indirect jump to trigger
	LDX	UNIT
	LDA	UNIT_B,X
	STA	PTR_0_L
	LDA	UNIT_C,X
	STA	PTR_0_H
	JMP	(PTR_0)
.endproc

;------------------------------------------------
