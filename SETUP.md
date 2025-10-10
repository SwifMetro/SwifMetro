# ⚡️ SwifMetro Setup - 2 Minutes

## Step 1: Add Package to Xcode (30 seconds)

1. Open your Xcode project
2. **File → Add Package Dependencies**
3. Paste: `https://github.com/SwifMetro/SwifMetro.git`
4. Click **Add Package**

✅ Package installed!

---

## Step 2: Add Permissions to Info.plist (60 seconds)

**This is CRITICAL for iOS 14+** - without this, your iPhone can't connect!

1. Open your **Info.plist** file in Xcode
2. Right-click → **Open As → Source Code**
3. **Copy-paste this INSIDE the `<dict>` tag:**

```xml
<!-- SWIFMETRO REQUIRED PERMISSIONS -->
<key>NSLocalNetworkUsageDescription</key>
<string>SwifMetro needs local network access to stream logs from your device to your Mac for debugging.</string>

<key>NSBonjourServices</key>
<array>
    <string>_swifmetro._tcp</string>
</array>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

4. **Save** (Cmd+S)

✅ Permissions added!

---

## Step 3: Start SwifMetro in Your App (30 seconds)

### For SwiftUI Apps:

Add this to your `@main` App struct:

```swift
import SwifMetro

@main
struct YourApp: App {
    init() {
        #if DEBUG
        SwifMetroClient.shared.start()
        print("🚀 SwifMetro initialized!")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### For UIKit Apps:

Add this to `AppDelegate.swift`:

```swift
import SwifMetro

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        SwifMetroClient.shared.start()
        print("🚀 SwifMetro initialized!")
        #endif
        
        return true
    }
}
```

✅ SwifMetro configured!

---

## Step 4: Run Dashboard & Test (30 seconds)

1. **On your Mac, run:**
   ```bash
   npm install -g swifmetro
   swifmetro dashboard
   ```

2. **Note the IP address** shown (e.g., `192.168.0.100`)

3. **Build & run your app** on your iPhone (real device, not simulator)

4. **First launch only:** iPhone will ask **"Allow Local Network Access?"** → Tap **Allow**

5. **Watch the magic!** All your `print()` statements appear in the dashboard!

---

## 🎉 You're Done!

Your app is now streaming logs wirelessly to your Mac!

Every `print()`, `NSLog()`, crash, and error appears in the SwifMetro dashboard in real-time.

---

## 🚨 Troubleshooting

### "No device connecting"

**Solution 1: Same WiFi**
- Make sure Mac and iPhone are on the **exact same WiFi network**
- Not just similar names - EXACT same network

**Solution 2: Manual IP**
If auto-discovery fails, use manual IP:
```swift
SwifMetroClient.shared.start(serverIP: "192.168.0.100") // Use YOUR Mac's IP
```

**Solution 3: Check Permissions**
- Go to iPhone: **Settings → Your App → Local Network** → Make sure it's **ON**
- If you don't see this option, you didn't add the Info.plist entries correctly

**Solution 4: Firewall**
- Mac: **System Settings → Network → Firewall** → Add exception for port 8081
- Or disable temporarily for testing

### "Cannot find SwifMetroClient in scope"

You forgot to import:
```swift
import SwifMetro  // Add this!
```

### "Old version after updating package"

Clear Xcode cache:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

Then: **File → Packages → Update to Latest Package Versions**

---

## 💡 Pro Tips

1. **Add your Mac's IP once** to avoid auto-discovery delays:
   ```swift
   SwifMetroClient.shared.start(serverIP: "192.168.0.100")
   ```

2. **Use structured logging:**
   ```swift
   SwifMetroClient.shared.logSuccess("Login successful!")
   SwifMetroClient.shared.logError("API call failed!")
   SwifMetroClient.shared.logWarning("Low memory")
   ```

3. **Track network requests:**
   ```swift
   SwifMetroClient.shared.enableNetworkLogging()
   ```

4. **Monitor memory:**
   ```swift
   SwifMetroClient.shared.logMemoryUsage()
   ```

---

## ⚡️ That's It!

**Setup time:** 2 minutes  
**Value:** Infinite

Welcome to wireless debugging! 🚀
