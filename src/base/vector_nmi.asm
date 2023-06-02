; ============================
; NMI ISR
; ============================
.macro SET_NMI_ROUTINE addr
	LDA	#<addr
	STA	NMI_ROUTINE+0
	LDA	#>addr
	STA	NMI_ROUTINE+1
.endmacro

.segment BANK(BK_SYSTEM)
.proc NMI
	PHA
	PHX
	PHY

	PHADR	{@return-1}
	JMP	(NMI_ROUTINE)
@return:

	; break WAIT_NMI loop
	LDA	#0
	STA	VBLANK_FLAG

	PLY
	PLX
	PLA
	RTI
.endproc
