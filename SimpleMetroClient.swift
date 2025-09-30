import Foundation
import UIKit

/// SwifMetro Client - Terminal logging for iOS
/// Created: September 30, 2025
/// The technology that shouldn't exist, but does.
class SimpleMetroClient {
    static let shared = SimpleMetroClient()
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    
    /// CHANGE THIS TO YOUR MAC'S IP ADDRESS
    /// To find your IP, run in Terminal: ifconfig | grep "inet " | grep -v 127.0.0.1
    private let HOST_IP = "YOUR_MAC_IP_HERE" // e.g., "192.168.0.100"
    private let PORT = "8081"
    
    func connect() {
        #if DEBUG
        print("🚀 SwifMetro: Attempting connection...")
        
        // Check if IP was configured
        guard HOST_IP != "YOUR_MAC_IP_HERE" else {
            print("❌ SwifMetro: Please set your Mac's IP address in SimpleMetroClient.swift")
            print("💡 Run this in Terminal to find your IP:")
            print("   ifconfig | grep 'inet ' | grep -v 127.0.0.1")
            return
        }
        
        let urlString = "ws://\(HOST_IP):\(PORT)"
        
        guard let url = URL(string: urlString) else {
            print("❌ SwifMetro: Invalid URL - check your IP address")
            return
        }
        
        print("📡 SwifMetro: Connecting to \(urlString)...")
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Send device info as first message
        let deviceInfo = "\(UIDevice.current.name) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
        let message = URLSessionWebSocketTask.Message.string(deviceInfo)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ SwifMetro: Connection failed - \(error.localizedDescription)")
                print("💡 Make sure:")
                print("   1. Server is running: node swifmetro-server.js")
                print("   2. iPhone and Mac are on same WiFi")
                print("   3. Mac firewall allows connection")
            } else {
                print("✅ SwifMetro: Connected successfully!")
                print("🔥 You can now use SimpleMetroClient.shared.log() anywhere!")
            }
        }
        
        // Start receiving messages
        receiveMessage()
        #endif
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 Server says: \(text)")
                case .data(let data):
                    print("📦 Received \(data.count) bytes")
                @unknown default:
                    break
                }
                // Continue receiving
                self?.receiveMessage()
            case .failure(let error):
                print("❌ SwifMetro receive error: \(error)")
                // Attempt reconnection after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    print("🔄 SwifMetro: Attempting reconnection...")
                    self?.connect()
                }
            }
        }
    }
    
    /// Send a log message to Terminal
    /// - Parameter message: The message to log
    func log(_ message: String) {
        #if DEBUG
        guard webSocketTask != nil else {
            print("⚠️ SwifMetro not connected. Call connect() first.")
            return
        }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("❌ SwifMetro log failed: \(error)")
            }
        }
        #endif
    }
    
    /// Disconnect from SwifMetro server
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        print("👋 SwifMetro: Disconnected")
    }
}

// MARK: - Helper Extensions
extension SimpleMetroClient {
    /// Log with emoji prefix for better visibility
    func logInfo(_ message: String) {
        log("ℹ️ \(message)")
    }
    
    func logSuccess(_ message: String) {
        log("✅ \(message)")
    }
    
    func logWarning(_ message: String) {
        log("⚠️ \(message)")
    }
    
    func logError(_ message: String) {
        log("❌ \(message)")
    }
    
    func logDebug(_ message: String) {
        log("🔍 \(message)")
    }
}