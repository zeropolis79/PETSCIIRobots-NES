
.define BZS  BEQ
.define BZC  BNE
.define BNS  BMI
.define BNC  BPL

.define BGE  BCS	; a >= val
.define BLT  BCC	; a <  val

.define MOD(ta,tb) (ta-((ta/tb)*tb))

.macro BLE  label
	BEQ	label
	BLT	label
.endmacro

.macro BGT  label
	.local	@not
	BEQ	@not
	BGE	label
@not:
.endmacro


.macro	NOT
	EOR	#$FF
.endmacro

.macro	NEG
	EOR	#$FF
	CLC
	ADC	#1
.endmacro

.macro ASR
	CMP	#$80
	ROR
.endmacro


.macro SETB  addr, bitnum
	SETM  addr, {(1 << bitnum)}
.endmacro

.macro CLRB  addr, bitnum
	CLRM  addr, {(1 << bitnum)}
.endmacro

.macro SETM  addr, mask
	LDA	addr
	ORA	#(mask)&$FF
	STA	addr
.endmacro

.macro CLRM  addr, mask
	LDA	addr
	AND	#(~(mask))&$FF
	STA	addr
.endmacro


.macro BBS  addr, bitnum, label
		BXNZ	addr, {(1 << bitnum)}, label
.endmacro

.macro BBC  addr, bitnum, label
		BXZ	addr, {(1 << bitnum)}, label
.endmacro

.macro BXZ  addr, mask, label
	LDA	#(mask)&$FF
	BIT	addr
	BEQ	label
.endmacro

.macro BXNZ  addr, mask, label
	LDA	#(mask)&$FF
	BIT	addr
	BNE	label
.endmacro

.macro BXEQ  addr, mask, value, label
	; LDA	#(mask)&$FF
	; AND	#(~(value))&$FF
	; BIT	addr
	LDA	addr
	AND	#(mask)&$FF
	CMP	#value
	BEQ	label
.endmacro

.macro BXNE  addr, mask, value, label
	; LDA	#(mask)&$FF
	; AND	#value
	; BIT	addr
	LDA	addr
	AND	#(mask)&$FF
	CMP	#value
	BNE	label
.endmacro

.macro B6C  addr, label
	BIT	addr
	BVC	label
.endmacro

.macro B6S  addr, label
	BIT	addr
	BVS	label
.endmacro

.macro B7C  addr, label
	BIT	addr
	BPL	label
.endmacro

.macro B7S  addr, label
	BIT	addr
	BMI	label
.endmacro



.macro PHX
	TXA
	PHA
.endmacro

.macro PLX
	PLA
	TAX
.endmacro

.macro PHY
	TYA
	PHA
.endmacro

.macro PLY
	PLA
	TAY
.endmacro

.macro PHXY
	PHX
	PHY
.endmacro

.macro PLXY
	PLY
	PLX
.endmacro


.macro PHADR address
	LDA	#>(address)
	PHA
	LDA	#<(address)
	PHA
.endmacro


.macro PHPTR address
	LDA	address+1
	PHA
	LDA	address+0
	PHA
.endmacro

.macro PLPTR address
	PLA
	STA	address+0
	PLA
	STA	address+1
.endmacro


.macro ADD16 addr0, addr1
	CLC
	LDA	addr0+0
	ADC	addr1+0
	STA	addr0+0
	LDA	addr0+1
	ADC	addr1+1
	STA	addr0+1
.endmacro

.macro ADD16_A addr
	CLC
	ADC	addr+0
	STA	addr+0
	LDA	addr+1
	ADC	#$00
	STA	addr+1
.endmacro

.macro ADDI16 addr, val
	CLC
	LDA	addr+0
	ADC	#<val
	STA	addr+0
	LDA	addr+1
	ADC	#>val
	STA	addr+1
.endmacro

.macro SUB16 addr0, addr1
	SEC
	LDA	addr0+0
	SBC	addr1+0
	STA	addr0+0
	LDA	addr0+1
	SBC	addr1+1
	STA	addr0+1
.endmacro

.macro SUBI16 addr, val
	SEC
	LDA	addr+0
	SBC	#<val
	STA	addr+0
	LDA	addr+1
	SBC	#>val
	STA	addr+1
.endmacro

.macro NEG16 addr
	SEC
	LDA	#$00
	SBC	addr+0
	STA	addr+0
	LDA	#$00
	SBC	addr+1
	STA	addr+1
.endmacro

.macro LDADDR ptr, addr
	LDA	#<addr
	STA	ptr+0
	LDA	#>addr
	STA	ptr+1
.endmacro

