#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../native-ios"
command -v xcodegen >/dev/null
mkdir -p ../artifacts/ios-verification
xcodebuild -version > ../artifacts/ios-verification/xcode-version.txt
xcodegen generate
xcodebuild -project TiltArena.xcodeproj -scheme TiltArena \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
app_plist='DerivedData/Build/Products/Debug-iphonesimulator/TiltArena.app/Info.plist'
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_plist")
build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app_plist")
tar -czf "../artifacts/ios-verification/TiltArena-${version}-build${build}-simulator.tar.gz" -C DerivedData/Build/Products/Debug-iphonesimulator TiltArena.app
device_id=$(xcrun simctl list devices available -j | python3 -c 'import sys,json; d=json.load(sys.stdin); print(next(x["udid"] for group in d["devices"].values() for x in group if x["name"].startswith("iPhone")))')
xcodebuild -project TiltArena.xcodeproj -scheme TiltArena \
  -destination "platform=iOS Simulator,id=$device_id" \
  -derivedDataPath DerivedData -resultBundlePath ../artifacts/ios-verification/TiltArena-tests.xcresult \
  CODE_SIGNING_ALLOWED=NO test
xcrun simctl bootstatus "$device_id" -b
xcrun simctl install "$device_id" DerivedData/Build/Products/Debug-iphonesimulator/TiltArena.app
xcrun simctl launch "$device_id" com.dmkr.tiltarena
sleep 3
xcrun simctl io "$device_id" screenshot ../artifacts/ios-verification/native-menu.png
