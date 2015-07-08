SHELL := /bin/bash
# Makefile for building PHP binary rpms. \
	- Variables assigned with ? are resolved in 'resolve_versions'

PHP_VERSION = ?
PHP_MAJOR_VERSION = 5
PHP_MINOR_VERSION = 6
PHP_RELEASE_VERSION = ?

RPM_PACKAGE_NAME = ?

PHP_GITHUB_VERSION_URL = https://raw.githubusercontent.com/php/php-src/PHP-$(PHP_MAJOR_VERSION).$(PHP_MINOR_VERSION)/main/php_version.h
PHP_GITHUB_WORKING_DIRECTORY = ./github
PHP_GITHUB_SOURCE_BRANCH = ?

all: rpms

download_version_info:
	mkdir -p $(PHP_GITHUB_WORKING_DIRECTORY)
	wget $(PHP_GITHUB_VERSION_URL) -O $(PHP_GITHUB_WORKING_DIRECTORY)/php_version.h

resolve_versions: download_version_info
	$(eval PHP_RELEASE_VERSION=$(shell sed -n '/#define PHP_RELEASE_VERSION /{s/.* //;p}' $(PHP_GITHUB_WORKING_DIRECTORY)/php_version.h))
	$(eval PHP_VERSION=$(PHP_MAJOR_VERSION).$(PHP_MINOR_VERSION).$(shell expr $(PHP_RELEASE_VERSION) - 2))
	$(eval PHP_GITHUB_SOURCE_BRANCH=PHP-$(PHP_VERSION))
	$(eval RPM_PACKAGE_NAME=php-$(PHP_VERSION))

download: resolve_versions
	@echo "Downloading PHP from GitHub..."
	wget http://www.php.net/distributions/php-$(PHP_VERSION).tar.bz2			 	\
		-O $(PHP_GITHUB_WORKING_DIRECTORY)/$(RPM_PACKAGE_NAME).tar.bz2				\
		--quiet

	mv $(PHP_GITHUB_WORKING_DIRECTORY)/$(RPM_PACKAGE_NAME).tar.bz2 ./buildroot/SOURCES
	rm -rf $(PHP_GITHUB_WORKING_DIRECTORY)
	@echo "Finished grabbing source tarball!"

build: clean
	@echo "Creating empty distributable directory."
	mkdir -p ./dist

clean:
	@echo "Cleaning distributable directory."
	-rm -rf ./dist/
	mock --clean --scrub=all

rpms: download build
	@echo "Building Source RPM..."
	rpmbuild --define="_topdir %(pwd)/buildroot" \
	-bs ./buildroot/SPECS/php-eos.spec \
	--define="version $(PHP_VERSION)" \
	--define="build_number $(BUILD_NUMBER)" \
	--define="_sysconfdir $(CONFIG_PATH)" \
	--define="_prefix $(PREFIX)"

	@echo "Running mock with $(ARCH) architecture..."
	mock -r $(ARCH) -v --rebuild buildroot/SRPMS/php-$(PHP_VERSION)-$(BUILD_NUMBER).eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s" --no-cleanup-after \
	--define="version $(PHP_VERSION)" \
	--define="build_number $(BUILD_NUMBER)" \
	--define="_sysconfdir $(CONFIG_PATH)" \
	--define="_prefix $(PREFIX)"

	@echo "Copying BUILDROOT to dist..."
	tar -czf ./dist/php-$(PHP_VERSION)-$(BUILD_NUMBER).eos.el6.tar.gz -C /var/lib/mock/$(ARCH)/root/builddir/build/BUILDROOT/php-$(PHP_VERSION)-$(BUILD_NUMBER).eos.el6.x86_64 .
