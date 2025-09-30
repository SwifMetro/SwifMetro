# Getting Started with SwifMetro

## 5-Minute Setup Guide

---

## What is SwifMetro?

SwifMetro lets you see your iPhone's debug logs instantly in Terminal. No Xcode console. No USB cable. Just real-time logs over WiFi.

**Before SwifMetro:**
```
Xcode Console → Cluttered → Hard to find your logs → Need USB cable
```

**With SwifMetro:**
```
Your iPhone → WiFi → Terminal → Clean, instant logs
```

---

## Installation (2 minutes)

### Step 1: Clone SwifMetro
```bash
git clone https://github.com/csainsworth123/swifmetro.git
cd swifmetro
```

### Step 2: Install Dependencies
```bash
npm install
```

### Step 3: Start Server
```bash
node swifmetro-server.js
```

You'll see:
```
🚀 SWIFMETRO SERVER
📱 Connect your iPhone to: 192.168.1.100
⏳ Waiting for connections...
```

---

## iOS Setup (3 minutes)

### Step 1: Add to Xcode

Drag `SwifMetroClient.swift` into your Xcode project.

### Step 2: Update AppDelegate

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Add this line
        SwifMetroClient.shared.start()
        
        return true
    }
}
```

### Step 3: Update Info.plist

Add this to allow local network access:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Step 4: Use It!

```swift
// Anywhere in your app
SwifMetroClient.shared.log("Hello from iPhone!")

// In a button tap
@IBAction func buttonTapped() {
    SwifMetroClient.shared.log("Button was tapped!")
}

// Track errors
catch {
    SwifMetroClient.shared.logError("Something went wrong: \(error)")
}
```

---

## What You'll See

### In Terminal:
```bash
🔥🔥🔥 iPHONE CONNECTED! 🔥🔥🔥
📱 Device: iPhone 15 Pro
📱 OS: iOS 17.0

[09:23:15] 📱 Hello from iPhone!
[09:23:20] 📱 Button was tapped!
[09:23:25] 📱 ❌ Something went wrong: Network timeout
```

---

## Basic Examples

### Track User Navigation
```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    SwifMetroClient.shared.log("📍 User navigated to: \(self.title ?? "Unknown")")
}
```

### Log Network Calls
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

### Debug State Changes
```swift
@Published var isLoading = false {
    didSet {
        SwifMetroClient.shared.log("⏳ Loading state: \(isLoading)")
    }
}
```

---

## Pro Tips

### 1. Use Emoji for Visual Scanning
```swift
SwifMetroClient.shared.log("✅ Success")     // Green in terminal
SwifMetroClient.shared.log("❌ Error")       // Red in terminal
SwifMetroClient.shared.log("⚠️ Warning")    // Yellow in terminal
SwifMetroClient.shared.log("ℹ️ Info")       // Blue in terminal
```

### 2. Log User Actions
```swift
SwifMetroClient.shared.log("👆 Tapped: Login Button")
SwifMetroClient.shared.log("⌨️ Typing in: Email Field")
SwifMetroClient.shared.log("📸 Took photo")
```

### 3. Track Performance
```swift
let startTime = Date()
// ... do work ...
let elapsed = Date().timeIntervalSince(startTime)
SwifMetroClient.shared.log("⏱ Operation took: \(elapsed)s")
```

---

## Troubleshooting

### Not Connecting?

1. **Check WiFi**: iPhone and Mac must be on same network
2. **Check Server**: Is `node swifmetro-server.js` running?
3. **Check Firewall**: Mac firewall might block connection
4. **Manual IP**: If auto-discovery fails, set IP manually:
```swift
// In SwifMetroClient.swift
private let HOST_IP = "192.168.1.100" // Your Mac's IP
```

### No Logs Showing?

- Make sure you called `SwifMetroClient.shared.start()`
- Check Info.plist has `NSAppTransportSecurity`
- Verify you're in DEBUG mode (not Release)

---

## Next Steps

- Read [Full Documentation](DOCUMENTATION.md)
- Check [API Reference](DOCUMENTATION.md#api-reference)
- Join [Discord Community](https://discord.gg/swifmetro)

---

## Need Help?

Create an issue on GitHub: [github.com/csainsworth123/swifmetro/issues](https://github.com/csainsworth123/swifmetro/issues)

---

**That's it! You're now logging iOS to Terminal like a pro! 🚀**