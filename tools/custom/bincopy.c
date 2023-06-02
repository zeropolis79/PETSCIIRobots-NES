#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define ARGPARSE_IMPLEMENTATION
#include "argparse.h"

#include "files.h"
#include "to_bin_stream.h"


static const char *const usages[] = {
    "bin_copy <input file> [-s <start offset>] [-l <num of bytes>] [-o <output file>]",
    NULL,
};

int main(int argc, const char* argv[]) {
    int start = 0;
    int length = -1;
    const char* i_filename = NULL;
    const char* o_filename = NULL;

    struct argparse_option options[] = {
        OPT_HELP(),
        OPT_INTEGER('s', "start", &start, "default: 0", NULL, 0, 0),
        OPT_INTEGER('l', "length", &length, "", NULL, 0, 0),
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

    if (length < 1) {
        fprintf(stderr, "Invalid length!\n");
        return -1;
    }

    i_filename = argv[0];

    uint32_t data_size;
    uint8_t* data = file_read(i_filename, &data_size);

    if (data == NULL) {
        return -1;
    }
    if (data_size < start + length) {
        fprintf(stderr, "Invalid start+length > %d!\n", data_size);
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

    for (int i = start; i < start + length; i++) {
        fputc(data[i], fp_w);
    }

    if (fp_w != stdout)
        fclose(fp_w);

    free(data);

    return 0;
}
