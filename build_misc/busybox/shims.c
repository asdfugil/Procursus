/* Code placed here will be injected into busybox */

#include <sys/types.h>
#include <signal.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define COMMON_BUFSIZE 6
char bb_common_bufsiz1_obj[COMMON_BUFSIZE] __attribute__ ((__aligned__(sizeof(long long))));
char* bb_common_bufsiz1 = (char*)&bb_common_bufsiz1_obj;
struct lineedit_statics *lineedit_ptr_to_statics;
struct globals_misc     *ash_ptr_to_globals_misc;
struct globals_memstack *ash_ptr_to_globals_memstack;
struct globals_var      *ash_ptr_to_globals_var;

#ifdef errno
int * bb_errno;
#endif

struct globals *ptr_to_globals;;

#ifndef HAVE_MEMPCPY
void *mempcpy(void *dst, const void *src, size_t len)
{
	return memcpy(dst, src, len) + len;
}
#endif

#ifndef HAVE_MEMRCHR

/*
 * Reverse memchr()
 * Find the last occurrence of 'c' in the buffer 's' of size 'n'.
 */
void* memrchr(const void *s, int c, size_t n)
{
    const unsigned char *cp;

    if (n != 0) {
	cp = (unsigned char *)s + n;
	do {
	    if (*(--cp) == (unsigned char)c)
		return (void *)cp;
	} while (--n != 0);
    }
    return (void *)0;
}
#endif /* HAVE_MEMRCHR */


