include VERSIONS

# We check for GitHub Actions environment to set the target accordingly if we
# are within a CI environment
ifdef GITHUB_ACTIONS
	TARGET ?= $(CURDIR)/build
else
	TARGET ?= /target/build
endif

ifdef GITHUB_REF
	COMMIT ?= $(GITHUB_REF)
else
	COMMIT ?= '(none)'
endif

BUILD_DIST := $(shell lsb_release -sc)
ifdef GITHUB_REF_TYPE
ifeq ($(GITHUB_REF_TYPE),tag)
	BUILD_VERSION ?= ~ppa$(GITHUB_REF_NAME:v%=%)
else
	BUILD_VERSION ?= ~ppa$(GITHUB_RUN_NUMBER)+$(GITHUB_REF_NAME)
endif
else
	BUILD_VERSION ?= $(shell date +'~ppa%Y%m%d+%H%M%S')
endif

BUILD_VERSION := $(BUILD_DIST)$(BUILD_VERSION)
BUILD_DIR := $(TARGET)

GITFS_DIR := $(BUILD_DIR)/gitfs-$(GITFS_VERSION)
PACKAGES_DIR := $(GITFS_DIR)/debian/packages

PREPARE_DEPS := $(addprefix prepare-, $(DEPENDENCIES))
BUILD_DEPS := $(addprefix build-, $(DEPENDENCIES))

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(PACKAGES_DIR):
	mkdir -p $(PACKAGES_DIR)

all: build

build: $(BUILD_DIR) $(BUILD_DEPS) build-gitfs

prepare: $(PREPARE_DEPS) $(BUILD_DEPS)

prepare-%: get-%
	ls -la $(BUILD_DIR)/
	@cp -r debian-$* $(BUILD_DIR)/$*-$($(shell echo $* | tr a-z- A-Z_)_VERSION)/debian

retrieve-package-%: $(PACKAGES_DIR)
	$(eval PKG_URL := $($(shell echo $* | tr a-z- A-Z_)_URL))
	$(eval PKG_EXT := $(if $(findstring .whl,$(PKG_URL)),.whl,.tar.gz))
	wget -q $(PKG_URL) -O $(PACKAGES_DIR)/$(shell echo $*)-$($(shell echo $* | tr a-z- A-Z_)_VERSION)$(PKG_EXT)
	echo debian/packages/$(shell echo $*)-$($(shell echo $* | tr a-z- A-Z_)_VERSION)$(PKG_EXT) >> $(GITFS_DIR)/debian/source/include-binaries

get-gitfs:
	@echo "Downloading gitfs $(GITFS_VERSION)"
	wget -q $(GITFS_URL) -O $(BUILD_DIR)/gitfs_$(GITFS_VERSION).orig.tar.gz
	tar -xzf $(BUILD_DIR)/gitfs_$(GITFS_VERSION).orig.tar.gz -C $(BUILD_DIR)/

prepare-gitfs: get-gitfs
	@cp -r debian-gitfs $(GITFS_DIR)/debian

get-python-pex:
	wget -q $(PYTHON_PEX_URL) -O $(BUILD_DIR)/python-pex_$(PYTHON_PEX_VERSION).orig.tar.gz
	tar -xzf $(BUILD_DIR)/python-pex_$(PYTHON_PEX_VERSION).orig.tar.gz -C $(BUILD_DIR)/
	ls -la $(BUILD_DIR)/
	mv $(BUILD_DIR)/pex-$(PYTHON_PEX_VERSION) $(BUILD_DIR)/python-pex-$(PYTHON_PEX_VERSION)

get-%:
	@echo "Downloading $($(shell echo $* | tr a-z- A-Z_)_URL)"
	wget --no-check-certificate --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 3 \
		$($(shell echo $* | tr a-z- A-Z_)_URL) -O $(BUILD_DIR)/$*_$($(shell echo $* | tr a-z- A-Z_)_VERSION).orig.tar.gz
	tar -xzf $(BUILD_DIR)/$*_$($(shell echo $* | tr a-z- A-Z_)_VERSION).orig.tar.gz -C $(BUILD_DIR)/

build-gitfs: prepare-gitfs $(addprefix retrieve-package-, $(PACKAGES))
	@echo "Building gitfs $(GITFS_VERSION) source package with packages included"
	@echo "Verifying packages are included..."
	@if [ ! -d "$(GITFS_DIR)/debian/packages" ] || [ -z "$$(ls -A $(GITFS_DIR)/debian/packages 2>/dev/null)" ]; then \
		echo "ERROR: debian/packages directory is empty or missing!"; \
		exit 1; \
	fi
	ls -la $(GITFS_DIR)/debian/packages/
	@echo "Packages included in source:"
	@cat $(GITFS_DIR)/debian/source/include-binaries
	cd $(GITFS_DIR) \
		&& dch -b -D $(BUILD_DIST) -v $(GITFS_VERSION)-$(BUILD_VERSION) "Automated build of gitfs $(GITFS_VERSION) $(COMMIT)" \
		&& echo "Building package (unsigned first)..." \
		&& dpkg-buildpackage -d -S -sa -us -uc \
		&& if gpg --list-secret-keys $(SIGNING_KEY) >/dev/null 2>&1; then \
			echo "Signing package with GPG..." && \
			cd .. && \
			export GNUPGHOME=~/.gnupg && \
			debsign -p "$(CURDIR)/gpg-batch-wrapper.sh" --no-re-sign -k $(SIGNING_KEY) gitfs_$(GITFS_VERSION)-$(BUILD_VERSION)_source.changes; \
		else \
			echo "Skipping GPG signing (no key available)"; \
		fi

build-%:
	@echo Building $($*_VERSION) source
	ls -la $(BUILD_DIR)
	cd $(BUILD_DIR)/$*-$($(shell echo $* | tr a-z- A-Z_)_VERSION) \
		&& dch -b -D $(BUILD_DIST) -v $($(shell echo $* | tr a-z- A-Z_)_VERSION)-$(BUILD_VERSION) "Automated build of $* $($*_VERSION) $(COMMIT)" \
		&& echo "Building package (unsigned first)..." \
		&& dpkg-buildpackage -d -S -sa -us -uc \
		&& if gpg --list-secret-keys $(SIGNING_KEY) >/dev/null 2>&1; then \
			echo "Signing package with GPG..." && \
			cd .. && \
			export GNUPGHOME=~/.gnupg && \
			debsign -p "$(CURDIR)/gpg-batch-wrapper.sh" --no-re-sign -k $(SIGNING_KEY) $*_$($(shell echo $* | tr a-z- A-Z_)_VERSION)-$(BUILD_VERSION)_source.changes; \
		else \
			echo "Skipping GPG signing (no key available)"; \
		fi

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all prepare build clean get-% mkdir-%
SIGNING_KEY ?= $(if $(GPG_KEY_ID),$(GPG_KEY_ID),vladtemian@gmail.com)
