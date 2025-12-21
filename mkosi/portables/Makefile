SUBDIRS := $(sort $(patsubst %/,%,$(wildcard */)))

.PHONY: $(SUBDIRS)

$(SUBDIRS):
	mkosi -C $@ -O ../../mkosi.output --image-version ${GITHUB_REF}

