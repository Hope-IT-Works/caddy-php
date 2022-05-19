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


```
php-cgi -b 127.0.0.1:9000
```

```
caddy run --watch
```
