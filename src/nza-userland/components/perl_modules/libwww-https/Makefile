include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  LWP-Protocol-https
COMPONENT_VERSION  =  6
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION).02
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:476a62275bf5ae89dd6799d8f660071dba1819b9
COMPONENT_ARCHIVE_URL  = http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

