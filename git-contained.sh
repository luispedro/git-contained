#!/usr/bin/env bash

set -e
set -o pipefail

tmpdir=$(mktemp -d)
central=$1

# Make sure we have all of the objects from the remote repository.
git fetch $central


# Enumerate each revision reachable from a ref under refs/heads
git ls-remote --heads --tags $central | \
    awk '{print $1}' | \
    sort -u | \
    xargs git rev-list | \
    sort -u > $tmpdir/present.in-remote-heads.txt

# add in the tags
git ls-remote --tags $central | \
    awk '{print $1 }' | \
    sort -u - $tmpdir/present.in-remote-heads.txt \
    > $tmpdir/present.in-remote.txt


# Enumerate the commit for each ref in this repository
git for-each-ref | \
    sort | \
    grep -v remote| \
    gawk '{print $1}'> $tmpdir/present.locally.txt

# Find any that are not in the list of remote revisions.
comm -13 $tmpdir/present.in-remote.txt $tmpdir/present.locally.txt > $tmpdir/missing.txt

if test -s $tmpdir/missing.txt
then
    echo "Oh, no.  Missing commits:"
    cat $tmpdir/missing.txt
else
    echo "The remote $central contains all the commits/tags present locally"
fi
