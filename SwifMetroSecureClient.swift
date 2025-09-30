import Foundation
import Network

/**
 * SwifMetro Secure Client
 * Supports both WS and WSS (encrypted) connections
 * Created: September 30, 2025
 */

class SwifMetroSecureClient {
    static let shared = SwifMetroSecureClient()
    
    // Configuration
    private var useSecureConnection = true
    private var port: Int = 8443 // WSS port
    private var insecurePort: Int = 8081 // WS port
    private var hostIP: String?
    
    // WebSocket
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    
    // State
    private var isConnected = false
    private var messageQueue: [String] = []
    private let maxQueueSize = 1000
    
    // Service discovery
    private var browser: NWBrowser?
    
    private init() {
        setupURLSession()
    }
    
    // MARK: - Setup
    
    private func setupURLSession() {
        // Configure session to accept self-signed certificates in DEBUG
        #if DEBUG
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        #else
        urlSession = URLSession.shared
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Start SwifMetro with auto-discovery
    func start(secure: Bool = true) {
        self.useSecureConnection = secure
        print("🔒 SwifMetro: Starting \(secure ? "secure" : "standard") connection...")
        
        #if DEBUG
        discoverServer()
        #endif
    }
    
    /// Connect to specific IP
    func connect(to ip: String, secure: Bool = true) {
        self.hostIP = ip
        self.useSecureConnection = secure
        establishConnection()
    }
    
    /// Log a message
    func log(_ message: String) {
        send(message)
    }
    
    /// Log with level
    func log(_ message: String, level: LogLevel) {
        let prefixed = "\(level.emoji) \(message)"
        send(prefixed)
    }
    
    /// Log structured data
    func logData<T: Encodable>(_ event: String, data: T) {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            
            if var json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json["event"] = event
                json["timestamp"] = ISO8601DateFormatter().string(from: Date())
                
                let finalData = try JSONSerialization.data(withJSONObject: json)
                if let jsonString = String(data: finalData, encoding: .utf8) {
                    send(jsonString)
                }
            }
        } catch {
            log("Failed to encode data: \(error)", level: .error)
        }
    }
    
    // MARK: - Connection Management
    
    private func discoverServer() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        let serviceType = useSecureConnection ? "_swifmetro-secure._tcp" : "_swifmetro._tcp"
        
        browser = NWBrowser(for: .bonjour(type: serviceType, domain: nil), using: parameters)
        
        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            guard let self = self else { return }
            
            for result in results {
                if case .service(let name, let type, _, _) = result.endpoint,
                   type == serviceType {
                    print("🔍 SwifMetro: Found service: \(name)")
                    self.resolveService(result.endpoint)
                    self.browser?.cancel()
                    break
                }
            }
        }
        
        browser?.start(queue: .main)
        
        // Fallback after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self, !self.isConnected else { return }
            print("⚠️ SwifMetro: Discovery timeout, trying local IPs...")
            self.tryCommonIPs()
        }
    }
    
    private func resolveService(_ endpoint: NWEndpoint) {
        guard case .service(_, _, _, let interface) = endpoint else { return }
        
        // Get IP from interface
        if let interface = interface {
            tryConnectToInterface(interface)
        }
    }
    
    private func tryConnectToInterface(_ interface: NWInterface) {
        // This is simplified - in production you'd properly resolve the IP
        tryCommonIPs()
    }
    
    private func tryCommonIPs() {
        let commonIPs = [
            "192.168.1.100",
            "192.168.0.100",
            "10.0.0.100",
            "172.20.10.2"
        ]
        
        for ip in commonIPs {
            if tryConnection(to: ip) {
                break
            }
        }
    }
    
    private func tryConnection(to ip: String) -> Bool {
        hostIP = ip
        establishConnection()
        return true
    }
    
    private func establishConnection() {
        guard let ip = hostIP else {
            print("❌ SwifMetro: No host IP configured")
            return
        }
        
        let protocol_ = useSecureConnection ? "wss" : "ws"
        let port = useSecureConnection ? self.port : self.insecurePort
        let urlString = "\(protocol_)://\(ip):\(port)"
        
        guard let url = URL(string: urlString) else {
            print("❌ SwifMetro: Invalid URL")
            return
        }
        
        print("🔌 SwifMetro: Connecting to \(urlString)...")
        
        webSocketTask?.cancel()
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Send device info
        sendDeviceInfo()
        
        // Start receiving
        receiveMessage()
        
        // Send queued messages
        flushQueue()
    }
    
    private func sendDeviceInfo() {
        let info: [String: Any] = [
            "device": UIDevice.current.name,
            "model": UIDevice.current.model,
            "os": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "app": Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown"
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: info),
           let json = String(data: data, encoding: .utf8) {
            send(json)
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage() // Continue receiving
            case .failure(let error):
                print("❌ SwifMetro: Receive error: \(error)")
                self?.handleDisconnection()
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            if !isConnected {
                isConnected = true
                print("✅ SwifMetro: \(useSecureConnection ? "Secure" : "Standard") connection established!")
            }
        case .data(_):
            break
        @unknown default:
            break
        }
    }
    
    private func send(_ message: String) {
        if isConnected {
            let wsMessage = URLSessionWebSocketTask.Message.string(message)
            webSocketTask?.send(wsMessage) { error in
                if let error = error {
                    print("❌ SwifMetro: Send error: \(error)")
                }
            }
        } else {
            // Queue message
            messageQueue.append(message)
            if messageQueue.count > maxQueueSize {
                messageQueue.removeFirst()
            }
        }
    }
    
    private func flushQueue() {
        guard isConnected else { return }
        
        for message in messageQueue {
            send(message)
        }
        messageQueue.removeAll()
    }
    
    private func handleDisconnection() {
        isConnected = false
        print("⚠️ SwifMetro: Disconnected")
        
        // Attempt reconnection after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            print("🔄 SwifMetro: Attempting reconnection...")
            self.establishConnection()
        }
    }
    
    // MARK: - Log Levels
    
    enum LogLevel {
        case debug
        case info
        case warning
        case error
        case success
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .success: return "✅"
            }
        }
    }
}

// MARK: - URLSession Delegate

extension SwifMetroSecureClient: URLSessionDelegate, URLSessionWebSocketDelegate {
    
    // Accept self-signed certificates in DEBUG
    func urlSession(_ session: URLSession, 
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        #if DEBUG
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        #endif
        
        completionHandler(.performDefaultHandling, nil)
    }
}

// MARK: - SwiftUI Integration

#if canImport(SwiftUI)
import SwiftUI

struct SwifMetroViewModifier: ViewModifier {
    let viewName: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                SwifMetroSecureClient.shared.log("📱 View appeared: \(viewName)")
            }
            .onDisappear {
                SwifMetroSecureClient.shared.log("👋 View disappeared: \(viewName)")
            }
    }
}

extension View {
    func swifMetroTracking(_ name: String) -> some View {
        modifier(SwifMetroViewModifier(viewName: name))
    }
}
#endif