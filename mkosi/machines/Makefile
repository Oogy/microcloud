SUBDIRS := $(sort $(patsubst %/,%,$(wildcard */)))
bootable = true

.PHONY: $(SUBDIRS)

$(SUBDIRS):
	sudo mkosi -C $@ -O ../../mkosi.output --image-version $(IMAGE_VERSION) --force --bootable=$(bootable)
