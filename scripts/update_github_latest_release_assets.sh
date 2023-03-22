#!/bin/bash

TOKEN=$GITHUB_API_TOKEN
SDK=$1
SLIM_SDK=$2
WATCH_SDK=$3

source ./scripts/github_asset_upload_utils.sh
check_commands

echo 'Getting latest release'
RELEASE_ID=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/pace/cloud-sdk-ios/releases/latest | jq -r '.id')

upload_asset $TOKEN $RELEASE_ID "PACECloudSDK" $SDK
upload_asset $TOKEN $RELEASE_ID "PACECloudSlimSDK" $SLIM_SDK
upload_asset $TOKEN $RELEASE_ID "PACECloudWatchSDK" $WATCH_SDK