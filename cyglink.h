#ifndef __CYGLINK_H
#define __CYGLINK_H

#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <unistd.h>
// Win32api
#include <windef.h>
#include <fileapi.h>

// utf8 -> utf16
#include <iconv.h>

// Override symlink as cyglink
#define symlink cyglink

#define __CYGLINK_MAGIC "!<symlink>"
#define __CYGLINK_BOM "\xff\xfe"
#define __CYGLINK_BUFSZ 1024

// Create a file with header magic which
// cygwin can detect it as a link
// if success return 0, else return 1
static inline int cyglink(const char *oldpath, const char *newpath) 
{
    int fd;
    size_t utf8len = strlen(oldpath);
    char *buf = (char *)malloc(__CYGLINK_BUFSZ);
    char *in = (char*)oldpath;
    size_t inbytesleft = utf8len;
    char *out = buf;
    size_t outbytesleft = __CYGLINK_BUFSZ;
    iconv_t conv = iconv_open("UTF-16LE", "UTF-8");
    if (conv == (iconv_t)(-1))
    {
        perror("iconv_open failed");
        return -1;
    }
    size_t result = iconv(conv, &in, &inbytesleft, &out, &outbytesleft);
    if (result == (size_t)(-1))
    {
        perror("iconv failed");
        return -1;
    }

    fd = open(newpath, O_CREAT | O_TRUNC | O_RDWR);
    if(!fd) {
        fprintf(stderr, "Error: Symlink %s create failed !\n", oldpath);
        return 1;
    }

    write(fd, __CYGLINK_MAGIC, sizeof(__CYGLINK_MAGIC)-1);
    write(fd, __CYGLINK_BOM, sizeof(__CYGLINK_BOM)-1);
    write(fd, buf, __CYGLINK_BUFSZ - outbytesleft + 2);

    close(fd);
    free(buf);
    iconv_close(conv);
    chmod(newpath, 0755);
    SetFileAttributesA(newpath, FILE_ATTRIBUTE_NORMAL | FILE_ATTRIBUTE_SYSTEM);
    return 0;
}

#endif // __CYGLINK_H