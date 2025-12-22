SUBDIRS := $(sort $(patsubst %/,%,$(wildcard */)))

bootable ?= false

.PHONY: $(SUBDIRS)

$(SUBDIRS):
	sudo mkosi -C $@ -O ../../mkosi.output --image-version $(IMAGE_VERSION) --force --bootable=$(bootable)
