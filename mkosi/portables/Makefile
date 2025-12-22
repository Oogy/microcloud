SUBDIRS := $(sort $(patsubst %/,%,$(wildcard */)))

bootable ?= false

.PHONY: $(SUBDIRS)

all: $(SUBDIRS)

ifeq ($(bootable), true)
$(SUBDIRS):
	sudo mkosi -C $@ -O ../../mkosi.output --image-version $(IMAGE_VERSION) --force --bootable
else
$(SUBDIRS):
	sudo mkosi -C $@ -O ../../mkosi.output --image-version $(IMAGE_VERSION) --force
endif
