
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define ARGPARSE_IMPLEMENTATION
#include "argparse.h"

#define STBI_ONLY_PNG
#define STBI_ONLY_BMP
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include "files.h"


static const uint8_t default_palette[4] = { 0x00, 0x55, 0xAA, 0xFF };
static const uint8_t tile_mapping[256] = {
    0,0,0,0,3,3,3,3,3,0,3,3,3,3,0,3,
    3,3,3,3,3,3,3,0,2,3,3,3,3,2,2,2,
    2,2,2,2,2,2,0,2,2,2,2,2,2,2,2,2,
    3,3,3,2,3,3,3,2,3,3,2,2,2,2,3,3,
    3,3,3,3,3,3,3,3,3,0,0,3,3,3,3,3,
    3,3,3,3,3,0,3,3,3,0,3,3,3,3,3,3,
    0,0,0,0,0,0,0,0,3,3,3,2,3,3,0,0,
    3,3,3,0,0,0,3,3,2,1,1,1,1,1,1,1,
    3,3,0,2,2,2,0,2,2,2,3,0,0,0,0,3,
    3,3,3,3,0,0,0,0,3,3,2,2,3,3,2,0,
    0,0,0,0,0,0,3,0,0,0,3,0,3,3,3,0,
    3,3,3,3,3,3,3,0,3,3,3,3,3,0,3,3,
    3,3,3,3,2,2,2,2,2,2,3,3,2,1,1,1,
    0,0,0,2,2,2,1,2,3,3,3,2,3,3,3,2,
    3,3,3,1,1,1,1,1,1,1,1,1,3,3,0,0,
    0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
};

uint8_t *read_chr(const char *filename, uint32_t *size) {
    return file_read(filename, size);
}

uint8_t *lvl2png(const uint8_t *in_data, const uint32_t in_size, uint32_t *out_size) {
    uint8_t *out_data = malloc(in_size);
    *out_size = in_size;

    if (out_data == NULL) return NULL;

    for (int t = 0; t < in_size; t++) {
        out_data[t] = default_palette[tile_mapping[in_data[t]]];
    }

    return out_data;
}

void write_png(const char* filename, const uint8_t *data, const uint32_t size) {
    int width = 128;
    int height = size / 128;
    stbi_write_png(filename, width, height, 1, data, 0);
}



static const char *const usages[] = {
    "lvl2png <input file> [-o <output file>]",
    NULL,
};

int main(int argc, const char* argv[]) {
    char* o_filename = NULL;

    struct argparse_option options[] = {
        OPT_HELP(),
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
    
    uint32_t i_size, o_size;
    uint8_t *i_data = read_chr(i_filename, &i_size);
    if (i_data == NULL) return -1;
    uint8_t *o_data = lvl2png(i_data, i_size, &o_size);
    if (o_data == NULL) {
        free(i_data);
        return -1;
    }
    write_png(o_filename, o_data, o_size);
    free(i_data);
    free(o_data);

    return 0;
}

