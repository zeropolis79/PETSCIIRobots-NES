; Declares the content of the Character ROM
.segment "TILES"

.incbin "resources/tileset/intro_1.chr"		; 00-03
.incbin "resources/tileset/intro_2.chr"		; 04-07
.incbin "resources/tileset/intro_sprites.chr"	; 08-0B
.incbin "resources/tileset/empty.chr"		; 0C-0F

.incbin "resources/tileset/settings.chr"	; 10-13
.incbin "resources/tileset/credits.chr"		; 14-17
.incbin "resources/tileset/game_end.chr"	; 18-1B
.incbin "resources/tileset/help.chr"		; 1C-1F

.incbin "resources/tileset/game_field_0.chr"	; 20-23
.incbin "resources/tileset/game_field_1.chr"	; 24-27
.incbin "resources/tileset/game_field_2.chr"	; 28-2B
.incbin "resources/tileset/game_field_3.chr"	; 2C-2F
.incbin "resources/tileset/game_sprites.chr"	; 30-33
.incbin "resources/tileset/game_ui.chr"		; 34-37
.incbin "resources/tileset/game_map.chr"	; 38-3B
.incbin "resources/tileset/empty.chr"		; 3C-3F

.incbin "resources/tileset/empty.chr"		; 40-43
.incbin "resources/tileset/empty.chr"		; 44-47
.incbin "resources/tileset/empty.chr"		; 48-4B
.incbin "resources/tileset/empty.chr"		; 4C-4F
.incbin "resources/tileset/empty.chr"		; 50-53
.incbin "resources/tileset/empty.chr"		; 54-57
.incbin "resources/tileset/empty.chr"		; 58-5B
.incbin "resources/tileset/empty.chr"		; 5C-5F

.incbin "resources/level/level-a.chr"		; 60-61
.incbin "resources/level/level-b.chr"		; 62-63
.incbin "resources/level/level-c.chr"		; 64-65
.incbin "resources/level/level-d.chr"		; 66-67
.incbin "resources/level/level-e.chr"		; 68-69
.incbin "resources/level/level-f.chr"		; 6A-6B
.incbin "resources/level/level-g.chr"		; 6C-6D
.incbin "resources/level/level-h.chr"		; 6E-6F
.incbin "resources/level/level-i.chr"		; 70-71
.incbin "resources/level/level-j.chr"		; 72-73
.incbin "resources/level/level-k.chr"		; 74-75
.incbin "resources/level/level-l.chr"		; 76-77
.incbin "resources/level/level-m.chr"		; 78-79
.incbin "resources/tileset/empty.chr",0,$800	; 7A-7B  ; level-n
.incbin "resources/tileset/empty.chr",0,$800	; 7C-7D  ; level-o
.incbin "resources/tileset/empty.chr",0,$800	; 7E-7F  ; level-p


TS_INTRO_1		= $00
TS_INTRO_2		= $04
TS_INTRO_SPRITES	= $08

TS_GAME_FIELD		= $20
TS_GAME_SPRITES		= $30
TS_GAME_UI		= $34
TS_GAME_MAP		= $38

TS_SETTINGS		= $10
TS_CREDITS		= $14
TS_GAME_END		= $18
TS_HELP			= $1C
