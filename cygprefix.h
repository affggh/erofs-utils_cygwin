// Prefix some issues

#ifdef __CYGWIN__
#define off64_t off_t // libext2
#define typeof __typeof // libcutils

// libsparse + -Wno-macro-redefined
#define lseek64 lseek
#define ftruncate64 ftruncate
#endif // __CYGWIN__