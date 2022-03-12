#!/bin/bash

set -o pipefail

# fetch tags
git fetch --tags

# get latest tag that looks like a semver (with or without v)
tag=""
tagFmt="^v?[0-9]+\.[0-9]+\.[0-9]+$"
tag_context=${TAG_CONTEXT:-repo}
case "$tag_context" in
    *repo*)
        taglist="$(git for-each-ref --sort=-v:refname --format '%(refname:lstrip=2)' | grep -E "$tagFmt")"
        if [ -z "$taglist" ]; then
            tag="$(semver $taglist | tail -n 1)"
        fi
        ;;
    *branch*)
        taglist="$(git tag --list --merged HEAD --sort=-v:refname | grep -E "$tagFmt")"
        tag="$(semver $taglist | tail -n 1)"
        ;;
esac

echo "!$tag!"

# if there are none, start tags at INITIAL_VERSION which defaults to 0.0.0
if [ -z "$tag" ]; then
    echo "there 1 - $tag"
    tag="$(jq .version metadata.json).0.0"
else
    echo "there 2 - $tag"
    tag="$(semver -i minor $tag)"
fi

echo "@$tag@"

# export env var for subsequent steps
echo "TAG=$tag" >> $GITHUB_ENV
