# SwifMetro

**Wireless logging dashboard for iOS development** - Stream logs from your iPhone, iPad, or Simulator to your Mac in real-time. No cables required.

[![Version](https://img.shields.io/badge/version-1.0.10-blue.svg)](https://github.com/SwifMetro/SwifMetro/releases/tag/v1.0.10)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%2014%2B-lightgrey.svg)](https://github.com/SwifMetro/SwifMetro)

---

## What is SwifMetro?

SwifMetro is a wireless logging solution that streams `print()` and `NSLog()` output from your iOS devices to a beautiful macOS dashboard.

**Key Benefits:**
- See logs from multiple devices in one place
- Beautiful, searchable interface with dark/light themes
- No USB cables needed - works over local WiFi
- Zero impact on Xcode - run both simultaneously
- Automatic capture of all print statements

---

## Features

### Logging & Display
- **Real-time Streaming** - Logs appear instantly via WebSocket connection
- **Multiple Device Support** - Connect iPhone, iPad, and Simulator simultaneously
- **Automatic Capture** - All `print()` and `NSLog()` statements sent automatically
- **Log Types** - Visual badges for ERROR, WARN, INFO, SUCCESS messages

### Dashboard
- **Professional UI** - Clean Electron-based macOS application
- **Dark/Light Theme** - Soft gray light mode and pure black dark mode
- **Search & Filter** - Find logs by text, type, or device
- **Auto-scroll Toggle** - Pause scrolling to inspect logs

### Export & Management
- **Export to File** - Save logs as .txt files
- **Copy to Clipboard** - Copy individual or all logs instantly
- **Clear Logs** - One-click clearing
- **Keyboard Shortcuts** - Power-user friendly commands

### Advanced Features
- **Crash Detection** - Captures fatal errors and exceptions
- **Network Logging** - Track HTTP requests and responses
- **Performance Metrics** - Monitor memory usage and FPS
- **Error Tracking** - Structured error logging with context

---

## Quick Start

### Step 1: Download SwifMetro for Mac

**Download the Dashboard App:**
1. Go to [GitHub Releases](https://github.com/SwifMetro/SwifMetro/releases/latest)
2. Download `SwifMetro-Installer.dmg`
3. Open the DMG and drag SwifMetro to Applications
4. **Launch SwifMetro** from Applications folder

**The server starts automatically!** You'll see:
```
🚀 SWIFMETRO SERVER
📡 Starting on port 8081...

📱 Your iPhone should connect to one of these IPs:
--------------------------------------------------
   192.168.0.100 (en0)
--------------------------------------------------
```

**Copy your Mac's IP address** - you'll need it for Step 3!

---

### Step 2: Add SwifMetro to Your iOS Project

**In Xcode:**
1. File → Add Package Dependencies
2. URL: `https://github.com/SwifMetro/SwifMetro.git`
3. Choose "Up to Next Major Version" → **1.0.10**
4. Add to your app target

---

### Step 3: Configure Your iOS App

**Add to Info.plist** (Required for iOS 14+):
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>SwifMetro needs local network access to stream logs to your Mac.</string>
<key>NSBonjourServices</key>
<array>
    <string>_swifmetro._tcp</string>
</array>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

**Initialize SwifMetro:**

For **SwiftUI** apps, add to your App struct:
```swift
import SwiftUI
import SwifMetro

@main
struct YourApp: App {
    init() {
        #if DEBUG
        // Use the IP from Step 1!
        SwifMetroClient.shared.start(serverIP: "192.168.0.100")  // ← Your Mac's IP here
        print("🚀 App launched!")  // This will appear in the dashboard!
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

For **UIKit** apps, add to AppDelegate:
```swift
import UIKit
import SwifMetro

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        SwifMetroClient.shared.start(serverIP: "192.168.0.100")  // ← Your Mac's IP here
        print("🚀 App launched!")
        #endif
        return true
    }
}
```

---

### Step 4: Run Your App & See Logs!

1. **Make sure SwifMetro Mac app is running** (from Step 1)
2. **Build and run your iOS app** (⌘R in Xcode)
3. **Watch logs appear instantly in the dashboard!** 🎉

```swift
print("Hello from iPhone!") // Appears in dashboard
SwifMetroClient.shared.logSuccess("User logged in")
SwifMetroClient.shared.logError("Failed to load data")
```

---

## Usage

### Basic Logging

SwifMetro automatically captures all `print()` statements:

```swift
print("User tapped button")
print("Fetching data from API...")
NSLog("Traditional NSLog works too!")
```

### Enhanced Logging

Use SwifMetro's API for structured logs:

```swift
// Log with severity levels
SwifMetroClient.shared.logInfo("User opened profile screen")
SwifMetroClient.shared.logSuccess("Payment processed successfully")
SwifMetroClient.shared.logWarning("Network connection unstable")
SwifMetroClient.shared.logError("Authentication failed")

// Log errors with context
do {
    try riskyOperation()
} catch {
    SwifMetroClient.shared.logError(error, context: "User Login")
}

// Log network requests
SwifMetroClient.shared.logNetwork(
    method: "POST",
    url: "https://api.example.com/login",
    statusCode: 200,
    duration: 0.45
)

// Log performance metrics
SwifMetroClient.shared.logPerformance("Image Load", value: 120.5, unit: "ms")
```

### SwiftUI View Tracking

Track view lifecycle automatically:

```swift
import SwiftUI
import SwifMetro

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .swifMetroTracking("ProfileView") // Logs appear/disappear
    }
}
```

### Network Request Logging

Wrap URLSession calls to automatically log requests:

```swift
URLSession.shared.swifMetroDataTask(with: request) { data, response, error in
    // Network request automatically logged to dashboard
    // Shows method, URL, status code, duration, and response
}
```

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + K` | Clear logs |
| `Cmd/Ctrl + E` | Export logs |
| `Cmd/Ctrl + F` | Focus search |
| `Cmd/Ctrl + C` | Copy all logs |
| `Space` | Toggle auto-scroll |

