PHP RPM Build Automation
===

__Add description of what the crap this is and why it exists. Brief.__

## Running the build

### Parameters

| Name | Description | Values |
| ---- | ----------- | ------ |
| ARCH | The target system architecture that mock will build for. | `epel-6-i386`, `epel-6-x86_64` |
| BUILD_NUMBER | This is a incrementing build identifier used to determine whether a package is up-to-date in yum. | _integer_ `1, 2, ..., N` |
| TBD: Configure Options | I'm fleshing this out right now. Will be linked to wiki from this README and required arguments will be updated here. | |

### Build Numbers

* Provided by Jenkins
* Epoch to crush, elaborate. Describe circumstances where required, but default to no.

```bash
find path/to/rpms -name "*i386.rpm" -exec sh -c "rpm2cpio {} | cpio -idmv" \;
find path/to/rpms -name "*x86_64.rpm" -exec sh -c "rpm2cpio {} | cpio -idmv" \;
```

### Configure options and what they do

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