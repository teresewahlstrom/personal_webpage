#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release

# Compatibility output for projects still configured with "dist" on Pages.
rm -rf dist
cp -r build/web dist
