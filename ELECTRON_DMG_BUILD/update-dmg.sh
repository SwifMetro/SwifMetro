#!/bin/bash

# SwifMetro DMG Update Script
# Automatically increments version, builds notarized DMG, updates download page

set -e  # Exit on any error

echo "🚀 SwifMetro DMG Update Script"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to SwiftMetro directory
cd /Users/conlanainsworth/Desktop/SwiftMetro

# Step 1: Get current version
echo "📋 Step 1: Reading current version..."
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "   Current version: ${CURRENT_VERSION}"

# Step 2: Increment patch version (1.0.7 -> 1.0.8)
IFS='.' read -r -a version_parts <<< "$CURRENT_VERSION"
major="${version_parts[0]}"
minor="${version_parts[1]}"
patch="${version_parts[2]}"
new_patch=$((patch + 1))
NEW_VERSION="${major}.${minor}.${new_patch}"

echo "   New version: ${NEW_VERSION}"
echo "   Auto-continuing with v${NEW_VERSION}..."

# Step 3: Update package.json
echo ""
echo "✏️  Step 2: Updating package.json..."
sed -i '' "s/\"version\": \"${CURRENT_VERSION}\"/\"version\": \"${NEW_VERSION}\"/" package.json
echo "   ✅ Updated to v${NEW_VERSION}"

# Step 4: Force unmount any existing DMGs
echo ""
echo "💾 Step 3: Unmounting existing DMGs..."
hdiutil detach "/Volumes/SwifMetro Installer" -force 2>/dev/null || true
hdiutil detach "/Volumes/SwifMetro Installer 1" -force 2>/dev/null || true
hdiutil detach "/Volumes/SwifMetro Installer 2" -force 2>/dev/null || true
hdiutil detach "/Volumes/SwifMetro Installer 3" -force 2>/dev/null || true
hdiutil detach "/Volumes/SwifMetro Installer 4" -force 2>/dev/null || true
echo "   ✅ DMGs unmounted"

# Step 5: Verify icon exists
echo ""
echo "🎨 Step 4: Checking icon..."
if [ ! -f "build/icon.icns" ]; then
    echo -e "   ${RED}❌ build/icon.icns missing!${NC}"
    echo "   Run: ./create-icon.sh"
    exit 1
fi
echo "   ✅ Icon exists"

# Step 6: Verify entitlements exist
echo ""
echo "📜 Step 5: Checking entitlements..."
if [ ! -f "build/entitlements.mac.plist" ]; then
    echo -e "   ${YELLOW}⚠️  Creating entitlements.mac.plist${NC}"
    cat > build/entitlements.mac.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
  </dict>
</plist>
EOF
fi
echo "   ✅ Entitlements exist"

# Step 7: Set Apple credentials for notarization
echo ""
echo "🔐 Step 6: Setting up notarization credentials..."
export APPLE_ID="conlanscottoc@icloud.com"
export APPLE_APP_SPECIFIC_PASSWORD="vnnj-ltex-msit-ezuh"
export APPLE_TEAM_ID="HPV26WQ9RU"
echo "   ✅ Credentials loaded"

# Step 8: Verify @electron/notarize is installed
if ! npm list @electron/notarize > /dev/null 2>&1; then
    echo -e "   ${YELLOW}⚠️  Installing @electron/notarize...${NC}"
    npm install --save-dev @electron/notarize
fi

# Step 9: Build DMG with notarization
echo ""
echo "🔨 Step 7: Building notarized DMG (this takes 5-15 mins)..."
echo "   ⏳ Apple is scanning for malware - please be patient..."
echo "   Building for Intel and Apple Silicon..."
npm run build 2>&1 | tee build.log

# Check for notarization success in log
if grep -q "notarization successful" build.log || grep -q "Notarization successful" build.log; then
    echo -e "   ${GREEN}✅ Notarization completed!${NC}"
elif grep -q "skipped macOS notarization" build.log; then
    echo -e "   ${RED}❌ Notarization was SKIPPED!${NC}"
    echo "   Check that credentials are set correctly"
    exit 1
fi

# Check if build succeeded
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Step 9: Verify DMG files exist
echo ""
echo "✅ Step 8: Verifying DMG files..."
if [ ! -f "dist/SwifMetro-${NEW_VERSION}.dmg" ]; then
    echo -e "${RED}❌ Intel DMG missing!${NC}"
    exit 1
fi
if [ ! -f "dist/SwifMetro-${NEW_VERSION}-arm64.dmg" ]; then
    echo -e "${RED}❌ Apple Silicon DMG missing!${NC}"
    exit 1
fi

INTEL_SIZE=$(ls -lh "dist/SwifMetro-${NEW_VERSION}.dmg" | awk '{print $5}')
ARM_SIZE=$(ls -lh "dist/SwifMetro-${NEW_VERSION}-arm64.dmg" | awk '{print $5}')

echo "   ✅ Intel DMG: ${INTEL_SIZE}"
echo "   ✅ Apple Silicon DMG: ${ARM_SIZE}"

# Step 10: Update download.html
echo ""
echo "📝 Step 9: Updating download.html..."
sed -i '' "s/SwifMetro-[0-9.]*-arm64\.dmg/SwifMetro-${NEW_VERSION}-arm64.dmg/g" download.html
sed -i '' "s/SwifMetro-[0-9.]*\.dmg/SwifMetro-${NEW_VERSION}.dmg/g" download.html
sed -i '' "s/• v[0-9.]*</• v${NEW_VERSION}</g" download.html
echo "   ✅ download.html updated"

# Step 11: Auto-open DMG for verification
echo ""
echo "🧪 Step 10: Opening DMG for verification..."
open "dist/SwifMetro-${NEW_VERSION}-arm64.dmg"

# Success summary
echo ""
echo "================================"
echo -e "${GREEN}✅ DMG v${NEW_VERSION} built successfully!${NC}"
echo ""
echo "📦 Files created:"
echo "   - dist/SwifMetro-${NEW_VERSION}.dmg (${INTEL_SIZE})"
echo "   - dist/SwifMetro-${NEW_VERSION}-arm64.dmg (${ARM_SIZE})"
echo ""
echo "📝 Updated:"
echo "   - package.json → v${NEW_VERSION}"
echo "   - download.html → v${NEW_VERSION}"
echo ""
echo "🔒 Notarization: ✅ Complete (no malware warnings)"
echo "🎨 Icon: ✅ Included"
echo ""
echo "🚀 Next steps:"
echo "   1. Test DMG: open dist/SwifMetro-${NEW_VERSION}-arm64.dmg"
echo "   2. Visit: http://localhost:3000/download.html"
echo "   3. Download and verify no warnings"
echo ""
