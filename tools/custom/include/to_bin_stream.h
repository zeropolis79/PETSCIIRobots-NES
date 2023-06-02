#ifndef TO_BIN_STREAM_H
#define TO_BIN_STREAM_H

#include <stdio.h>

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif
#ifdef __BORLANDC__
#define _setmode setmode
#endif

extern int to_bin_stream(FILE* fp) {
#ifdef _WIN32
    return _setmode(_fileno(fp), _O_BINARY);
#else
    if (freopen(0, "wb", fp) == 0)
        return -1;
    return 0;
#endif
}

#endif // TO_BIN_STREAM_H
