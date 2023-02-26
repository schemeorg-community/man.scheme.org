#!/bin/sh
set -eu
cd "$(dirname "$0")"
cd ..
rsync -vcr www/ alpha.servers.scheme.org:/production/man/www/
