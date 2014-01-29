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
# Copyright (c) 2014 Nexenta Systems, Inc.  All rights reserved.

include ../../make-rules/shared-macros.mk

COMPONENT_NAME= clang
LLVM_NAME=llvm
CLANG_NAME=cfe

REQUIRES_RTTI=1

COMPONENT_VERSION= 3.3
COMPONENT_SUMMARY= LLVM tools and Clang compiler
COMPONENT_SRC= $(LLVM_NAME)-$(COMPONENT_VERSION).src
COMPONENT_ARCHIVE= $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH= \
  sha256:68766b1e70d05a25e2f502e997a3cb3937187a3296595cf6e0977d5cd6727578
COMPONENT_ARCHIVE_URL= \
  http://llvm.org/releases/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL = http://llvm.org/

COMPONENT_ARCHIVE_1=    $(CLANG_NAME)-$(COMPONENT_VERSION).src.tar.gz
COMPONENT_ARCHIVE_HASH_1= \
    sha256:b1b55de4ab3a57d3e0331a83e0284610191c77d924e3446498d9113d08dfb996
COMPONENT_ARCHIVE_URL_1= http://llvm.org/releases/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE_1)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

CONFIGURE_PREFIX= /usr/clang/$(COMPONENT_VERSION)

PATH=/opt/gcc-4.7.2/bin:/usr/sbin:/usr/bin:/usr/perl5/bin
GCC_ROOT=/opt/gcc-4.7.2/

COMPONENT_PRE_PATCH_ACTION += tar -xzf $(COMPONENT_ARCHIVE_1) && \
	mv $(CLANG_NAME)-$(COMPONENT_VERSION).src $(COMPONENT_SRC)/tools/clang

COMPONENT_PRE_CONFIGURE_ACTION = (/usr/gnu/bin/cp -a $(SOURCE_DIR)/* $(@D))

CONFIGURE_OPTIONS += --enable-optimized
CONFIGURE_OPTIONS += --disable-assertions
CONFIGURE_OPTIONS += --enable-targets=x86,cpp
CONFIGURE_OPTIONS += --enable-pic=yes
CONFIGURE_OPTIONS += --enable-docs=no

build: $(BUILD_32)

install: $(INSTALL_32)
