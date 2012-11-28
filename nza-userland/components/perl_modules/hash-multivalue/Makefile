include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  Hash-MultiValue
COMPONENT_VERSION  =  0
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION).13
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:98352f2d2bdc9e735be3b698ed0bd2f1ca8410ea
COMPONENT_ARCHIVE_URL  = http://search.cpan.org/CPAN/authors/id/M/MI/MIYAGAWA/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

