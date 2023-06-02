.segment BANK(BK_MAIN_CODE)

RLE_REPEAT_FLAG = $60

; Load src address to PTR_0
; Load dst address to PTR_1
.proc DECOMPRESS_RLE_DATA
	LDY	#00
FN_LOOP:
	LDA	(PTR_0),Y
	CMP	#RLE_REPEAT_FLAG
	BEQ	FN_REPEAT_START
	STA	(PTR_1),Y
FN_NEXT:
	ADDI16	PTR_0, 1
	ADDI16	PTR_1, 1
	JMP	FN_LOOP

FN_REPEAT_START:
	; read number of repeats to X
	ADDI16	PTR_0, 1
	LDA	(PTR_0),Y
	TAX
	; read repeated char to A
	ADDI16	PTR_0, 1
	LDA	(PTR_0),Y
	STA	TEMP_A
	; if number of repeats is 0, exit
	CPX	#0
	BNE	FN_REPEAT_LOOP
	RTS

FN_REPEAT_LOOP:
	LDA	TEMP_A
	STA	(PTR_1),Y
	ADDI16	PTR_1, 1
	DEX
	BNE	FN_REPEAT_LOOP
FN_REPEAT_END:
	SUBI16	PTR_1, 1
	JMP	FN_NEXT
.endproc


; Load src address to PTR_0
; Load NT address to PPU_ADDR
.proc DECOMPRESS_RLE_NT_DATA
	LDY	#0
FN_LOOP:
	LDA	(PTR_0),Y
	CMP	#RLE_REPEAT_FLAG
	BEQ	FN_REPEAT_START
	STA	PPUDATA
FN_NEXT:
	ADDI16	PTR_0, 1
	JMP	FN_LOOP

FN_REPEAT_START:
	; read number of repeats to X
	ADDI16	PTR_0, 1
	LDA	(PTR_0),Y
	TAX
	; read repeated char to A
	ADDI16	PTR_0, 1
	LDA	(PTR_0),Y
	; if number of repeats is 0, exit
	CPX	#0
	BNE	FN_REPEAT_LOOP
	RTS
FN_REPEAT_LOOP:
	STA	PPUDATA
	DEX
	BNE	FN_REPEAT_LOOP
FN_REPEAT_END:
	JMP	FN_NEXT
.endproc
