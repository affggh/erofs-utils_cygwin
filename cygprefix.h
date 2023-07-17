#ifndef __CYGPREFIX_H
#define __CYGPREFIX_H

// Prefix some issues
#include <stdlib.h>

// When i update cygwin, i meet these errors... func below from stdlib.h
#ifndef __builtin_malloc
void	*__builtin_malloc(size_t) __malloc_like __result_use_check __alloc_size(1) _NOTHROW;
#endif

#ifndef __builtin_free
void	__builtin_free (void *) _NOTHROW;
#endif

#ifdef __CYGWIN__
#define off64_t off_t // libext2
#define typeof __typeof // libcutils

// libsparse + -Wno-macro-redefined
#define lseek64 lseek
#define ftruncate64 ftruncate
#endif // __CYGWIN__
#endif