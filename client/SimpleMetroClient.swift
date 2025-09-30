import Foundation
import UIKit

/// Simplified SwifMetro Client using URLSession WebSocket
class SimpleMetroClient {
    static let shared = SimpleMetroClient()
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    
    func connect() {
        // REMOVED #if DEBUG TO FORCE CONNECTION
        print("🚀 SimpleMetro: Attempting connection...")
        NSLog("🚀 SimpleMetro: FORCING connection...")
        
        // Hardcoded IP for testing
        let urlString = "ws://192.168.0.100:8081"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("📡 SimpleMetro: WebSocket started")
        
        // Send device info
        let deviceName = UIDevice.current.name
        let message = URLSessionWebSocketTask.Message.string(deviceName)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ Failed to send device info: \(error)")
                NSLog("❌ Failed to send: \(error)")
            } else {
                print("✅ Sent device info: \(deviceName)")
                NSLog("✅ SUCCESS - Device sent: \(deviceName)")
                // Send a test message
                let testMsg = URLSessionWebSocketTask.Message.string("TEST LOG FROM IPHONE!")
                self.webSocketTask?.send(testMsg) { _ in }
            }
        }
        
        // Start receiving messages
        receiveMessage()
        // REMOVED #endif
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("❌ WebSocket error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📝 Received: \(text)")
                case .data(let data):
                    print("📦 Received data: \(data.count) bytes")
                @unknown default:
                    break
                }
                
                // Continue receiving
                self?.receiveMessage()
            }
        }
    }
    
    func log(_ message: String) {
        // REMOVED DEBUG CHECK
        print("📱 \(message)")
        let wsMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("Failed to send log: \(error)")
            }
        }
    }
}