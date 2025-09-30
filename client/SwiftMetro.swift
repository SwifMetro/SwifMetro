// 
// SwiftMetro.swift
// The first hot reload framework for native iOS development
//
// Created by 72hConcept Team
// Copyright © 2025 SwiftMetro. All rights reserved.
//

import Foundation
import Network
import UIKit
import os.log

/// SwiftMetro - Hot reload for native iOS development
public class SwiftMetro {
    
    // MARK: - Singleton
    public static let shared = SwiftMetro()
    
    // MARK: - Properties
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.swiftmetro.client", qos: .userInitiated)
    private let logger = Logger(subsystem: "com.swiftmetro", category: "client")
    
    // Configuration
    private var host: String = "localhost"
    private var port: UInt16 = 8081
    private var autoConnect: Bool = true
    private var visualFeedback: Bool = true
    
    // State
    private var isConnected: Bool = false
    private var reconnectTimer: Timer?
    private var messageHandlers: [String: (Data) -> Void] = [:]
    
    // Callbacks
    public var onReload: (() -> Void)?
    public var onConnect: (() -> Void)?
    public var onDisconnect: (() -> Void)?
    public var onError: ((Error) -> Void)?
    
    // MARK: - Initialization
    
    private init() {
        setupDefaultHandlers()
    }
    
    // MARK: - Public API
    
    /// Start SwiftMetro with default configuration
    public func start() {
        #if DEBUG
        logger.info("🚀 SwiftMetro starting...")
        
        // Try to get host from environment or Info.plist
        if let envHost = ProcessInfo.processInfo.environment["SWIFT_METRO_HOST"] {
            self.host = envHost
        } else if let plistHost = Bundle.main.object(forInfoDictionaryKey: "SwiftMetroHost") as? String {
            self.host = plistHost
        }
        
        // Try to get port from environment
        if let envPort = ProcessInfo.processInfo.environment["SWIFT_METRO_PORT"],
           let portNumber = UInt16(envPort) {
            self.port = portNumber
        }
        
        connect()
        #else
        logger.debug("SwiftMetro disabled in release builds")
        #endif
    }
    
    /// Start SwiftMetro with custom configuration
    public func start(host: String, port: UInt16 = 8081) {
        #if DEBUG
        self.host = host
        self.port = port
        start()
        #endif
    }
    
    /// Stop SwiftMetro and disconnect
    public func stop() {
        disconnect()
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    /// Send log message to bundler console
    public func log(_ message: String, level: LogLevel = .info) {
        #if DEBUG
        let logData: [String: Any] = [
            "type": "console_log",
            "level": level.rawValue,
            "message": message,
            "timestamp": Date().timeIntervalSince1970,
            "device": UIDevice.current.name
        ]
        
        sendMessage(logData)
        #endif
    }
    
    /// Register a custom message handler
    public func registerHandler(for type: String, handler: @escaping (Data) -> Void) {
        messageHandlers[type] = handler
    }
    
    // MARK: - Connection Management
    
    private func connect() {
        logger.info("🔗 Connecting to \(self.host):\(self.port)")
        
        let parameters = NWParameters.tcp
        parameters.prohibitExpensivePaths = false
        parameters.prohibitConstrainedPaths = false
        
        connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port)!,
            using: parameters
        )
        
