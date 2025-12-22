SUBDIRS := portables machines
IMAGE_VERSION ?= $(shell git rev-parse --short=8 HEAD)

PORTABLES := $(shell find portables -maxdepth 1 -mindepth 1  -type d)

MACHINES := $(shell find machines -maxdepth 1 -mindepth 1  -type d)

image := booter

bootble := false

.PHONY: all $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ IMAGE_VERSION=$(IMAGE_VERSION) ENTRYPOINTD_VERSION=$(ENTRYPOINTD_VERSION) bootable=$(bootable)

ifeq ($(bootable),true)
run:
	sudo systemd-nspawn -i mkosi.output/$(image)_$(IMAGE_VERSION).raw -b -M $(image) --capability=$(capability)
else
run:
	sudo systemd-nspawn -i mkosi.output/$(image)_$(IMAGE_VERSION).raw -M $(image)
endif
