#!/bin/bash

COMMIT_MESSAGE=$1

echo 'Creating xcFramework for Slim SDK'
./scripts/build_slim_xcframework.sh

echo 'Creating xcFramework for Watch SDK'
./scripts/build_watch_xcframework.sh

echo 'Setting up dev review branch'
git remote set-url origin "git@$CI_SERVER_HOST:$CI_PROJECT_PATH.git"
git fetch --all --tags --force
git push origin :development-review
git branch -D development-review
git checkout -b "development-review"

echo 'Updating Package.swift file'
./scripts/update_package.sh dev-review build/PACECloudSlimSDK.zip build/PACECloudWatchSDK.zip

echo 'Committing changes'
git add -u
git commit -m "dev-review: $COMMIT_MESSAGE"
git tag -f dev-review
git push origin development-review --tags --set-upstream --atomic --force # Force push needed to override tag

echo 'Updating dev review release'
./scripts/update_github_dev_review_release_assets.sh build/PACECloudSlimSDK.zip build/PACECloudWatchSDK.zip