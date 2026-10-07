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
trap 'xcrun xcresulttool export attachments --path ../artifacts/ios-verification/TiltArena-tests.xcresult --output-path ../artifacts/ios-verification/screenshots || true' EXIT

test_selection=(-only-testing:TiltArenaTests -only-testing:TiltArenaUITests)
if [ "${QA_ENGINE_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests)
fi
if [ "${QA_CONTROLS_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testAutomaticCalibrationSettingInBothLanguagesAndThemes
    -only-testing:TiltArenaUITests/ClassicFlowTests/testDefaultCalibrationAndSavedResume
    -only-testing:TiltArenaUITests/ClassicFlowTests/testPosturesPlayPauseAndResumeWithoutCalibration)
fi
if [ "${QA_AUDIO_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testSpikesOverGreenShieldAndExpiryWarning
    -only-testing:TiltArenaUITests/ClassicFlowTests/testAutomaticCalibrationSettingInBothLanguagesAndThemes
    -only-testing:TiltArenaUITests/ClassicFlowTests/testDefaultCalibrationAndSavedResume
    -only-testing:TiltArenaUITests/ClassicFlowTests/testPosturesPlayPauseAndResumeWithoutCalibration
    -only-testing:TiltArenaUITests/ClassicFlowTests/testApprovedAudioCreditsAreAccessibleInBothLanguages
    -only-testing:TiltArenaUITests/ClassicFlowTests/testRestartAfterDeathIsImmediateInBothThemes)
fi
if [ "${QA_DEATH_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testApprovedAudioCreditsAreAccessibleInBothLanguages
    -only-testing:TiltArenaUITests/ClassicFlowTests/testFinalSpeedHasNoTrialControlInMenuPauseOrResults
    -only-testing:TiltArenaUITests/ClassicFlowTests/testDeathFragmentsAppearBeforeResultsAndRestartNeedsNoConfirmation
    -only-testing:TiltArenaUITests/ClassicFlowTests/testTapSkipsDeathWithoutRestartingOrPausing
    -only-testing:TiltArenaUITests/ClassicFlowTests/testRestartAfterDeathIsImmediateInBothThemes)
fi
if [ "${QA_VISUAL_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testRestartAfterDeathIsImmediateInBothThemes
    -only-testing:TiltArenaUITests/ClassicFlowTests/testApprovedAudioCreditsAreAccessibleInBothLanguages
    -only-testing:TiltArenaUITests/ClassicFlowTests/testHardModeSelectionPersistsAndOpeningIsCrowded
    -only-testing:TiltArenaUITests/ClassicFlowTests/testIllustratedMenuAndConfirmedRunActionsInBothLanguagesAndThemes
    -only-testing:TiltArenaUITests/ClassicFlowTests/testLingeringAreasAndColoredOrbsInBothThemes
    -only-testing:TiltArenaUITests/ClassicFlowTests/testReleaseIgnoresOldVisualPreferences)
fi
if [ "${QA_HUD_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testHUDRibbonsWithLargeNumbersInBothLanguages
    -only-testing:TiltArenaUITests/ClassicFlowTests/testReleaseIgnoresOldVisualPreferences)
fi
if [ "${QA_GAMEPLAY_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testHardModeSelectionPersistsAndOpeningIsCrowded
    -only-testing:TiltArenaUITests/ClassicFlowTests/testReleaseIgnoresOldVisualPreferences
    -only-testing:TiltArenaUITests/ClassicFlowTests/testFireRecoveryIndicatorAfterDash
    -only-testing:TiltArenaUITests/ClassicFlowTests/testLaserAndRevisedWaveOrbInBothThemes)
fi
if [ "${QA_MENU_EFFECTS_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testAutomaticCalibrationSettingInBothLanguagesAndThemes
    -only-testing:TiltArenaUITests/ClassicFlowTests/testHardModeSelectionPersistsAndOpeningIsCrowded
    -only-testing:TiltArenaUITests/ClassicFlowTests/testLingeringAreasAndColoredOrbsInBothThemes)
fi
if [ "${QA_AREA_EFFECTS_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testLingeringAreasAndColoredOrbsInBothThemes)
fi
if [ "${QA_LASER_TRIAL_ONLY:-false}" = "true" ]; then
  test_selection=(-only-testing:TiltArenaTests
    -only-testing:TiltArenaUITests/ClassicFlowTests/testFinalEffectsAndMenuInBothLanguages
    -only-testing:TiltArenaUITests/ClassicFlowTests/testReleaseIgnoresOldVisualPreferences)
fi
xcodebuild -project TiltArena.xcodeproj -scheme TiltArena \
  -destination "platform=iOS Simulator,id=$device_id" \
  -derivedDataPath DerivedData -resultBundlePath ../artifacts/ios-verification/TiltArena-tests.xcresult \
  -parallel-testing-enabled NO "${test_selection[@]}" CODE_SIGNING_ALLOWED=NO test
# The area UI test already captures both styles at peak and lingering times.
# Avoid a second simulator boot solely for an unrelated default-menu screenshot.
if [ "${QA_AREA_EFFECTS_ONLY:-false}" = "true" ] || [ "${QA_LASER_TRIAL_ONLY:-false}" = "true" ] || [ "${QA_DEATH_ONLY:-false}" = "true" ]; then exit 0; fi
xcrun simctl bootstatus "$device_id" -b
xcrun simctl install "$device_id" DerivedData/Build/Products/Debug-iphonesimulator/TiltArena.app
xcrun simctl launch "$device_id" com.dmkr.tiltarena
sleep 3
xcrun simctl io "$device_id" screenshot ../artifacts/ios-verification/native-menu.png
