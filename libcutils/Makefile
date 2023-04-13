CXX = clang++
AR = ar rcs
RM = rm -rf
SHELL = bash

override CXXFLAGS := $(CXXFLAGS) -std=c++17

ifeq ($(shell uname -s | cut -d "-" -f 1), CYGWIN_NT)
CXXFLAGS += -stdlib=libc++ -static
endif

libcutils_src = \
    config_utils.cpp \
    iosched_policy.cpp \
    load_file.cpp \
    native_handle.cpp \
    properties.cpp \
    record_stream.cpp \
    strlcpy.c \
    threads.cpp \
    fs.cpp \
    hashmap.cpp \
    multiuser.cpp \
    str_parms.cpp \
    ashmem-host.cpp \
    canned_fs_config.cpp \
    fs_config.cpp \
    trace-host.cpp

ifeq ($(shell uname -s | cut -d "_" -f1), MINGW64)
remove_src = fs.cpp multiuser.cpp ashmem-host.cpp
libcutils_src := $(filter-out $(remove_src),$(libcutils_src))
endif

libcutils_obj = $(patsubst %.cpp,obj/%.o,$(libcutils_src))
libcutils_cxxflags = $(CXXFLAGS) \
    -Wall \
    -Werror \
    -Wextra \
    -Wno-exit-time-destructors \
    -include"../cygprefix.h"

ifeq ($(shell uname -s | cut -d "-" -f 1), CYGWIN_NT)
# Not a big issue
libcutils_cxxflags += -D_Bool=bool
endif

.PHONY: all

all: .lib/libcutils.a

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\t    CPP\t    $@"
	@$(CXX) $(libcutils_cxxflags) -I../libbase/include -I../logging/liblog/include -I./include -c $< -o $@

.lib/libcutils.a: $(libcutils_obj)
	@mkdir -p `dirname $@`
	@echo -e "\tAR    \t$@"
	@$(AR) $@ $^

clean:
	$(RM) obj .lib
