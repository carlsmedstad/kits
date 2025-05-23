ifeq ($(PKGNAME),)
  $(error PKGNAME is not defined)
endif

MAKEPKG_ARGS ?= --syncdeps --noconfirm

PKGVER = $(shell git describe --abbrev=7 | sed 's/\([^-]*-g\)/r\1/;s/-/./g')
ARCHIVE = $(PKGNAME)-$(PKGVER).tar.gz
PKGFILE = $(PKGNAME)-$(PKGVER)-1-any.pkg.tar.zst

$(ARCHIVE):
	git archive HEAD \
	  --prefix=$(PKGNAME)-$(PKGVER)/ \
	  --format=tar.gz \
	  --output $@

.PHONY: archive
archive: $(ARCHIVE)

.PHONY: PKGBUILD
PKGBUILD: PKGBUILD.in
	sed -e 's/@PKGVER@/$(PKGVER)/' PKGBUILD.in > PKGBUILD

$(PKGFILE): archive PKGBUILD
	test -f $@ || makepkg $(MAKEPKG_ARGS)

$(PKGFILE).sig: archive PKGBUILD
	test -f $@ || makepkg $(MAKEPKG_ARGS) --force --sign

.PHONY: package
package: $(PKGFILE)

.PHONY: package-signed
package-signed: $(PKGFILE).sig

.PHONY: install
install: $(PKGFILE)
	sudo pacman -U $<

.PHONY: uninstall
uninstall:
	sudo pacman -Rs $(PKGNAME)

.PHONY: clean
clean:
	rm -rf ./*.pkg.tar.zst ./*.tar.gz ./PKGBUILD ./pkg/ ./src/
