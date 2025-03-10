KITS = $(notdir $(shell find kits -mindepth 1 -maxdepth 1 -type d))

.PHONY: $(addprefix install-,$(KITS))
$(addprefix install-,$(KITS)): install-%:
	@$(MAKE) -C kits/$* install

.PHONY: $(addprefix uninstall-,$(KITS))
$(addprefix uninstall-,$(KITS)): uninstall-%:
	@$(MAKE) -C kits/$* uninstall

.PHONY: install-all
install-all: $(addprefix install-,$(KITS))