---

## Troubleshooting

### No logs appearing in dashboard

**Solution 1: Verify Same WiFi Network**
- Mac and iPhone MUST be on the same WiFi
- Check Mac: Click WiFi icon in menu bar
- Check iPhone: Settings → WiFi
- They must show the SAME network name

**Solution 2: Use Manual IP (Recommended)**
```swift
// Get your Mac's IP from the server output
SwifMetroClient.shared.start(serverIP: "192.168.0.100")  // Replace with YOUR IP
```

**Solution 3: Check Firewall**
- Mac: System Settings → Network → Firewall
- If enabled, add exception for port 8081
- Or disable temporarily for testing

**Solution 4: Verify Info.plist Permissions**
Make sure you added BOTH:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>SwifMetro needs local network access to stream logs from your device to your Mac for debugging.</string>
<key>NSBonjourServices</key>
<array>
    <string>_swifmetro._tcp</string>
</array>
```

**Solution 5: Check iPhone Permissions**
- First launch should ask "Allow Local Network Access"
- If you denied it: Settings → YourApp → Local Network → Enable

### "Cannot find 'SwifMetroClient' in scope"

**Solution: Missing import statement**
```swift
import SwifMetro  // Add this at the top of the file
```

### How do I find my Mac's IP?

The server shows it when you run `swifmetro dashboard`:
```
📱 Your iPhone should connect to one of these IPs:
--------------------------------------------------
   192.168.0.100 (en0)
