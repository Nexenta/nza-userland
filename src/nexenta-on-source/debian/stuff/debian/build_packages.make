#!/usr/bin/make -f


CWD=$(shell pwd)
TARGET_DIR=$(CWD)/debian/packages

define list_targets
	$(patsubst %,$1%,$(shell cd $(TARGET_DIR) && ls -1))
endef

build-packages: prepare $(call list_targets, build-package-)
	@echo "Build of packages finished"
	@failed_pkgs=`ls -1 $(PKG_BUILD_LOGS_DIR)/*.failed 2>/dev/null`;\
	if test "x$$failed_pkgs" != "x"; then\
		echo "Logs of failed packages:";\
		echo $$failed_pkgs;\
	else \
		echo "All packages were successfully built";\
	fi

prepare:
	rm -rf $(PKG_BUILD_LOGS_DIR)
	install -d $(PKG_BUILD_LOGS_DIR)

build-package-%: prepare $(TARGET_DIR)/%/debian
	@echo "Build package ... $*";\
	cd $(TARGET_DIR)/$* && BASEGATE=$(BASEGATE) dpkg-buildpackage -kNexenta -pgpg-nexenta -sgpg -d -b 2>$(PKG_BUILD_LOGS_DIR)/$*.log 1>&2 || mv $(PKG_BUILD_LOGS_DIR)/$*.log $(PKG_BUILD_LOGS_DIR)/$*.log.failed
