.include "DATA.asm"

;======================================================================================================================
; FAMISTUDIO_INIT (public)
; Reset APU, initialize the sound engine with some music data.
; [in] a : Playback platform, zero for PAL, non-zero for NTSC.
; [in] x : Pointer to music data (lo)
; [in] y : Pointer to music data (hi)
;======================================================================================================================
; FAMISTUDIO_MUSIC_PLAY (public)
; Plays a song from the loaded music data (from a previous call to famistudio_init).
; [in] a : Song index.
;======================================================================================================================
; FAMISTUDIO_MUSIC_PAUSE (public)
; Pause/unpause the currently playing song.
; [in] a : zero to play, non-zero to pause.
;======================================================================================================================
; FAMISTUDIO_MUSIC_STOP (public)
; Stops any music currently playing, if any.
;======================================================================================================================
; FAMISTUDIO_SFX_INIT (public)
; Initialize the sound effect player.
; [in] x: Sound effect data pointer (lo)
; [in] y: Sound effect data pointer (hi)
;======================================================================================================================
; FAMISTUDIO_SFX_PLAY (public)
; Plays a sound effect.
; [in] a: Sound effect index (0...127)
; [in] x: Offset of sound effect channel, should be FAMISTUDIO_SFX_CH0..FAMISTUDIO_SFX_CH3
;======================================================================================================================
; FAMISTUDIO_SFX_SAMPLE_PLAY (public)
; Play DPCM sample with higher priority, for sound effects
; [in] a: Sample index, 1...63.
;======================================================================================================================
; FAMISTUDIO_UPDATE (public)
; Main update function, should be called once per frame.
;======================================================================================================================


.segment BANK(BK_MAIN_CODE)

.proc SOUND_SYSTEM_SFX_INIT
	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_MUSIC_0, SAVED_PRG_0
	LDX	#<petrobots_sfx_data
	LDY	#>petrobots_sfx_data
	JSR	famistudio_sfx_init
	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_GENERAL, SAVED_PRG_0
	RTS
.endproc


.macro SOUND_SYSTEM_MUSIC_PLAY  music_bank, index
	LDA	SAVED_PRG_0
	PHA
	; LDA	SAVED_PRG_1
	; PHA

	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_MUSIC_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, #music_bank ; , SAVED_PRG_1
	STA	SOUND_SYSTEM_BANK
	
	LDX	#.lobyte($A000)
	LDY	#.hibyte($A000)
	; 0=PAL; other=NTSC
	LDA	TV_SYSTEM
	SEC
	SBC	#1
	JSR	famistudio_init
	LDA	#index
	JSR	famistudio_music_play

	; PLA
	; STA	SAVED_PRG_1
	PLA
	STA	SAVED_PRG_0

	MMC3_BANK_SELECT  MMC3_PRG_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, SAVED_PRG_1
.endmacro


.proc SOUND_SYSTEM_MUSIC_PLAY__INTRO
	SOUND_SYSTEM_MUSIC_PLAY  song_bank_metal_heads, song_metal_heads
	RTS
.endproc


.proc SOUND_SYSTEM_MUSIC_PLAY__WIN
	SOUND_SYSTEM_MUSIC_PLAY  song_bank_all_clear, song_all_clear
	RTS
.endproc


.proc SOUND_SYSTEM_MUSIC_PLAY__LOSE
	SOUND_SYSTEM_MUSIC_PLAY  song_bank_end_of_the_line, song_end_of_the_line
	RTS
.endproc


.proc SOUND_SYSTEM_MUSIC_PLAY__IN_GAME
	LDY	SELECTED_MAP
	LDA	LEVEL_TO_MUSIC_MAPPING, Y
	CMP	#3
	BNE	:+
	JMP	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_3
:	CMP	#2
	BNE	:+
	JMP	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_2
:	CMP	#1
	BNE	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_0
	JMP	SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_1
.endproc

.proc SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_0
	SOUND_SYSTEM_MUSIC_PLAY  song_bank_metallic_bop, song_metallic_bop
	RTS
.endproc

.proc SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_1
	SOUND_SYSTEM_MUSIC_PLAY  song_bank_rushin_in, song_rushin_in
	RTS
