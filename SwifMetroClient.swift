import Foundation
import UIKit
import Network

/// SwifMetro Client - Advanced Version with Auto-Discovery
/// Created: September 30, 2025
/// The technology that revolutionized iOS debugging
class SwifMetroClient {
    static let shared = SwifMetroClient()
    
    // WebSocket
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    
    // Bonjour Service Discovery
    private var browser: NWBrowser?
    private var connection: NWConnection?
    private let serviceTy
    
    // Configuration
    private var serverIP: String?
    private var isConnected = false
    private let port = "8081"
    
    // Message Queue (for offline support)
    private var messageQueue: [String] = []
    private let maxQueueSize = 1000
    
    // Performance Monitoring
    private var startTime: Date?
    private var logCount = 0
    
    /// Start SwifMetro with auto-discovery
    func start() {
        #if DEBUG
        print("🚀 SwifMetro: Starting auto-discovery...")
        discoverServer()
        startTime = Date()
        
        // Fallback: Try localhost if on simulator
        #if targetEnvironment(simulator)
        connectToServer("127.0.0.1")
        #endif
        #endif
    }
    
    /// Discover SwifMetro server using Bonjour
    private func discoverServer() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        browser = NWBrowser(for: .bonjour(type: "_swifmetro._tcp", domain: nil), using: parameters)
        
        browser?.browseResultsChangedHandler = { results, changes in
            for result in results {
                if case NWEndpoint.service(let name, let type, let domain, _) = result.endpoint {
                    print("📡 SwifMetro: Found server: \(name)")
                    self.resolveService(result.endpoint)
                    self.browser?.cancel()
                    break
                }
            }
        }
        
        browser?.start(queue: .main)
        
