include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  Net-HTTP
COMPONENT_VERSION  =  6
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION).09
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha256:52762b939d84806908ba544581c5708375f7938c3c0e496c128ca3fbc425e58d
COMPONENT_ARCHIVE_URL  = http://search.cpan.org/CPAN/authors/id/E/ET/ETHER/$(COMPONENT_ARCHIVE)
DEBVERSION:=40-0-4

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

