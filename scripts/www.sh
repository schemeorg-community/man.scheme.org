#!/bin/bash
set -eu -o pipefail
cd "$(dirname "$0")"
cd ..
echo "Entering directory '$PWD'"

mkdir -p dist/scheme-manpages
tar -C dist/scheme-manpages \
    -xf dist/scheme-manpages.tar.gz \
    --wildcards '*/man[1-9]/*'

mkdir -p www
find www -mindepth 1 -delete
mkdir -p www/raw
find dist -type f -name '*.[1-9]*' | xargs -I x mv x www/raw/

for page in $(cd www/raw && ls *.[1-9]*); do
    echo "$page"
    raw="www/raw/$page"
    new="www/.$page.new"
    dst="www/$page"
    if unroff -man <"$raw" >"$new"; then
        mv -f "$new" "$dst"
    else
        rm -f "$new"
    fi
done

cp -f dist/schemeorg.css www/
gosh -I lib lib/generate-index.scm