.endproc

.proc SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_2
	SOUND_SYSTEM_MUSIC_PLAY  song_bank_get_psyched, song_get_psyched
	RTS
.endproc

.proc SOUND_SYSTEM_MUSIC_PLAY__IN_GAME_3
	SOUND_SYSTEM_MUSIC_PLAY  song_bank_robot_attack, song_robot_attack
	RTS
.endproc

.proc SOUND_SYSTEM_MUSIC_PAUSE
	LDA	SAVED_PRG_0
	PHA
	; LDA	SAVED_PRG_1
	; PHA

	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_MUSIC_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, SOUND_SYSTEM_BANK ; , SAVED_PRG_1

	LDA	#1
	JSR	famistudio_music_pause

	; PLA
	; STA	SAVED_PRG_1
	PLA
	STA	SAVED_PRG_0

	MMC3_BANK_SELECT  MMC3_PRG_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, SAVED_PRG_1

	RTS
.endproc

.proc SOUND_SYSTEM_MUSIC_RESUME
	LDA	SAVED_PRG_0
	PHA
	; LDA	SAVED_PRG_1
	; PHA

	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_MUSIC_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, SOUND_SYSTEM_BANK ; , SAVED_PRG_1

	LDA	#0
	JSR	famistudio_music_pause

	; PLA
	; STA	SAVED_PRG_1
	PLA
	STA	SAVED_PRG_0

	MMC3_BANK_SELECT  MMC3_PRG_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, SAVED_PRG_1

	RTS
.endproc

.proc SOUND_SYSTEM_MUSIC_STOP
	SETB	SOUND_SYSTEM_STOP_FLAG, 7
	RTS
.endproc

.proc SOUND_SYSTEM_SFX_PLAY
	TAY
	LDA	SFX_MAPPING,Y
	STA	SOUND_SYSTEM_SFX_INDEX
	RTS
.endproc

.proc SOUND_SYSTEM_SSFX_PLAY
	STA	SOUND_SYSTEM_SSFX_INDEX
	RTS
.endproc


.proc SOUND_SYSTEM_UPDATE
	LDA	SAVED_PRG_0
	PHA
	; LDA	SAVED_PRG_1
	; PHA

	MMC3_BANK_SELECT  MMC3_PRG_0, #BK_MUSIC_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, SOUND_SYSTEM_BANK ; , SAVED_PRG_1

	LDA	SOUND_SYSTEM_SFX_INDEX
	CMP	#$FF
	BEQ	:+
	LDA	SOUND_SYSTEM_SFX_INDEX	; sfx index
	LDX	#FAMISTUDIO_SFX_CH0	; sfx channel, always zero
	JSR	famistudio_sfx_play
	LDA	#$FF
	STA	SOUND_SYSTEM_SFX_INDEX
:

	; LDA	SOUND_SYSTEM_SSFX_INDEX
	; CMP	#$FF
	; BEQ	:+
	; LDA	SOUND_SYSTEM_SSFX_INDEX	; sfx index
	; JSR	famistudio_sfx_sample_play
	; LDA	#$FF
	; STA	SOUND_SYSTEM_SSFX_INDEX
; :

	B7C	SOUND_SYSTEM_STOP_FLAG, :+
	CLRB	SOUND_SYSTEM_STOP_FLAG, 7
	JSR	famistudio_music_stop
	JMP	@skip
:	
	JSR	famistudio_update

	LDA	TV_SYSTEM
	CMP	#2 ; DENDY
	BNE	@skip

	INC	SOUND_SYSTEM_COUNTER
	LDA	SOUND_SYSTEM_COUNTER
	AND	#%00000111
	CMP	#6
	BNE	@skip
	LDA	SOUND_SYSTEM_COUNTER
	AND	#%11111000
	STA	SOUND_SYSTEM_COUNTER
	JSR	famistudio_update
@skip:
	; PLA
	; STA	SAVED_PRG_1
	PLA
	STA	SAVED_PRG_0

	MMC3_BANK_SELECT  MMC3_PRG_0, SAVED_PRG_0
	MMC3_BANK_SELECT  MMC3_PRG_1, SAVED_PRG_1

	RTS
.endproc
