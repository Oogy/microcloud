ALL := portables machines
IMAGE_VERSION ?= $(shell git rev-parse --short=8 HEAD)

PORTABLES := $(shell find portables -maxdepth 1 -mindepth 1  -type d)

MACHINES := $(shell find machines -maxdepth 1 -mindepth 1  -type d)

image := booter

bootble := false

.PHONY: $(ALL) $(PORTABLES) $(MACHINES)

$(ALL):
	$(MAKE) -C $@ IMAGE_VERSION=$(IMAGE_VERSION)

$(PORTABLES):
	$(MAKE) -C $@ IMAGE_VERSION=$(IMAGE_VERSION) bootable=$(bootable)

$(MACHINES):
	$(MAKE) -C $@ IMAGE_VERSION=$(IMAGE_VERSION) ENTRYPOINTD_VERSION=$(ENTRYPOINTD_VERSION)

ifeq ($(bootable),true)
run:
	sudo systemd-nspawn -i mkosi.output/$(image)_$(IMAGE_VERSION).raw -b -M $(image)
else
run:
	sudo systemd-nspawn -i mkosi.output/$(image)_$(IMAGE_VERSION).raw -M $(image)
endif
