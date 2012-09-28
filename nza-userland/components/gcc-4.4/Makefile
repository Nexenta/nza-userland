#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license
# at http://www.opensource.org/licenses/CDDL-1.0
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each file.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright (C) 2012, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk


COMPONENT_NAME         := gcc
COMPONENT_VERSION      := 4.4.7
COMPONENT_SRC          := $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  := http://gcc.gnu.org
COMPONENT_ARCHIVE      := $(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH := sha1:a6c834b0c2f58583da1d093de7a81a20ede9af75
COMPONENT_ARCHIVE_URL  := http://gcc.parentingamerica.com/releases/$(COMPONENT_SRC)/$(COMPONENT_ARCHIVE)


CONFIGURE_OPTIONS += \
--enable-languages='c,c++,fortran' \
--enable-shared \
--enable-ssp \
--enable-threads=posix \
--enable-tls \
--program-suffix=-4.4 \
--with-as=/usr/gnu/bin/as \
--with-gmp-include=/usr/include/gmp \
--with-gnu-as \
--with-ld=/usr/bin/ld \
--with-mpfr-include=/usr/include/mpfr \
--without-gnu-ld \


# This is COMPILER !!!!11
CFLAGS := -O2
CXXFLAGS := $(CFLAGS)
LDFLAGS :=

include ../../make-rules/prep.mk
include ../../make-rules/ips.mk
include ../../make-rules/configure.mk

build: $(BUILD_32)

install: $(INSTALL_32)


include ../../make-rules/depend.mk

