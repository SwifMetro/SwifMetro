# SwifMetro - Current Working Versions

**Date:** October 10, 2025  
**Status:** ✅ PRODUCTION - WORKING PERFECTLY

This document tracks the EXACT working versions of all SwifMetro components that are currently deployed and running perfectly.

---

## 📱 Desktop App (Electron)

**Location:** `/Applications/SwifMetro.app`  
**Version:** 1.0.9  
**Status:** ✅ Running perfectly with live logs

### Files Inside App

The app contains these EXACT working files (extracted from app.asar):

1. **electron-main.js** (13.3 KB)
   - License validation system
   - Hardware ID tracking
   - Trial management (7 days)
   - Auto-starts server on port 8081
   - Loads dashboard HTML
   - Backed up at: `CURRENT_ELECTRON_BACKUP.js`

2. **swifmetro-dashboard.html** (39.8 KB)
   - Beautiful dark/light theme dashboard
   - Real-time WebSocket connection
   - Device filtering
   - Search functionality
   - Export/copy/clear logs
   - Auto-scroll toggle
   - Keyboard shortcuts
   - Backed up at: `CURRENT_DASHBOARD_BACKUP.html`

3. **swifmetro-server.js** (19 KB)
   - Production server with dashboard broadcasting
   - WebSocket server on port 8081
   - Device management
   - Log broadcasting to all dashboards
   - Network request tracking
   - Backed up at: `CURRENT_SERVER_BACKUP.js`

4. **package.json**
   - Dependencies: ws, dotenv, pg, better-sqlite3, express, bonjour, resend

---

## 🖥️ Server Files (Development)

**Location:** `/Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/`

### Main Server

**File:** `swifmetro-server.js` (19 KB)  
**Port:** 8081  
**Status:** ✅ Currently running (PID 18536)

**Features:**
- WebSocket server with dashboard broadcasting
- Device identification and tracking
- Log message routing
- Network request logging
- Heartbeat system
- Database integration (SQLite + PostgreSQL support)

**How to start:**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
npm install  # First time only
node swifmetro-server.js
```

**Expected output:**
```
🚀 SWIFMETRO SERVER
📡 Starting on port 8081...
✅ Server is running!
✅ Database tables initialized
💻 Dashboard connected
```

### Dashboard HTML

**File:** `swifmetro-dashboard.html` (exact copy from app)  
**Port:** Connects to server at ws://localhost:8081  
**Status:** ✅ Working perfectly

**Features:**
- Dark/light theme toggle (🌙/☀️)
- Real-time log streaming
- Device filters
- Log type filters (All, Errors, Warnings, Success)
- Search functionality
- Export to file
- Copy all logs
- Clear logs
- Auto-scroll toggle
- Keyboard shortcuts (Cmd+K, Cmd+E, Cmd+F, Cmd+C, Space)

### Electron Main

**File:** `electron-main.js` (exact copy from app)  
**Status:** ✅ Working perfectly

**Features:**
- License key validation
- Hardware ID tracking (anti-piracy)
- 7-day trial system
- Auto-starts server
- Single instance lock
- Beautiful license prompt UI

---

## 📦 iOS Client Package

**Location:** `/Users/conlanainsworth/Desktop/SwiftMetroTEST/`  
**GitHub:** https://github.com/yourusername/SwiftMetroTEST  
**Commit:** 0f82918  
**Status:** ✅ Working perfectly with automatic print() capture

### Main File

**File:** `SwifMetro/SwifMetroClient.swift` (788 lines)  
**Status:** ✅ Capturing 100+ logs automatically

**Features:**
- Automatic print() capture using dup2()
- stdout/stderr redirection
- WebSocket connection to server
- License key validation
- Device identification
- Network request interception
- Real-time log streaming

**Usage in iOS app:**
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
        #endif
        #endif
    }
}
```

---

## 🔄 How Everything Works Together

