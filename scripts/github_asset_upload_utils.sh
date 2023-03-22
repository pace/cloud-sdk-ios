#!/bin/bash

check_commands() {
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
}

upload_asset() {
  TOKEN=$1
  RELEASE_ID=$2
  ASSET_NAME=$3
  ASSET_BINARY=$4

  echo "Uploading asset for $ASSET_NAME"
  status_asset=$(curl -s \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/octet-stream" \
    https://uploads.github.com/repos/pace/cloud-sdk-ios/releases/$RELEASE_ID/assets?name=$ASSET_NAME.zip \
    --data-binary "@$ASSET_BINARY" \
    --write-out %{http_code} \
    --output /dev/null)

  if [ $status_asset == "201" ]; then
      echo "Successfully uploaded asset for $ASSET_NAME"
  else
      echo "Failed uploading asset for $ASSET_NAME with error $status_asset"  
  fi
}