AURUTILS_COMMIT = efec060c20498e49f01e921fb7127ead74f36b79
AURUTILS_VERSION = 20.4-1
AURUTILS_ARCHIVE = aur-$(AURUTILS_COMMIT).tar.gz
AURUTILS_PACKAGE = aur-$(AURUTILS_COMMIT)/aurutils-$(AURUTILS_VERSION)-any.pkg.tar.zst

$(AURUTILS_ARCHIVE):
	curl -sSfLO https://aur.archlinux.org/cgit/aur.git/snapshot/$@

aur-$(AURUTILS_COMMIT): $(AURUTILS_ARCHIVE)
	tar -xzf $<

$(AURUTILS_PACKAGE): aur-$(AURUTILS_COMMIT)
	test -f $@ || makepkg --dir $< --syncdeps

.PHONE: install
install: $(AURUTILS_PACKAGE)
	pacman -Qq aurutils || sudo pacman -U --asdeps $<
