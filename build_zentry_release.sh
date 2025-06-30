#!/bin/bash
echo "Building Zentry Mobile APK..."

flutter clean
flutter pub get

flutter build apk --release --build-name=1.1.0 --build-number=1

APK_NAME="ZentryMobile-v1.1.0-$(date +%Y%m%d).apk"
mv build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/$APK_NAME"

echo "✅ APK built successfully: $APK_NAME"
echo "📁 Location: build/app/outputs/flutter-apk/$APK_NAME"

