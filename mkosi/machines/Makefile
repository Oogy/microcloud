SUBDIRS := $(sort $(patsubst %/,%,$(wildcard */)))

.PHONY: $(SUBDIRS)

$(SUBDIRS):
	sudo mkosi -C $@ -O ../../mkosi.output --image-version ${GITHUB_REF_NAME}

