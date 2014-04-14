# Makefile for building PHP binary rpms.

PACKAGE_NAME = php-5.4-latest
PHP_GITHUB_BRANCH = PHP-5.4
PHP_GITHUB_WORKING_DIRECTORY = ./build


all: rpms

download:
	@mkdir -p $(PHP_GITHUB_WORKING_DIRECTORY)

	@echo "Downloading PHP from GitHub..."
	@wget https://github.com/php/php-src/archive/$(PHP_GITHUB_BRANCH).tar.gz 	\
		-O $(PHP_GITHUB_WORKING_DIRECTORY)/$(PACKAGE_NAME).tar.gz				\
		--quiet

	@echo "Reorganizing tarball..."
	@tar -zxf $(PHP_GITHUB_WORKING_DIRECTORY)/$(PACKAGE_NAME).tar.gz 			\
		--transform s/php-src-$(PHP_GITHUB_BRANCH)/$(PACKAGE_NAME)/				\
		-C $(PHP_GITHUB_WORKING_DIRECTORY)

	@cd $(PHP_GITHUB_WORKING_DIRECTORY); tar -czf $(PACKAGE_NAME).tar.gz $(PACKAGE_NAME)/

	@mv $(PHP_GITHUB_WORKING_DIRECTORY)/$(PACKAGE_NAME).tar.gz ./buildroot/SOURCES
	@rm -rf $(PHP_GITHUB_WORKING_DIRECTORY)
	@echo "Finished grabbing source tarball!"

clean:
	@echo "Cleaning distributable directory."
	-rm -rf ./dist/

build: clean
	@echo "Creating empty distributable directory."
	mkdir -p ./dist

rpms: build
	@echo "Building Source RPM..."
	rpmbuild --define="_topdir %(pwd)/buildroot" \
	-bs ./buildroot/SPECS/php-eos.spec

	@echo "Building x86_64 RPMS..."
	mock --scrub=all -r epel-6-x86_64 -v --rebuild buildroot/SRPMS/php-5.4-latest.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s" --cleanup-after

	@echo "Building i386 RPMS..."
	mock --scrub=all -r epel-6-i386 -v --rebuild buildroot/SRPMS/php-5.4-latest.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s" --cleanup-after