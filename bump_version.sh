NEW_VERSION=$1
DATE=$(date +'%Y-%m-%d')

# Update Plists
agvtool new-marketing-version $NEW_VERSION

# Update Fallback plist
/usr/libexec/PlistBuddy -c "Set :ReleaseVersion $NEW_VERSION" "PACECloudSDK/Utils/Plists/FallbackVersions.plist"
echo "Updated fallback version to $NEW_VERSION"

# Update podspec file
bundle exec fastlane bump_podspec version_number:$NEW_VERSION
echo "Updated PACECloudSDK.podspec to $NEW_VERSION"

# Update Changelog
NEW_RELEASE_STRING="""x.y.z Release notes (yyyy-MM-dd)\n\
=============================================================\n\
\n\
<!-- ### Breaking Changes - Include, if needed -->\n\
<!-- ### Enhancements - Include, if needed -->\n\
<!-- ### Fixes - Include, if needed -->\n\
<!-- ### Internal - Include, if needed -->\n"""

sed -i '' -e "s/x.y.z Release notes (yyyy-MM-dd)/${NEW_VERSION} Release notes (${DATE})/" -e '/^<!--.*-->$/d' -e '1s/^/'"${NEW_RELEASE_STRING}"'\'$'\n/' CHANGELOG.md
echo "Updated CHANGELOG.md to $NEW_VERSION"

# Commit changes
git checkout -b "bump-version-$NEW_VERSION"
git add -u
git commit -m "Bump version to $NEW_VERSION"
