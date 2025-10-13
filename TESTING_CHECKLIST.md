# ✅ SwifMetro Testing Checklist

**Use this checklist before making SwifMetro public**

Print this out or keep it open while testing. Check off each item as you complete it.

---

## 🔧 Pre-Testing Setup

- [ ] Confirmed current directory: `/Users/conlanainsworth/Desktop/SwifMetro-Public-NPM`
- [ ] Verified all files present (electron-main.js, dashboard files, server, package.json)
- [ ] Created test tarball: `npm pack` (creates swifmetro-1.0.0.tgz)
- [ ] Created fresh test directory: `mkdir ~/Desktop/SwifMetro-TEST-INSTALL`

---

## 📦 Package Installation Testing

- [ ] Installed from local tarball: `npm install ~/Desktop/SwifMetro-Public-NPM/swifmetro-1.0.0.tgz`
- [ ] Verified node_modules/swifmetro/ folder created
- [ ] Verified all files copied correctly (check electron-main.js, dashboard files)
- [ ] Verified package.json contains correct dependencies
- [ ] Checked Electron binaries downloaded (node_modules/.bin/electron)

---

## 🖥️ Server Mode Testing

- [ ] Started server: `npm run server` (from test install location)
- [ ] Verified server starts without errors
- [ ] Confirmed listening on port 8081
- [ ] Checked console shows "WebSocket server listening on port 8081"
- [ ] No error messages or warnings in terminal
- [ ] Server responds to WebSocket connections

---

## 🎨 Electron Dashboard Testing

- [ ] Started dashboard: `npm start` (from test install location)
- [ ] Electron window opens without errors
- [ ] License prompt appears (first launch)
- [ ] Tested demo license key: `SWIF-DEMO-DEMO-DEMO` (should accept)
- [ ] Tested invalid key: `TEST-INVALID-KEY` (should reject)
- [ ] Tested 7-day trial activation (creates ~/Library/Application Support/SwifMetro/trial.json)
- [ ] Dashboard UI loads correctly (no blank screen)
- [ ] Both light and dark themes work (toggle button)

---

## 📱 iOS Client Connection Testing

### Setup
- [ ] Opened SwiftMetroTEST project in Xcode
- [ ] Updated server IP to localhost (or Mac IP address)
- [ ] Built and ran iOS app in simulator
- [ ] iOS app shows "Connected" status

### Log Capture
- [ ] iOS logs appear in dashboard (print statements)
- [ ] Logs show correct timestamp
- [ ] Logs show correct log level (INFO, DEBUG, ERROR, etc.)
- [ ] Multiple log types captured (print, NSLog, os_log)
- [ ] Real-time streaming works (logs appear instantly)

### Performance
- [ ] Dashboard handles 100+ logs without lag
- [ ] Dashboard handles 1,000+ logs without crashing
- [ ] Scrolling remains smooth with many logs
- [ ] Memory usage stays reasonable (check Activity Monitor)

---

## 🔍 Dashboard Features Testing

### Filtering
- [ ] Search box filters logs correctly
- [ ] Case-sensitive toggle works
- [ ] Log level filter works (INFO, DEBUG, ERROR, WARNING)
- [ ] Clear logs button empties dashboard
- [ ] Filters persist when adding new logs

### Pause/Resume
- [ ] Pause button stops log display
- [ ] Logs continue buffering while paused
- [ ] Resume button shows buffered logs
- [ ] Pause indicator visible when active

### Export Functionality
- [ ] Export as CSV works (opens file, contains all logs)
- [ ] Export as JSON works (valid JSON format)
- [ ] Export as TXT works (readable plain text)
- [ ] Export includes filtered logs only (when filter active)
- [ ] Files saved to ~/Downloads/ or user-selected location

### Multi-Device Support
- [ ] Connect second iOS device (or simulator)
- [ ] Dashboard shows both devices in device list
- [ ] Logs from both devices display correctly
- [ ] Device names/IDs distinguishable
- [ ] Disconnect one device (other continues working)

---

## 🔐 License System Testing

### Trial System
- [ ] Delete existing trial: `rm -rf ~/Library/Application\ Support/SwifMetro/trial.json`
- [ ] Start SwifMetro (should show license prompt)
- [ ] Activate 7-day trial
- [ ] Verify trial.json created with correct expiration date
- [ ] Close and reopen SwifMetro (trial persists)
- [ ] Verify trial shows remaining days

### Demo License
- [ ] Enter demo key: `SWIF-DEMO-DEMO-DEMO`
- [ ] Verify unlimited access granted
- [ ] Verify no trial expiration warnings
- [ ] Close and reopen (demo key remembered)

