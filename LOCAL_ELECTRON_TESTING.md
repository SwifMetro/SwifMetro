# Local Electron Testing - Test Changes Before DMG Build

**Date:** October 10, 2025  
**Status:** ✅ Ready to use!

---

## ✅ YES! You Can Test Locally Without Building DMG!

Run Electron app locally to see dashboard changes immediately!

---

## 🚀 How To Test Changes Locally

### Step 1: Make Changes to Dashboard
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking

# Edit dashboard
code swifmetro-dashboard.html

# Make your changes:
# - Change colors
# - Add buttons
# - Modify UI
# - Fix bugs
```

### Step 2: Run Electron Locally
```bash
# Start Electron app (uses local files)
npm start

# Or use:
npm run dev
```

**This opens Electron app with your LATEST changes!** ✅

---

## 🔄 The Workflow

### Test Loop (Super Fast):
```
1. Edit swifmetro-dashboard.html
   ↓
2. Save file (Cmd+S)
   ↓
3. npm start (run Electron)
   ↓
4. See changes immediately!
   ↓
5. Close Electron, edit more
   ↓
6. Repeat until perfect
```

### Then Build DMG:
```
1. Changes look good in local Electron
   ↓
2. ./ELECTRON_DMG_BUILD/update-dmg.sh
   ↓
3. DMG created with your changes
   ↓
4. Upload to website
```

---

## 📋 Commands You Have

### Start Local Electron:
```bash
npm start
# OR
npm run dev
```

**This:**
- ✅ Reads `electron-main.js`
- ✅ Loads `swifmetro-dashboard.html` (your latest changes)
- ✅ Starts `swifmetro-server.js` automatically
- ✅ Opens window with dashboard
- ✅ NO DMG building needed!

### Just Run Server (No Electron):
```bash
npm run server
# OR
node swifmetro-server.js
```

---

## 🎨 Example: Change Dashboard Color

**1. Edit dashboard:**
```bash
code swifmetro-dashboard.html
```

**2. Change background color (line ~17):**
```css
body {
    background: #FF0000; /* Changed to red for testing */
}
```

**3. Test immediately:**
```bash
npm start
```

**4. See red background! ✅**

**5. Change back to black:**
```css
body {
    background: #000000;
}
```

**6. Test again:**
```bash
npm start
```

**7. Perfect! Now build DMG:**
```bash
./ELECTRON_DMG_BUILD/update-dmg.sh
```

---

## ⚡ Fast vs Slow Testing

### ❌ SLOW Way (Don't do this):
```
Edit → Build DMG (15 mins) → Install → Test → Repeat
```

### ✅ FAST Way (Do this):
```
Edit → npm start (5 secs) → Test → Close → Repeat
↓
When perfect → Build DMG once → Done!
```

**Save HOURS of time!** 💪

---

## 🔧 What npm start Does

```bash
npm start
# Runs: electron .
```

**Electron looks for:**
1. `package.json` → Sees `"main": "electron-main.js"`
2. Opens `electron-main.js`
3. `electron-main.js` loads `swifmetro-dashboard.html`
4. Dashboard shows with your latest changes!

**All local files, no DMG needed!** ✅

---

## 📁 Files Being Used

### Local Electron Uses:
- ✅ `electron-main.js` - Your local copy
- ✅ `swifmetro-dashboard.html` - Your local copy (with changes!)
- ✅ `swifmetro-server.js` - Your local copy
- ✅ `node_modules/` - Your local dependencies

### Installed App Uses:
- `/Applications/SwifMetro.app/Contents/Resources/app.asar`
- **NOT your local files!**
- That's why you need to rebuild DMG to update installed app

---

## 🎯 When To Use Each

### Use `npm start` (Local Electron):
- ✅ Testing changes quickly
- ✅ Developing new features
- ✅ Debugging issues
- ✅ Trying different designs
- ✅ Before building DMG

### Use DMG Build:
- ✅ After local testing is complete
- ✅ Ready to distribute
- ✅ Want to update installed app
- ✅ Uploading to website

---

## 🚀 Complete Development Flow

### Day-to-Day Development:
```bash
# Morning: Start work
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
code swifmetro-dashboard.html

# Make changes, test immediately
npm start

# Keep editing and testing
# Close Electron, edit, npm start, repeat...

# End of day: Build DMG if ready
./ELECTRON_DMG_BUILD/update-dmg.sh
```

### Quick Feature Test:
```bash
# Add new button
code swifmetro-dashboard.html
# (add button code)

# Test it
npm start
# Click button, see if it works

# Works? Great! Build DMG
./ELECTRON_DMG_BUILD/update-dmg.sh

# Doesn't work? Close, fix, npm start again
```

---

## 💡 Pro Tips

### Tip 1: Keep Server Running
```bash
# Terminal 1: Run server
node swifmetro-server.js

# Terminal 2: Run Electron (connects to server)
npm start
```

### Tip 2: Edit While Running
- Edit HTML/CSS
- Save (Cmd+S)
- Close Electron
- `npm start` again
- See new changes!

### Tip 3: Check Console
```bash
# Electron shows console errors
npm start
# Look for errors in terminal
```

---

## 🐛 Troubleshooting

### Electron won't start?
```bash
# Reinstall electron
npm install --save-dev electron

# Try again
npm start
```

### Changes not showing?
```bash
# Make sure you saved file
# Close Electron completely
# Run npm start again
```

### Server errors?
```bash
# Start server separately first
node swifmetro-server.js

# Then in new terminal:
npm start
```

---

## ✅ Summary

**You can test changes locally without DMG!**

**Commands:**
- `npm start` - Run local Electron app with latest changes
- `npm run dev` - Same as npm start
- `npm run server` - Just run server

**Workflow:**
1. Edit `swifmetro-dashboard.html`
2. `npm start` to test
3. Repeat until perfect
4. Build DMG once when ready

**This saves TONS of time!** 🚀

---

## 📋 Quick Reference

**Test changes:**
```bash
npm start
```

**Just server:**
```bash
npm run server
```

**Build DMG (when ready):**
```bash
./ELECTRON_DMG_BUILD/update-dmg.sh
```

**Perfect for rapid development!** ⚡
