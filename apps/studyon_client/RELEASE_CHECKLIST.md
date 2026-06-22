# StudyON Mobile Release Checklist

## Before Build

- Confirm `pubspec.yaml` version/build is higher than the store version.
- Confirm `0013_character_rpg_xp` and later migrations are deployed.
- Run `flutter analyze` from `apps/studyon_client`.
- Run API typecheck and focused reward tests from `apps/api`.
- Verify iOS focus mode text says soft guard, not hard blocking.

## App Store

- Fill `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`, and `FASTLANE_USER` in CI secrets.
- Replace Fastlane review demo account placeholders before submission.
- Build `build/ios/ipa/studyon_client.ipa`.
- Upload with `bundle exec fastlane appstore_upload`.
- Submit only after screenshots, privacy URL, support URL, age rating, and review notes are final.

## ONE Store

- Build `build/app/outputs/bundle/release/app-release.aab`.
- Set `ONESTORE_USERNAME`, `ONESTORE_PASSWORD`, and optional `ONESTORE_OTP_SECRET` outside git.
- Run `node scripts/onestore_portal_release.mjs` in a headed session after inspecting portal selectors.
- Keep `ONESTORE_SUBMIT_FOR_VERIFICATION=false` until metadata and screenshots are reviewed.
