# Electron App & DMG Build Guide

**Location:** `/Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/ELECTRON_DMG_BUILD/`  
**Purpose:** Complete guide to building the Electron app and DMG installer  
**Source:** Copied from `/Users/conlanainsworth/Desktop/SwiftMetro/`

---

## 📦 What's In This Folder

### Build Files:
- ✅ `package.json` - Electron build configuration
- ✅ `electron-main.js` - Main Electron process
- ✅ `update-dmg.sh` - Automated DMG build script
- ✅ `build-dmg-clean.sh` - Clean build (if stuck)
- ✅ `icon.icns` - App icon (512x512)

### Missing Files (Need to Create):
- ⏳ `build/entitlements.mac.plist` - macOS entitlements
- ⏳ `build/notarize.js` - Notarization script

---

## 🎯 How The Current DMG Was Built

The production DMG (`SwifMetro-1.0.0-arm64.dmg`) in `/Applications/` was built using:

### 1. package.json Configuration

```json
{
  "name": "swiftmetro",
  "version": "1.0.9",
  "main": "electron-main.js",
  "scripts": {
    "build": "electron-builder --mac"
  },
  "build": {
    "appId": "com.swiftmetro.app",
    "productName": "SwifMetro",
    "afterSign": "build/notarize.js",
    "mac": {
      "category": "public.app-category.developer-tools",
      "icon": "build/icon.icns",
      "identity": "Conlan Ainsworth (HPV26WQ9RU)",
      "hardenedRuntime": true,
      "target": [
        {
          "target": "dmg",
          "arch": ["x64", "arm64"]
        }
      ]
    },
    "files": [
      "electron-main.js",
      "swifmetro-server.js",
      "swifmetro-dashboard.html",
      "CONFIDENTIAL/.env",
      "node_modules/**/*"
    ]
  }
}
```

### 2. Files Included In DMG

The DMG packages these files:
- `electron-main.js` (13 KB) - License system, window management
- `swifmetro-server.js` (19 KB) - WebSocket server
- `swifmetro-dashboard.html` (39 KB) - Dashboard UI
- `node_modules/` - All dependencies (ws, dotenv, pg, etc.)
- `.env` file - Environment variables

All packed into: `app.asar` (52 MB)

---

## 🔨 How To Build DMG

### Method 1: Automated Script (RECOMMENDED)

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking

# Copy files to root (electron-builder looks here)
cp electron-main.js ./
cp swifmetro-server.js ./
cp swifmetro-dashboard.html ./

# Run automated build
./ELECTRON_DMG_BUILD/update-dmg.sh
```

**This script:**
1. ✅ Auto-increments version (1.0.9 → 1.0.10)
2. ✅ Creates entitlements if missing
3. ✅ Builds DMG for Intel + Apple Silicon
4. ✅ Notarizes with Apple (no malware warnings)
5. ✅ Updates download.html with new version
6. ✅ Opens DMG for verification

**Output:**
- `dist/SwifMetro-1.0.10.dmg` (Intel)
- `dist/SwifMetro-1.0.10-arm64.dmg` (Apple Silicon)

---

### Method 2: Manual Build

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking

# Install electron-builder
npm install --save-dev electron electron-builder

# Create build folder
mkdir -p build

# Copy icon
cp ELECTRON_DMG_BUILD/icon.icns build/

# Create entitlements
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

# Build DMG
npm run build
```

---

### Method 3: Clean Build (If Stuck)

```bash
# Clean everything
./ELECTRON_DMG_BUILD/build-dmg-clean.sh

# Then rebuild
npm run build
```

---

## 🔐 Notarization (Apple Security)

### What is Notarization?
Apple scans your app for malware. Without it, users see:
> "SwifMetro.app cannot be opened because the developer cannot be verified"

### How To Notarize:

#### 1. Set Credentials:
```bash
export APPLE_ID="conlanscottoc@icloud.com"
export APPLE_APP_SPECIFIC_PASSWORD="vnnj-ltex-msit-ezuh"
export APPLE_TEAM_ID="HPV26WQ9RU"
```

