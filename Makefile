KITS = $(notdir $(shell find kits -mindepth 1 -maxdepth 1 -type d))

.PHONY: $(addprefix package-signed-,$(KITS))
$(addprefix package-signed-,$(KITS)): package-signed-%:
	@$(MAKE) -C kits/$* package-signed

.PHONY: package-signed-all
package-signed-all: $(addprefix package-signed-,$(KITS))

.PHONY: $(addprefix install-,$(KITS))
$(addprefix install-,$(KITS)): install-%:
	@$(MAKE) -C kits/$* install

.PHONY: $(addprefix uninstall-,$(KITS))
$(addprefix uninstall-,$(KITS)): uninstall-%:
	@$(MAKE) -C kits/$* uninstall

.PHONY: install-all
install-all: $(addprefix install-,$(KITS))

GPGKEY ?= 69F8E5E5E85F771020A0777C3D309011083BA25E
REPO_ADD_ARGS ?= --sign --include-sigs --new --remove --key $(GPGKEY)
REPONAME = kits

.PHONY: create-gh-pages-branch
gh-pages-create-branch:
	git show-ref --quiet refs/heads/gh-pages || { \
		git checkout --orphan gh-pages; \
		git reset --hard; \
		git commit --allow-empty -m "Initial commit"; \
		git checkout main; \
	}
	git worktree add gh-pages || :
	repo-add $(REPO_ADD_ARGS) gh-pages/$(REPONAME).db.tar.gz
	git -C gh-pages add '$(REPONAME).*'
	git -C gh-pages diff --quiet --cached || \
		git -C gh-pages commit -m "Add empty repo database"

PKGVER = $(shell git describe --abbrev=7 | sed 's/\([^-]*-g\)/r\1/;s/-/./g')
PKGFILES = $(foreach kit,$(KITS),kits/$(kit)/$(kit)-$(PKGVER)-1-any.pkg.tar.zst)

.PHONY: gh-pages-stage-packages
gh-pages-stage-packages: $(PKGFILES)
	install -Dm644 -t gh-pages $^ $(addsuffix .sig,$^)
	repo-add $(REPO_ADD_ARGS) gh-pages/$(REPONAME).db.tar.gz $^
	./mk/gen-index-html gh-pages > gh-pages/index.html
	git -C gh-pages add '*'
	git -C gh-pages commit -m "upgpkg: $(PKGVER)"

.PHONY: gh-pages-push-packages
gh-pages-push-packages:
	git -C gh-pages push origin gh-pages
