
JSON2NT = ./tools/custom/bin/json2ntbl.exe
PNG2CHR = ./tools/custom/bin/png2chr.exe
LVL2PNG = ./tools/custom/bin/lvl2png.exe
RLE     = ./tools/custom/bin/rle.exe
BINCOPY = ./tools/custom/bin/bincopy.exe

CA65 = ./tools/cc65/ca65.exe
LD65 = ./tools/cc65/ld65.exe
OD65 = ./tools/cc65/od65.exe 

MAIN = src/MAIN.asm
FLAGS = -D GOD_MODE=0

RES_TILESETS = $(wildcard ./resources/tileset/*.png)
RES_LEVELS   = $(wildcard ./resources/level/level-*.bin)
RES_SCREENS  = $(wildcard ./resources/screen/*.json)


default: rom-nes

all: tools resources rom-nes rom-bin

%.unit: %.bin
	$(BINCOPY) $< -s 2   -l 512  -o $@

%.map: %.bin
	$(BINCOPY) $< -s 770 -l 8192 -o $@
	$(RLE) $@ -c -o $@.rle -z
	$(LVL2PNG) $@ -o  $(patsubst %.map,%.png,$@) 

%.chr: %.png
	$(PNG2CHR) $< -o $@

%.nt: %.json
	$(JSON2NT) $<
	$(RLE) $@ -c -o $@.rle -z


tileset: $(patsubst %.png,%.chr,$(RES_TILESETS)) $(patsubst %.bin,%.chr,$(RES_LEVELS))

level: $(patsubst %.bin,%.unit,$(RES_LEVELS)) $(patsubst %.bin,%.map,$(RES_LEVELS))

screen: $(patsubst %.json,%.nt,$(RES_SCREENS))

resources: screen level tileset

petrobots: $(MAIN) resources
	echo -e ".segment BANK(BK_INTRO_CODE)\nBUILD_DATE: .BYTE \"$$(date +"%d/%m/%y")\", \$$FF\nBUILD_TIME: .BYTE \"$$(date +"%H:%M")\", \$$FF\n" > src/build_time.asm
	$(CA65) \
		$< $(FLAGS) \
		-I src \
		-g \
		--verbose \
		--large-alignment \
		-o $@.o
	$(LD65) \
		--obj     $@.o \
		-C        resources/ldscript/nes.ld \
		-m        $@.map.d.txt \
		-Ln       $@.labels.d.txt \
		--dbgfile $@.dbg \
		--large-alignment \
		-vm \
		-o        $@.nes
	
	sort $@.labels.d.txt -o $@.labels.d.txt
	$(OD65) -S $@.o > $@.seg.d.txt


rom-nes: petrobots

rom-bin: petrobots
	@echo $(.FEATURES) 
	$(BINCOPY) $<.nes -s 16 -l 262144 -o $<.prg.rom
	$(BINCOPY) $<.nes -s 262160 -l 131072 -o $<.chr.rom

tools:
	$(MAKE) -C tools/custom/

clean:
	rm -f $(wildcard ./*.d.txt)
	rm -f $(wildcard ./*.dbg)
	rm -f $(wildcard ./*.nes)
	rm -f $(wildcard ./*.o)
	rm -f $(wildcard ./*.chr.rom)
	rm -f $(wildcard ./*.prg.rom)
	rm -f $(wildcard ./resources/level/level-*.unit)
	rm -f $(wildcard ./resources/level/level-*.map)
	rm -f $(wildcard ./resources/level/level-*.map.rle)
	rm -f $(wildcard ./resources/level/level-*.png)
	rm -f $(wildcard ./resources/level/level-*.chr)
	rm -f $(wildcard ./resources/tileset/*.chr)
	rm -f $(wildcard ./resources/screen/*.nt)
	rm -f $(wildcard ./resources/screen/*.nt.rle)
	rm -f $(wildcard ./resources/screen/*.nt_atr)
	rm -f $(wildcard ./resources/screen/*.nt_plt)

.PHONY: tools clean
