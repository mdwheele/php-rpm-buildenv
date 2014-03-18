# Makefile for building PHP binary rpms.

all: rpms

clean:
	@echo "Cleaning distributable directory."
	-rm -rf dist/

build: clean
	@echo "Creating empty distributable directory."
	mkdir -p ./dist

rpms: build
	@echo "Building Source RPM..."
	rpmbuild --define="_topdir %(pwd)/buildroot" \
	-bs ./buildroot/SPECS/php-eos.spec

	@echo "Building x86_64 RPMS..."
	mock --scrub=all -r epel-6-x86_64 rebuild buildroot/SRPMS/php-5.4.26-3.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s"/

	@echo "Building i386 RPMS..."
	mock --scrub=all -r epel-6-i386 rebuild buildroot/SRPMS/php-5.4.26-3.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s"/