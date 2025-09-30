import UIKit
import SwiftUI

// MARK: - UIKit Example
class ExampleViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log screen load
        SimpleMetroClient.shared.log("📱 LoginScreen loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SimpleMetroClient.shared.log("👁 LoginScreen will appear")
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Log button tap with details
        SimpleMetroClient.shared.log("🔵 Login button tapped")
        SimpleMetroClient.shared.log("📧 Email: \(emailField.text ?? "")")
        SimpleMetroClient.shared.log("🔑 Password length: \(passwordField.text?.count ?? 0)")
        
        // Perform login
        performLogin()
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        SimpleMetroClient.shared.logWarning("Forgot password tapped")
    }
    
    func performLogin() {
        SimpleMetroClient.shared.log("🌐 Starting API call...")
        
        // Simulate API call
        APIService.login(email: emailField.text ?? "", password: passwordField.text ?? "") { result in
            switch result {
            case .success(let user):
                SimpleMetroClient.shared.logSuccess("Login successful for user: \(user.id)")
                self.navigateToHome()
            case .failure(let error):
                SimpleMetroClient.shared.logError("Login failed: \(error.localizedDescription)")
                self.showError(error)
            }
        }
    }
    
    func navigateToHome() {
        SimpleMetroClient.shared.log("📍 Navigating to HomeScreen")
        // Navigation code
    }
    
    func showError(_ error: Error) {
        SimpleMetroClient.shared.logError("Showing error alert: \(error)")
        // Alert code
    }
}

// MARK: - SwiftUI Example
struct ExampleSwiftUIView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: username) { newValue in
                    SimpleMetroClient.shared.log("⌨️ Username changed: \(newValue)")
                }
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: password) { _ in
                    SimpleMetroClient.shared.log("🔑 Password changed (length: \(password.count))")
                }
            
            Button(action: loginTapped) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Forgot Password?") {
                SimpleMetroClient.shared.logInfo("Forgot password tapped")
            }
            .foregroundColor(.blue)
        }
        .padding()
        .onAppear {
            SimpleMetroClient.shared.log("📱 LoginView appeared")
        }
        .onDisappear {
            SimpleMetroClient.shared.log("👋 LoginView disappeared")
        }
    }
    
    func loginTapped() {
        SimpleMetroClient.shared.log("🔵 Login button tapped in SwiftUI")
        SimpleMetroClient.shared.log("👤 Username: \(username)")
        
        isLoading = true
        SimpleMetroClient.shared.log("⏳ Starting login process...")
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let success = Bool.random()
            
            if success {
                SimpleMetroClient.shared.logSuccess("Login successful!")
                // Navigate to home
            } else {
                SimpleMetroClient.shared.logError("Login failed: Invalid credentials")
                // Show error
            }
            
            isLoading = false
        }
    }
}

// MARK: - AppDelegate Integration
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Connect to SwiftMetro on app launch
        #if DEBUG
        SimpleMetroClient.shared.connect()
        
        // Log app launch details
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SimpleMetroClient.shared.log("🚀 App launched successfully")
            SimpleMetroClient.shared.log("📱 Device: \(UIDevice.current.name)")
            SimpleMetroClient.shared.log("🖥 iOS: \(UIDevice.current.systemVersion)")
            SimpleMetroClient.shared.log("📦 Bundle: \(Bundle.main.bundleIdentifier ?? "unknown")")
        }
        #endif
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        SimpleMetroClient.shared.log("✅ App became active")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        SimpleMetroClient.shared.log("⏸ App will resign active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SimpleMetroClient.shared.log("🌙 App entered background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        SimpleMetroClient.shared.log("☀️ App will enter foreground")
    }
}

// MARK: - Network Request Logging
extension URLSession {
    func dataTaskWithLogging(with request: URLRequest, 
                             completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        // Log request
        SimpleMetroClient.shared.log("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        return dataTask(with: request) { data, response, error in
            // Log response
            if let httpResponse = response as? HTTPURLResponse {
                let emoji = httpResponse.statusCode < 400 ? "✅" : "❌"
                SimpleMetroClient.shared.log("\(emoji) API Response: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                SimpleMetroClient.shared.logError("API Error: \(error.localizedDescription)")
            }
            
            completionHandler(data, response, error)
        }
    }
}

// MARK: - Custom Logging Extensions
extension SimpleMetroClient {
    
    /// Log performance metrics
    func logPerformance(operation: String, startTime: Date) {
        let elapsed = Date().timeIntervalSince(startTime)
        log("⏱ \(operation): \(String(format: "%.3f", elapsed))s")
    }
    
    /// Log memory usage
    func logMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            log("💾 Memory: \(String(format: "%.1f", usedMB)) MB")
        }
    }
    
    /// Log user action with context
    func logUserAction(_ action: String, context: [String: Any]? = nil) {
        var message = "👤 User: \(action)"
        if let context = context {
            for (key, value) in context {
                message += "\n   \(key): \(value)"
            }
        }
        log(message)
    }
    
    /// Log analytics event
    func logAnalytics(event: String, parameters: [String: Any]? = nil) {
        var message = "📊 Analytics: \(event)"
        if let parameters = parameters {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            if let json = String(data: jsonData ?? Data(), encoding: .utf8) {
                message += " \(json)"
            }
        }
        log(message)
    }
}