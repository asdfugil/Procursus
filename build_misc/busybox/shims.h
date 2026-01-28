#ifndef BB_SHIMS_H
#define BB_SHIMS_H

#include <string.h>
#include <signal.h>
#include <arpa/inet.h>

#define sigisemptyset(x) sigemptyset(x)

void *mempcpy(void *dst, const void *src, size_t len);
void* memrchr(const void *s, int c, size_t n);

#endif
