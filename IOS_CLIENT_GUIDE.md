# SwifMetro iOS Client

Professional wireless logging for native iOS apps. Stream logs from your iPhone/iPad to your Mac terminal in real-time - no cables required.

## Installation

### Swift Package Manager (Recommended)

Add SwifMetro to your Xcode project:

1. In Xcode, select **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/SwifMetro/swifmetro-ios.git
   ```
3. Select version: `1.0.0`
4. Click **Add Package**

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SwifMetro/swifmetro-ios.git", from: "1.0.0")
]
```

## Quick Start

### 1. Start SwifMetro Server on Mac

```bash
npm install -g swifmetro
swifmetro terminal
```

### 2. Add to Your iOS App

```swift
import SwifMetro

// In AppDelegate or @main
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    #if DEBUG
    SwifMetroClient.shared.start()
    #endif

    return true
}
```

### 3. Start Logging

```swift
// Simple logging
SwifMetroClient.shared.log("Hello from iOS!")

// Structured logging with emojis
SwifMetroClient.shared.logSuccess("✅ Login successful")
SwifMetroClient.shared.logError("❌ Network request failed")
SwifMetroClient.shared.logWarning("⚠️ Battery low")

// Network logging
SwifMetroClient.shared.logNetwork(
    method: "POST",
    url: "/api/login",
    status: 200,
    duration: 0.45
)

// Performance metrics
SwifMetroClient.shared.logPerformance("API Response", value: 234.5)
```

## Features

- ✅ **Auto-Discovery** - Finds your Mac automatically via Bonjour
- ✅ **Real-Time** - WebSocket streaming with <10ms latency
- ✅ **Zero Configuration** - Works out of the box
- ✅ **Debug Only** - Automatically disabled in release builds
- ✅ **Message Queue** - Buffers logs when offline (up to 1,000 messages)
- ✅ **Auto-Reconnect** - Recovers from network issues
- ✅ **Device Info** - Sends device name, model, iOS version
- ✅ **Performance** - Monitors FPS and memory usage

## Advanced Features

### Automatic print() Capture

All `print()` and `NSLog()` calls are automatically captured:

```swift
print("This appears in terminal!")  // Automatically logged
```

### Performance Monitoring

```swift
// Log memory usage
SwifMetroClient.shared.logMemoryUsage()

// Log FPS (requires display link setup)
SwifMetroClient.shared.logPerformance("FPS", value: 60.0, unit: "fps")
```

### Custom Log Levels

```swift
SwifMetroClient.shared.logInfo("ℹ️ User opened profile")
SwifMetroClient.shared.logDebug("🔍 Debugging authentication flow")
```

### Structured Data Logging

```swift
struct LoginEvent: Codable {
    let username: String
    let timestamp: Date
    let success: Bool
}

let event = LoginEvent(username: "john@example.com", timestamp: Date(), success: true)
SwifMetroClient.shared.logData("login_attempt", data: event)
```

## SwiftUI Support

Track view lifecycle automatically:

```swift
import SwiftUI
import SwifMetro

struct ContentView: View {
    var body: some View {
        Text("Hello, SwifMetro!")
            .swifMetroTracking("ContentView")  // Logs appear/disappear
    }
}
```

## Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.9+
- Xcode 15.0+

## Server Installation

Install the SwifMetro server on your Mac:

```bash
# Install via npm
npm install -g swifmetro

# Start terminal mode (default)
swifmetro terminal

# Or start dashboard mode
swifmetro dashboard
```

## Configuration

### Manual IP (if auto-discovery fails)

```swift
SwifMetroClient.shared.connectToServer("192.168.1.100")
```

### License Key (Pro features)

```swift
SwifMetroClient.shared.setLicenseKey("SWIF-XXXX-XXXX-XXXX")
```

## Troubleshooting

### Not connecting?

1. Ensure your Mac and iPhone are on the **same Wi-Fi network**
2. Check that the server is running: `swifmetro status`
3. Check firewall settings (allow port 8081)
4. Try manual IP connection (see Configuration above)

### Logs not appearing?

1. Verify the client is connected: Check console for "✅ SwifMetro: Connected"
2. Restart the server: `swifmetro terminal`
3. Check network connectivity

## Examples

See the [Examples](https://github.com/SwifMetro/SwifMetro/tree/main/examples) folder for:
- UIKit integration
- SwiftUI integration
- Network logging
- Custom extensions
- Performance monitoring

## Documentation

Full documentation: [swifmetro.dev/docs](https://swifmetro.dev/docs)

## License

MIT License - See [LICENSE](LICENSE) for details

## Support

- **Issues**: [GitHub Issues](https://github.com/SwifMetro/swifmetro-ios/issues)
- **Email**: support@swifmetro.dev
- **Website**: [swifmetro.dev](https://swifmetro.dev)

---

**Built with ❤️ for iOS developers who love wireless debugging**
