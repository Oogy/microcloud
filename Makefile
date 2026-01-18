ORG := Oogy

.PHONY: all repos pages microcloud booter entrypointd-portable dnsmasq-portable

all: repos pages

repos: microcloud booter entrypointd-portable dnsmasq-portable

# Create repos
microcloud:
	@gh repo view $(ORG)/microcloud &>/dev/null || \
		gh repo create $(ORG)/microcloud --public --description "Orchestrator for baremetal local cloud"

booter:
	@gh repo view $(ORG)/booter &>/dev/null || \
		gh repo create $(ORG)/booter --public --description "Bootable machine image for microcloud"

entrypointd-portable:
	@gh repo view $(ORG)/entrypointd-portable &>/dev/null || \
		gh repo create $(ORG)/entrypointd-portable --public --description "Portable service manager for microcloud"

dnsmasq-portable:
	@gh repo view $(ORG)/dnsmasq-portable &>/dev/null || \
		gh repo create $(ORG)/dnsmasq-portable --public --description "PXE/TFTP server portable for microcloud"

# Enable GitHub Pages
pages:
	@echo "Enabling GitHub Pages on microcloud..."
	@gh api -X PUT /repos/$(ORG)/microcloud/pages \
		-f source[branch]=main -f source[path]=/docs 2>/dev/null || \
	gh api -X POST /repos/$(ORG)/microcloud/pages \
		-f source[branch]=main -f source[path]=/docs 2>/dev/null || \
		echo "Pages already configured"
