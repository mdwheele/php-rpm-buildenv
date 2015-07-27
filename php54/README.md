PHP RPM Build Automation
===

This repository exists to provide a way of sanely maintaining a RPM specfile for PHP in addition to a Makefile that
grabs latest changes from the PHP source repository on a particular branch.  This can be used to do a one-off build of
PHP from source, but it is meant to be used by a build server to compile PHP and distribute to appropriate Yum
repositories thereafter.

## Running the build

### Parameters

| Name | Description | Values | Spec Variable |
| ---- | ----------- | ------ | ------------- |
| ARCH | The target system architecture that mock will build for. | `epel-6-i386`, `epel-6-x86_64` | `%{?dist}` |
| BUILD_NUMBER | This is a incrementing build identifier used to determine whether a package is up-to-date in yum. | _integer_ `1, 2, ..., N` | `%{build_number}` |
| PREFIX | Where to install PHP. | `/usr` | `%{_prefix}` |
| CONFIG_PATH | The location `php.ini` should be retrieved from. | `/etc` | `%{_sysconfdir}` |

**Architecture**

[Mock](http://fedoraproject.org/wiki/Projects/Mock) creates chroots and builds packages in them. Its only task is to
reliably populate a chroot and attempt to build a package in that chroot.  Mock has access to several configurations
for different architectures that (for example) allow a maintainer to build both i386 and x86_64 packages.  All of the
configurations are viewable at `/etc/mock` in most systems:

```
default.cfg        epel-6-ppc64.cfg      fedora-19-ppc64.cfg   fedora-20-armhfp.cfg  fedora-20-s390x.cfg   fedora-5-i386-epel.cfg    fedora-devel-ppc.cfg        fedora-rawhide-ppc64.cfg  fedora-rawhide-x86_64.cfg
epel-5-i386.cfg    epel-6-x86_64.cfg     fedora-19-ppc.cfg     fedora-20-i386.cfg    fedora-20-x86_64.cfg  fedora-5-ppc-epel.cfg     fedora-devel-x86_64.cfg     fedora-rawhide-ppc.cfg    logging.ini
epel-5-ppc.cfg     epel-7-x86_64.cfg     fedora-19-s390.cfg    fedora-20-ppc64.cfg   fedora-21-armhfp.cfg  fedora-5-x86_64-epel.cfg  fedora-rawhide-aarch64.cfg  fedora-rawhide-s390.cfg   site-defaults.cfg
epel-5-x86_64.cfg  fedora-19-armhfp.cfg  fedora-19-s390x.cfg   fedora-20-ppc.cfg     fedora-21-i386.cfg    fedora-devel-i386.cfg     fedora-rawhide-armhfp.cfg   fedora-rawhide-s390x.cfg
epel-6-i386.cfg    fedora-19-i386.cfg    fedora-19-x86_64.cfg  fedora-20-s390.cfg    fedora-21-x86_64.cfg  fedora-devel-ppc64.cfg    fedora-rawhide-i386.cfg     fedora-rawhide-sparc.cfg
```

**Build Numbers**

Build numbers are used as a factor in determining when a package has an update. This should be an incrementing number
and in the case of our environment, is most likely populated by Jenkins (from `${env.BUILD_NUMBER}`).

There are **rare** circumstances where your back is to the wall and the Huns are about to burn your village. Under
these circumstances, RPM Epoch can be used as a way to **CRUSH** the default package update mechanism.  **This should
really ONLY ever be used under DIRE circumstances and in most cases the versioning scheme for the package should be
changed instead of using Epoch**.

**Prefix**

This is used to prefix many of the paths when `./configure` runs during the build process.  I had issues setting this
and it needs more attention.  Currently, it will be passed down at compile time appropriately, but I think I was just
using it wrong or setting it to a improper value.  More docs to come I'm sure.

**Configuration Path**

This allows a maintainer to specify the default path to `php.ini`.  At run-time, any configuration may be used, but
the default path is set at compile-time.

### Random notes

**Running the Makefile**
```bash
make ARCH="epel-6-x86_64" BUILD_NUMBER=1 CONFIG_PATH="/etc/custom"
```

**Extracting RPMs to filesystem pre-tarball**
```bash
find path/to/rpms -name "*i386.rpm" -exec sh -c "rpm2cpio {} | cpio -idmv" \;
find path/to/rpms -name "*x86_64.rpm" -exec sh -c "rpm2cpio {} | cpio -idmv" \;
```

### Configure options and what they do (eventually)

```bash
%configure \
        --cache-file=../config.cache \
        --with-libdir=%{_lib} \
        --with-config-file-path=%{_sysconfdir} \
        --with-config-file-scan-dir=%{_sysconfdir}/php.d \
        --disable-debug \
        --with-pic \
        --disable-rpath \
        --without-pear \
        --with-bz2 \
        --with-exec-dir=%{_bindir} \
        --with-freetype-dir=%{_prefix} \
        --with-png-dir=%{_prefix} \
        --with-xpm-dir=%{_prefix} \
        --enable-gd-native-ttf \
        --with-t1lib=%{_prefix} \
        --without-gdbm \
        --with-gettext \
        --with-gmp \
        --with-iconv \
        --with-jpeg-dir=%{_prefix} \
        --with-openssl \
        --with-pcre-regex=%{_prefix} \
        --with-zlib \
        --with-layout=GNU \
        --enable-exif \
        --enable-ftp \
        --enable-sockets \
        --with-kerberos \
        --enable-shmop \
        --enable-calendar \
        --with-libxml-dir=%{_prefix} \
        --enable-xml \
        --with-system-tzdata \
        --with-mhash \
```

## Known Issues / Pointpoints

* Usage of make for something as dynamic as this build process was a bad idea.  I want to translate this to
something more appropriate like bash, perl, php, or python.  Considering the duration of build, perl/bash are
most likely the best candidates given my current knowledge.