```
┌─────────────────────────────────────────────────────────────┐
│                     SWIFMETRO ARCHITECTURE                   │
└─────────────────────────────────────────────────────────────┘

  iOS App (Simulator/Device)
       │
       │ 1. Import SwifMetro package from GitHub
       │    (SwiftMetroTEST/SwifMetro/SwifMetroClient.swift)
       │
       │ 2. Automatic print() capture via dup2()
       │    - Redirects stdout → pipe
       │    - Redirects stderr → pipe
       │    - Reads continuously from pipes
       │
       │ 3. WebSocket connection
       ▼
  ws://localhost:8081
       │
       │ 4. Server receives logs
       ▼
  swifmetro-server.js (Node.js)
       │
       │ 5. Broadcasts to all connected dashboards
       │    - Production server has this feature
       │    - Simple server does NOT
       │
       ▼
  Dashboard (Browser or Electron App)
       │
       │ 6. Displays logs in real-time
       │    - Beautiful UI with filters
       │    - Search, export, copy features
       │    - Dark/light theme
       │
       ▼
  Developer sees logs wirelessly! 🎉
```

---

## ✅ What's Working

- ✅ iOS app captures 100+ logs automatically
- ✅ Server broadcasting to dashboard
- ✅ Dashboard showing logs in real-time
- ✅ Electron app with license system
- ✅ Dark/light theme toggle
- ✅ Search and filter functionality
- ✅ Export and copy features
- ✅ Device identification
- ✅ Trial system (7 days)
- ✅ Auto-scroll toggle
- ✅ Keyboard shortcuts

---

## 📂 File Locations Summary

| Component | Location | Size | Status |
|-----------|----------|------|--------|
| Electron App | `/Applications/SwifMetro.app` | 111 MB | ✅ Running |
| Server (Prod) | `SwifMetro-PerfectWorking/swifmetro-server.js` | 19 KB | ✅ Running |
| Dashboard HTML | `SwifMetro-PerfectWorking/swifmetro-dashboard.html` | 39.8 KB | ✅ Working |
| Electron Main | `SwifMetro-PerfectWorking/electron-main.js` | 13.3 KB | ✅ Working |
| iOS Client | `SwiftMetroTEST/SwifMetro/SwifMetroClient.swift` | 788 lines | ✅ Working |
| Backup (Dashboard) | `SwifMetro-PerfectWorking/CURRENT_DASHBOARD_BACKUP.html` | 39.8 KB | ✅ Backup |
| Backup (Electron) | `SwifMetro-PerfectWorking/CURRENT_ELECTRON_BACKUP.js` | 13.3 KB | ✅ Backup |
| Backup (Server) | `SwifMetro-PerfectWorking/CURRENT_SERVER_BACKUP.js` | 19 KB | ✅ Backup |

---

## 🔒 License Keys

### Demo/Trial Key
```
SWIF-DEMO-DEMO-DEMO
```
- 7-day trial
- Tied to hardware ID
- Stored in `~/.swifmetro/license`
- Trial data in `~/.swifmetro/trial_{hardwareId}`

### Production Key Format
```
SWIF-XXXX-XXXX-XXXX
```
- Must match pattern: `^SWIF-.{4}-.{4}-.{4}$`
- Validated on app startup
- Generated via Stripe integration

---

## 🚨 IMPORTANT: Which Server to Use

**✅ USE THIS ONE:**
```bash
node /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/swifmetro-server.js
```

**❌ DO NOT USE THIS ONE:**
```bash
node /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/server/swiftmetro-server.js
```

The server in the `server/` folder is a SIMPLE server that only shows terminal output.  
It does NOT broadcast to dashboards!

---

## 📋 Quick Start Commands

### Start Server
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
node swifmetro-server.js
```

### Install App to Simulator
```bash
xcrun simctl install booted /path/to/YourApp.app
```

### Launch App in Simulator
```bash
xcrun simctl launch booted com.yourapp.bundleid
```

### Open Dashboard (if not using Electron)
```
Open swifmetro-dashboard.html in browser
```

### Open Electron App
```bash
open -a SwifMetro
```

---

## 🎯 Current Status

**Server:** Running (PID 18536) on port 8081  
**Dashboard:** Open in Electron app, showing "Connected" (green)  
**iOS App:** Streaming 100+ logs  
**All Features:** Working perfectly ✅

---

## 📝 Notes

- All files are backed up in `CURRENT_*_BACKUP.*` format
- Production server requires `npm install` first
- Dashboard auto-reconnects if server restarts
- iOS app needs restart after server changes
- Trial system uses hardware ID to prevent abuse
- Server supports both SQLite and PostgreSQL

---

## 🔮 Next Steps (Future)

See `FUTURE_TASKS.md` for planned work:
1. Build XCFramework binary
2. Create NPM package with license system
3. Test on real iOS device
4. Performance optimization
5. Memory leak testing

**But first:** Keep testing to make sure everything works perfectly!
