# 📂 SwifMetro Folder Structure Explained

**Last Updated:** October 10, 2025  
**Status:** ✅ Complete Working System

---

## 🎯 Quick Overview

SwifMetro uses **TWO main folders** that work together:

| Folder | Purpose | What's Inside |
|--------|---------|---------------|
| **SwiftMetroTEST** | iOS Client Package | Swift source code for iOS apps |
| **SwifMetro-PerfectWorking** | Server & Dashboard | Node.js server, Electron app, docs |

**Think of it like:**
- **SwiftMetroTEST** = The library your iOS app imports (like React/Redux)
- **SwifMetro-PerfectWorking** = The backend server + dashboard (like your API + admin panel)

---

## 1️⃣ SwiftMetroTEST (GitHub Package)

**Location:** `/Users/conlanainsworth/Desktop/SwiftMetroTEST/`

**GitHub:** https://github.com/SwifMetro/SwiftMetroTEST

### What It Contains

```
SwiftMetroTEST/
├── .git/                          ← Git repository
├── Package.swift                  ← Swift Package configuration
└── SwifMetro/
    └── SwifMetroClient.swift      ← 788 lines of Swift code
```

### Purpose

This is a **Swift Package** that iOS apps add as a dependency.

**What it does:**
- ✅ Captures ALL print() statements automatically
- ✅ Captures NSLog() calls
- ✅ Uses dup2() to redirect stdout/stderr
- ✅ Connects to server via WebSocket
- ✅ Sends logs in real-time
- ✅ License validation
- ✅ Crash handler
- ✅ OS Log capture

### How iOS Apps Use It

**In Xcode:**
```
File → Add Package Dependencies
URL: https://github.com/SwifMetro/SwiftMetroTEST
Branch: main
```

**In AppDelegate.swift:**
```swift
import SwifMetro

@main
struct YourApp: App {
    init() {
        #if DEBUG
        #if targetEnvironment(simulator)
        SwifMetroClient.shared.start(
            serverIP: "127.0.0.1",
            licenseKey: "SWIF-DEMO-DEMO-DEMO"
        )
        #else
        SwifMetroClient.shared.start(
            serverIP: "192.168.0.100",  // Your Mac's IP
            licenseKey: "SWIF-DEMO-DEMO-DEMO"
        )
        #endif
        #endif
    }
}
```

That's it! ALL print() statements now stream to dashboard!

### Key File: SwifMetroClient.swift

**Size:** 27KB (788 lines)  
**Language:** Swift  
**Features:**
- Automatic print() capture via dup2() pipes
- WebSocket URLSession client
- Background queue for log processing
- Reconnection logic
- Device info detection
- License validation

**Critical Code Snippet:**
```swift
// Lines 394-418 - The magic automatic capture
private func startAutomaticCapture() {
    #if DEBUG
    // Save original file descriptors
    originalStdout = dup(STDOUT_FILENO)
    originalStderr = dup(STDERR_FILENO)
    
    // Create pipes for stdout and stderr
    pipe(&stdoutPipe)
    pipe(&stderrPipe)
    
    // Redirect stdout and stderr to our pipes
    dup2(stdoutPipe[1], STDOUT_FILENO)
    dup2(stderrPipe[1], STDERR_FILENO)
    
    // Start reading from pipes in background
    captureQueue.async { [weak self] in
        self?.readFromPipe(fileDescriptor: self?.stdoutPipe[0] ?? 0, type: "print")
    }
    
    captureQueue.async { [weak self] in
        self?.readFromPipe(fileDescriptor: self?.stderrPipe[0] ?? 0, type: "NSLog")
    }
    
    log("✅ Automatic capture enabled - ALL print() and NSLog() will appear!")
    #endif
}
```

**Genius!** No code changes needed - just intercepts stdout!

### Git Commits

```
0f82918 - Fix SwifMetroClient - use complete file (CURRENT)
7a9d330 - Add working SwifMetroClient from backup
a048a2f - Fix Package.swift to use source target
bcbc3ce - Perfect working SwifMetro version
```

