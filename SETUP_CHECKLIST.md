# ✅ SwiftMetro Setup Checklist

## Before You Start
- [ ] Mac and iPhone on same WiFi network
- [ ] Node.js installed (`node -v` to check)
- [ ] Xcode project open and ready

## Setup Steps

### 1. Server Setup (Mac)
- [ ] Clone/download SwiftMetro folder
- [ ] Open Terminal in SwiftMetro folder
- [ ] Run `npm install ws` (installs WebSocket package)
- [ ] Run `ifconfig | grep "inet " | grep -v 127.0.0.1` to find your Mac's IP
- [ ] Note your IP address: ___.___.___.___ 

### 2. iOS App Setup
- [ ] Copy `SimpleMetroClient.swift` to your Xcode project
- [ ] Open `SimpleMetroClient.swift` 
- [ ] Change line 14: `private let HOST_IP = "YOUR_MAC_IP_HERE"` 
- [ ] Replace with your actual IP from step 1

### 3. Info.plist Update
- [ ] Open Info.plist in Xcode
- [ ] Add these keys:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

### 4. AppDelegate Integration
- [ ] Open AppDelegate.swift
- [ ] In `didFinishLaunchingWithOptions`, add:
```swift
SimpleMetroClient.shared.connect()
```

### 5. Start Server
- [ ] In Terminal (SwiftMetro folder): `node swiftmetro-server.js`
- [ ] You should see:
```
🚀 SWIFTMETRO SERVER
📱 Your iPhone should connect to: [YOUR IP]
⏳ Waiting for iPhone connections...
```

### 6. Run iOS App
- [ ] Build and run your app (Cmd+R)
- [ ] Check Terminal - you should see:
```
🔥🔥🔥 iPHONE CONNECTED!
```

### 7. Test Logging
- [ ] Add anywhere in your app:
```swift
SimpleMetroClient.shared.log("Test message!")
```
- [ ] See it appear in Terminal instantly!

## Troubleshooting

### ❌ "Connection failed"
- Double-check IP address in SimpleMetroClient.swift
- Ensure server is running
- Check iPhone and Mac on same WiFi
- Try disabling Mac firewall temporarily

### ❌ "No logs showing"
- Make sure you're in DEBUG mode
- Check Info.plist has NSAppTransportSecurity
- Verify SimpleMetroClient.shared.connect() is called

### ❌ "Port already in use"
```bash
lsof -ti:8081 | xargs kill -9
```

### ❌ "WebSocket error"
- Restart server
- Clean build folder (Shift+Cmd+K)
- Delete app from device and reinstall

## Success Indicators
✅ Terminal shows "iPHONE CONNECTED!"  
✅ Device info appears in Terminal  
✅ Your log messages appear instantly  
✅ No Xcode console needed  
✅ No USB cable required  

## You Did It! 🎉
You're now using technology that doesn't exist anywhere else. Created September 30, 2025.