```

Or run in Terminal: `ifconfig | grep "inet " | grep -v 127.0.0.1`

### Auto-discovery fails

This is normal on many networks! **Use manual IP instead:**
```swift
SwifMetroClient.shared.start(serverIP: "YOUR_MAC_IP")
```

---

## Complete Setup Checklist

Before asking for help, verify:
- [ ] Server running on Mac (`swifmetro dashboard`)
- [ ] Mac IP address noted (from server output)
- [ ] SwifMetro package added in Xcode
- [ ] `import SwifMetro` at top of file
- [ ] `SwifMetroClient.shared.start(serverIP: "YOUR_IP")` in app init
- [ ] Permissions added to Info.plist
- [ ] Mac and iPhone on SAME WiFi
- [ ] Building to real iPhone or Simulator
- [ ] Local Network permission granted on iPhone

---

## Installation Modes

SwifMetro has two ways to view logs from your iOS app:

### 🎨 Dashboard Mode (Beautiful GUI - Recommended)

**What you get:**
- Beautiful Electron desktop app with modern UI
- Real-time log streaming with color coding
- Search, filter, and export features
- Dark/light theme support
- Network request inspector
- Keyboard shortcuts

**How to use:**
```bash
swifmetro dashboard  # Opens GUI app
```

**Who it's for:**
- Daily iOS development
- Visual debugging
- Teams who want a polished tool
- Anyone who prefers GUI over terminal

---

### 💻 Terminal Mode (CLI Only - Free Alternative)

**What you get:**
- Plain text logs in your terminal
- Lightweight and fast
- Perfect for remote servers
- No GUI dependencies

**How to use:**
```bash
swifmetro          # Default: terminal mode
swifmetro terminal # Explicit terminal mode
```

**Who it's for:**
- Terminal enthusiasts
- CI/CD pipelines
- Automation scripts
- Remote debugging over SSH
- Minimalists who prefer text

---

### 🚀 Use Both!

The Mac app and terminal mode are just different views of the same server. Use the GUI for development, terminal for automation. Your choice!

---

## System Requirements

### iOS App
- iOS 13.0 or later
- iPadOS 13.0 or later
- Xcode 12.0 or later

### Desktop App
- macOS 10.15 (Catalina) or later
- Node.js 14.0 or later (for CLI)

### Network
- Mac and iOS device on same local network
- Port 8081 available (default, configurable)

---

## Advanced Configuration

### Custom Port

```bash
swifmetro dashboard --port 3000
```

```swift
SwifMetroClient.shared.start(serverIP: "192.168.0.100", port: 3000)
```

### Enable Network Logging

```swift
SwifMetroClient.shared.enableNetworkLogging()
```

### Manual Logging Control

```swift
// Start with auto-discovery
SwifMetroClient.shared.start()

// Or with manual IP
SwifMetroClient.shared.start(serverIP: "192.168.0.100")

// Stop capturing
SwifMetroClient.shared.stopAutomaticCapture()
```

---

## How It Works

```
Your iOS Device                    Your Mac
---------------                    --------
App launches              →        Dashboard running
Calls print()             →
SwifMetro intercepts      →
Sends via WebSocket       →        Appears in UI
```

**Technical Details:**
- **Protocol**: WebSocket (RFC 6455) over local network
- **iOS Side**: URLSessionWebSocketTask (native iOS API)
- **Server**: Node.js with 'ws' package
- **Latency**: <4ms on local network
- **Memory**: <100KB overhead
- **CPU**: <0.1% usage
- **Security**: Only runs in DEBUG mode, no production impact

SwifMetro intercepts stdout/stderr file descriptors to capture all print statements, then streams them over a WebSocket connection to your Mac. It's lightweight, secure, and App Store safe (only runs in DEBUG builds).

---

## FAQ

**Q: Does this work with SwiftUI?**
A: Yes! Works with SwiftUI, UIKit, and any iOS framework.

**Q: Will this slow down my app?**
A: No. Overhead is <0.1% CPU and <100KB memory. Negligible impact.

**Q: Is this safe for production?**
A: SwifMetro only runs in DEBUG builds (wrapped in `#if DEBUG`). It won't appear in App Store builds.

**Q: Can I use this with Xcode Console?**
A: Yes! SwifMetro doesn't replace Xcode's console - it mirrors the output. Logs appear in both places.

**Q: Does this require jailbreak?**
A: No. SwifMetro uses only public iOS APIs. No jailbreak or private APIs.

**Q: Can multiple developers use this simultaneously?**
A: Yes. Each developer runs their own SwifMetro server on their Mac. Devices connect to their respective developer's Mac.

**Q: Does this work on simulators?**
A: Yes! Works on both physical devices and simulators.

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Support

- **GitHub Issues**: [github.com/SwifMetro/SwifMetro/issues](https://github.com/SwifMetro/SwifMetro/issues)
- **Documentation**: [github.com/SwifMetro/SwifMetro/wiki](https://github.com/SwifMetro/SwifMetro/wiki)

---

**SwifMetro** - Wireless iOS logging, simplified.
