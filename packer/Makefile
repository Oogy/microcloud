DISTROS := $(wildcard distros/*.pkrvars.hcl)
IMAGES := $(wildcard images/*.pkrvars.hcl)

distro ?= arch

.PHONY: build $(IMAGES)

init:
	packer init .

build: $(IMAGES)

$(IMAGES):
	packer build -force -var-file="distros/$(distro).pkrvars.hcl" -var-file="$@" .
