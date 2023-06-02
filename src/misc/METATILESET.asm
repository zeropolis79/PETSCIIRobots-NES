
.segment BANK(BK_GENERAL)
; include macro tileset at fixed position
DESTRUCT_PATH	=$8000  ; Destruct path array (256 bytes)
	.incbin "resources/metatileset/metatileset_destruct_path.bin"

TILE_ATTRIB	=$8100  ; Tile attrib array (256 bytes)
                        ;   %00000001=01  ; WALKABLE
                        ;   %00000010=02  ; HOVERABLE
                        ;   %00000100=04  ; CAN_MOVE
                        ;   %00001000=08  ; DESTROY
                        ;   %00010000=10  ; SEE_TROUGH
                        ;   %00100000=20  ; MOVE_ONTO
                        ;   %01000000=40  ; SEARCH
                        ;   %10000000=80  ; UNUSED
	.incbin "resources/metatileset/metatileset_tile_attrib.bin"

TILE_DATA_TL	=$8200  ; Tile character top-left (256 bytes)
TILE_DATA_TM	=$8300  ; Tile character top-middle (256 bytes)
TILE_DATA_TR	=$8400  ; Tile character top-right (256 bytes)
TILE_DATA_ML	=$8500  ; Tile character middle-left (256 bytes)
TILE_DATA_MM	=$8600  ; Tile character middle-middle (256 bytes)
TILE_DATA_MR	=$8700  ; Tile character middle-right (256 bytes)
TILE_DATA_BL	=$8800  ; Tile character bottom-left (256 bytes)
TILE_DATA_BM	=$8900  ; Tile character bottom-middle (256 bytes)
TILE_DATA_BR	=$8A00  ; Tile character bottom-right (256 bytes)
; fill pointer with data
	.incbin "resources/metatileset/metatileset.bin"
