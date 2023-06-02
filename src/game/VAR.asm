.segment "ZEROPAGE"
UNIT_TIMER_A:	.RES 64 ; Primary timer for units (64 bytes)
UNIT_TIMER_B:	.RES 64 ; Secondary timer for units (64 bytes)
UNIT_TILE:	.RES 32 ; Current tile assigned to unit (32 bytes)

.segment "RAM"
UNIT_TYPE:	.RES 64 ; Unit type        (64 bytes)
UNIT_LOC_X:	.RES 64 ; Unit X location  (64 bytes)
UNIT_LOC_Y:	.RES 64 ; Unit Y location  (64 bytes)
UNIT_A:		.RES 64 ; Unit attribute A (64 bytes)
UNIT_B:		.RES 64 ; Unit attribute B (64 bytes)
UNIT_C:		.RES 64 ; Unit attribute C (64 bytes)
; UNIT_HEALTH:	.RES 28 ; Unit health      (64 bytes, only 28 needed)
UNIT_HEALTH = 	UNIT_B

.segment "WRAM0"
MAP:		.RES 8192 ; Location of MAP (8K)


.segment "ZEROPAGE"
TILE:		.RES 1	; The tile number to be plotted
MAP_X:		.RES 1	; Current X location on map
MAP_Y:		.RES 1	; Current Y location on map
MAP_WINDOW_X:	.RES 1	; Top left location of what is displayed in map window
MAP_WINDOW_Y:	.RES 1	; Top left location of what is displayed in map window
UNIT:		.RES 1	; Current unit being processed
UNIT_FIND:	.RES 1	; 255=no unit present.
MOVE_TYPE:	.RES 1	; %00000001=WALK %00000010=HOVER
MOVE_RESULT:	.RES 1	; 1=Move request success, 0=fail.

GAME_FLAG:	.RES 1	; Holds up to 8 flags

F_CURSOR_ON =	 2	; Is cursor active or not? 1=yes 0=no
CURSOR_X:	.RES 1	; For on-screen cursor
CURSOR_Y:	.RES 1	; For on-screen cursor

F_KEY_FAST = 	 3	; When 1 repeated presses are fired faster

KEYS:		.RES 1	; bit0=spade bit2=heart bit3=star
AMMO_PISTOL:	.RES 1	; how much ammo for the pistol
AMMO_PLASMA:	.RES 1	; how many shots of the plasmagun
INV_BOMBS:	.RES 1	; How many bombs do we have
INV_EMP:	.RES 1	; How many EMPs do we have
INV_MEDKIT:	.RES 1	; How many medkits do we have?
INV_MAGNET:	.RES 1	; How many magnets do we have?
SELECTED_WEAPON:.RES 1	; 0=none 1=pistol 2=plasmagun
SELECTED_ITEM:	.RES 1	; 0=none 1=bomb 2=emp 3=medkit 4=magnet
BIG_EXP_ACT:	.RES 1	; 0=No explosion active 1=big explosion active
MAGNET_ACT:	.RES 1	; 0=no magnet active 1=magnet active
PLASMA_ACT:	.RES 1	; 0=No plasma fire active 1=plasma fire active

SCREEN_SHAKE:	.RES 1	; 1>=shake 0=no shake

F_TRANSFER_FIELD = 0	; 1=request transfer game field to PPU; 0=cancel request
F_REDRAW_FIELD = 4	; 1=yes 0=no
F_SHOW_MAP =	 5	; 

F_CLOCK_ACTIVE = 7
COUNTER:	.RES 1
FRAMES:		.RES 1
CYCLES:		.RES 1
SECONDS:	.RES 1
MINUTES:	.RES 1
HOURS:		.RES 1

GAME_TIMER_NUM	= 6
GAME_TIMER:	.RES GAME_TIMER_NUM

BG_TIMER	= GAME_TIMER+0	; background timer
GP_TIMER	= GAME_TIMER+1	; general purpose timer
KEY_TIMER	= GAME_TIMER+2	; Used for repeat of movement
FLASH_TIMER	= GAME_TIMER+3	
EMP_TIMER	= GAME_TIMER+4
SELECT_TIMEOUT	= GAME_TIMER+5	; can only change weapons once it hits zero

IRQ_COUNTER:	.RES 1	; counts which irq is next 
SCROLL_X:	.RES 1
GAME_BG_PALETTE:.RES 1

ANIMATION_INX:	.RES 2 

.segment "RAM"
SCR_BUFFER:	.RES 32*21+1

.segment "STACK"
; Stores pre-calculated objects for map window
MAP_PRECALC_OBJ:	.RES 32
; Stores the content of the information box
UI_BUFFER:		.RES 18*3


.segment "ZEROPAGE"
; Stores the rendered digits of the amount of the selected item
ITM_NUM_BUFFER:		.RES 3
; Stores the rendered digits of the amount of the selected weapon
WPN_NUM_BUFFER:		.RES 3
