#!/bin/bash

SLIM_SDK=$1
WATCH_SDK=$2

echo 'Updating Package.swift file'
./scripts/update_package.sh dev $SLIM_SDK $WATCH_SDK

echo 'Committing changes'
git fetch --all --tags --force
git pull --rebase
git add -u
git commit -m "build: Update Package file"
git tag -f dev
git push origin master --tags --atomic --force # Force push needed to override tag

echo 'Updating dev release'
./scripts/update_github_dev_release_assets.sh $SLIM_SDK $WATCH_SDK