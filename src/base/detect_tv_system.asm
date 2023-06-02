;
; NES TV system detection code
; Copyright 2011 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;

.segment BANK(BK_SYSTEM)
; .align 32  ; ensure that branches do not cross a page boundary

;;
; Detects which of NTSC, PAL, or Dendy is in use by counting cycles
; between NMIs.
;
; NTSC NES produces 262 scanlines, with 341/3 CPU cycles per line.
; PAL NES produces 312 scanlines, with 341/3.2 CPU cycles per line.
; Its vblank is longer than NTSC, and its CPU is slower.
; Dendy is a Russian famiclone distributed by Steepler that uses the
; PAL signal with a CPU as fast as the NTSC CPU.  Its vblank is as
; long as PAL's, but its NMI occurs toward the end of vblank (line
; 291 instead of 241) so that cycle offsets from NMI remain the same
; as NTSC, keeping Balloon Fight and any game using a CPU cycle-
; counting mapper (e.g. FDS, Konami VRC) working.
;
; nmis is a variable that the NMI handler modifies every frame.
; Make sure your NMI handler finishes within 1500 or so cycles (not
; taking the whole NMI or waiting for sprite 0) while calling this,
; or the result in A will be wrong.
;
; @return A: TV system (0: NTSC, 1: PAL, 2: Dendy; 3: unknown
;         Y: high byte of iterations used (1 iteration = 11 cycles)
;         X: low byte of iterations used
.proc DETECT_TV_SYSTEM
	LDX	#0
	LDY	#0

@wait1:	LDA	VBLANK_FLAG
	BNE	@wait1
	INC	VBLANK_FLAG

	; Each iteration takes 11 cycles.
	; NTSC NES: 29780 cycles or 2707 = $A93 iterations
	; PAL NES:  33247 cycles or 3022 = $BCE iterations
	; Dendy:    35464 cycles or 3224 = $C98 iterations
	; so we can divide by $100 (rounding down), subtract ten,
	; and end up with 0=ntsc, 1=pal, 2=dendy, 3=unknown
@wait2:	INX			; 2
	BNE	:+		; 2*1/256+3*255/256
	INY			; 2*1/256
:	LDA	VBLANK_FLAG	; 3
	BNE	@wait2		; 3 -> 11.00390625 cycles/iteration
	INC	VBLANK_FLAG	

	TYA
	SEC
	SBC	#10
	CMP	#3
	BLT	@not_above_3
	LDA	#3
@not_above_3:
	RTS
.endproc
