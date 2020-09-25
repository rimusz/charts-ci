#!/bin/sh -e

# shellcheck disable=SC2002
tag=${TAG_ARGS}

if [[ "${tag}" == "" ]]
then
    echo "Please provide tag x.x.x !!!"
    exit
fi

echo "Tagging chartcenter-plugin with v${tag} ..."

git checkout master
git pull
git tag -a -m "Release v$tag" "v$tag" 
git push origin refs/tags/v"$tag"
