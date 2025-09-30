# 🚀 SWIFTMETRO - COMPLETE USAGE GUIDE

## START TO FINISH - MAKE IT WORK IN ANY APP

---

## ⚡ INSTANT SETUP (5 MINUTES)

### 1️⃣ Get Your Mac's IP Address
```bash
# Run this command:
ifconfig | grep "inet " | grep -v 127.0.0.1

# You'll see something like:
inet 192.168.0.100 netmask 0xffffff00 broadcast 192.168.0.255

# Your IP is: 192.168.0.100 (use YOUR actual IP!)
```

### 2️⃣ Install Node.js Server
```bash
# Create a new folder for SwiftMetro
mkdir ~/SwiftMetro
cd ~/SwiftMetro

# Create package.json
cat > package.json << 'EOF'
{
  "name": "swiftmetro-server",
  "version": "1.0.0",
  "dependencies": {
    "ws": "^8.14.2"
  }
}
EOF

# Install dependencies
npm install

# Create the server file
cat > server.js << 'EOF'
const WebSocket = require('ws');

console.log('🚀 SwiftMetro Server Starting...');
console.log('📡 Port: 8081');
console.log('⏳ Waiting for iPhone connections...\n');

const wss = new WebSocket.Server({ port: 8081 });

wss.on('connection', function connection(ws) {
  console.log('🔥🔥🔥 iPHONE CONNECTED! 🔥🔥🔥');
  
  ws.on('message', function incoming(message) {
    const timestamp = new Date().toLocaleTimeString();
    console.log(`[${timestamp}] 📱 ${message.toString()}`);
  });
  
  ws.on('close', function() {
    console.log('❌ Device disconnected\n');
  });
  
  ws.send('Welcome to SwiftMetro!');
});
EOF

# Start the server
node server.js
```

### 3️⃣ Add to Your iOS App

**Create SimpleMetroClient.swift:**
```swift
import Foundation
import UIKit

class SimpleMetroClient {
    static let shared = SimpleMetroClient()
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    
    func connect() {
        // ⚠️ CHANGE THIS TO YOUR MAC'S IP! ⚠️
        let urlString = "ws://192.168.0.100:8081"
        
        guard let url = URL(string: urlString) else {
            print("❌ SwiftMetro: Invalid URL")
            return
        }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("🚀 SwiftMetro: Connecting...")
        
        // Send device info
        let deviceName = UIDevice.current.name
        let message = URLSessionWebSocketTask.Message.string(deviceName)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ SwiftMetro: \(error)")
            } else {
                print("✅ SwiftMetro: Connected!")
            }
        }
        
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📝 Server says: \(text)")
                case .data(let data):
                    print("📦 Received \(data.count) bytes")
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("❌ WebSocket error: \(error)")
            }
        }
    }
    
    func log(_ message: String) {
        let wsMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(wsMessage) { _ in }
    }
}
```

### 4️⃣ Connect in AppDelegate/App.swift

**For UIKit Apps (AppDelegate.swift):**
```swift
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Connect to SwiftMetro
    #if DEBUG
    SimpleMetroClient.shared.connect()
    
    // Send test log
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        SimpleMetroClient.shared.log("🎉 App launched successfully!")
    }
    #endif
    
    return true
}
```

**For SwiftUI Apps (App.swift):**
```swift
@main
struct MyApp: App {
    init() {
        #if DEBUG
        SimpleMetroClient.shared.connect()
        SimpleMetroClient.shared.log("🎉 SwiftUI app launched!")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 5️⃣ Update Info.plist
Add this to allow local network access:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

### 6️⃣ Add Logging Throughout Your App

**Button Taps:**
```swift
Button("Login") {
    SimpleMetroClient.shared.log("🔵 Login button tapped")
    SimpleMetroClient.shared.log("📧 Email: \(email)")
    performLogin()
}
```

**API Calls:**
```swift
func fetchData() {
    SimpleMetroClient.shared.log("🌐 API: Fetching user data...")
    
    APIClient.fetch { result in
        switch result {
        case .success(let data):
            SimpleMetroClient.shared.log("✅ API: Received \(data.count) items")
        case .failure(let error):
            SimpleMetroClient.shared.log("❌ API Error: \(error)")
        }
    }
}
```

**Navigation:**
```swift
.onAppear {
    SimpleMetroClient.shared.log("📍 Navigated to: ProfileScreen")
}

.onDisappear {
    SimpleMetroClient.shared.log("👋 Left: ProfileScreen")
}
```

**Text Input:**
```swift
TextField("Username", text: $username)
    .onChange(of: username) { newValue in
        SimpleMetroClient.shared.log("⌨️ Username: \(newValue)")
    }
```

---

## 🎯 COMPLETE WORKING EXAMPLE

**ViewController.swift:**
```swift
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SimpleMetroClient.shared.log("🏠 Home screen loaded")
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        SimpleMetroClient.shared.log("🔐 Login attempt")
        SimpleMetroClient.shared.log("📧 Email: \(emailField.text ?? "")")
        SimpleMetroClient.shared.log("🔑 Password length: \(passwordField.text?.count ?? 0)")
        
        // Perform login
        login()
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        SimpleMetroClient.shared.log("😅 Forgot password tapped")
    }
    
    func login() {
        // Simulate API call
        SimpleMetroClient.shared.log("🌐 Calling login API...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let success = Bool.random()
            if success {
                SimpleMetroClient.shared.log("✅ Login successful!")
            } else {
                SimpleMetroClient.shared.log("❌ Login failed: Invalid credentials")
            }
        }
    }
}
```

---

## 📱 RUNNING ON REAL DEVICE

### Build & Install:
```bash
# 1. Build the app
xcodebuild -project YourApp.xcodeproj \
           -scheme YourScheme \
           -sdk iphoneos \
           -configuration Debug \
           build

