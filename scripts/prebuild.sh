#!/bin/bash
set -e

echo "🧹 Cleaning Flutter cache..."
flutter clean

echo "🗑️ Removing pubspec.lock..."
rm -f pubspec.lock

echo "🔧 Repairing Flutter pub cache..."
flutter pub cache repair

echo "📦 Getting dependencies..."
flutter pub get

echo "✅ Prebuild setup complete!"
