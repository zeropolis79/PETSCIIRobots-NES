.ifndef GOD_MODE
	GOD_MODE = 0
.endif

; Constant for each bank
BK_GENERAL	= $10
BK_INTRO_CODE	= $11
BK_END_CODE	= $11
BK_GAME_CODE	= $13
BK_CREDITS	= $14
BK_SETTINGS	= $15
BK_HELP		= $16
BK_UNUSED_3	= $17
BK_UNUSED_4	= $18
BK_MUSIC_0	= $19
BK_MUSIC_1	= $1A
BK_MUSIC_2	= $1B
BK_MUSIC_3	= $1C
BK_PPU_TRANS	= $1D
BK_MAIN_CODE	= $1E
BK_SYSTEM	= $1F

; Converts a bank number to its respective bank name
.define BANK(bank_num)  .sprintf("BANK%02X", bank_num)
.define BANK_ID(bank_num)  .ident(.sprintf("BANK%02X", bank_num))
