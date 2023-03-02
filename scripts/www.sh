#!/bin/bash
set -eu -o pipefail
cd "$(dirname "$0")"
cd ..
scripts/man.sh
mkdir -p www
find www -mindepth 1 -delete
mkdir -p www/raw
find man[1-9] -type f -name '*.[1-9]*' | xargs -I x cp -p x www/raw/
for page in $(cd www/raw && ls *.[1-9]*); do
    raw="www/raw/$page"
    new="www/.$page.new"
    dst="www/$page"
    if unroff -man <"$raw" >"$new"; then
        mv -f "$new" "$dst"
    else
        echo "FAIL $page"
        rm -f "$new"
    fi
done
cp -f dist/schemeorg.css www/
gosh -I lib lib/generate-index.scm
