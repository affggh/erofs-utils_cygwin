override CC = clang
override CXX = clang++

CFLAGS = -DAUDITD_LOG_TAG=1003 -Wno-pointer-bool-conversion

SHELL = bash

INCLUDES = -Iinclude

LIBSELINUX_SRC = \
    src/booleans.c \
    src/canonicalize_context.c \
    src/disable.c \
    src/enabled.c \
    src/fgetfilecon.c \
    src/fsetfilecon.c \
    src/getenforce.c \
    src/getfilecon.c \
    src/getpeercon.c \
    src/lgetfilecon.c \
    src/load_policy.c \
    src/lsetfilecon.c \
    src/policyvers.c \
    src/procattr.c \
    src/setenforce.c \
    src/setfilecon.c \
    src/context.c \
    src/mapping.c \
    src/stringrep.c \
    src/compute_create.c \
    src/compute_av.c \
    src/avc.c \
    src/avc_sidtab.c \
    src/get_initial_context.c \
    src/sestatus.c \
    src/deny_unknown.c \
    src/callbacks.c \
    src/check_context.c \
    src/freecon.c \
    src/init.c \
    src/label.c \
    src/label_file.c \
    src/label_android_property.c \
    src/label_support.c

ifeq ($(shell uname -s | cut -d"_" -f1), MINGW64)
filterout = \
    src/fgetfilecon.c \
    src/fsetfilecon.c \
    src/getfilecon.c \
    src/getpeercon.c \
    src/lgetfilecon.c \
    src/lsetfilecon.c \
    src/setfilecon.c \
    src/init.c
LIBSELINUX_SRC := $(filter-out $(filterout),$(LIBSELINUX_SRC)) mman.c
endif
LIBSELINUX_OBJ = $(patsubst %.c,obj/%.o,$(LIBSELINUX_SRC))

obj/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\033[94m\tCC\t$@\033[0m"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

.lib/libselinux.a: $(LIBSELINUX_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[94m\tAR\t$@\033[0m"
	@$(AR) rcs $@ $^

clean:
ifeq ($(shell [[ -d "obj" ]];echo $$?), 0)
	@echo -e "\033[94m\tRM\tobj\033[0m"
	@rm -rf obj
endif
ifeq ($(shell [[ -d ".lib" ]];echo $$?), 0)
	@echo -e "\033[94m\tRM\t.lib\033[0m"
	@rm -rf .lib
endif