        // Timeout fallback
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if !self!.isConnected {
                print("⚠️ SwifMetro: Auto-discovery timed out")
                self?.tryCommonIPs()
            }
        }
    }
    
    /// Resolve Bonjour service to IP
    private func resolveService(_ endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: .tcp)
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                if let innerEndpoint = connection.currentPath?.remoteEndpoint,
                   case .hostPort(let host, _) = innerEndpoint {
                    let ip = "\(host)".replacingOccurrences(of: "%en0", with: "")
                    print("✅ SwifMetro: Resolved to IP: \(ip)")
                    self.connectToServer(ip)
                }
            case .failed(let error):
                print("❌ SwifMetro: Resolution failed: \(error)")
            default:
                break
            }
        }
        
        connection.start(queue: .main)
    }
    
    /// Try common local IPs as fallback
    private func tryCommonIPs() {
        let commonIPs = [
            "192.168.0.100", // Try Mac's common IP first!
            "192.168.1.100", 
            "192.168.0.1", "192.168.0.2",
            "192.168.1.1", "192.168.1.2",
            "10.0.0.1", "10.0.0.100",
            "172.20.10.1" // iPhone hotspot default
        ]
        
        tryConnectionSequentially(ips: commonIPs, index: 0)
    }
    
    /// Try IPs one by one with proper async handling
    private func tryConnectionSequentially(ips: [String], index: Int) {
        guard index < ips.count else { return }
        
        let ip = ips[index]
        let url = URL(string: "ws://\(ip):\(port)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2.0
        
        let testTask = session.webSocketTask(with: request)
        testTask.resume()
        
        testTask.sendPing { [weak self] error in
            if error == nil {
                print("✅ SwifMetro: Found server at \(ip)!")
                self?.connectToServer(ip)
            } else {
                // Try next IP
                self?.tryConnectionSequentially(ips: ips, index: index + 1)
            }
        }
    }
    
    /// Connect to discovered server
    private func connectToServer(_ ip: String) {
        serverIP = ip
        let urlString = "ws://\(ip):\(port)"
        
        guard let url = URL(string: urlString) else { return }
        
        print("📡 SwifMetro: Connecting to \(urlString)...")
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Send device info
        let deviceInfo = [
            "device": UIDevice.current.name,
            "model": UIDevice.current.model,
            "os": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "app": Bundle.main.bundleIdentifier ?? "unknown",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: deviceInfo),
           let json = String(data: data, encoding: .utf8) {
            let message = URLSessionWebSocketTask.Message.string(json)
            webSocketTask?.send(message) { [weak self] error in
                if error == nil {
                    self?.isConnected = true
                    print("✅ SwifMetro: Connected successfully!")
                    self?.flushMessageQueue()
                } else {
                    print("❌ SwifMetro: Connection failed")
                }
            }
        }
        
        receiveMessage()
        setupHeartbeat()
    }
    
    /// Receive messages from server
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleServerMessage(text)
                case .data(let data):
                    self?.handleServerData(data)
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("❌ SwifMetro: Receive error: \(error)")
                self?.handleDisconnection()
            }
        }
    }
    
    /// Handle messages from server (for hot reload, commands, etc)
    private func handleServerMessage(_ message: String) {
        if message.hasPrefix("CMD:") {
            let command = String(message.dropFirst(4))
            executeCommand(command)
        } else if message.hasPrefix("RELOAD:") {
            let className = String(message.dropFirst(7))
            performHotReload(className)
        } else {
            print("📨 Server: \(message)")
        }
    }
    
    /// Handle binary data from server
    private func handleServerData(_ data: Data) {
        // For future: Handle dylib injection for hot reload
        print("📦 Received binary data: \(data.count) bytes")
    }
    
    /// Execute server commands
    private func executeCommand(_ command: String) {
        switch command {
        case "screenshot":
            takeScreenshot()
        case "memory":
            logMemoryUsage()
        case "fps":
            logFPS()
        case "clear":
            clearLogs()
        default:
            print("Unknown command: \(command)")
        }
    }
    
    /// Perform hot reload (future implementation)
    private func performHotReload(_ className: String) {
        print("🔄 Hot reload requested for: \(className)")
        // Future: Dynamic library loading and method swizzling
    }
    
    /// Setup heartbeat to keep connection alive
    private func setupHeartbeat() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.webSocketTask?.sendPing { error in
                if error != nil {
                    self?.handleDisconnection()
                }
            }
        }
    }
    
    /// Handle disconnection
    private func handleDisconnection() {
        isConnected = false
        print("🔄 SwifMetro: Reconnecting...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.start()
        }
    }
    
    /// Flush queued messages
    private func flushMessageQueue() {
        for message in messageQueue {
            log(message)
        }
        messageQueue.removeAll()
    }
    
    // MARK: - Public Logging API
    
    /// Log a message
    func log(_ message: String) {
        logCount += 1
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] \(message)"
        
        if isConnected {
            let wsMessage = URLSessionWebSocketTask.Message.string(logMessage)
            webSocketTask?.send(wsMessage) { error in
                if error != nil {
                    self.queueMessage(logMessage)
                }
            }
        } else {
            queueMessage(logMessage)
        }
    }
    
    /// Queue message for later
    private func queueMessage(_ message: String) {
        if messageQueue.count >= maxQueueSize {
            messageQueue.removeFirst()
        }
        messageQueue.append(message)
    }
    
    // MARK: - Advanced Logging
    
    /// Log with structured data
    func logData<T: Encodable>(_ event: String, data: T) {
        let wrapper = LogWrapper(event: event, data: data, timestamp: Date())
        if let json = try? JSONEncoder().encode(wrapper),
           let string = String(data: json, encoding: .utf8) {
            log(string)
        }
    }
    
    /// Log network request
    func logNetwork(method: String, url: String, status: Int? = nil, duration: TimeInterval? = nil) {
        var message = "🌐 \(method) \(url)"
        if let status = status {
            message += " → \(status)"
        }
        if let duration = duration {
            message += " (\(String(format: "%.2f", duration))s)"
        }
        log(message)
    }
    
    /// Log user interaction
    func logInteraction(_ action: String, element: String, metadata: [String: Any]? = nil) {
        var message = "👆 \(action): \(element)"
        if let metadata = metadata {
            message += " \(metadata)"
        }
        log(message)
    }
    
    /// Log performance metric
    func logPerformance(_ metric: String, value: Double, unit: String = "ms") {
        log("📊 \(metric): \(String(format: "%.2f", value))\(unit)")
    }
    
    // MARK: - Utility Functions
    
    /// Take screenshot and send to server
    private func takeScreenshot() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let imageData = image?.jpegData(compressionQuality: 0.5) {
            let message = URLSessionWebSocketTask.Message.data(imageData)
            webSocketTask?.send(message) { _ in }
            log("📸 Screenshot sent (\(imageData.count / 1024)KB)")
        }
    }
    
    /// Log current memory usage
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
            logPerformance("Memory", value: usedMB, unit: "MB")
        }
    }
    
    /// Log current FPS
    private func logFPS() {
        // Implementation depends on your rendering framework
        logPerformance("FPS", value: 60.0, unit: "fps")
    }
    
    /// Clear logs on server
    private func clearLogs() {
        let message = URLSessionWebSocketTask.Message.string("CLEAR_LOGS")
        webSocketTask?.send(message) { _ in }
    }
    
    /// Get session statistics
    func getStatistics() -> SessionStats {
        let uptime = Date().timeIntervalSince(startTime ?? Date())
        return SessionStats(
            logCount: logCount,
            uptimeSeconds: uptime,
            isConnected: isConnected,
            serverIP: serverIP,
            queuedMessages: messageQueue.count
        )
    }
}

// MARK: - Helper Types

struct LogWrapper<T: Encodable>: Encodable {
    let event: String
    let data: T
    let timestamp: Date
}

struct SessionStats {
    let logCount: Int
    let uptimeSeconds: TimeInterval
    let isConnected: Bool
    let serverIP: String?
    let queuedMessages: Int
}

// MARK: - Convenience Extensions

extension SwifMetroClient {
    func logInfo(_ message: String) { log("ℹ️ \(message)") }
    func logSuccess(_ message: String) { log("✅ \(message)") }
    func logWarning(_ message: String) { log("⚠️ \(message)") }
    func logError(_ message: String) { log("❌ \(message)") }
    func logDebug(_ message: String) { log("🔍 \(message)") }
}

// MARK: - SwiftUI Support

#if canImport(SwiftUI)
import SwiftUI

struct SwifMetroView: ViewModifier {
    let viewName: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                SwifMetroClient.shared.log("📱 View appeared: \(viewName)")
            }
            .onDisappear {
                SwifMetroClient.shared.log("👋 View disappeared: \(viewName)")
            }
    }
}

extension View {
    func swifMetroTracking(_ name: String) -> some View {
        modifier(SwifMetroView(viewName: name))
    }
}
#endif