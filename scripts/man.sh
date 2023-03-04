#!/bin/bash
set -eu -o pipefail
cd "$(dirname "$0")"
cd ..
echo "Entering directory '$PWD'"

TAR=${TAR:-tar} # GNU tar

##

mkdir -p dist/scheme-manpages
$TAR -C dist/scheme-manpages \
    -xf dist/scheme-manpages.tar.gz \
    --wildcards '*/man[1-9]/*'

##

mkdir -p dist/chibi-scheme
$TAR -C dist/chibi-scheme \
    -xf dist/chibi-scheme.tar.gz \
    --wildcards '*/doc/*.[1-9]'

mkdir -p dist/gambit
$TAR -C dist/gambit \
    -xf dist/gambit.tar.gz \
    --wildcards '*/doc/*.[1-9]'

mkdir -p dist/gauche
$TAR -C dist/gauche \
    -xf dist/gauche.tar.gz \
    --wildcards '*/doc/*.[1-9].in'

mkdir -p dist/guile
$TAR -C dist/guile \
    -xf dist/guile.tar.gz \
    --wildcards '*/doc/*.[1-9]'

mkdir -p dist/kawa
$TAR -C dist/kawa \
    -xf dist/kawa.tar.gz \
    --wildcards '*/doc/*.man'

mkdir -p dist/stklos
$TAR -C dist/stklos \
    -xf dist/stklos.tar.gz \
    --wildcards '*/doc/*.[1-9].in'

##

mkdir -p dist/akku
$TAR -C dist/akku \
    -xf dist/akku.tar.gz \
    --wildcards '*/docs/*.[1-9]'

##

for section in 1 2 3 4 5 6 7 8 9; do
    mkdir -p "man${section}"
    find dist -type f -name "*.${section}*" | xargs -I x mv x "man${section}/"
done
find dist -type f -name "*.man" | xargs -I x mv x "man1/"

for page_man in man*/*.man; do
    page="$(echo "$page_man" | sed 's/.man$/.1/')"
    mv -f "$page_man" "$page"
done

for page_in in man*/*.[1-9].in; do
    page="$(echo "$page_in" | sed 's/.in$//')"
    mv -f "$page_in" "$page"
done
