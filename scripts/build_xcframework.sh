#!/bin/bash

PROJECT_NAME=$1
DEVICE_SDK=$2
SIMULATOR_SDK=$3

xcodebuild archive -scheme $PROJECT_NAME -sdk $DEVICE_SDK -archivePath "archives/ios_devices.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO | xcpretty || exit 1
xcodebuild archive -scheme $PROJECT_NAME -sdk $SIMULATOR_SDK -archivePath "archives/ios_simulators.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO | xcpretty || exit 1
xcodebuild -create-xcframework -framework archives/ios_devices.xcarchive/Products/Library/Frameworks/$PROJECT_NAME.framework -framework archives/ios_simulators.xcarchive/Products/Library/Frameworks/$PROJECT_NAME.framework -output build/${PROJECT_NAME}.xcframework | xcpretty || exit 1
zip -r build/$PROJECT_NAME.zip build/$PROJECT_NAME.xcframework || exit 1

echo "Successfully built xcFramework of $PROJECT_NAME"