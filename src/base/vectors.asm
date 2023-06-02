.segment "VECTORS"

; Don't change the order!
INTERRUPT_VECTOR:
	.addr	NMI
	.addr	RESET
	.addr	IRQ
