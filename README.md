# caddy-php
script for setting up a caddy-server with PHP support

## About
After some research I realized that there was no way to set up a caddy server with PHP support without much effort. That's why I created this repository.

## How to install
Download the `.ps1`-file from [here](./src/). Run the script in PowerShell with `.\caddy-php.ps1`.

The script
- will suggest available PHP versions and lets you choose.
- tries to choose the caddy version automatically but lets you choose when it has problems to do so.
- creates a subfolder named "caddy-php".

## How to run
```
php-cgi -b 127.0.0.1:9000
```

```
caddy run --watch
```

## CLI Documentation
Caddy: [Link](https://caddyserver.com/docs/command-line)

php-cgi (`-h`): 
```
Usage: php [-q] [-h] [-s] [-v] [-i] [-f <file>]
       php <file> [args...]
  -a               Run interactively
  -b <address:port>|<port> Bind Path for external FASTCGI Server mode
  -C               Do not chdir to the script's directory
  -c <path>|<file> Look for php.ini file in this directory
  -n               No php.ini file will be used
  -d foo[=bar]     Define INI entry foo with value 'bar'
  -e               Generate extended information for debugger/profiler
  -f <file>        Parse <file>.  Implies `-q'
  -h               This help
  -i               PHP information
  -l               Syntax check only (lint)
  -m               Show compiled in modules
  -q               Quiet-mode.  Suppress HTTP Header output.
  -s               Display colour syntax highlighted source.
  -v               Version number
  -w               Display source with stripped comments and whitespace.
  -z <file>        Load Zend extension <file>.
  -T <count>       Measure execution time of script repeated <count> times.
```
