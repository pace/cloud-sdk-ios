#!/bin/bash

COMMIT_MESSAGE=$1

echo 'Creating xcFramework for Slim SDK'
./scripts/build_slim_xcframework.sh

echo 'Creating xcFramework for Watch SDK'
./scripts/build_watch_xcframework.sh

echo 'Setting up dev review branch'
git remote set-url origin "git@$CI_SERVER_HOST:$CI_PROJECT_PATH.git"
git fetch --all --tags --force
git push origin :dev-review
git branch -D dev-review
git checkout -b "dev-review"

echo 'Updating Package.swift file'
./scripts/update_package.sh 0.1.0 build/PACECloudSlimSDK.zip build/PACECloudWatchSDK.zip

echo 'Committing changes'
git add -u
git commit -m "dev-review: $COMMIT_MESSAGE"
git tag -f 0.1.0
git push origin dev-review --set-upstream
git push origin 0.1.0 --force # Force push needed to override tag

echo 'Updating dev review release'
./scripts/update_github_dev_review_release_assets.sh build/PACECloudSlimSDK.zip build/PACECloudWatchSDK.zip