SUBDIRS := $(sort $(patsubst %/,%,$(wildcard */)))

bootable ?= false

.PHONY: $(SUBDIRS)

$(image):
	sudo mkosi -C $(image) -O ../../mkosi.output --image-version $(IMAGE_VERSION) --force --bootable=$(bootable)


$(SUBDIRS):
	sudo mkosi -C $@ -O ../../mkosi.output --image-version $(IMAGE_VERSION) --force --bootable=$(bootable)
