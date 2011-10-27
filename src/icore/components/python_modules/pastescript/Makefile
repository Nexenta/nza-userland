include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  PasteScript
COMPONENT_VERSION  =  1.7.4.2
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:7fafeec284e4d13ddb6be717acee5cbfe6f1e1ec
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/P/PasteScript/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

