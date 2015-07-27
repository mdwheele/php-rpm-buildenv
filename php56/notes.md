## php.conf

- Has directive to set handler for *.php scripts.
- Specifies soap.wsdl_cache_dir to be directory that may or may not exist (/var/lib/php/wsdlcache)
	- RPM note : cache directory must be owned by process owner

## php.ini

- Default character set is UTF-8, from <empty>.
- New options for input and output encoding. Defaulted.
- New option for specifying directory where temporary files should be placed. System default if empty.
- [mail] SMTP port not specified in new configuration. Differs from host+port settings.
	- Seems to be Windows-specific?
- [mail] Added option to log all calls to `mail()` to syslog. Previously only a simple log file existed.
- [session] https://wiki.php.net/rfc/strict_sessions was added to the language. Default off, but usage is encouraged.
	- Prevents session fixation attacks
- [openssl] CA options are added for specifying cacert/path. Recommendation is to leave <empty> and OS setting will be used.

## php-fpm.conf

- Several additional options made available, nothing went away.

## php-fpm-www.conf

- `listen.backlog` default changed from -1 to 65535.

## Patches

- Remove `php-5.2.0-includedir.patch` (https://bugzilla.redhat.com/show_bug.cgi?id=225434)
	- We're overriding include paths at the virtual host level anyway and this is honestly a stupid
	  solution to a nearly decade-old "problem". Smarty is no longer used and in ANY case where we WERE using it,
	  it was not installed using pear.
- Updates `php-5.3.1-systzdata-v10.patch` to `php-5.6.9-systzdata-v12.patch`.
- Removes `php-5.4.0-easter.patch`. Was patching in PHP egg logo... why.