**Current commit:** `0f82918` (verified working with 788 lines)

---

## 2️⃣ SwifMetro-PerfectWorking (Complete Tech Stack)

**Location:** `/Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/`

### What It Contains

```
SwifMetro-PerfectWorking/
│
├── 🌐 SERVER FILES
│   ├── swifmetro-server.js                ← PRODUCTION SERVER (19KB) ⭐ USE THIS
│   ├── swifmetro-advanced-server.js       ← Advanced features
│   ├── swifmetro-secure-server.js         ← SSL/TLS version
│   ├── swifmetro-hot-reload.js            ← Hot reload support
│   ├── payment-server.js                  ← Stripe integration
│   └── server/
│       └── swiftmetro-server.js           ← Simple server (terminal only)
│
├── 🖥️ ELECTRON APP FILES
│   ├── electron-main.js                   ← Electron entry point (13KB)
│   ├── swifmetro-dashboard.html           ← Dashboard UI (39KB)
│   └── package.json                       ← NPM dependencies
│
├── 📱 ALSO HAS SWIFT CLIENT (backup copy)
│   └── Sources/
│       └── SwifMetro/
│           └── SwifMetroClient.swift      ← Same as SwiftMetroTEST
│
├── 🔐 CREDENTIALS
│   └── CONFIDENTIAL/
│       └── .env                           ← Database, Stripe, API keys
│
├── 🌍 DASHBOARDS (HTML)
│   ├── swifmetro-dashboard.html           ← Main dashboard (39KB) ⭐
│   ├── swifmetro-admin.html               ← Admin panel
│   ├── index.html                         ← Landing page
│   ├── showcase.html                      ← Product showcase
│   ├── landing.html                       ← Marketing page
│   ├── checkout.html                      ← Payment checkout
│   └── [more HTML files...]
│
├── 📚 DOCUMENTATION
│   ├── MASTER_GUIDE.md                    ← Complete reference
│   ├── SETUP_GUIDE.md                     ← Step-by-step setup
│   ├── START_SERVER.md                    ← How to start server
│   ├── FOLDER_STRUCTURE.md                ← This file!
│   ├── DOCUMENTATION.md                   ← Technical docs
│   ├── README.md                          ← Project overview
│   ├── HOW_TO_USE_SWIFTMETRO.md          ← Usage guide
│   ├── SWIFTMETRO_EXACTLY_HOW_IT_WORKS.md ← Deep dive
│   ├── TECHNICAL_DEEP_DIVE.md             ← Architecture
│   └── [more docs...]
│
├── 🛠️ UTILITIES
│   ├── bin/
│   │   └── swifmetro.js                   ← CLI tool
│   ├── examples/
│   │   └── ExampleIntegration.swift       ← Sample code
│   └── LICENSE                             ← MIT License
│
└── 📦 NODE MODULES (after npm install)
    └── node_modules/                       ← 346 packages
        ├── ws/                             ← WebSocket library
        ├── dotenv/                         ← Environment variables
        ├── pg/                             ← PostgreSQL client
        ├── better-sqlite3/                 ← SQLite database
        ├── express/                        ← HTTP server
        └── [more packages...]
```

### Purpose

This folder is the **complete backend infrastructure** for SwifMetro.

**What it does:**
- ✅ Runs WebSocket server on port 8081
- ✅ Receives logs from iOS apps
- ✅ Broadcasts logs to dashboard(s)
- ✅ Stores logs in database (PostgreSQL/SQLite)
- ✅ Validates license keys
- ✅ Manages multiple connected devices
- ✅ Provides beautiful dashboard UI
- ✅ Supports multiple dashboards simultaneously

### Key Files Explained

#### **swifmetro-server.js** (PRODUCTION SERVER) ⭐

**Size:** 19KB  
**Language:** JavaScript (Node.js)  
**Status:** ✅ CURRENTLY RUNNING

