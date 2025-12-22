SUBDIRS := $(sort $(patsubst %/,%,$(wildcard */)))

.PHONY: $(SUBDIRS)

$(SUBDIRS):
	sudo mkosi -C $@ -O ../../mkosi.output --image-version $(IMAGE_VERSION) --force
