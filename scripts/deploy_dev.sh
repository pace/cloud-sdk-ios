#!/bin/bash

SLIM_SDK=$1
WATCH_SDK=$2

echo 'Updating Package.swift file'
./scripts/update_package.sh dev $SLIM_SDK $WATCH_SDK

echo 'Committing changes'
git remote set-url origin "git@$CI_SERVER_HOST:$CI_PROJECT_PATH.git"
git fetch --all --tags --force
git checkout master
git add -u
git commit -m "build: Update Package file"
git tag -f dev
git push origin master --tags --atomic --force-with-lease # Force push needed to override tag

echo 'Updating dev release'
./scripts/update_github_dev_release_assets.sh $SLIM_SDK $WATCH_SDK