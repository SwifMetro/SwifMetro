# 🚀 How to Start SwifMetro Server

## The WORKING Method (Use This!)

### Step 1: Start the Server

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
node swifmetro-server.js
```

**You'll see:**
```
🚀 SWIFMETRO SERVER
==================================================
📡 Starting on port 8081...
✅ Server is running!
✅ Database tables initialized
```

### Step 2: Open SwifMetro Dashboard

```bash
open /Applications/SwifMetro.app
```

**Dashboard will:**
- Auto-connect to server on port 8081
- Show "Connected" (green indicator)
- Display: "💻 Dashboard connected" in server terminal

### Step 3: Run Your iOS App

```bash
# Build and install
cd /Users/conlanainsworth/Desktop/StickerPlanNEW
xcrun simctl install booted /path/to/StickerPlanNative.app

# Launch
xcrun simctl launch booted com.stickerplan.app
```

**Server will show:**
```
🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
🔥 CLIENT CONNECTED!
📱 From IP: 127.0.0.1
🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥

[01:39:43] ✅ Automatic capture enabled - ALL print() and NSLog() will appear!
[01:39:43] 🚀 StickerPlan app launched on SIMULATOR!
[01:39:43] 🖨️ [print] Testing SwifMetro log capture
```

### Step 4: Watch Logs Stream! 🎉

**In Terminal:**
- Color-coded logs
- Real-time streaming
- Device info shown

**In SwifMetro Dashboard:**
- Beautiful UI
- Search/filter logs
- Export/copy features
- Auto-scroll

---

## ✅ Verification Checklist

**Server Running:**
- [ ] `node swifmetro-server.js` is running
- [ ] Shows "✅ Server is running!" 
- [ ] Listening on port 8081

**Dashboard Connected:**
- [ ] SwifMetro.app is open
- [ ] Shows "Connected" (green indicator)
- [ ] Server shows "💻 Dashboard connected"

**iPhone Connected:**
- [ ] App is running on simulator
- [ ] Server shows "🔥 CLIENT CONNECTED!"
- [ ] Logs streaming in both terminal and dashboard

---

## 🔧 Dependencies Already Installed

The server needs these packages (already installed with `npm install`):

```json
{
  "ws": "^8.14.2",           // WebSocket support
  "dotenv": "^17.2.3",       // Environment variables
  "pg": "^8.16.3",           // PostgreSQL database
  "better-sqlite3": "^12.4.1", // SQLite database
  "express": "^5.1.0",       // HTTP server
  "bonjour": "^3.5.0",       // Service discovery
  "resend": "^6.1.2"         // Email support
}
```

---

## 🐛 Troubleshooting

### Server Won't Start

**Error: "Cannot find module 'dotenv'"**

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
npm install
```

### Dashboard Not Showing Logs

**Fix: Restart the app**

```bash
xcrun simctl terminate booted com.stickerplan.app
sleep 1
xcrun simctl launch booted com.stickerplan.app
```

Dashboard will automatically receive logs!

### Port 8081 Already In Use

**Kill existing server:**

```bash
lsof -ti:8081 | xargs kill -9
```

Then restart server.

---

## 📁 Server Location

**Production Server:**
```
/Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/swifmetro-server.js
```

**Features:**
- ✅ Dashboard broadcasting (working!)
- ✅ Database integration
- ✅ License validation
- ✅ Color-coded terminal output
- ✅ Multiple device support
- ✅ Real-time WebSocket streaming

**Simple Server (Terminal Only):**
```
/Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/server/swiftmetro-server.js
```

**Features:**
- ✅ Terminal output only
- ❌ No dashboard broadcasting
- ⚠️ Use for debugging only

**Always use the production server for dashboard support!**

---

## 🎯 Quick Commands

**Start Everything:**
```bash
# Terminal 1: Start server
cd ~/Desktop/SwifMetro-PerfectWorking && node swifmetro-server.js

# Terminal 2: Open dashboard
open /Applications/SwifMetro.app

# Terminal 3: Launch app
xcrun simctl launch booted com.stickerplan.app
```

**Stop Everything:**
```bash
# Kill server
lsof -ti:8081 | xargs kill -9

# Kill app
xcrun simctl terminate booted com.stickerplan.app

# Close dashboard
killall SwifMetro
```

**Restart App Only:**
```bash
xcrun simctl terminate booted com.stickerplan.app && sleep 1 && xcrun simctl launch booted com.stickerplan.app
```

---

## 🔑 Environment Variables

Server uses `.env` file in `CONFIDENTIAL/` folder:

```
DATABASE_URL=postgresql://...
STRIPE_KEY=sk_...
RESEND_API_KEY=re_...
```

**For development:** These are optional, server works without them!

---

## 📊 Connection Flow

```
┌─────────────────────┐
│   iOS App           │
│  (Simulator/Device) │
└──────────┬──────────┘
           │
           │ WebSocket ws://127.0.0.1:8081
           │
           ▼
┌─────────────────────┐
│  Node.js Server     │
│ (swifmetro-server)  │
│                     │
│  - Receives logs    │
│  - Broadcasts to    │
│    dashboards       │
└──────────┬──────────┘
           │
           │ WebSocket
           │
           ▼
┌─────────────────────┐
│ SwifMetro Dashboard │
│ (/Applications/)    │
│                     │
│  - Beautiful UI     │
│  - Real-time logs   │
└─────────────────────┘
```

---

## ✨ Success Indicators

**Terminal shows:**
```
🚀 SWIFMETRO SERVER
📡 Starting on port 8081...
✅ Server is running!
💻 Dashboard connected
📊 Total dashboards: 1
🔥 CLIENT CONNECTED!
[01:39:43] ✅ Automatic capture enabled
[01:39:43] 🚀 StickerPlan app launched
```

**Dashboard shows:**
- Green "Connected" indicator
- Logs appearing in real-time
- Device count: 1
- Total logs increasing

**You know it's working when all 3 show logs!** 🔥

---

**Last updated:** October 10, 2025  
**Status:** ✅ VERIFIED WORKING  
**Method:** Production server with dashboard broadcasting
