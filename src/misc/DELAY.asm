.define _delay_n_iter()    ((cycles - 1) / 5)
.define _delay_n_cycles()  (5 * _delay_n_iter + 1)
.define _delay_n_rest()    (cycles - _delay_n_cycles)

.define _delay_m_iter()    ((cycles - 1281) / 512)
.define _delay_m_cycles()  (512 * _delay_m_iter + 1281)
.define _delay_m_rest()    (cycles - _delay_m_cycles)


.macro _DLY_TEST_BRANCH_CROSSING  target
	.assert .hibyte(target) = .hibyte(*), warning, "Delay is crossing pages and will take longer then expected!"
.endmacro

.macro DELAY cycles
	_DLY	cycles	; Delay
.endmacro


.macro _DLY cycles, suppress

	.if .paramcount < 1
		.error "DELAY: No parameter provided!"

	.elseif cycles<0
		.error "DELAY: Delay has to be positive!"

	.elseif cycles=1
		.error "DELAY: Delay can't be 1!"

	.elseif cycles=0
		.ifblank suppress
		.warning "DELAY: Delay is 0! Is this intentional?"
		.endif

	.elseif cycles=2
		NOP		; 2

	.elseif cycles=3
		LDX	$00	; 3

	.elseif cycles=4
		_DLY_S	2	; 2
		_DLY_S	2	; 2
	
	.elseif cycles=5
		_DLY_S	3	; 3
		_DLY_S	2	; 2
	
	.elseif cycles=6
		_DLY_S	4	; 4
		_DLY_S	2	; 2
	
	.elseif cycles=7
		_DLY_S	5	; 5
		_DLY_S	2	; 2
	
	.elseif cycles=8
		_DLY_S	6	; 6
		_DLY_S	2	; 2
	
	.elseif cycles=9
		_DLY_S	7	; 7
		_DLY_S	2	; 2
	
	.elseif cycles=10
		_DLY_S	8	; 8
		_DLY_S	2	; 2
	
	.elseif _delay_n_iter >= 1 .and _delay_n_iter <= 256 .and _delay_n_rest = 1
		_DLY_N	{(_delay_n_iter-1)} ; 0-255
		_DLY_S	6
	
	.elseif _delay_n_iter >= 0 .and _delay_n_iter <= 256
		_DLY_N	{_delay_n_iter} ; 0-256
		_DLY_S	{_delay_n_rest} ; 0,2-4
	
	.elseif _delay_m_iter > 0 .and _delay_m_rest = 1
		_DLY_M	{(_delay_m_iter-1)} ; 0-...
		_DLY_S	513
	
	.elseif _delay_m_iter >= 0
		_DLY_M	{_delay_m_iter} ; 0-...
		_DLY_S	{_delay_m_rest} ; 0,2-511
	
	.else
		.error .sprintf("DELAY: something went wrong with %d!", cycles)

	.endif
.endmacro


; same as DELAY, but without warnings
.macro _DLY_S cycles
	_DLY	cycles, 1
.endmacro


; n*5+1, n in [1,256]; 5 bytes
; -> 6, 11, 16, ..., 1281
.macro _DLY_N n
	.local @loop
	.if n<0
		.error "_DLY_N: Index has to be positive!"
	.elseif n>256
		.error "_DLY_N: Index has to be less than 256!"
	.elseif n=0
		.error "_DLY_N: Index cannot be 0!"
	.elseif n=1
		_DLY_S	6	; 3xNOP is smaller than LDX#,DEX,BNE
	.elseif n=256
		LDX	#0	; 2
	@loop:	DEX		; 256*2
		BNE	@loop	; 256*3-1
		_DLY_TEST_BRANCH_CROSSING	@loop
	.else
		LDX	#n	; 2
	@loop:	DEX		; n*2
		BNE	@loop	; n*3-1
		_DLY_TEST_BRANCH_CROSSING	@loop
	.endif 
.endmacro


; m*512+1281, m in [0,~1000]; 5+sizeof(DELAY 2m) bytes
; -> 1281, 1793, 2305, 2817, ..., 513281
.macro _DLY_M m
	.local @loop
	.if m<0
		.error "_DLY_M: Index has to be positive!"
	.else
		LDY	#0	; 2
	@loop:	DEY		; 256*2
		_DLY_S	{(2*m)}	; 256*2*m
		BNE	@loop	; 256*3-1
		_DLY_TEST_BRANCH_CROSSING	@loop
	.endif
.endmacro
