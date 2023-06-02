# CA65 configuration script for UOROM

MEMORY {
    # Internal RAM
    RAM:    start = $0000, size = $0800, type = rw, file = "";
    ZP0:    start = $0024, size = $00dc, type = rw, file = "";
    ZP1:    start = $0024, size = $00dc, type = rw, file = "";
    # Cartridge RAM
    WRAM0:  start = $6000, size = $2000, type = rw, file = "";
    WRAM1:  start = $6000, size = $2000, type = rw, file = "";
    # ROM
    HDR:    start = $0000, size = $0010, type = ro, file = %O, fill = yes, fillval = $FF;
    # MAP_DATA
    ROM00:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $00;
    ROM01:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $01;
    ROM02:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $02;
    ROM03:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $03;
    ROM04:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $04;
    ROM05:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $05;
    ROM06:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $06;
    ROM07:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $07;
    ROM08:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $08;
    ROM09:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $09;
    ROM0A:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $0A;
    ROM0B:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $0B;
    ROM0C:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $0C;
    ROM0D:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $0D;
    ROM0E:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $0E;
    ROM0F:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $0F;
    # METATILESET, MUSIC, CONSTANT_GAME_DATA
    ROM10:  start = $8000, size = $2000, type = ro, file = %O, fill = yes, fillval = $10;
    # SCREEN_DATA
    ROM11:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $11;
    ROM12:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $12;
    ROM13:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $13;
    # UNUSED
    ROM14:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $14;
    ROM15:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $15;
    ROM16:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $16;
    ROM17:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $17;
    ROM18:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $18;
    # MUSIC_DATA
    ROM19:  start = $8000, size = $2000, type = ro, file = %O, fill = yes, fillval = $19;
    ROM1A:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $1A;
    ROM1B:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $1B;
    ROM1C:  start = $A000, size = $2000, type = ro, file = %O, fill = yes, fillval = $1C;
    # PPU_TRANSFER
    ROM1D:  start = $8000, size = $2000, type = ro, file = %O, fill = yes, fillval = $1D;
    # CODE
    ROMF:   start = $C000, size = $4000, type = ro, file = %O, fill = yes, fillval = $1E;
    
    CHR:    start = $0000, size = $20000, type = ro, file = %O, fill = yes, fillval = $00;
}

SEGMENTS {
    ZEROPAGE:  load = RAM,   type = zp,  start = $0000;
    ZP0:       load = ZP0,   type = zp,                 optional = yes;
    ZP1:       load = ZP1,   type = zp,                 optional = yes;
    STACK:     load = RAM,   type = bss, start = $0100;
    OAM:       load = RAM,   type = bss, start = $0200;
    RAM:       load = RAM,   type = bss, start = $0300;
    WRAM0:     load = WRAM0, type = bss,                optional = yes;
    WRAM1:     load = WRAM1, type = bss,                optional = yes;
    HEADER:    load = HDR,   type = ro;
    BANK00:    load = ROM00, type = ro,  align = $0100, optional = yes;
    BANK01:    load = ROM01, type = ro,  align = $0100, optional = yes;
    BANK02:    load = ROM02, type = ro,  align = $0100, optional = yes;
    BANK03:    load = ROM03, type = ro,  align = $0100, optional = yes;
    BANK04:    load = ROM04, type = ro,  align = $0100, optional = yes;
    BANK05:    load = ROM05, type = ro,  align = $0100, optional = yes;
    BANK06:    load = ROM06, type = ro,  align = $0100, optional = yes;
    BANK07:    load = ROM07, type = ro,  align = $0100, optional = yes;
    BANK08:    load = ROM08, type = ro,  align = $0100, optional = yes;
    BANK09:    load = ROM09, type = ro,  align = $0100, optional = yes;
    BANK0A:    load = ROM0A, type = ro,  align = $0100, optional = yes;
    BANK0B:    load = ROM0B, type = ro,  align = $0100, optional = yes;
    BANK0C:    load = ROM0C, type = ro,  align = $0100, optional = yes;
    BANK0D:    load = ROM0D, type = ro,  align = $0100, optional = yes;
    BANK0E:    load = ROM0E, type = ro,  align = $0100, optional = yes;
    BANK0F:    load = ROM0F, type = ro,  align = $0100, optional = yes;
    BANK10:    load = ROM10, type = ro,  align = $0100, optional = yes;
    BANK11:    load = ROM11, type = ro,  align = $0100, optional = yes;
    BANK12:    load = ROM12, type = ro,  align = $0100, optional = yes;
    BANK13:    load = ROM13, type = ro,  align = $0100, optional = yes;
    BANK14:    load = ROM14, type = ro,  align = $0100, optional = yes;
    BANK15:    load = ROM15, type = ro,  align = $0100, optional = yes;
    BANK16:    load = ROM16, type = ro,  align = $0100, optional = yes;
    BANK17:    load = ROM17, type = ro,  align = $0100, optional = yes;
    BANK18:    load = ROM18, type = ro,  align = $0100, optional = yes;
    BANK19:    load = ROM19, type = ro,  align = $0100, optional = yes;
    BANK1A:    load = ROM1A, type = ro,  align = $0100, optional = yes;
    BANK1B:    load = ROM1B, type = ro,  align = $0100, optional = yes;
    BANK1C:    load = ROM1C, type = ro,  align = $0100, optional = yes;
    BANK1D:    load = ROM1D, type = ro,  align = $0100, optional = yes;
    BANK1E:    load = ROMF,  type = ro,  start = $C000;
    BANK1F:    load = ROMF,  type = ro,  start = $FE00;
    VECTORS:   load = ROMF,  type = ro,  start = $FFFA;
    TILES:     load = CHR,   type = ro;
}
