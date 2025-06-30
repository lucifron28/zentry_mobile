#!/bin/bash
echo "🏗️ Building Zentry Mobile APK (Release)..."

# Clean and prepare
echo "🧹 Cleaning previous build..."
flutter clean
flutter pub get

# Check if .env file exists and warn if not
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found. AI assistant will run in demo mode."
    echo "💡 To enable full AI features:"
    echo "   1. Copy .env.example to .env"
    echo "   2. Add your Gemini API key"
    echo "   3. Rebuild the app"
    echo ""
fi

# Build release APK with optimizations
echo "📦 Building release APK..."
flutter build apk --release \
    --build-name=1.1.0 \
    --build-number=1 \
    --target-platform android-arm64 \
    --shrink

# Custom naming with date and features
DATE=$(date +%Y%m%d)
FEATURES="AI-Webhooks-Teams"
APK_NAME="ZentryMobile-v1.1.0-$FEATURES-$DATE.apk"

# Move and rename APK
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    mv build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/$APK_NAME"
    
    echo ""
    echo "✅ APK built successfully!"
    echo "📱 Name: $APK_NAME"
    echo "📁 Location: build/app/outputs/flutter-apk/$APK_NAME"
    echo "📊 Features: AI Assistant (Demo Mode), Webhooks, Teams Integration"
    echo ""
    
    # Show APK size
    APK_SIZE=$(du -h "build/app/outputs/flutter-apk/$APK_NAME" | cut -f1)
    echo "💾 APK Size: $APK_SIZE"
    
    # Optional: Copy to desktop for easy access
    if [ -d "$HOME/Desktop" ]; then
        cp "build/app/outputs/flutter-apk/$APK_NAME" "$HOME/Desktop/"
        echo "📋 APK copied to Desktop for easy access!"
    fi
    
    echo ""
    echo "🎉 Ready for demo and distribution!"
    
else
    echo "❌ Build failed - APK not found"
    exit 1
fi

