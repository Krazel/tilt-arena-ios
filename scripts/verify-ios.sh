#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../native-ios"
command -v xcodegen >/dev/null
xcodegen generate
xcodebuild -project TiltArena.xcodeproj -scheme TiltArena \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
device_id=$(xcrun simctl list devices available -j | python3 -c 'import sys,json; d=json.load(sys.stdin); print(next(x["udid"] for group in d["devices"].values() for x in group if x["name"].startswith("iPhone")))')
xcodebuild -project TiltArena.xcodeproj -scheme TiltArena \
  -destination "platform=iOS Simulator,id=$device_id" \
  -derivedDataPath DerivedData -resultBundlePath "${TMPDIR:-/tmp}/TiltArena-tests-$(date +%s).xcresult" \
  CODE_SIGNING_ALLOWED=NO test
