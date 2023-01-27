NAME = plugin.video.elementum
VERSION = $(shell sed -ne "s/.*version=\"\([0-9a-z\.\-]*\)\"\sprovider.*/\1/p" addon.xml)
ARCHS = \
	android_arm \
	android_arm64 \
	android_x86 \
	darwin_x64 \
	linux_armv6 \
	linux_armv7 \
	linux_arm64 \
	linux_x64 \
	linux_x86 \
	windows_x64 \
	windows_x86 \
	client
ZIP_SUFFIX = zip
ZIP_FILE = $(NAME)-$(VERSION).$(ZIP_SUFFIX)

all: clean zip

.PHONY: $(ARCHS)

$(ARCHS):
	$(MAKE) clean_arch ZIP_SUFFIX=$@.zip
	$(MAKE) zip ARCHS=$@ ZIP_SUFFIX=$@.zip

$(ZIP_FILE):
	echo "Zipping $(ZIP_FILE)"
	git archive --format zip --prefix $(NAME)/ --output $(ZIP_FILE) HEAD
	mkdir -p $(NAME)/resources/bin
	for arch in $(ARCHS); do \
		cp -r `pwd`/resources/bin/$$arch $(NAME)/resources/bin/$$arch; \
		echo "v$(VERSION)" >> $(NAME)/resources/bin/$$arch/version; \
		zip -9 -r -g $(ZIP_FILE) $(NAME)/resources/bin/$$arch; \
	done
	rm -rf $(NAME)

zip: $(ZIP_FILE)

zipfiles: addon.xml
	echo "Zipping all platforms"
	for arch in $(ARCHS); do \
		$(MAKE) $$arch; \
	done

clean_arch:
	 rm -f $(ZIP_FILE)

clean:
	for arch in $(ARCHS); do \
		$(MAKE) clean_arch ZIP_SUFFIX=$$arch.zip; \
	done
	rm -f $(ZIP_FILE)
	rm -rf $(NAME)
