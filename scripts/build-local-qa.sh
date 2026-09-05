#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p artifacts/local-qa
xcodebuild -version > artifacts/local-qa/xcode-version.txt
(cd native-ios && xcodegen generate)
xcodebuild archive -project native-ios/TiltArena.xcodeproj -scheme TiltArena \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -archivePath artifacts/TiltArena-Local-QA.xcarchive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' \
  | tee artifacts/local-qa/archive.log
app='artifacts/TiltArena-Local-QA.xcarchive/Products/Applications/TiltArena.app'
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Info.plist")
build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Info.plist")
sha=$(git rev-parse HEAD)
name="TiltArena-${version}-build${build}-Local-QA-${sha:0:7}"
mkdir -p artifacts/ipa-staging/Payload
ditto "$app" artifacts/ipa-staging/Payload/TiltArena.app
(cd artifacts/ipa-staging && /usr/bin/zip -qry "../local-qa/$name.ipa" Payload)
xcrun lipo -archs "$app/TiltArena" > artifacts/local-qa/architectures.txt
xcrun vtool -show-build "$app/TiltArena" > artifacts/local-qa/macho-platform.txt
python3 - "$app" "artifacts/local-qa/$name.ipa" "$sha" <<'PY'
import hashlib, json, os, pathlib, plistlib, sys, zipfile
app, ipa, sha = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
info = plistlib.loads((app / 'Info.plist').read_bytes())
assert info['CFBundleSupportedPlatforms'] == ['iPhoneOS']
assert info['CFBundleIdentifier'] == 'com.dmkr.tiltarena'
assert (app / 'TiltArena').read_bytes()[:4] == bytes.fromhex('cffaedfe')
with zipfile.ZipFile(ipa) as z:
    assert z.testzip() is None
    assert 'Payload/TiltArena.app/Info.plist' in z.namelist()
manifest = {
    'app': 'TiltArena', 'version': info['CFBundleShortVersionString'],
    'build': info['CFBundleVersion'], 'purpose': 'Local-QA',
    'sourceCommit': sha, 'runID': os.environ.get('GITHUB_RUN_ID'),
    'ipa': ipa.name, 'sha256': hashlib.sha256(ipa.read_bytes()).hexdigest(),
    'platforms': info['CFBundleSupportedPlatforms'], 'architecture': 'arm64',
    'bundleIdentifier': info['CFBundleIdentifier'], 'minimumOS': info['MinimumOSVersion'],
    'signing': 'Unsigned device IPA; requires signing during Sideloadly installation',
    'physicalDeviceTested': False, 'testFlightUploaded': False,
}
(ipa.parent / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps(manifest, indent=2))
PY
