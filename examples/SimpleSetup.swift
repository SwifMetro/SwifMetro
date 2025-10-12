import SwiftUI
import SwifMetro
import UIKit

// EXAMPLE 1: SwiftUI App Setup
@main
struct MyApp: App {
    init() {
        #if DEBUG
        // Start SwifMetro with auto-discovery
        SwifMetroClient.shared.start()

        // Log app launch
        SwifMetroClient.shared.log("🚀 App launched!")
        SwifMetroClient.shared.logSuccess("✅ SwifMetro connected!")
        SwifMetroClient.shared.logInfo("📱 Device: \(UIDevice.current.name)")

        // Test print capture (automatically captured)
        print("This print() will appear in your terminal!")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// EXAMPLE 2: UIKit AppDelegate Setup
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        // Start SwifMetro
        SwifMetroClient.shared.start()

        // Wait a moment for connection, then log
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SwifMetroClient.shared.log("🚀 App launched!")
            SwifMetroClient.shared.logSuccess("✅ Connected to SwifMetro")
            SwifMetroClient.shared.logInfo("📱 Device: \(UIDevice.current.name)")
        }
        #endif

        return true
    }
}

// EXAMPLE 3: Logging Throughout Your App
class MyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
        SwifMetroClient.shared.log("📱 LoginScreen loaded")
        #endif
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        #if DEBUG
        SwifMetroClient.shared.log("🔵 Login button tapped")
        #endif

        performLogin()
    }

    func performLogin() {
        #if DEBUG
        SwifMetroClient.shared.log("🌐 Starting API call...")
        #endif

        // Your API call here
        APIService.login { result in
            #if DEBUG
            switch result {
            case .success:
                SwifMetroClient.shared.logSuccess("Login successful!")
            case .failure(let error):
                SwifMetroClient.shared.logError("Login failed: \(error.localizedDescription)")
            }
            #endif
        }
    }
}

// EXAMPLE 4: SwiftUI View Tracking
struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile")
        }
        .swifMetroTracking("ProfileView")  // Automatically logs appear/disappear
    }
}

// EXAMPLE 5: Network Request Logging
extension URLSession {
    func loggedDataTask(with request: URLRequest,
                        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        #if DEBUG
        let startTime = Date()
        SwifMetroClient.shared.logNetwork(
            method: request.httpMethod ?? "GET",
            url: request.url?.absoluteString ?? ""
        )
        #endif

        return dataTask(with: request) { data, response, error in
            #if DEBUG
            let duration = Date().timeIntervalSince(startTime)
            let status = (response as? HTTPURLResponse)?.statusCode
            SwifMetroClient.shared.logNetwork(
                method: request.httpMethod ?? "GET",
                url: request.url?.absoluteString ?? "",
                status: status,
                duration: duration
            )

            if let error = error {
                SwifMetroClient.shared.logError("Network error: \(error.localizedDescription)")
            }
            #endif

            completionHandler(data, response, error)
        }
    }
}

// EXAMPLE 6: Performance Monitoring
class PerformanceMonitor {
    static func measureOperation<T>(_ name: String, operation: () -> T) -> T {
        #if DEBUG
        let startTime = Date()
        #endif

        let result = operation()

        #if DEBUG
        let elapsed = Date().timeIntervalSince(startTime) * 1000 // Convert to ms
        SwifMetroClient.shared.logPerformance(name, value: elapsed, unit: "ms")
        #endif

        return result
    }
}

// Usage:
// let data = PerformanceMonitor.measureOperation("Database Query") {
//     return database.fetchAll()
// }