**What it does:**
```javascript
// Starts WebSocket server
const wss = new WebSocket.Server({ port: 8081 });

// Handles device connections
wss.on('connection', (ws) => {
  if (message.type === 'identify') {
    if (message.clientType === 'device') {
      devices.set(deviceId, deviceInfo);
    } else if (message.clientType === 'dashboard') {
      dashboards.add(ws);
    }
  }
  
  // Broadcasts logs to all dashboards
  if (message.type === 'log') {
    dashboards.forEach(dashboard => {
      dashboard.send(JSON.stringify(message));
    });
  }
});
```

**Features:**
- WebSocket server (ws library)
- Dashboard broadcasting ✅
- Database integration (PostgreSQL)
- License validation
- Color-coded terminal output
- Device management
- Heartbeat messages

**Start command:**
```bash
cd ~/Desktop/SwifMetro-PerfectWorking
node swifmetro-server.js
```

#### **electron-main.js** (Electron App)

**Size:** 13KB  
**Language:** JavaScript  
**Packaged as:** `/Applications/SwifMetro.app`

**What it does:**
- Creates desktop app window
- Loads dashboard HTML
- Validates license keys
- Hardware ID tracking
- 7-day trial system
- Auto-update support

**License logic:**
```javascript
function checkLicense() {
  const licenseKey = fs.readFileSync(licensePath, 'utf8').trim();
  
  if (licenseKey === 'SWIF-DEMO-DEMO-DEMO') {
    // Check trial expiration (7 days)
    if (daysElapsed > 7) {
      return false; // Trial expired
    }
    return true;
  }
  
  // Validate real license: SWIF-XXXX-XXXX-XXXX
  const pattern = /^SWIF-.{4}-.{4}-.{4}$/;
  return pattern.test(licenseKey);
}
```

#### **swifmetro-dashboard.html** (Dashboard UI)

**Size:** 39KB  
**Language:** HTML + CSS + JavaScript  
**Loaded by:** Electron app

**Features:**
- 🌙 Dark/Light theme toggle
- 🔍 Real-time log search
- 🎨 Color-coded logs (red errors, green success)
- 📱 Device filtering
- 💾 Export logs to file
- 📋 Copy logs to clipboard
- ⬇️ Auto-scroll toggle
- ⌨️ Keyboard shortcuts (Cmd+K, Cmd+E, etc.)
- 📊 Live stats (device count, log count)
- 🎯 Filter by type (All/Errors/Warnings/Success)

**WebSocket connection:**
```javascript
ws = new WebSocket('ws://localhost:8081');

ws.onmessage = (event) => {
  const parsed = JSON.parse(event.data);
  
  if (parsed.type === 'log') {
    allLogs.unshift({
      message: parsed.message,
      deviceId: parsed.deviceId,
      deviceName: parsed.deviceName,
      type: categorizeLog(parsed.message),
      timestamp: parsed.timestamp
    });
    renderLogs();
  }
};
```

#### **package.json** (Dependencies)

**What it defines:**
```json
{
  "name": "swiftmetro",
  "version": "1.0.9",
  "dependencies": {
    "ws": "^8.14.2",              // WebSocket server
    "dotenv": "^17.2.3",          // Environment variables
    "pg": "^8.16.3",              // PostgreSQL database
    "better-sqlite3": "^12.4.1",  // SQLite database
    "express": "^5.1.0",          // HTTP server
    "bonjour": "^3.5.0",          // Service discovery
    "resend": "^6.1.2"            // Email support
  }
}
```

**Install dependencies:**
```bash
cd ~/Desktop/SwifMetro-PerfectWorking
npm install  # Installs 346 packages
```

#### **CONFIDENTIAL/.env** (Secrets)

**Contains:**
```
DATABASE_URL=postgresql://user:pass@host:5432/dbname
STRIPE_KEY=sk_live_...
RESEND_API_KEY=re_...
```

**Used by:** swifmetro-server.js for database and payments

**Security:** ⚠️ Never commit this file to Git!

---

## 🔗 How The Folders Work Together

