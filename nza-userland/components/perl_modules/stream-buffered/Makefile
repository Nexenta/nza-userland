include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  Stream-Buffered
COMPONENT_VERSION  =  0
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION).02
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:35d216f6a3b3b4c9112d928e2b9b9cfd7eeb9e47
COMPONENT_ARCHIVE_URL  = http://search.cpan.org/CPAN/authors/id/D/DO/DOY/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

