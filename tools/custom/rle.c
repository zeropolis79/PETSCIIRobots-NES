#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define ARGPARSE_IMPLEMENTATION
#include "argparse.h"

#include "files.h"
#include "to_bin_stream.h"


uint8_t repeat_flag = 0x60;

int count_repeat(const uint8_t* src, int offset, int size) {
    int index = offset;
    while (1) {
        if (index >= size) break;
        if ((index - offset) == 255) break;
        if (src[index] != src[offset]) break;
        index++;
    }
    return (index - offset);
}

void rle_compress(FILE *fp, const uint8_t* src, int size) {
    int j = 0;
    for (int i = 0; i < size;) {
        if (src[i] == repeat_flag) {
            fputc(repeat_flag, fp);
            fputc(1, fp);
            fputc(repeat_flag, fp);
            i++;
        } else {
            uint8_t rpt = count_repeat(src, i, size) & 0xFF;
            if (rpt < 4) {
                fputc(src[i], fp);
                i++;
            } else {
                fputc(repeat_flag, fp);
                fputc(rpt, fp);
                fputc(src[i], fp);
                i += rpt;
            }
        }
    }
}

int rle_decompress(FILE *fp, const uint8_t* src, int size) {
    int j = 0;
    for (int i = 0; i < size;) {
        uint8_t d = src[i++];
        if (d != repeat_flag) {
            fputc(d, fp);
        } else {
            uint8_t r = src[i++];
            uint8_t c = src[i++];
            for (int k = 0; k < r; k++) {
                fputc(c, fp);
            }
        }
    }
}


static const char *const usages[] = {
    "rle <input file> -c [-r <repeat flag>] [-o <output file>] [-z]",
    "rle <input file> -d [-r <repeat flag>] [-o <output file>]",
    NULL,
};

int main(int argc, const char* argv[]) {
    int compress = 0;
    const char* i_filename = NULL;
    const char* o_filename = NULL;
    int zeroend = 0;

    struct argparse_option options[] = {
        OPT_HELP(),
        OPT_BIT('c', "compress", &compress, "compress a file with RLE", NULL, 1, OPT_NONEG),
        OPT_BIT('d', "decompress", &compress, "decomprpess a RLE file", NULL, 2, OPT_NONEG),
        OPT_INTEGER('r', "repeat-flag", &repeat_flag, "defines with character to use as repeat flag. default: 0x60", NULL, 0, 0),
        OPT_BOOLEAN('z', "zero-end", &zeroend, "appends a zero repeat element to mark the end of a RLE compressed file", NULL, 0, 0),
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

    if (compress != 1 && compress != 2) {
        fprintf(stderr, "Invalid options!\n");
        return -1;
    }

    i_filename = argv[0];

    uint32_t src_size;
    uint8_t* src = file_read(i_filename, &src_size);

    if (src == NULL) {
        return -1;
    }

    FILE *fp_w;
    if (o_filename != NULL) {
        fp_w = fopen(o_filename, "wb");
        if (fp_w == NULL) {
            fprintf(stderr, "Could not open output file \"%s\"!\n", o_filename);
            return -1;
        }
    } else {
        if (to_bin_stream(stdout) == -1) {
            fprintf(stderr, "could not convert stdout to bin\n");
            return -1;
        }
        fp_w = stdout;
    }

    if (compress == 1)
        rle_compress(fp_w, src, src_size);
    else
        rle_decompress(fp_w, src, src_size);


    if (zeroend == 1) {
        fputc(repeat_flag, fp_w);
        fputc(0, fp_w);
        fputc(0, fp_w);
    }

    if (fp_w != stdout)
        fclose(fp_w);

    free(src);

    return 0;
}
