; ============================
; IRQ ISR
; ============================
.macro SET_IRQ_ROUTINE addr
	LDA	#<addr
	STA	IRQ_ROUTINE+0
	LDA	#>addr
	STA	IRQ_ROUTINE+1
.endmacro

.segment BANK(BK_SYSTEM)
.proc IRQ
	PHA
	PHX
	PHY

	PHADR	@return-1
	JMP	(IRQ_ROUTINE)
@return:

	PLY
	PLX
	PLA
	RTI
.endproc
