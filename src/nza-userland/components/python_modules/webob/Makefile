include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  WebOb
COMPONENT_VERSION  =  1.2b2
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).zip
COMPONENT_ARCHIVE_HASH = sha1:9475bf6b0445d8bd2783e7152468eb62007d0b37
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/W/WebOb/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

