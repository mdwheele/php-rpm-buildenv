SHELL := /bin/bash
# Makefile for building PHP binary rpms. \
	- Variables assigned with ? are resolved in 'resolve_versions'

PHP_VERSION = ?
PHP_MAJOR_VERSION = 5
PHP_MINOR_VERSION = 4
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
	$(eval PHP_VERSION=$(PHP_MAJOR_VERSION).$(PHP_MINOR_VERSION).$(shell expr $(PHP_RELEASE_VERSION) - 1))
	$(eval PHP_GITHUB_SOURCE_BRANCH=PHP-$(PHP_VERSION))
	$(eval RPM_PACKAGE_NAME=php-$(PHP_VERSION))

download: resolve_versions
	@echo "Downloading PHP from GitHub..."
	wget https://github.com/php/php-src/archive/$(PHP_GITHUB_SOURCE_BRANCH).tar.gz 	\
		-O $(PHP_GITHUB_WORKING_DIRECTORY)/$(RPM_PACKAGE_NAME).tar.gz				\
		--quiet

	@echo "Reorganizing tarball..."
	tar -zxf $(PHP_GITHUB_WORKING_DIRECTORY)/$(RPM_PACKAGE_NAME).tar.gz 			\
		--transform s/php-src-$(PHP_GITHUB_SOURCE_BRANCH)/$(RPM_PACKAGE_NAME)/				\
		-C $(PHP_GITHUB_WORKING_DIRECTORY)

	cd $(PHP_GITHUB_WORKING_DIRECTORY); tar -czf $(RPM_PACKAGE_NAME).tar.gz $(RPM_PACKAGE_NAME)/

	mv $(PHP_GITHUB_WORKING_DIRECTORY)/$(RPM_PACKAGE_NAME).tar.gz ./buildroot/SOURCES
	rm -rf $(PHP_GITHUB_WORKING_DIRECTORY)
	@echo "Finished grabbing source tarball!"

clean:
	@echo "Cleaning distributable directory."
	-rm -rf ./dist/

build: clean
	@echo "Creating empty distributable directory."
	mkdir -p ./dist

rpms: download build
	@echo "Building Source RPM..."
	rpmbuild --define="_topdir %(pwd)/buildroot" --define="version $(PHP_VERSION)" \
	-bs ./buildroot/SPECS/php-eos.spec

	@echo "Building x86_64 RPMS..."
	mock --scrub=all -r epel-6-x86_64 -v --rebuild buildroot/SRPMS/php-$(PHP_VERSION)-1.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s" --cleanup-after

	@echo "Building i386 RPMS..."
	mock --scrub=all -r epel-6-i386 -v --rebuild buildroot/SRPMS/php-$(PHP_VERSION)-1.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s" --cleanup-after