### Complete Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: iOS App Setup                                      │
│                                                              │
│  StickerPlanNative App                                      │
│  └─ Adds GitHub package: SwiftMetroTEST                     │
│     └─ Imports SwifMetroClient.swift                        │
│        └─ Starts automatic print() capture                  │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ WebSocket: ws://127.0.0.1:8081
                   │ Message: { type: "identify", deviceName: "iPhone 16 Pro" }
                   │ Message: { type: "log", message: "App launched!" }
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Server Receives Logs                               │
│                                                              │
│  SwifMetro-PerfectWorking/swifmetro-server.js              │
│  └─ Listens on port 8081                                    │
│     └─ Receives device connection                           │
│        └─ Receives log messages                             │
│           └─ Stores in database (optional)                  │
│              └─ Broadcasts to all dashboards                │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ WebSocket broadcast
                   │ To all connected dashboards
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Dashboard Displays Logs                            │
│                                                              │
│  /Applications/SwifMetro.app                                │
│  └─ Built from electron-main.js                             │
│     └─ Loads swifmetro-dashboard.html                       │
│        └─ Connects to ws://localhost:8081                   │
│           └─ Receives log broadcasts                        │
│              └─ Renders in beautiful UI                     │
│                 └─ Search, filter, export features          │
└─────────────────────────────────────────────────────────────┘
```

### Simplified View

```
iOS App (imports SwiftMetroTEST)
    ↓
Sends logs via WebSocket
    ↓
Server (SwifMetro-PerfectWorking/swifmetro-server.js)
    ↓
Broadcasts to dashboard(s)
    ↓
Dashboard (/Applications/SwifMetro.app)
```

---

## 🚀 How to Use Each Folder

### Using SwiftMetroTEST

**Purpose:** Add to iOS projects as dependency

**Steps:**
1. Open your iOS project in Xcode
2. File → Add Package Dependencies
3. Enter: `https://github.com/SwifMetro/SwiftMetroTEST`
4. Select branch: `main`
5. Add to your app target

**That's it!** Your app now has SwifMetro client code.

### Using SwifMetro-PerfectWorking

**Purpose:** Run the server and dashboard

**Steps:**

1. **Install dependencies (first time only):**
```bash
cd ~/Desktop/SwifMetro-PerfectWorking
npm install
```

2. **Start server:**
```bash
node swifmetro-server.js
```

3. **Open dashboard:**
```bash
open /Applications/SwifMetro.app
```

4. **Run your iOS app:**
```bash
xcrun simctl launch booted com.yourapp.bundle
```

**Logs will stream automatically!**

---

## 📊 Current Working Configuration

### What's Currently Running

**Server:**
```
Location: ~/Desktop/SwifMetro-PerfectWorking/swifmetro-server.js
Status: ✅ Running
Port: 8081
Connected: iPhone 16 Pro + SwifMetro Dashboard
```

**Dashboard:**
```
Location: /Applications/SwifMetro.app
Status: ✅ Open and connected
WebSocket: ws://localhost:8081
Showing: Real-time logs from iPhone
```

**iOS App:**
```
Name: StickerPlanNative
Package: github.com/SwifMetro/SwiftMetroTEST
Commit: 0f82918
Status: ✅ Streaming 100+ logs
```

---

## 🗂️ Other Important Folders

### StickerPlanNEW (Test App)

**Location:** `/Users/conlanainsworth/Desktop/StickerPlanNEW/`

**What it is:**
- Example iOS app for testing SwifMetro
- Uses SwiftMetroTEST package as dependency
- Has working AppDelegate.swift setup

**Files:**
```
StickerPlanNEW/
├── StickerPlanNative.xcodeproj
├── StickerPlanNative/
│   ├── AppDelegate.swift          ← SwifMetro initialization
│   ├── Info.plist                 ← NSAppTransportSecurity settings
│   └── [app files...]
└── StickerPlanNative.xcodeproj/
    └── project.xcworkspace/
        └── xcshareddata/
            └── swiftpm/
                └── Package.resolved  ← Points to SwiftMetroTEST commit 0f82918
```

