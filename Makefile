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