        connection?.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionStateChange(state)
        }
        
        connection?.start(queue: queue)
    }
    
    private func disconnect() {
        connection?.cancel()
        connection = nil
        isConnected = false
    }
    
    private func handleConnectionStateChange(_ state: NWConnection.State) {
        switch state {
        case .ready:
            isConnected = true
            logger.info("✅ SwiftMetro connected to bundler")
            sendDeviceInfo()
            startReceiving()
            
            DispatchQueue.main.async {
                self.onConnect?()
                if self.visualFeedback {
                    self.showConnectionIndicator(connected: true)
                }
            }
            
        case .failed(let error):
            isConnected = false
            logger.error("❌ Connection failed: \(error.localizedDescription)")
            
            DispatchQueue.main.async {
                self.onError?(error)
                self.onDisconnect?()
            }
            
            scheduleReconnect()
            
        case .cancelled:
            isConnected = false
            logger.info("🔌 Connection cancelled")
            
            DispatchQueue.main.async {
                self.onDisconnect?()
            }
            
        case .waiting(let error):
            logger.warning("⏳ Connection waiting: \(error.localizedDescription)")
            
        default:
            break
        }
    }
    
    private func scheduleReconnect() {
        guard autoConnect else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, !self.isConnected else { return }
            self.logger.info("🔄 Attempting to reconnect...")
            self.connect()
        }
    }
    
    // MARK: - Message Handling
    
    private func startReceiving() {
        receiveMessage()
    }
    
    private func receiveMessage() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let error = error {
                self?.logger.error("Receive error: \(error.localizedDescription)")
            }
            
            if let data = data, !data.isEmpty {
                self?.handleMessage(data)
            }
            
            if !isComplete {
                self?.receiveMessage()
            }
        }
    }
    
    private func handleMessage(_ data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else {
                return
            }
            
            // Check for custom handlers first
            if let handler = messageHandlers[type] {
                handler(data)
                return
            }
            
            // Default handlers
            switch type {
            case "hot_reload":
                handleHotReload(json)
            case "code_update":
                handleCodeUpdate(json)
            case "console_response":
                handleConsoleResponse(json)
            case "error":
                handleError(json)
            default:
                logger.debug("Unknown message type: \(type)")
            }
            
        } catch {
            logger.error("Failed to parse message: \(error)")
        }
    }
    
    private func sendMessage(_ data: [String: Any]) {
        guard isConnected else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            
            connection?.send(content: jsonData, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    self?.logger.error("Send error: \(error)")
                }
            })
        } catch {
            logger.error("Failed to serialize message: \(error)")
        }
    }
    
    // MARK: - Default Message Handlers
    
    private func setupDefaultHandlers() {
        // Register default handlers here if needed
    }
    
    private func sendDeviceInfo() {
        let device = UIDevice.current
        let screen = UIScreen.main
        
        let deviceInfo: [String: Any] = [
            "type": "device_info",
            "name": device.name,
            "model": device.model,
            "systemVersion": device.systemVersion,
            "screenScale": screen.scale,
            "screenSize": [
                "width": screen.bounds.width,
                "height": screen.bounds.height
            ],
            "bundleId": Bundle.main.bundleIdentifier ?? "unknown",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        ]
        
        sendMessage(deviceInfo)
    }
    
    private func handleHotReload(_ payload: [String: Any]) {
        logger.info("🔥 Hot reload received")
        
        guard let fileName = payload["file"] as? String else { return }
        
        DispatchQueue.main.async { [weak self] in
            // Trigger UI refresh
            self?.refreshUI()
            
            // Call user callback
            self?.onReload?()
            
            // Show visual feedback
            if self?.visualFeedback == true {
                self?.showReloadIndicator(fileName: fileName)
            }
        }
    }
    
    private func handleCodeUpdate(_ payload: [String: Any]) {
        guard let hexData = payload["data"] as? String,
              let fileName = payload["file"] as? String else { return }
        
        logger.info("📦 Code update for \(fileName)")
        
        // Convert hex to data
        guard let data = hexData.hexadecimalData() else { return }
        
        // Save to temporary location
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("swift_metro_\(fileName).dylib")
        
        do {
            try data.write(to: tempURL)
            
            // Attempt to load dynamic library
            let path = tempURL.path
            if let handle = dlopen(path, RTLD_NOW) {
                logger.info("✅ Successfully loaded \(fileName)")
                
                DispatchQueue.main.async {
                    self.refreshUI()
                    self.onReload?()
                }
                
                dlclose(handle)
            } else {
                if let error = dlerror() {
                    logger.error("Failed to load dylib: \(String(cString: error))")
                }
            }
        } catch {
            logger.error("Failed to save dylib: \(error)")
        }
    }
    
    private func handleConsoleResponse(_ payload: [String: Any]) {
        if let message = payload["message"] as? String {
            logger.info("📝 Console: \(message)")
        }
    }
    
    private func handleError(_ payload: [String: Any]) {
        if let message = payload["message"] as? String {
            logger.error("❌ Error: \(message)")
        }
    }
    
    // MARK: - UI Updates
    
    private func refreshUI() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        
        // Force all views to refresh
        window.rootViewController?.view.setNeedsLayout()
        window.rootViewController?.view.layoutIfNeeded()
        
        // For SwiftUI apps, trigger environment update
        NotificationCenter.default.post(name: .swiftMetroReload, object: nil)
    }
    
    private func showReloadIndicator(fileName: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        container.center = CGPoint(x: window.center.x, y: 100)
        container.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        
        let label = UILabel(frame: container.bounds)
        label.text = "🔥 Reloaded"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        container.addSubview(label)
        
        window.addSubview(container)
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            container.alpha = 1
            container.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseIn) {
                container.alpha = 0
                container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { _ in
                container.removeFromSuperview()
            }
        }
    }
    
    private func showConnectionIndicator(connected: Bool) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        
        let indicator = UIView(frame: CGRect(x: window.bounds.width - 70, y: 50, width: 60, height: 30))
        indicator.backgroundColor = connected ? .systemGreen : .systemRed
        indicator.layer.cornerRadius = 15
        
        let label = UILabel(frame: indicator.bounds)
        label.text = connected ? "●" : "○"
        label.textAlignment = .center
        label.textColor = .white
        indicator.addSubview(label)
        
        window.addSubview(indicator)
        
        UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut) {
            indicator.alpha = 0
        } completion: { _ in
            indicator.removeFromSuperview()
        }
    }
}

// MARK: - Supporting Types

public extension SwiftMetro {
    enum LogLevel: String {
        case verbose = "verbose"
        case debug = "debug"
        case info = "info"
        case warning = "warning"
        case error = "error"
    }
}

// MARK: - Extensions

extension Notification.Name {
    static let swiftMetroReload = Notification.Name("SwiftMetroReload")
}

extension String {
    func hexadecimalData() -> Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        return data
    }
}

// MARK: - SwiftUI Support

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
public struct SwiftMetroModifier: ViewModifier {
    @State private var reloadCount = 0
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                SwiftMetro.shared.start()
            }
            .onReceive(NotificationCenter.default.publisher(for: .swiftMetroReload)) { _ in
                reloadCount += 1
            }
            .id(reloadCount) // Force view refresh
    }
}

@available(iOS 13.0, *)
public extension View {
    /// Enable hot reload for this view
    func enableHotReload() -> some View {
        self.modifier(SwiftMetroModifier())
    }
}
#endif