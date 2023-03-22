#!/bin/bash

NEW_VERSION=$1
SLIM_SDK=$2
WATCH_SDK=$3

update_checksum() {
	sdk_name=$1
	sdk=$2

	# Get line of checksum
	line_download_path=$(sed -n ''"/https:\/\/github.com\/pace\/cloud-sdk-ios\/releases\/download\/.+\/$sdk_name.zip/="'' Package.swift)
	line_checksum=$(($line_download_path + 1))
	
	# # Update checksum
	checksum=$(swift package compute-checksum $sdk)
	sed -i '' -E ''"$line_checksum"'s/(checksum:[[:space:]]*).+/\1'\"$checksum\"'/' Package.swift
}

sed -i '' -E 's/(https:\/\/github.com\/pace\/cloud-sdk-ios\/releases\/download\/).+\//\1'"$NEW_VERSION\/"'/' Package.swift

update_checksum "PACECloudSlimSDK" $SLIM_SDK
update_checksum "PACECloudWatchSDK" $WATCH_SDK

echo "Updated binary targets of Slim and Watch SDK in Package.swift file"