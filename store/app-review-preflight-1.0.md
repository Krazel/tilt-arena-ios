# Tilt Arena — App Review preparation (version 1.0)

Updated: 2026-09-15

This dossier records preparation only. No App Store review submission or public release was created.

## Verified in App Store Connect API

- App: Tilt Arena (`6809193185`), bundle ID `com.dmkr.tiltarena`.
- Primary locale: `en-US`; secondary locale: `es-ES`.
- Version: `1.0`, state `PREPARE_FOR_SUBMISSION`.
- Candidate build: 0.3.9 (1), build ID `88f7f95e-aeaa-40ab-bae8-456a4d829471`, processing `VALID`, `APP_STORE_ELIGIBLE`, `usesNonExemptEncryption=false`.
- Version 1.0 now points to that build through the App Store Connect API.
- Copyright: `© 2026 Krazel Games`.
- Category: Games / Action.
- Age rating: 9+ (`INFREQUENT_OR_MILD` cartoon/fantasy violence; all other declared categories none).
- Spain base territory: `ESP`, currency `EUR`; current price point is `3.99` EUR (official point `10049`, proceeds `2.29`). The regional schedule is documented rather than assuming a universal 3.99 price.
- Four 1290×2796 iPhone 6.7-inch screenshots are uploaded and processed (`COMPLETE`) for `es-ES` and `en-US`. The English set was replaced with the English-language CI capture from GitHub Actions run `34999997547`; API read-back confirms all eight resources are `COMPLETE` with no asset errors. The source provenance is retained under `artifacts/ci-english/`.
- Export compliance is supported by the exact build flag `ITSAppUsesNonExemptEncryption=false`; no encryption declaration is attached to the valid build.
- Metadata copy is present in both localizations. The approved Spanish description/promotional text is in `artifacts/update-asc-spanish-copy.mjs` and the English primary copy remains in `artifacts/set-primary-english.mjs`.
- Privacy policy and support URLs are now public and return HTTPS 200: `https://krazel.github.io/tilt-arena/privacy/` and `https://krazel.github.io/tilt-arena/support/`. App Store Connect API read-back confirms both URLs on both `en-US` and `es-ES` localizations.

## Binary/privacy evidence

The 0.3.9 TestFlight IPA is `artifacts/TiltArena-0.3.9-build1-TestFlight.ipa`, SHA-256 `47cf7f63273f6b3031508885d6ede0ada0084bc39ba7a50b5653ef359b11e67b`. Its privacy manifest declares no collected data and no tracking; only UserDefaults and SystemBootTime required-reason APIs are listed. The app has no ads, account, analytics, network service, or in-app purchase flow in the candidate build. Motion data is used locally for control and is never sent.

## Still required before a review submission

- App Privacy questionnaire must be completed in App Store Connect. The official API has no app privacy questionnaire resource for this account (the app resource relationship and the previously attempted `appPrivacyDetails` paths return `404 PATH_ERROR`); the questionnaire must be completed in the App Store Connect web interface by the account owner. The privacy manifest and public policy are evidence, not a substitute for that questionnaire.
- App Review contact first/last name, phone, email, demo-account answer, and review notes must be entered once the owner supplies the private review contact details. The API relationship currently returns `data: null`; no private contact details were invented or written.
- Review the final screenshots visually on the actual product and keep the API evidence with the submission record.
- The D1 library record needs a post-preflight write with the verified build, price and screenshot state. The authorized library token is not present in this product task, so this remains a reconciliation item for the coordinating library task.

No submission, approval, public App Store release, or external TestFlight group was created by this preparation.