### Invalid License
- [ ] Enter invalid key: `INVALID-KEY-TEST`
- [ ] Verify error message shown
- [ ] Verify cannot proceed without valid key or trial
- [ ] Error message clear and helpful

### Hardware ID Binding
- [ ] Check hardware ID generated: `system_profiler SPHardwareDataType | grep "Hardware UUID"`
- [ ] Verify hardware ID hashed in trial.json (sha256, 16 chars)
- [ ] Copy trial.json to another Mac (should fail to validate)

---

## 🌐 Network & Connectivity Testing

### WebSocket Connection
- [ ] Dashboard connects to server (ws://localhost:8081)
- [ ] Connection survives server restart
- [ ] Connection survives dashboard restart
- [ ] Multiple dashboards can connect simultaneously

### Firewall Testing
- [ ] Works with macOS firewall enabled
- [ ] Prompts for network access permission (if required)
- [ ] iOS simulator can reach Mac server
- [ ] Physical iOS device can reach Mac server (same WiFi)

### Error Handling
- [ ] Start dashboard without server (shows connection error)
- [ ] Start server without dashboard (no crash)
- [ ] Kill server while dashboard running (dashboard shows disconnected)
- [ ] Reconnect server (dashboard auto-reconnects)

---

## 🎯 Cross-Platform Testing (If Applicable)

- [ ] Test on macOS Ventura (13.x)
- [ ] Test on macOS Sonoma (14.x)
- [ ] Test on macOS Sequoia (15.x)
- [ ] Test on Intel Mac (if available)
- [ ] Test on Apple Silicon Mac (M1/M2/M3)

---

## 📄 Documentation Testing

- [ ] README.md displays correctly on GitHub
- [ ] Installation instructions accurate
- [ ] Usage examples work as documented
- [ ] Screenshots/images load correctly (if any)
- [ ] Links in README work (no 404s)
- [ ] LAUNCH_INSTRUCTIONS.md clear and complete

---

## 🔒 Security Verification

- [ ] No secrets in published code (.env, API keys, passwords)
- [ ] .npmignore excludes CONFIDENTIAL/ folder
- [ ] .npmignore excludes .env* files
- [ ] .npmignore excludes *.pem, *.key files
- [ ] Run security scan: `grep -r "API_KEY\|SECRET\|PASSWORD" . --exclude-dir=node_modules`
- [ ] Verify no database URLs in code
- [ ] Verify no Stripe keys in code

---

## 🚨 Edge Case Testing

- [ ] Start dashboard before server (should show error, not crash)
- [ ] Start multiple dashboard instances (should all work)
- [ ] Send 10,000+ logs rapidly (performance test)
- [ ] Disconnect iOS device mid-stream (graceful handling)
- [ ] Enter extremely long log message (>10KB)
- [ ] Enter Unicode/emoji in logs (displays correctly)
- [ ] Test with no internet connection (local features work)

---

## 📊 Final Verification

- [ ] All tests passed with no critical errors
- [ ] Performance acceptable on target hardware
- [ ] No console errors or warnings (check DevTools)
- [ ] User experience smooth and professional
- [ ] Ready to publish to npm
- [ ] Ready to make GitHub repository public

---

## 🚀 Ready to Launch?

If ALL checkboxes above are checked:

**Next steps:**
1. Go to `LAUNCH_INSTRUCTIONS.md`
2. Follow Phase 2 (Public Launch)
3. Publish to npm: `npm publish`
4. Make GitHub public: Settings → Change visibility → Make public

---

## 🐛 If Tests Fail

### Dashboard won't start
- Check Electron installed: `ls node_modules/.bin/electron`
- Reinstall: `npm install`
- Check logs: Look for error in terminal

### iOS won't connect
- Verify server running on port 8081
- Check iOS app server URL (must match Mac IP)
- Check firewall settings
- Try localhost first, then WiFi IP

### License prompt doesn't appear
- Check electron-main.js loaded correctly
- Delete trial.json and restart
- Check console for JavaScript errors

### Logs not appearing
- Verify WebSocket connection in dashboard console
- Check server receiving connections (terminal output)
- Verify iOS client sending data (Xcode console)

---

## 📝 Testing Notes

Use this space to note any issues found during testing:

```
Issue 1: [Description]
Fix: [Solution]
Status: [Fixed/Pending]

Issue 2: [Description]
Fix: [Solution]
Status: [Fixed/Pending]
```

---

*Testing Date: ___________*
*Tested By: ___________*
*macOS Version: ___________*
*Xcode Version: ___________*
*Result: [ ] PASS  [ ] FAIL*

---

*Last Updated: 2025-10-13*
