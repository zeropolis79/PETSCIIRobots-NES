
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define ARGPARSE_IMPLEMENTATION
#include "argparse.h"

#define STBI_ONLY_PNG
#define STBI_ONLY_BMP
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STBI_ONLY_PNG
#define STBI_ONLY_BMP
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include "files.h"
#include "change_ext.h"

static const uint8_t default_palette[4] = { 0x00, 0x55, 0xAA, 0xFF };

uint8_t *read_png(const char* filename, uint32_t *size) {
    int width, height;
    uint8_t *data = stbi_load(filename, &width, &height, NULL, 1);

    if (data == NULL) {
        fprintf(stderr, "Error loading the file:\n%s\n", stbi_failure_reason());
        return NULL;
    }
    if (width != 128) {
        fprintf(stderr, "Width is not equal to 128!\n");
        return NULL;
    }
    if (height % 8 != 0) {
        fprintf(stderr, "Height is not multiple of 8!\n");
        return NULL;
    }

    *size = width * height;

    int palette[4] = {-1, -1, -1, -1};

    for (int i=0; i< width*height; i++) {
        for (int j=0; j < 4; j++) {
            if (palette[j] == data[i]) goto cont;
            if (palette[j] == -1) {
                palette[j] = data[i];
                goto cont;
            }
        }
        fprintf(stderr, "Palette has more than 4 colors!\n");
        return NULL;
        cont: ;
    }

#define SWAP(d, x,y) if (d[y] < d[x]) { int tmp = d[x]; d[x] = d[y]; d[y] = tmp; }
    SWAP(palette, 0, 1);
    SWAP(palette, 2, 3);
    SWAP(palette, 0, 2);
    SWAP(palette, 1, 3);
    SWAP(palette, 1, 2);
#undef SWAP

    for (int i=0; i< width*height; i++) {
        for (int j=0; j < 4; j++) {
            if (palette[j] == data[i]) {
                data[i] = default_palette[j];
            }
        }
    }

    return data;
}

void write_png(const char* filename, const uint8_t *data, const uint32_t size) {
    int width = 128;
    int height = size / 128;
    stbi_write_png(filename, width, height, 1, data, 0);
}


uint8_t *read_chr(const char *filename, uint32_t *size) {
    return file_read(filename, size);
}

void write_chr(const char* filename, const uint8_t *data, const uint32_t size) {
    file_write(filename, data, size);
}


// 2 8x8 bit-planes (16 bytes) -> 8x8 pixel (64 bytes)
uint8_t *chr2png(const uint8_t *in_data, const uint32_t in_size, uint32_t *out_size) {
    int tiles = in_size / 16;
    int cols = 128 / 8; 
    int rows = tiles / cols;
    int width = 128;
    int height = rows * 8;

    uint8_t *out_data = malloc(width * height);
    *out_size = width * height;

    if (out_data == NULL) return NULL;

    for (int t = 0; t < tiles; t++) {
        int tx = (t % 16) * 8;
        int ty = (t / 16) * 8;
        for (int y = 0; y < 8; y++) {
            uint8_t d1 = in_data[16 * t + y + 0];
            uint8_t d2 = in_data[16 * t + y + 8];
            for (int x = 0; x < 8; x++) {
                uint8_t idx = ((d1 >> (7-x)) & 1) | ((d2 >> (7-x)) & 1) << 1;
                out_data[(ty+y) * width + tx + x] = default_palette[idx];
            }
        }
    }

    return out_data;
}

// assumes that data is [128, 8*n]
uint8_t *png2chr(const uint8_t *in_data, const uint32_t in_size, uint32_t *out_size) {
    int width = 128;
    int height = in_size / width;
    int rows = height / 8;
    int cols = width / 8;
    int tiles = in_size / 64;

    uint8_t *out_data = malloc(tiles * 16);
    *out_size = tiles * 16;

    if (out_data == NULL) return NULL;

    int i = 0;
    for (int r = 0; r < rows; r++) 
    for (int c = 0; c < cols; c++) {
        for (int y = 0; y < 8; y++) {
            uint8_t d = 0;
            for (int x = 0; x < 8; x++) {
                d =  (d << 1) | ((in_data[8*128*r+128*y+8*c+x] >> 0) & 1);
            }
            out_data[i++] = d;
        }
        for (int y = 0; y < 8; y++) {
            uint8_t d = 0;
            for (int x = 0; x < 8; x++) {
                d =  (d << 1) | ((in_data[8*128*r+128*y+8*c+x] >> 1) & 1);
            }
            out_data[i++] = d;
        }
    }
    
    return out_data;
}






static const char *const usages[] = {
    "png2chr <input file> [-r] [-o <output file>]",
    NULL,
};

int main(int argc, const char* argv[]) {
    char* o_filename = NULL;
    int reverse = 0;

    struct argparse_option options[] = {
        OPT_HELP(),
        OPT_BOOLEAN('r', "reverse", &reverse, "reverses the operation", NULL, 0, 0),
        OPT_STRING('o', "output", &o_filename, "if this option is not present the output will be placed to stdout", NULL, 0, 0),
        OPT_END(),
    };

    struct argparse argparse;
    argparse_init(&argparse, options, usages, 0);
    // argparse_describe(&argparse, "\nA brief description of what the program does and how it works.", "\nAdditional description of the program after the description of the arguments.");
    argc = argparse_parse(&argparse, argc, argv);

    if (argc < 1) {
        fprintf(stderr, "No input file!\n");
        return -1;
    }

    if (o_filename == NULL) {
        fprintf(stderr, "No output file!\n");
        return -1;
    }

    const char *i_filename = argv[0];
    
    if (reverse == 0) {
        uint32_t i_size, o_size;
        uint8_t *i_data = read_png(i_filename, &i_size);
        if (i_data == NULL) return -1;
        uint8_t *o_data = png2chr(i_data, i_size, &o_size);
        if (o_data == NULL) {
            free(i_data);
            return -1;
        }
        write_chr(o_filename, o_data, o_size);
        free(i_data);
        free(o_data);
    } else {
        uint32_t i_size, o_size;
        uint8_t *i_data = read_chr(i_filename, &i_size);
        if (i_data == NULL) return -1;
        uint8_t *o_data = chr2png(i_data, i_size, &o_size);
        if (o_data == NULL) {
            free(i_data);
            return -1;
        }
        write_png(o_filename, o_data, o_size);
        free(i_data);
        free(o_data);
    }

    return 0;
}

