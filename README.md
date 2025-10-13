# SwifMetro

**Wireless logging dashboard for iOS development** - Stream logs from your iPhone, iPad, or Simulator to your Mac in real-time. No cables required.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/SwifMetro/SwifMetro)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%2013%2B-lightgrey.svg)](https://github.com/SwifMetro/SwifMetro)

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

### 1. Install SwifMetro CLI

```bash
npm install -g swifmetro
```

### 2. Start the Dashboard

```bash
swifmetro dashboard
```

You'll see:
```
🚀 SWIFMETRO SERVER
📡 Starting on port 8081...

📱 Your iPhone should connect to one of these IPs:
   192.168.0.100 (en0)

⏳ Waiting for iPhone connections...
```

### 3. Add to Your iOS Project

**Add Swift Package in Xcode:**
- File → Add Package Dependencies
- URL: `https://github.com/SwifMetro/SwifMetro.git`

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

**Initialize in AppDelegate.swift:**
```swift
import SwifMetro

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        SwifMetroClient.shared.start(serverIP: "192.168.0.100") // Your Mac's IP
        print("🚀 App launched!") // This appears in the dashboard!
        #endif

        return true
    }
}
```

**Or for SwiftUI Apps:**
```swift
import SwiftUI
import SwifMetro

@main
struct YourApp: App {
    init() {
        #if DEBUG
        SwifMetroClient.shared.start(serverIP: "192.168.0.100")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 4. Run Your App

Launch your app and watch logs appear in the SwifMetro dashboard!

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

### Dashboard Mode (Recommended)
```bash
swifmetro dashboard
```
Opens the Electron GUI application with full features.

### Terminal Mode
```bash
swifmetro
# or
swifmetro terminal
```
Logs appear directly in your terminal - useful for CI/CD or scripting.

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
