.segment BANK(BK_MUSIC_0)
petrobots_sfx_data:
.include "../../resources/music/petrobots_sfx.asm"
sfx_explosion	= 0 
sfx_medkit	= 1 
sfx_emp		= 2 
sfx_magnet	= 3 
sfx_shock	= 4 
sfx_move_obj	= 5 
sfx_plasma	= 6 
sfx_pistol	= 7 
sfx_item_found	= 8 
sfx_error	= 9 
sfx_cycle_wpn	= 10
sfx_cycle_item	= 11
sfx_door	= 12
sfx_menu_beep	= 13
sfx_short_beep	= 14


.segment BANK(BK_MUSIC_1)
petrobots_music_data_0:
.include "../../resources/music/petrobots_music_0.asm"
song_robot_attack		= 0
song_all_clear			= 1
song_end_of_the_line		= 2
song_bank_robot_attack		= BK_MUSIC_1
song_bank_all_clear		= BK_MUSIC_1
song_bank_end_of_the_line	= BK_MUSIC_1


.segment BANK(BK_MUSIC_2)
petrobots_music_data_1:
.include "../../resources/music/petrobots_music_1.asm"
song_metallic_bop	= 0
song_rushin_in		= 1
song_bank_metallic_bop	= BK_MUSIC_2
song_bank_rushin_in	= BK_MUSIC_2


.segment BANK(BK_MUSIC_3)
petrobots_music_data_2:
.include "../../resources/music/petrobots_music_2.asm"
song_get_psyched	= 0
song_metal_heads	= 1
song_bank_get_psyched	= BK_MUSIC_3
song_bank_metal_heads	= BK_MUSIC_3


.segment BANK(BK_GENERAL)
SONG_NAMES:
	.BYTE  "  METAL HEADS   " ; intro song 
	.BYTE  "  METALLIC BOP  " ; level song 1
	.BYTE  "   RUSHIN IN    " ; level song 2
	.BYTE  "    PSYCHED     " ; level song 3
	.BYTE  "  ROBOT ATTACK  " ; level song 4
	.BYTE  "   ALL CLEAR    " ; win   song
	.BYTE  "END OF THE LINE " ; lose  song

; decides which level gets mapped
; to which level song index
LEVEL_TO_MUSIC_MAPPING:
	.BYTE  0, 1, 2, 3
	.BYTE  0, 1, 2, 3
	.BYTE  0, 1, 2, 3
	.BYTE  0, 1, 2, 3

; decides which sound index gets mapped
; to which sound effect
SFX_MAPPING:
	.BYTE  sfx_explosion	; sound 0
	.BYTE  sfx_explosion	; sound 1
	.BYTE  sfx_medkit	; sound 2
	.BYTE  sfx_emp		; sound 3
	.BYTE  sfx_magnet	; sound 4
	.BYTE  sfx_shock	; sound 5
	.BYTE  sfx_move_obj	; sound 6
	.BYTE  sfx_shock	; sound 7
	.BYTE  sfx_plasma	; sound 8
	.BYTE  sfx_pistol	; sound 9
	.BYTE  sfx_item_found	; sound 10
	.BYTE  sfx_error	; sound 11
	.BYTE  sfx_cycle_wpn	; sound 12
	.BYTE  sfx_cycle_item	; sound 13
	.BYTE  sfx_door		; sound 14
	.BYTE  sfx_menu_beep	; sound 15
	.BYTE  sfx_short_beep	; sound 16
	.BYTE  sfx_short_beep	; sound 17
