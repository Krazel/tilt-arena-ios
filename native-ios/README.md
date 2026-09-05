# TiltArena native iOS prototype

Native SpriteKit version of the web prototype.

## Build on Mac

1. Install Xcode.
2. Install XcodeGen if needed: `brew install xcodegen`.
3. From this folder run: `xcodegen generate`.
4. Open `TiltArena.xcodeproj`.
5. Set your Apple Developer Team in Signing & Capabilities.
6. Run on an iPhone or simulator in landscape orientation.

The game is drawn natively with SpriteKit and uses CoreMotion for tilt input, with touch-drag fallback for simulator testing.
