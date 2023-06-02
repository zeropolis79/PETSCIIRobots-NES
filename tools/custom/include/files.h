
#ifndef FILE_READ_H
#define FILE_READ_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

FILE *file_open(const char *filename, const char* mode) {
    FILE *fp = fopen(filename, mode);
    if (fp == NULL) {
        fprintf(stderr, "Could not open file \"%s\"!\n", filename);
        return NULL;
    }
    return fp;
}

uint32_t file_get_size(FILE * fp) {
    if (fseek(fp, 0L, SEEK_END) != 0) {
        fprintf(stderr, "Failed to get size!\n");
        return 0;
    }

    long bufsize = ftell(fp);

    if (bufsize == -1) {
        fprintf(stderr, "Failed to get size!\n");
        return 0; 
    }

    if (fseek(fp, 0L, SEEK_SET) != 0) {
        fprintf(stderr, "Failed to get size!\n");
        return 0; 
    }

    return (uint32_t) (bufsize & 0xFFFFFFFF);
}


uint8_t *file_read(const char *filename, uint32_t *filesize) {
    FILE *fp = file_open(filename, "rb");
    if (fp == NULL) return NULL;

    uint32_t bufsize = file_get_size(fp);
    if (bufsize == 0) {
        fclose(fp);
        return NULL;
    }

    uint8_t *source = malloc(sizeof(uint8_t) * bufsize);
    *filesize = bufsize;

    /* Read the entire file into memory. */
    size_t newLen = fread(source, sizeof(uint8_t), bufsize, fp);
    if (ferror(fp) != 0) {
        fprintf(stderr, "Error reading file \"%s\"!\n", filename);
        free(source);
        fclose(fp);
        source = NULL;
    }

    fclose(fp);

    return source;
}

bool file_write(const char *filename, const uint8_t *data, uint32_t filesize) {
    FILE *fp = file_open(filename, "wb");
    if (fp == NULL) return false;
    
    fwrite(data, sizeof(uint8_t), filesize, fp);

    fclose(fp);
    
    return true;
}

#endif // FILE_READ_H
