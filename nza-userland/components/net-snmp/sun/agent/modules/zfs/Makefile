#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2013 Nexenta Systems, Inc.  All rights reserved.
#

LIBSRCS = \
	arc_access.c	\
	zfs.c

LIB = libzfs_snmp.so.1

OBJECTS = $(LIBSRCS:%.c=%.o)

SNMPLIBS = -lnetsnmp -lnetsnmphelpers -lnetsnmpagent -lnvpair -lumem -lkstat \
	-lzfs_core -ldevid -lc

LDLIBS = $(SNMPLIBS)

CFLAGS_sparcv9 = -m64
CFLAGS_amd64 = -m64
CFLAGS_32 = -m32
CFLAGS_cc = -xsb -K PIC -xc99
CFLAGS_gcc = -fPIC -std=c99
CFLAGS += $(CFLAGS_$(COMPILER)) $(CFLAGS_$(ARCH)) -DPIC -DDEBUG -D_TS_ERRNO
LDFLAGS_cc += -G
LDFLAGS_gcc += -shared 
LDFLAGS += $(LDFLAGS_$(COMPILER)) -h$(LIB) -ztext -zdefs -Bdirect $(LDLIBS)

%.o: %.c
	$(COMPILE.c) -o $@ $<

$(LIB):	$(OBJECTS)
	if [[ -z "$(CFLAGS_$(COMPILER))" || -z "$(LDFLAGS_$(COMPILER))" ]]; then \
		print -u2 "unknown compiler: \"$(COMPILER)\"" ; \
		exit 1; \
	fi; \
	if [[ -z "$(CFLAGS_$(ARCH))" ]]; then \
		print -u2 "unknown or unsupported architecture: \"$(ARCH)\"" ; \
		exit 1; \
	fi; \
	$(LINK.c) -o $@ $(OBJECTS)

all:	$(LIB)

clean:
	rm -f $(OBJECTS) $(LIB)

DESTDIR_sparcv9 = $(ROOT)/$(CFGLIB64)
DESTDIR_amd64 = $(ROOT)/$(CFGLIB64)
DESTDIR_32 = $(ROOT)/$(CFGLIB)
DESTDIR = $(DESTDIR_$(ARCH))
install: $(LIB)
	if [[ -z "$(DESTDIR_$(ARCH))" ]]; then \
		print -u "unknown architecture: \"$(ARCH)\""; \
		exit 1; \
	fi; \
	cp $(LIB) $(DESTDIR)