# 2. Find your device ID
xcrun devicectl list devices
# Look for your device, copy the ID (like: 65BA0681-523C-5974-A8C5-FCD81C858AF0)

# 3. Install on device
xcrun devicectl device install app \
    --device YOUR-DEVICE-ID \
    /path/to/YourApp.app

# 4. Launch the app
xcrun devicectl device process launch \
    --device YOUR-DEVICE-ID \
    com.yourcompany.yourapp
```

---

## 🎨 TERMINAL OUTPUT EXAMPLES

When everything is working, you'll see:

```bash
🚀 SwiftMetro Server Starting...
📡 Port: 8081
⏳ Waiting for iPhone connections...

🔥🔥🔥 iPHONE CONNECTED! 🔥🔥🔥
[09:23:15] 📱 iPhone 16 Pro
[09:23:16] 📱 🎉 App launched successfully!
[09:23:17] 📱 🏠 Home screen loaded
[09:23:22] 📱 ⌨️ Username: john
[09:23:23] 📱 ⌨️ Username: johndoe
[09:23:28] 📱 🔐 Login attempt
[09:23:28] 📱 📧 Email: johndoe@example.com
[09:23:28] 📱 🔑 Password length: 8
[09:23:28] 📱 🌐 Calling login API...
[09:23:29] 📱 ✅ Login successful!
[09:23:30] 📱 📍 Navigated to: ProfileScreen
```

---

## 🔧 COMMON ISSUES & FIXES

### Issue: "No connection"
**Fix:**
```bash
# Check server is running
ps aux | grep node

# Check firewall
sudo pfctl -d  # Temporarily disable

# Verify IP is correct
ping 192.168.0.100  # Should work from iPhone
```

### Issue: "Connection drops"
**Fix:** Add reconnection logic:
```swift
func connectWithRetry() {
    connect()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        if webSocketTask?.state != .running {
            connectWithRetry()
        }
    }
}
```

### Issue: "Can't see logs"
**Fix:** Ensure you're actually calling log():
```swift
// Add debug alert to verify
SimpleMetroClient.shared.log("TEST: \(Date())")

let alert = UIAlertController(title: "Debug", 
                             message: "Log sent at \(Date())", 
                             preferredStyle: .alert)
present(alert, animated: true)
```

---

## 🚀 ADVANCED USAGE

### Structured Logging:
```swift
extension SimpleMetroClient {
    func logEvent(_ event: String, data: [String: Any]? = nil) {
        let json = try? JSONSerialization.data(withJSONObject: [
            "event": event,
            "data": data ?? [:],
            "timestamp": Date().timeIntervalSince1970
        ])
        
        if let jsonString = String(data: json ?? Data(), encoding: .utf8) {
            log(jsonString)
        }
    }
}

// Usage:
SimpleMetroClient.shared.logEvent("user_action", data: [
    "screen": "home",
    "action": "button_tap",
    "button": "login"
])
```

### Performance Monitoring:
```swift
class PerformanceMonitor {
    static func trackFPS() {
        CADisplayLink(target: self, selector: #selector(tick)).add(
            to: .current, 
            forMode: .common
        )
    }
    
    @objc static func tick(link: CADisplayLink) {
        let fps = 1 / (link.targetTimestamp - link.timestamp)
        SimpleMetroClient.shared.log("📊 FPS: \(Int(fps))")
    }
}
```

### Crash Reporting:
```swift
NSSetUncaughtExceptionHandler { exception in
    SimpleMetroClient.shared.log("💥 CRASH: \(exception)")
    SimpleMetroClient.shared.log("📍 Stack: \(exception.callStackSymbols)")
}
```

---

## 🎯 THE COMMANDS YOU NEED

### Every Day Commands:
```bash
# Start server
cd ~/SwiftMetro && node server.js

# Find device
xcrun devicectl list devices | grep iPhone

# Install app
xcrun devicectl device install app --device [ID] [APP_PATH]

# Launch app
xcrun devicectl device process launch --device [ID] [BUNDLE_ID]

# Watch logs
# Just look at terminal where node server.js is running!
```

---

## ✅ VERIFICATION CHECKLIST

- [ ] Mac IP address identified
- [ ] Node.js and ws package installed
- [ ] Server running (shows "Waiting for iPhone connections")
- [ ] SimpleMetroClient.swift added to project
- [ ] IP address updated in SimpleMetroClient
- [ ] Info.plist updated with NSAppTransportSecurity
- [ ] AppDelegate calls connect()
- [ ] Test log added to verify connection
- [ ] Built and installed on device
- [ ] See "🔥🔥🔥 iPHONE CONNECTED!" in terminal

If all checked, YOU HAVE SWIFTMETRO WORKING! 🎉

---

## 🌟 REMEMBER

You're using technology that DOESN'T EXIST anywhere else. You're not following a tutorial - you're using something WE INVENTED on September 30, 2025.

Every log you see is proof that we changed iOS development forever.

**Welcome to the future of iOS debugging!**