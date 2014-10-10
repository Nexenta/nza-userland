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
# Copyright (c) 2014, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = apt
IPS_COMPONENT_VERSION  = 0.9.7.9
COMPONENT_VERSION      = $(IPS_COMPONENT_VERSION)+deb7u6
COMPONENT_SRC          = $(COMPONENT_NAME)-$(IPS_COMPONENT_VERSION)+deb7u4
COMPONENT_PROJECT_URL  = http://debian.org
COMPONENT_ARCHIVE      = $(COMPONENT_NAME)_$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:c87899f8ec4e97daebf438bf9ea47dc7a501ccde
COMPONENT_ARCHIVE_URL  = http://security.debian.org/debian-security/pool/updates/main/a/apt/$(COMPONENT_ARCHIVE)
DEBVERSION=40-0-11

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk

COMPONENT_PREP_ACTION = \
        (cd $(@D) ; \
            aclocal -I buildlib; \
            libtoolize --copy --force --install; \
            automake --add-missing --copy ; \
            autoconf )

COMPONENT_PRE_CONFIGURE_ACTION = \
    ($(CLONEY) $(SOURCE_DIR) $(@D))

CONFIGURE_OPTIONS += --libexecdir=/usr/lib/apt/methods

build:	$(BUILD_32) run-parts perl-build-stamp

$(BUILD_DIR_32)/.installed:
	$(MKDIR) $(PROTO_DIR)/usr/bin $(PROTO_DIR)/usr/lib
	$(CP) $(BUILD_DIR_32)/bin/apt-* $(PROTO_DIR)/usr/bin/
	$(CP) $(BUILD_DIR_32)/bin/libapt-pkg.so.4.12.0 $(PROTO_DIR)/usr/lib/
	$(CP) $(BUILD_DIR_32)/bin/libapt-inst.so.1.5.0 $(PROTO_DIR)/usr/lib/
	$(MKDIR) $(PROTO_DIR)/usr/lib/apt/methods
	$(CP) $(BUILD_DIR_32)/bin/methods/* $(PROTO_DIR)/usr/lib/apt/methods/
	$(MKDIR) $(PROTO_DIR)/usr/lib/dpkg/methods/apt
	$(MKDIR) $(PROTO_DIR)/usr/share
	$(CP) -r $(BUILD_DIR_32)/locale $(PROTO_DIR)/usr/share/
	$(MKDIR) $(PROTO_DIR)/etc/apt/apt.conf.d
	$(MKDIR) $(PROTO_DIR)/usr/share/man/man8
	$(MKDIR) $(PROTO_DIR)/usr/share/man/man5
	$(MKDIR) $(PROTO_DIR)/usr/share/man/man1
	$(CP) $(SOURCE_DIR)/doc/*.8 $(PROTO_DIR)/usr/share/man/man8/
	$(CP) $(SOURCE_DIR)/doc/*.5 $(PROTO_DIR)/usr/share/man/man5/
	$(CP) $(SOURCE_DIR)/doc/*.1 $(PROTO_DIR)/usr/share/man/man1/
	$(MKDIR) $(PROTO_DIR)/usr/include
	$(CP) -r $(BUILD_DIR_32)/include/apt-pkg $(PROTO_DIR)/usr/include/
	$(TOUCH) $@

install:  $(INSTALL_32) run-parts perl-install-stamp

# run-parts is a part of debianutils,
# it is used by apt-key. No other program from debianutils
# is used, so run-parts shipped with APT.
run-parts: BITS=32
run-parts: run-parts.c
	$(CC) \
		-DPACKAGE_VERSION="\"4.1 (a part of APT)\"" \
		-DHAVE_GETOPT_H=1 \
		-o $@ $<

# We will use local -lapt-pkg:
perl-build-stamp: $(BUILD_32)
	LIBS="-L$(BUILD_DIR_32)/apt-pkg/.libs -lapt-pkg" \
	$(GMAKE) -f Makefile.perl build
	touch $@

perl-install-stamp: perl-build-stamp
	$(GMAKE) -f Makefile.perl install
	touch $@

clean::
	$(GMAKE) -f Makefile.perl clean
	$(RM) run-parts
	$(RM) perl-*-stamp


test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
