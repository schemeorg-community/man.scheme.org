#!/bin/sh
set -eu
cd "$(dirname "$0")"
cd ..

download() {
    file="$1"
    url="$2"
    file="$file"
    if test -e "$file"; then
        echo "Skipping $file"
    else
        echo "Downloading $file from $url"
        curl --location --fail --silent --show-error -o "$file.new" "$url"
        mv -f "$file.new" "$file"
    fi
}

mkdir -p dist
cd dist
echo "Entering directory '$PWD'"

##

download scheme-manpages.tar.gz \
    https://github.com/schemedoc/manpages/archive/refs/heads/master.tar.gz

##

download chibi-scheme.tar.gz \
    https://files.scheme.org/chibi-scheme-0.9.1.tgz

download gambit.tar.gz \
    https://gambitscheme.org/latest/gambit-v4_9_4.tgz

download gauche.tar.gz \
    https://files.scheme.org/Gauche-0.9.9.tgz

download stklos.tar.gz \
    https://stklos.net/download/stklos-1.70.tar.gz

##

download schemeorg.css https://www.scheme.org/schemeorg.css
