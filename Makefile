CC = clang
CXX = clang++
AR = ar rcs
STRIP = llvm-strip
LD = clang++
LDFLAGS =
SHELL = bash
RM = rm -rf
CP = cp -f

ifeq ($(shell uname -s | cut -d "-" -f 1 | cut -d "_" -f 2), NT)
ext = .exe
else
ext = 
endif

EROFS_DEF_DEFINES = \
    -Wall \
    -Werror \
    -Wno-error=\#warnings \
    -Wno-ignored-qualifiers \
    -Wno-pointer-arith \
    -Wno-unused-parameter \
    -Wno-unused-function \
    -DHAVE_FALLOCATE \
    -DHAVE_LINUX_TYPES_H \
    -DHAVE_LIBSELINUX \
    -DHAVE_LIBUUID \
    -DLZ4_ENABLED \
    -DLZ4HC_ENABLED \
    -DWITH_ANDROID \
    -DHAVE_MEMRCHR \
    -DHAVE_SYS_IOCTL_H \
    -DHAVE_LLISTXATTR \
    -DHAVE_LGETXATTR


# Add cygwin remove unsupport flags
ifeq ($(shell uname -s | cut -d "-" -f 1), CYGWIN_NT)
EROFS_DEF_REMOVE = -DHAVE_LINUX_TYPES_H -DHAVE_FALLOCATE
override EROFS_DEF_DEFINES := $(filter-out $(EROFS_DEF_REMOVE),$(EROFS_DEF_DEFINES))
endif

# Add on for extract.erofs
CXXFLAGS += -DNDEBUG

ifeq ($(shell uname -s | cut -d "-" -f 1), CYGWIN_NT)
CXXFLAGS += -stdlib=libc++ -static
endif

override CFLAGS := $(CFLAGS) $(EROFS_DEF_DEFINES)
override CXXFLAGS := $(CXXFLAGS) $(EROFS_DEF_DEFINES) -std=c++17 

INCLUDES = \
    -I./include \
    -I./libext2_uuid \
    -include"erofs-utils-version.h" \
    -I./lz4/lib \
    -I./libselinux/include \
    -I./libcutils/include \
    -I./extract/extract/include

liberofs_src = $(shell find lib -name \*.c)
liberofs_obj = $(patsubst %.c,obj/%.o,$(liberofs_src))

mkfs_src = $(shell find mkfs -name \*.c)
mkfs_obj = $(patsubst %.c,obj/%.o,$(mkfs_src))

fsck_src = $(shell find fsck -name \*.c)
fsck_obj = $(patsubst %.c,obj/%.o,$(fsck_src))

dump_src = $(shell find dump -name \*.c)
dump_obj = $(patsubst %.c,obj/%.o,$(dump_src))

# Addon extract.erofs
ifeq ($(shell [ -d "extract" ] && echo "true"), true)
extract_src = $(shell find extract/extract -name \*.cpp)
extract_obj = $(patsubst %.cpp,obj/%.o,$(extract_src))
endif

version_header = erofs-utils-version.h
all_lib_prefix = \
    erofs \
    cutils \
    base \
    ext2_uuid \
    log \
    lz4 \
    selinux
ifeq ($(shell uname -s | cut -d "-" -f 1), CYGWIN_NT)
# linux can install libpcre++-dev like debian
all_lib_prefix += pcre
else
LDFLAGS += -lpcre
endif
all_lib = $(patsubst %,.lib/lib%.a,$(all_lib_prefix))

all_bin_prefix = \
    mkfs \
    fsck \
    dump
ifeq ($(shell [ -d "extract" ] && echo "true"), true)
all_bin_prefix += extract
endif

all_bin = $(patsubst %,bin/%.erofs$(ext),$(all_bin_prefix))

.PHONY: all

all: lib bin

lib: $(version_header) $(all_lib)

bin: $(all_bin)

obj/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\t    CC\t    $@"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\t    CC\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

erofs-utils-version.h:
	@echo -e "\tGEN    \t$@"
	@echo "#define PACKAGE_VERSION \"$(shell ./scripts/cyg-get-version-number)\"" > $@

.lib/liberofs.a: $(liberofs_obj)
	@mkdir -p `dirname $@`
	@echo -e "\tAR    \t$@"
	@$(AR) $@ $^

.lib/libbase.a:
	@mkdir -p `dirname $@`
	@$(MAKE) -C libbase
	@$(CP) ./libbase/$@ $@

.lib/libcutils.a:
	@mkdir -p `dirname $@`
	@$(MAKE) -C libcutils
	@$(CP) ./libcutils/$@ $@

.lib/libext2_uuid.a:
	@mkdir -p `dirname $@`
	@$(MAKE) -C libext2_uuid
	@$(CP) ./libext2_uuid/$@ $@

.lib/liblog.a:
	@mkdir -p `dirname $@`
	@$(MAKE) -C logging
	@$(CP) ./logging/$@ $@

.lib/liblz4.a:
	@mkdir -p `dirname $@`
	@$(MAKE) -C lz4 lib
	@$(CP) ./lz4/lib/`basename $@` $@

# I have no interest support this on cygwin
# cause aosp is also not support lzma compression
# you fan fill this up if you want lzma compression
.lib/liblzma.a:

.lib/libselinux.a:
	@mkdir -p `dirname $@`
	@$(MAKE) -C libselinux
	@$(CP) ./libselinux/$@ $@ 

# Cygwin does not support libpcre.a
# We can only link dynamicly
# But with libpcre source, we still can
# link this program static
.lib/libpcre.a:
	@mkdir -p `dirname $@`
#	@cd libpcre && ./autogen.sh && ./configure && $(MAKE)
	@$(CP) libpcre/.libs/`basename $@` $@

bin/mkfs.erofs$(ext): $(mkfs_obj) $(all_lib)
	@mkdir -p `dirname $@`
	@echo -e "\tLD\t    $@"
	@$(LD) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

bin/fsck.erofs$(ext): $(fsck_obj) $(all_lib)
	@mkdir -p `dirname $@`
	@echo -e "\tLD\t    $@"
	@$(LD) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

bin/dump.erofs$(ext): $(dump_obj) $(all_lib)
	@mkdir -p `dirname $@`
	@echo -e "\tLD\t    $@"
	@$(LD) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

# Add on unoffical extract program
bin/extract.erofs$(ext): $(extract_obj) $(all_lib)
	@mkdir -p `dirname $@`
	@echo -e "\tLD\t    $@"
	@$(LD) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

clean: 
	@echo -e "\tRM    \tobj .lib bin"
	@$(RM) obj .lib bin erofs-utils-version.h
	@$(MAKE) -C libbase clean
	@$(MAKE) -C libcutils clean
	@$(MAKE) -C libext2_uuid clean
	@$(MAKE) -C logging clean
	@$(MAKE) -C lz4 clean
	@$(MAKE) -C libselinux clean
ifeq ($(shell [ -e "libpcre/Makefile" ] && echo "true"), true)
	@$(MAKE) -C libpcre clean
endif