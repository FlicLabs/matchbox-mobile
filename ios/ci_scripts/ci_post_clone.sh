#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# Navigate to the root of the cloned repo.
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Install Flutter using git (3.19.5 tag).
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.24.0 "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# Make sure Flutter pulls the Dart SDK from the proper Google bucket
# (this overrides any weird defaults in the Xcode Cloud environment).
export PUB_HOSTED_URL="https://pub.dev"
export FLUTTER_STORAGE_BASE_URL="https://storage.googleapis.com"

# Install Flutter artifacts for iOS.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1  # disable Homebrew's automatic updates.
brew install cocoapods

# Navigate to the `ios` directory.
cd ios

# Deintegrate CocoaPods and then reinstall dependencies to ensure compatibility.
pod deintegrate
pod install

exit 0