### TESTEDBACKUP (Complete Backup)

**Location:** `/Users/conlanainsworth/Desktop/TESTEDBACKUP/`

**What it is:**
- Complete backup of ALL working code
- Restore from here if anything breaks

**Contains:**
```
TESTEDBACKUP/
├── SwifMetro-PerfectWorking/     ← Complete copy
├── SwiftMetroTEST/                ← Complete copy
├── StickerPlanNEW/                ← Complete copy
├── README.md                       ← Setup instructions
└── HOW_TO_USE_DASHBOARD.md        ← Dashboard guide
```

**Size:** 262MB

**Restore command:**
```bash
cp -r ~/Desktop/TESTEDBACKUP/SwifMetro-PerfectWorking/* \
      ~/Desktop/SwifMetro-PerfectWorking/
```

---

## 📋 Folder Comparison

| Feature | SwiftMetroTEST | SwifMetro-PerfectWorking |
|---------|----------------|--------------------------|
| **Purpose** | iOS client package | Server + Dashboard |
| **Language** | Swift | JavaScript (Node.js) |
| **Size** | 27KB (1 file) | 1.2MB (50+ files) |
| **Published** | GitHub | Local |
| **Used by** | iOS apps | Developers |
| **Runs where** | iPhone/iPad/Simulator | Mac (server) |
| **Git repo** | Yes | Yes |
| **Dependencies** | None | 346 NPM packages |
| **Main file** | SwifMetroClient.swift | swifmetro-server.js |

---

## 🎯 Quick Reference

### SwiftMetroTEST Commands

```bash
# View source
cd ~/Desktop/SwiftMetroTEST
cat SwifMetro/SwifMetroClient.swift

# Check git status
git status

# View commits
git log --oneline

# Push changes
git add .
git commit -m "Update"
git push origin main
```

### SwifMetro-PerfectWorking Commands

```bash
# Install dependencies
cd ~/Desktop/SwifMetro-PerfectWorking
npm install

# Start server
node swifmetro-server.js

# Open dashboard
open /Applications/SwifMetro.app

# Check server status
lsof -i :8081
```

---

## 🔥 Key Takeaways

1. **Two folders, different purposes:**
   - SwiftMetroTEST = Swift package for iOS
   - SwifMetro-PerfectWorking = Server + Dashboard

2. **They work together:**
   - iOS app imports SwiftMetroTEST
   - Sends logs to server in SwifMetro-PerfectWorking
   - Dashboard shows logs in real-time

3. **Both are needed:**
   - Can't run iOS client without package
   - Can't see logs without server + dashboard

4. **Current setup is working:**
   - SwiftMetroTEST on GitHub (commit 0f82918)
   - Server running from SwifMetro-PerfectWorking
   - Dashboard connected and showing logs
   - Everything backed up in TESTEDBACKUP

---

## ❓ Common Questions

### Q: Which folder do I edit to change the iOS client?

**A:** SwiftMetroTEST/SwifMetro/SwifMetroClient.swift

Then commit and push to GitHub. iOS apps will get updates when they run:
```
File → Packages → Update to Latest Package Versions
```

### Q: Which folder do I edit to change the server?

**A:** SwifMetro-PerfectWorking/swifmetro-server.js

Then restart the server.

### Q: Which folder do I edit to change the dashboard?

**A:** SwifMetro-PerfectWorking/swifmetro-dashboard.html

Then rebuild the Electron app or refresh browser.

### Q: Where is the Electron app source?

**A:** SwifMetro-PerfectWorking/electron-main.js

The built app is at: `/Applications/SwifMetro.app`

### Q: Do I need both folders?

**A:** Yes! SwiftMetroTEST for iOS, SwifMetro-PerfectWorking for server.

### Q: Where should I make changes?

**A:** 
- Swift client code → SwiftMetroTEST
- Server/Dashboard → SwifMetro-PerfectWorking
- Documentation → SwifMetro-PerfectWorking

---

**That's everything about the folder structure!** 🎉

Now you know exactly what each folder does and how they work together!
