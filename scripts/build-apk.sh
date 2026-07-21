#!/usr/bin/env bash
#
# build-apk.sh — prod serverga (IP+HTTP) ulanadigan Android APK.
# Mac'da Flutter/Android SDK bilan ishlaydi.
#
#   ./scripts/build-apk.sh
#   API_URL=http://boshqa-manzil/api/v1 ./scripts/build-apk.sh   # boshqa backend
#
# Natija: build/app/outputs/flutter-apk/app-release.apk
set -euo pipefail
cd "$(dirname "$0")/.."

API_URL="${API_URL:-http://169.58.51.242/api/v1}"
echo "→ API_URL=$API_URL"

flutter pub get
flutter build apk --release \
  --dart-define=API_URL="$API_URL" \
  --dart-define=DEV_TOOLS=false \
  --dart-define=LOG_HTTP=false

APK="build/app/outputs/flutter-apk/app-release.apk"
echo "✓ APK tayyor: $APK"
ls -lh "$APK" 2>/dev/null || true
