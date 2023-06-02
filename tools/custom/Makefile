CC = gcc

INC_DIR = -I./include
LIB_DIR = -L./lib
OUT_DIR = ./bin
EXT = .exe

CFLAGS = -lraylib -lopengl32 -lgdi32 -lwinmm

all: json2ntbl png2chr rle ntatr_editor bincopy lvl2png

$(OUT_DIR): 
	- mkdir -p $@
	

ntatr_editor: ntatr_editor.c $(OUT_DIR)
	$(CC) -o $(OUT_DIR)/$@${EXT} $< $(CFLAGS) $(INC_DIR) $(LIB_DIR)

json2ntbl: json2ntbl.c $(OUT_DIR)
	$(CC) -o $(OUT_DIR)/$@${EXT} $< $(CFLAGS) $(INC_DIR) $(LIB_DIR)

png2chr: png2chr.c $(OUT_DIR)
	$(CC) -o $(OUT_DIR)/$@${EXT} $< $(CFLAGS) $(INC_DIR) $(LIB_DIR)

rle: rle.c $(OUT_DIR)
	$(CC) -o $(OUT_DIR)/$@${EXT} $< $(CFLAGS) $(INC_DIR) $(LIB_DIR)

bincopy: bincopy.c $(OUT_DIR)
	$(CC) -o $(OUT_DIR)/$@${EXT} $< $(CFLAGS) $(INC_DIR) $(LIB_DIR)

lvl2png: lvl2png.c $(OUT_DIR)
	$(CC) -o $(OUT_DIR)/$@${EXT} $< $(CFLAGS) $(INC_DIR) $(LIB_DIR)


clean:
	rm -rf $(OUT_DIR)


.PHONY: clean json2ntbl png2chr rle ntatr_editor bincopy lvl2png
