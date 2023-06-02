
#ifndef CHANGE_EXT_H
#define CHANGE_EXT_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void change_ext(char *buffer, const char *filename, const char *new_ext) {
    char *end = buffer + strlen(filename);

    memcpy(buffer, filename, strlen(filename) + 1);
    while (end > buffer && *end != '.' && *end != '\\' && *end != '/') --end;
    if ((end > buffer && *end == '.') && (*(end - 1) != '\\' && *(end - 1) != '/')) {
        *end = '\0';
    }
    strcat(buffer, ".");
    strcat(buffer, new_ext);
}

#endif // CHANGE_EXT_H
