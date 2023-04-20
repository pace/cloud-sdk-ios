#!/bin/bash

TOKEN=$GITHUB_API_TOKEN
RELEASE_ID=$1
SLIM_SDK=$2
WATCH_SDK=$3

source ./scripts/github_asset_upload_utils.sh
check_commands

echo 'Getting assets for release'
assets=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/pace/cloud-sdk-ios/releases/$RELEASE_ID/assets) 

echo 'Deleting assets for release'
echo $assets | jq -r '.[].id' | while read asset_id ; do
  curl -s \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/pace/cloud-sdk-ios/releases/assets/$asset_id
done

upload_asset $TOKEN $RELEASE_ID "PACECloudSlimSDK" $SLIM_SDK
upload_asset $TOKEN $RELEASE_ID "PACECloudWatchSDK" $WATCH_SDK