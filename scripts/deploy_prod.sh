#!/bin/bash

SDK=$1
SLIM_SDK=$2
WATCH_SDK=$3

echo 'Checking out master branch'
git remote set-url origin "git@$CI_SERVER_HOST:$CI_PROJECT_PATH.git"
git fetch --all --tags --force
git checkout master
git pull --rebase

source ./scripts/bump_version.sh # Using 'source' here lets us use the exported env variables $OLD_SDK_VERSION and $NEW_SDK_VERSION in this script as well

echo 'Updating Package.swift file'
./scripts/update_package.sh $NEW_SDK_VERSION $SLIM_SDK $WATCH_SDK

echo 'Committing changes'
git add -u
git commit -m "build: Bump version to $NEW_SDK_VERSION"
git tag $NEW_SDK_VERSION
git push origin master
git push origin $NEW_SDK_VERSION

echo 'Creating new release on GitHub'
bundle exec fastlane create_github_release new_sdk_version:$NEW_SDK_VERSION

echo 'Creating new release for CocoaPods'
pod trunk push PACECloudSDK.podspec --allow-warnings