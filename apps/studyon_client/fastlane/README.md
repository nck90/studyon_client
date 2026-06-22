fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios appstore_create_app

```sh
[bundle exec] fastlane ios appstore_create_app
```

Create the App Store Connect app record and Developer Portal bundle id

### ios appstore_upload

```sh
[bundle exec] fastlane ios appstore_upload
```

Upload binary, metadata, and screenshots to App Store Connect

### ios appstore_binary_upload

```sh
[bundle exec] fastlane ios appstore_binary_upload
```

Upload only the IPA binary to App Store Connect

### ios appstore_metadata

```sh
[bundle exec] fastlane ios appstore_metadata
```

Update App Store metadata and screenshots without a binary

### ios appstore_submit_review

```sh
[bundle exec] fastlane ios appstore_submit_review
```

Upload and submit the App Store version for review

### ios appstore_submit_existing_review

```sh
[bundle exec] fastlane ios appstore_submit_existing_review
```

Submit the already uploaded App Store Connect version for review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
