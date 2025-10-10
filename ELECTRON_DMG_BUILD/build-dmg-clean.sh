#!/bin/bash

# Clean DMG Build Script
# Use this if npm run build hangs or fails

set -e

echo "🧹 Cleaning up previous builds..."

# Kill any stuck processes
pkill -9 node 2>/dev/null || true
pkill -9 electron 2>/dev/null || true
pkill -9 electron-builder 2>/dev/null || true
pkill -9 codesign 2>/dev/null || true

sleep 2

# Unmount any DMGs
hdiutil detach "/Volumes/SwifMetro Installer" -force 2>/dev/null || true

# Clean dist folders
rm -rf dist/mac dist/mac-arm64

# Clean caches
rm -rf node_modules/.cache
rm -rf ~/Library/Caches/electron-builder

echo "✅ Cleanup complete!"
echo ""
echo "Now run: npm run build"
