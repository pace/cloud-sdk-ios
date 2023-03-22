#!/bin/bash

echo 'Checking if "curl" command is available'
if ! [[ $(command -v curl) ]]; then
  echo "'curl' is not installed. Install 'curl' via 'brew install curl' or your OS's respective dependency manager's command"
  exit 1
fi

echo 'Checking if "jq" command is available'
if ! [[ $(command -v jq) ]]; then
  echo "'jq' is not installed. Install 'jq' via 'brew install jq' or your OS's respective dependency manager's command"
  exit 1
fi

TOKEN=$GITHUB_API_TOKEN
SDK=$1
SLIM_SDK=$2
WATCH_SDK=$3

echo 'Getting latest release'
RELEASE_ID=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/pace/cloud-sdk-ios/releases/latest | jq -r '.id')

echo 'Uploading SDK xcframework'
status_sdk=$(curl -s \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  https://uploads.github.com/repos/pace/cloud-sdk-ios/releases/$RELEASE_ID/assets?name=PACECloudSDK.zip \
  --data-binary "@$SDK" \
  --write-out %{http_code} \
  --output /dev/null)

if [ $status_sdk == "201" ]; then
    echo "Successfully uploaded SDK"
else
    echo "Failed uploading SDK with error $status_sdk"  
fi

echo 'Uploading Slim SDK xcframework'
status_slim_sdk=$(curl -s \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  https://uploads.github.com/repos/pace/cloud-sdk-ios/releases/$RELEASE_ID/assets?name=PACECloudSlimSDK.zip \
  --data-binary "@$SLIM_SDK" \
  --write-out %{http_code} \
  --output /dev/null)

if [ $status_slim_sdk == "201" ]; then
    echo "Successfully uploaded Slim SDK"
else
    echo "Failed uploading Slim SDK with error $status_slim_sdk"  
fi

echo 'Uploading Watch SDK xcframework'
status_watch_sdk=$(curl -s \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  https://uploads.github.com/repos/pace/cloud-sdk-ios/releases/$RELEASE_ID/assets?name=PACECloudWatchSDK.zip \
  --data-binary "@$WATCH_SDK" \
  --write-out %{http_code} \
  --output /dev/null)

if [ $status_watch_sdk == "201" ]; then
    echo "Successfully uploaded Watch SDK"
else
    echo "Failed uploading Watch SDK with error $status_watch_sdk"  
fi