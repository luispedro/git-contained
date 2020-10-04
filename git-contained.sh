#!/usr/bin/env bash

tmpdir=$(mktemp -d)

# Make sure we have all of the objects from the remote repository.
git fetch central-repository

# Enumerate each revision reachable from a ref under refs/heads and
# refs/tags and save it in a file.
git ls-remote central-repository refs/heads/* refs/tags/* | awk '{print $1}' | \
    xargs git rev-list > $tmpdir/remote-revs

# Enumerate the commit for each ref in this repository and find any
# that are not in the list of remote revisions.
if git for-each-ref | awk '{print $1}' | grep -f $tmpdir/remote-revs -qsvF
then
    echo "Oh, no!  Missing commits!"
else
    echo "Up to date."
fi
