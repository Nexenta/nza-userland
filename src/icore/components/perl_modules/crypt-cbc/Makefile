include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  Crypt-CBC
COMPONENT_VERSION  =  2.30
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:fd8c984fc76aee67dc812c8ac10f8979526fd687
COMPONENT_ARCHIVE_URL  = http://search.cpan.org/CPAN/authors/id/L/LD/LDS/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