#### 2. Create notarize.js:
```javascript
// build/notarize.js
const { notarize } = require('@electron/notarize');

exports.default = async function notarizing(context) {
  const { electronPlatformName, appOutDir } = context;
  if (electronPlatformName !== 'darwin') return;

  const appName = context.packager.appInfo.productFilename;

  return await notarize({
    appBundleId: 'com.swiftmetro.app',
    appPath: `${appOutDir}/${appName}.app`,
    appleId: process.env.APPLE_ID,
    appleIdPassword: process.env.APPLE_APP_SPECIFIC_PASSWORD,
    teamId: process.env.APPLE_TEAM_ID,
  });
};
```

#### 3. Install notarize package:
```bash
npm install --save-dev @electron/notarize
```

#### 4. Build with notarization:
```bash
npm run build
```

**Time:** 5-15 minutes (Apple scans for malware)

---

## 📝 Important Notes

### Source Code vs Binary

**In SwifMetro-PerfectWorking (SOURCE):**
- Files are editable source code
- Changes affect future builds
- NOT used by installed app

**In /Applications/SwifMetro.app (BINARY):**
- Files packed in app.asar
- Self-contained, can't edit
- This is what runs

### To Update Installed App:
1. Edit source files in SwifMetro-PerfectWorking
2. Rebuild DMG with `npm run build`
3. Open new DMG
4. Drag app to /Applications/ (replace old)

---

## 🎨 Customizing The App

### Change App Icon:
```bash
# Replace icon
cp new-icon.icns build/icon.icns

# Rebuild
npm run build
```

### Change App Name:
```json
// package.json
{
  "build": {
    "productName": "MyNewName"
  }
}
```

### Change Dashboard:
```bash
# Edit dashboard
code swifmetro-dashboard.html

# Rebuild to see changes in app
npm run build
```

---

## 🔧 Troubleshooting

### Build Hangs?
```bash
./ELECTRON_DMG_BUILD/build-dmg-clean.sh
npm run build
```

### DMG Won't Mount?
```bash
hdiutil detach "/Volumes/SwifMetro Installer" -force
```

### Notarization Failed?
Check credentials are set:
```bash
echo $APPLE_ID
echo $APPLE_APP_SPECIFIC_PASSWORD
echo $APPLE_TEAM_ID
```

### App Icon Missing?
```bash
ls build/icon.icns  # Should exist
```

---

## 📦 What Goes Into The DMG

### Folder Structure:
```
dist/
├── SwifMetro-1.0.9.dmg (Intel)
└── SwifMetro-1.0.9-arm64.dmg (Apple Silicon)
    └── SwifMetro.app/
        ├── Contents/
        │   ├── MacOS/SwifMetro (binary)
        │   ├── Resources/
        │   │   ├── app.asar (52 MB - packed files)
        │   │   │   ├── electron-main.js
        │   │   │   ├── swifmetro-server.js
        │   │   │   ├── swifmetro-dashboard.html
        │   │   │   └── node_modules/
        │   │   └── icon.icns
        │   └── Info.plist
        └── ...
```

---

## 🚀 Quick Commands

### Build DMG:
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
npm run build
```

### Clean Build:
```bash
./ELECTRON_DMG_BUILD/build-dmg-clean.sh
npm run build
```

### Auto-Build with Version Bump:
```bash
./ELECTRON_DMG_BUILD/update-dmg.sh
```

### Test Locally (No Build):
```bash
npm start  # Opens Electron app from source
```

---

## ✅ Summary

**To build production DMG:**
1. Edit source files in `SwifMetro-PerfectWorking/`
2. Run `npm run build` or `./ELECTRON_DMG_BUILD/update-dmg.sh`
3. DMG created in `dist/` folder
4. Open DMG and install to `/Applications/`

**DMG includes:**
- Electron app wrapper
- Server (swifmetro-server.js)
- Dashboard (swifmetro-dashboard.html)
- All dependencies
- License system
- Notarized by Apple (no warnings)

**Current working DMG:** `/Applications/SwifMetro-1.0.0-arm64.dmg`

---

## 🔮 For Website Distribution

### Upload DMG To Website:
```bash
# Copy DMG to website folder
cp dist/SwifMetro-1.0.9-arm64.dmg /path/to/website/downloads/

# Update download page with new link
```

### Download Link:
```html
<a href="/downloads/SwifMetro-1.0.9-arm64.dmg">
  Download SwifMetro for Apple Silicon
</a>
```

**Users download DMG, open it, drag app to /Applications/, done!**
