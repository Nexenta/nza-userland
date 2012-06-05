#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
#
#Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		postgresql
COMPONENT_VERSION=	8.4.11
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:b12084003937d8ed59287b6db2508e098ac52953
COMPONENT_ARCHIVE_URL=	http://ftp.postgresql.org/pub/source/v8.4.11/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk


COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR) $(@D))

#This macro will help to look for the configure 
#file at the pointed location 


CONFIGURE_OPTIONS 	+= CFLAGS="$(CFLAGS)"
CONFIGURE_OPTIONS	+= --with-tcl
CONFIGURE_OPTIONS.32	+= --with-perl
CONFIGURE_OPTIONS	+= --with-python
CONFIGURE_OPTIONS	+= --enable-debug
CONFIGURE_OPTIONS	+= --enable-nls
CONFIGURE_OPTIONS	+= --with-pam
CONFIGURE_OPTIONS	+= --with-gssapi
CONFIGURE_OPTIONS	+= --with-openssl
CONFIGURE_OPTIONS	+= --with-libxml
CONFIGURE_OPTIONS	+= --with-libxslt
CONFIGURE_OPTIONS	+= --enable-integer-datetimes
CONFIGURE_OPTIONS	+= --enable-thread-safety
CONFIGURE_OPTIONS	+= --with-tclconfig=/usr/lib
CONFIGURE_OPTIONS	+= --with-tkconfig=/usr/lib
CONFIGURE_OPTIONS	+= --with-pgport=5432

COMPONENT_TEST_TARGETS = test

# common targets
build:		$(BUILD_32_and_64)

install:	$(INSTALL_32_and_64)  

test: 		$(TEST_32_and_64)


BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
