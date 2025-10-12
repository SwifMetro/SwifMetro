# 🚀 SWIFMETRO - GETTING STARTED GUIDE

**Last Updated:** October 12, 2025
**Version:** 1.0.0
**Time to Setup:** 5 minutes

---

## 📋 QUICK START OVERVIEW

SwifMetro gives you wireless iOS logging with automatic capture. No code changes needed beyond a single `start()` call.

**What you get:**
- Beautiful desktop dashboard
- Wireless logging (no cables!)
- Automatic print() and NSLog() capture
- Multi-device support
- FPS & Memory monitoring
- Terminal mode (optional)

**Before SwifMetro:**
```
Xcode Console → Cluttered → Hard to find your logs → Need USB cable
```

**With SwifMetro:**
```
Your iPhone → WiFi → Beautiful Dashboard → Clean, instant logs
```

---

## 🖥️ INSTALLATION (Desktop App - Recommended)

### Step 1: Download SwifMetro
1. Go to [swifmetro.dev/download](https://swifmetro.dev/download)
2. Download `SwifMetro-1.0.0.dmg`
3. Drag SwifMetro.app to Applications folder
4. Launch SwifMetro from Applications (or Spotlight: `Cmd+Space` → "SwifMetro")

### Step 2: Activate Your License
When you first launch SwifMetro, you'll see:

```
┌───────────────────────────────────────┐
│   🚀 Welcome to SwifMetro!            │
│                                       │
│   Enter your license key:             │
│   ┌─────────────────────────────────┐ │
│   │ SWIF-XXXX-XXXX-XXXX-XXXX       │ │
│   └─────────────────────────────────┘ │
│                                       │
│   [Activate License]                  │
│                                       │
│   Don't have a license?               │
│   Start 7-day free trial →            │
└───────────────────────────────────────┘
```

**Options:**
- **Have a license?** Enter your key and click "Activate License"
- **New user?** Click "Start 7-day free trial" (no credit card required)

Once activated:
✅ Server auto-starts on port 8081
✅ Dashboard opens automatically
✅ License saved to `~/.swifmetro/license`

---

## 📱 iOS SETUP (3 minutes)

### Step 1: Add SwifMetro via Swift Package Manager

**In Xcode:**
1. File → Add Package Dependencies
2. Enter: `https://github.com/csainsworth123/swifmetro-ios`
3. Add to your app target

**Or download manually:**
- Download `SwifMetroClient.swift` from [swifmetro.dev/ios](https://swifmetro.dev/ios)
- Drag into your Xcode project

### Step 2: Update Info.plist

Add local network access permissions:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<key>NSLocalNetworkUsageDescription</key>
<string>SwifMetro needs local network access to send logs to your Mac</string>

<key>NSBonjourServices</key>
<array>
    <string>_swifmetro._tcp</string>
</array>
```

### Step 3: Start SwifMetro

**In your AppDelegate or App struct:**

```swift
import UIKit
import SwifMetro // If using SPM

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Start SwifMetro (ONE line - that's it!)
        SwifMetroClient.shared.start()

        return true
    }
}
```

**For SwiftUI apps:**
```swift
import SwiftUI

@main
struct MyApp: App {

    init() {
        SwifMetroClient.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Step 4: Run Your App!

**On Simulator:**
- Press `Cmd+R` in Xcode
- SwifMetro auto-detects `127.0.0.1:8081`
- Connection happens instantly ⚡

**On Physical Device:**
- Ensure iPhone and Mac are on **same WiFi**
- Run app (`Cmd+R`)
- SwifMetro uses **Bonjour** to auto-discover your Mac
- No manual IP entry needed! 🎉

---

## ✅ QUALITY CHECK - Did It Work?

Within **5 seconds** of launching your iOS app, you should see:

### In SwifMetro Dashboard:
```
┌─────────────────────────────────────────────────────────┐
│ 🔥🔥🔥 iPHONE CONNECTED! 🔥🔥🔥                          │
│                                                         │
│ 📱 Device: iPhone 15 Pro                                │
│ 📱 OS: iOS 17.4                                         │
│ 🌐 IP: 192.168.1.145                                    │
│ ✅ Auto-monitoring: FPS + Memory                        │
└─────────────────────────────────────────────────────────┘

[12:34:56] 📱 [iPhone 15 Pro] SwifMetro connected!
[12:34:57] 📊 [FPS] 60 FPS
[12:34:58] 💾 [Memory Stats] 45.2 MB used
```

**If you DON'T see this:**
- Check WiFi (same network?)
- Check firewall (allow SwifMetro)
- See troubleshooting section below ⬇️

---

## 🎯 USING SWIFMETRO

### Log Anything, Anywhere

```swift
// Simple logs
SwifMetroClient.shared.log("Hello from iPhone!")

// Button taps
@IBAction func buttonTapped() {
    SwifMetroClient.shared.log("Button was tapped!")
}

// Network calls
SwifMetroClient.shared.log("🌐 Fetching users...")

// Errors
catch {
    SwifMetroClient.shared.logError("Something went wrong: \(error)")
}

// Warnings
SwifMetroClient.shared.logWarning("Low battery detected")

// Success
SwifMetroClient.shared.logSuccess("Payment completed!")
```

### Automatic Capture (Zero Code Changes!)

SwifMetro **automatically captures**:
- ✅ All `print()` statements
- ✅ All `NSLog()` calls
- ✅ All `Console.log()` output
- ✅ FPS (every 1 second)
- ✅ Memory stats (every 5 seconds)
- ✅ Network requests (URLSession)

**You don't need to change existing logs!** Just call `start()` and everything flows to SwifMetro.

---

## 🎨 DASHBOARD FEATURES

### Search & Filter
- **Real-time search**: Type to filter logs instantly
- **Regex search**: Toggle `.*` button for pattern matching (e.g., `/error.*network/i`)
- **Filter by type**: All, Errors, Warnings, Success, Info
- **Filter by device**: Click device pills to show logs from specific devices
- **Time range**: Last 5min, 15min, 30min, 1hr, or All Time

### Advanced Filters
Click **⚙️ Advanced** to toggle:
- **FPS Monitor**: Show/hide frame rate logs
- **Memory Stats**: Show/hide memory logs
- **UserDefaults**: Show/hide settings changes
- **Debug Logs**: Show/hide verbose debug output

### Export & Copy
- **📋 Copy All**: Copy all visible logs to clipboard
- **💾 Export**: Export logs to CSV, JSON, or TXT
- **Copy individual log**: Click 📋 button on any log line

### Pause & Resume
- **⏸️ Pause**: Freeze log display (new logs buffered)
- **▶️ Resume**: Resume live streaming
- **🚀 Jump to Live**: Scroll to latest logs instantly

### Stats
- **Device count**: Number of connected devices
- **Total logs**: All logs captured (capacity: 500,000!)
- **Filtered**: Logs matching current filters

---

## 💻 OPTIONAL: TERMINAL MODE (For Power Users)

**Want Metro-style terminal logs?** Install SwifMetro via npm:

```bash
npm install -g swifmetro
swifmetro
```

You'll see:
```bash
🚀 SWIFMETRO SERVER
📱 Connect your iPhone to: 192.168.1.100
⏳ Waiting for connections...

🔥🔥🔥 iPHONE CONNECTED! 🔥🔥🔥
📱 Device: iPhone 15 Pro
📱 OS: iOS 17.4

[12:34:56] 📱 Hello from iPhone!
[12:34:57] 📊 60 FPS
[12:34:58] 💾 45.2 MB used
```

**Use both simultaneously:**
- Terminal for quick log scanning
- Dashboard for advanced search/filter/export
- Both connect to same server (port 8081)

**Note:** NPM package coming soon! For now, use desktop app.

---

## 💡 BEST PRACTICES

### 1. Use Emoji for Visual Scanning
```swift
SwifMetroClient.shared.log("✅ Success")     // Green checkmark
SwifMetroClient.shared.log("❌ Error")       // Red X
SwifMetroClient.shared.log("⚠️ Warning")    // Yellow warning
SwifMetroClient.shared.log("ℹ️ Info")       // Blue info
SwifMetroClient.shared.log("🚀 Launch")     // Rocket for events
SwifMetroClient.shared.log("🌐 Network")    // Globe for API calls
```

### 2. Track User Actions
```swift
SwifMetroClient.shared.log("👆 Tapped: Login Button")
SwifMetroClient.shared.log("⌨️ Typing in: Email Field")
SwifMetroClient.shared.log("📸 Took photo")
SwifMetroClient.shared.log("📍 Navigated to: Profile")
```

### 3. Log Navigation
```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    SwifMetroClient.shared.log("📍 User navigated to: \(self.title ?? "Unknown")")
}
```

### 4. Track Network Calls
```swift
func fetchUsers() {
    SwifMetroClient.shared.log("🌐 Fetching users...")

    API.getUsers { result in
        switch result {
        case .success(let users):
            SwifMetroClient.shared.log("✅ Fetched \(users.count) users")
        case .failure(let error):
            SwifMetroClient.shared.logError("Failed: \(error)")
        }
    }
}
```

### 5. Debug State Changes
```swift
@Published var isLoading = false {
    didSet {
        SwifMetroClient.shared.log("⏳ Loading state: \(isLoading)")
    }
}
```

### 6. Measure Performance
```swift
let startTime = Date()
// ... do work ...
let elapsed = Date().timeIntervalSince(startTime)
SwifMetroClient.shared.log("⏱ Operation took: \(String(format: "%.2f", elapsed))s")
```

---

## 🐛 TROUBLESHOOTING

### Issue 1: iPhone Not Connecting

**Symptoms:** Dashboard shows "0 devices", no connection message

**Solutions:**
1. **Check WiFi**: iPhone and Mac must be on **same network**
   ```bash
   # Find your Mac's IP
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. **Check Firewall**: Allow SwifMetro through Mac firewall
   - System Settings → Network → Firewall
   - Allow SwifMetro connections

3. **Check Server**: Is SwifMetro running?
   ```bash
   lsof -i :8081  # Should show SwifMetro process
   ```

4. **Restart Everything**:
   - Quit SwifMetro (`Cmd+Q`)
   - Relaunch SwifMetro
   - Stop iOS app in Xcode
   - Run iOS app again (`Cmd+R`)

5. **Manual IP (Last Resort)**:
   ```swift
   // In SwifMetroClient.swift, if Bonjour fails
   SwifMetroClient.shared.start(serverIP: "192.168.1.100")
   ```

### Issue 2: No Logs Showing

**Symptoms:** Connected but logs don't appear

**Solutions:**
1. **Verify start() was called**:
   ```swift
   // Should be in AppDelegate.application(_:didFinishLaunchingWithOptions:)
   SwifMetroClient.shared.start()
   ```

2. **Check Info.plist permissions**:
   - Ensure `NSAppTransportSecurity` is set
   - Ensure `NSLocalNetworkUsageDescription` is present
   - Ensure `NSBonjourServices` includes `_swifmetro._tcp`

3. **Check build configuration**:
   - SwifMetro is DEBUG-only by default
   - If in Release mode, logs won't send
   - Switch to Debug scheme in Xcode

4. **Check filters in dashboard**:
   - Maybe logs are filtered out!
   - Click "All" filter pill
   - Clear search box
   - Disable advanced filters

### Issue 3: Dashboard Shows Old Logs

**Symptoms:** Logs from previous sessions still visible

**Solution:** Click **🗑️ Clear** button to remove old logs

### Issue 4: "Port 8081 already in use"

**Symptoms:** Error when starting SwifMetro

**Solution:**
```bash
# Kill process on port 8081
lsof -ti:8081 | xargs kill -9

# Restart SwifMetro
open -a SwifMetro
```

### Issue 5: FPS/Memory Logs Too Noisy

**Symptoms:** Dashboard flooded with performance metrics

**Solution:** Use **Advanced Filters** to hide:
- Uncheck "FPS Monitor"
- Uncheck "Memory Stats"
- Logs still captured, just hidden from view

### Issue 6: License Expired

**Symptoms:** "Trial expired" message after 7 days

**Solution:**
1. Visit [swifmetro.dev/pricing](https://swifmetro.dev/pricing)
2. Purchase license (🔥 Early bird: $19-49/mo)
3. Enter license key in dashboard
4. License saved to `~/.swifmetro/license`

---

## 🎓 TIPS & TRICKS

### Tip 1: Multi-Device Development
Connect iPhone + iPad + Simulator simultaneously:
- All devices appear in dashboard with color-coded labels
- Click device pill to filter logs from specific device
- Perfect for testing universal apps!

### Tip 2: Search with Regex
Enable `.*` button for powerful searches:
- `error.*network` → Find all network errors
- `^\[FPS\]` → Find all FPS logs
- `user.*login.*success` → Find successful logins

### Tip 3: Export for Bug Reports
When filing bugs:
1. Reproduce the issue
2. Search for relevant logs
3. Click **💾 Export** → CSV
4. Attach to bug report
5. Developers will love you! ❤️

### Tip 4: Pause During Debugging
When hitting breakpoints:
1. Click **⏸️ Pause** to freeze dashboard
2. Step through code in Xcode
3. Click **▶️ Resume** when done
4. Logs buffered during pause appear instantly!

### Tip 5: Copy Individual Logs
Hover over any log → Click **📋** button → Copied to clipboard!

---

## 📚 NEXT STEPS

✅ **You're all set up!** SwifMetro is now logging your iOS app.

**Want to learn more?**
- [Full Documentation](DOCUMENTATION.md) - Advanced features, API reference
- [Pricing](LAUNCH_PRICING_STRATEGY.md) - Early bird pricing info
- [GitHub Issues](https://github.com/csainsworth123/swifmetro/issues) - Report bugs, request features

**Need help?**
- Email: support@swifmetro.dev
- Twitter: [@swifmetro](https://twitter.com/swifmetro)
- Discord: [discord.gg/swifmetro](https://discord.gg/swifmetro) (coming soon!)

---

## 🎉 THAT'S IT!

**You're now logging iOS like a pro!** 🚀

SwifMetro gives you:
✅ Wireless logging (no cables!)
✅ Automatic capture (zero code changes!)
✅ Beautiful dashboard (search, filter, export!)
✅ Multi-device support (iPhone + iPad + Simulator!)
✅ FPS & Memory monitoring (auto-enabled!)

**Enjoy building!** 💪

---

**Created:** October 12, 2025
**Version:** 1.0.0
**Status:** Ready for launch! 🔥