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
	mock --scrub=all -r epel-6-x86_64 -v --rebuild buildroot/SRPMS/php-5.4.26-4.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s" --cleanup-after

	@echo "Building i386 RPMS..."
	mock --scrub=all -r epel-6-i386 -v --rebuild buildroot/SRPMS/php-5.4.26-4.eos.el6.src.rpm \
	--resultdir=./dist/"%(target_arch)s" --cleanup-after