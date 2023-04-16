#ifndef __CYGLINK_H
#define __CYGLINK_H

#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <unistd.h>
// Win32api
#include <windef.h>
#include <fileapi.h>

// Override symlink as cyglink
#define symlink cyglink

#define __CYGLINK_MAGIC "!<symlink>\xff\xfe"

// Create a file with header magic which
// cygwin can detect it as a link
static inline int cyglink(const char *oldpath, const char *newpath) 
{
    int fd;
    fd = open(newpath, O_CREAT | O_TRUNC | O_RDWR);
    if(!fd) {
        fprintf(stderr, "Error: Symlink %s create failed !\n", oldpath);
        return 1;
    }
    write(fd, __CYGLINK_MAGIC, sizeof(__CYGLINK_MAGIC)-1);
    for (int i=0;i<strlen(oldpath);i++) {
        write(fd, &oldpath[i], 1); write(fd, "\x00", 1);
    }
    write(fd, "\x00\x00", 2);
    close(fd);
    chmod(newpath, 0755);
    SetFileAttributesA(newpath, FILE_ATTRIBUTE_NORMAL | FILE_ATTRIBUTE_SYSTEM);
    return 0;
}

#endif // __CYGLINK_H