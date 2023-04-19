#!/bin/bash

SDK=$1
SLIM_SDK=$2
WATCH_SDK=$3

source ./scripts/bump_version.sh # Using 'source' here lets us use the exported env variables $OLD_SDK_VERSION and $NEW_SDK_VERSION in this script as well

echo 'Updating Package.swift file'
./scripts/update_package.sh $NEW_SDK_VERSION $SLIM_SDK $WATCH_SDK

echo 'Committing changes'
git remote set-url origin "git@$CI_SERVER_HOST:$CI_PROJECT_PATH.git"
git fetch --all --tags --force
git checkout master
git add -u
git commit -m "build: Bump version to $NEW_SDK_VERSION"
git tag $NEW_SDK_VERSION
git push origin master --tags --atomic --force-with-lease # Force push needed to override tags

echo 'Creating new release on GitHub'
git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@${COMMON_REPO} tmp/common
pip3 install -r tmp/common/scripts/tags/requirements.txt
python3 tmp/common/scripts/tags/create_github_release.py -d pace/cloud-sdk-ios

echo 'Updating GitHub release assets'
./scripts/update_github_latest_release_assets.sh $SDK $SLIM_SDK $WATCH_SDK

echo 'Creating new release for CocoaPods'
pod trunk push PACECloudSDK.podspec --allow-warnings