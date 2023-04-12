CC = clang
AR = ar rcs
RM = rm -rf
SHELL = bash

E2FS_DEF_DEFINES = \
    -Wall \
    -Werror \
    -Wno-pointer-arith \
    -Wno-sign-compare \
    -Wno-type-limits \
    -Wno-typedef-redefinition \
    -Wno-unused-parameter

ifeq ($(shell uname -s | cut -d "-" -f 1), CYGWIN_NT)
# Not a big issue
E2FS_DEF_DEFINES += -Wno-char-subscripts
endif

override CFLAGS := $(CFLAGS) $(E2FS_DEF_DEFINES) -I./

libext2_uuid_src = \
    clear.c \
    compare.c \
    copy.c \
    gen_uuid.c \
    isnull.c \
    pack.c \
    parse.c \
    unpack.c \
    unparse.c \
    uuid_time.c 
libext2_uuid_obj = $(patsubst %.c,obj/%.o,$(libext2_uuid_src))

.PHONY: all

all: .lib/libext2_uuid.a

obj/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\t    CC\t    $@"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

.lib/libext2_uuid.a: $(libext2_uuid_obj)
	@mkdir -p `dirname $@`
	@echo -e "\tAR    \t$@"
	@$(AR) $@ $^

clean:
	$(RM) obj .lib
