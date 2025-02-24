PKGNAME = kit-arch-user-repository

include ../../mk/kit.mk

.PHONY: install-aurutils
install-aurutils:
	make -C aurutils install

$(PACKAGE_FILE): archive install-aurutils
