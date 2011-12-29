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
include ../../make-rules/shared-macros.mk
COMPONENT_NAME         = rrdtool
COMPONENT_VERSION      = 1.4.3
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  = http://oss.oetiker.ch/rrdtool/
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:1e65de0192c149a30ee0d277e758a31ff7d6d6f0
COMPONENT_ARCHIVE_URL  = http://oss.oetiker.ch/rrdtool/pub/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

CONFIGURE_OPTIONS += --disable-lua
CONFIGURE_OPTIONS += --disable-tcl
CONFIGURE_OPTIONS += --disable-ruby
CONFIGURE_OPTIONS += --enable-perl-site-install
CONFIGURE_OPTIONS += --with-perl-options='INSTALLDIRS=vendor'

COMPONENT_PRE_CONFIGURE_ACTION = \
	$(CLONEY) $(SOURCE_DIR) $(@D)

build: $(BUILD_32_and_64)

test: $(NO_TEST)

install: $(INSTALL_32_and_64)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

