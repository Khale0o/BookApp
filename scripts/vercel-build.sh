#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="/tmp/flutter"

rm -rf "$FLUTTER_DIR"

git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  --branch 3.38.5 \
  "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --enable-web
flutter pub get

flutter build web --release \
  --dart-define=BOOKSTORE_API_BASE_URL=https://bookstoreapi.runasp.net