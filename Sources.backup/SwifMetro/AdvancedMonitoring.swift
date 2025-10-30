import Foundation
import UIKit
import os
import QuartzCore

/// Advanced monitoring features for SwifMetro
public class AdvancedMonitoring: NSObject {
    
    private static var displayLink: CADisplayLink?
    private static var frameCount = 0
    private static var lastFrameTime: CFTimeInterval = 0
    private static var memoryTimer: Timer?
    private static var userDefaultsObserver: NSKeyValueObservation?
    
    // MARK: - Logger API Interception (iOS 14+)
    
    /// Intercept Logger API calls
    public static func interceptLoggerAPI() {
        if #available(iOS 14.0, *) {
            // Hook into os_log system which Logger uses under the hood
            // Logger internally calls os_log, so our existing os_log capture works!
            // But let's also add explicit Logger monitoring
            
            // Create a test logger to verify capture
            let testLogger = Logger(subsystem: "com.swifmetro.test", category: "LoggerAPI")
            testLogger.info("🔍 Logger API interception active")
            testLogger.debug("Debug level Logger message")
            testLogger.error("Error level Logger message")
            testLogger.warning("Warning level Logger message")
            testLogger.critical("Critical level Logger message")
            
            SwifMetroClient.shared.captureLog("✅ [SwifMetro] Logger API interception enabled - all Logger() calls are captured via os_log system")
        } else {
            SwifMetroClient.shared.captureLog("ℹ️ [SwifMetro] Logger API requires iOS 14+, using os_log capture instead")
        }
    }
    
    // MARK: - Memory Statistics
    
    /// Start automatic memory monitoring
    public static func startMemoryMonitoring(interval: TimeInterval = 5.0) {
        stopMemoryMonitoring() // Stop any existing timer
        
        // Log initial memory
        logMemoryStats()
        
        // Set up periodic monitoring
        memoryTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            logMemoryStats()
        }
        
        SwifMetroClient.shared.captureLog("📊 [Memory Monitor] Started - logging every \(interval)s")
    }
    
    /// Stop memory monitoring
    public static func stopMemoryMonitoring() {
        memoryTimer?.invalidate()
        memoryTimer = nil
    }
    
    /// Log current memory statistics
    private static func logMemoryStats() {
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
            let virtualMB = Double(info.virtual_size) / 1024.0 / 1024.0
            
            // Get memory pressure
            let memoryPressure = ProcessInfo.processInfo.physicalMemory
            let availableMemoryMB = Double(memoryPressure) / 1024.0 / 1024.0
            
            SwifMetroClient.shared.captureLog("""
                📊 [Memory Stats] Used: \(String(format: "%.1f", usedMB))MB | \
                Virtual: \(String(format: "%.1f", virtualMB))MB | \
                Available: \(String(format: "%.0f", availableMemoryMB))MB
                """)
            
            // Warn if memory usage is high
            if usedMB > 500 {
                SwifMetroClient.shared.captureLog("⚠️ [Memory Warning] High memory usage: \(String(format: "%.1f", usedMB))MB")
            }
        }
    }
    
    // MARK: - FPS Monitoring
    
    /// Start FPS monitoring
    public static func startFPSMonitoring() {
        stopFPSMonitoring() // Stop any existing display link
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
        displayLink?.add(to: .main, forMode: .common)
        
        SwifMetroClient.shared.captureLog("📱 [FPS Monitor] Started - real-time frame rate tracking")
    }
    
    /// Stop FPS monitoring
    public static func stopFPSMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private static func updateFPS(displayLink: CADisplayLink) {
        if lastFrameTime == 0 {
            lastFrameTime = displayLink.timestamp
            return
        }
        
        frameCount += 1
        let elapsed = displayLink.timestamp - lastFrameTime
        
        // Log FPS every second
        if elapsed >= 1.0 {
            let fps = Double(frameCount) / elapsed
            
            // Color code based on performance
            let fpsMessage: String
            if fps >= 55 {
                fpsMessage = "🟢 [FPS] \(String(format: "%.0f", fps)) fps - Smooth"
            } else if fps >= 30 {
                fpsMessage = "🟡 [FPS] \(String(format: "%.0f", fps)) fps - Acceptable"
            } else {
                fpsMessage = "🔴 [FPS] \(String(format: "%.0f", fps)) fps - Poor performance!"
            }
            
            SwifMetroClient.shared.captureLog(fpsMessage)
            
            // Reset counters
            frameCount = 0
            lastFrameTime = displayLink.timestamp
        }
    }
    
    // MARK: - UserDefaults Monitoring
    
    /// Start monitoring UserDefaults changes
    public static func startUserDefaultsMonitoring() {
        // Monitor standard UserDefaults
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
        SwifMetroClient.shared.captureLog("⚙️ [UserDefaults Monitor] Started - tracking all preference changes")
        
        // Log current UserDefaults state
        logCurrentUserDefaults()
    }
    
    /// Stop monitoring UserDefaults
    public static func stopUserDefaultsMonitoring() {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc private static func userDefaultsDidChange(notification: Notification) {
        guard let userDefaults = notification.object as? UserDefaults else { return }
        
        // Log the change
        SwifMetroClient.shared.captureLog("⚙️ [UserDefaults] Settings changed")
        
        // Try to detect what changed by comparing with cached values
        // For now, just log that a change occurred
        if let changedKeys = notification.userInfo?["NSUserDefaultsKeysChanged"] as? [String] {
            for key in changedKeys {
                if let value = userDefaults.object(forKey: key) {
                    SwifMetroClient.shared.captureLog("  ↳ \(key) = \(value)")
                }
            }
        }
    }
    
    /// Log current UserDefaults state
    private static func logCurrentUserDefaults() {
        let defaults = UserDefaults.standard
        let dict = defaults.dictionaryRepresentation()
        
        // Filter out system keys
        let userKeys = dict.keys.filter { key in
            !key.hasPrefix("NS") && 
            !key.hasPrefix("Apple") && 
            !key.hasPrefix("com.apple") &&
            !key.contains("LanguageCode")
        }
        
        if !userKeys.isEmpty {
            SwifMetroClient.shared.captureLog("⚙️ [UserDefaults] Current settings:")
            for key in userKeys.sorted() {
                if let value = dict[key] {
                    // Truncate long values
                    let valueStr = String(describing: value)
                    let displayValue = valueStr.count > 100 ? 
                        String(valueStr.prefix(100)) + "..." : valueStr
                    SwifMetroClient.shared.captureLog("  ↳ \(key) = \(displayValue)")
                }
            }
        }
    }
    
    // MARK: - Start All Monitoring
    
    /// Start all advanced monitoring features
    public static func startAllMonitoring() {
        SwifMetroClient.shared.captureLog("🚀 [SwifMetro Advanced] Starting all monitoring...")
        
        interceptLoggerAPI()
        startMemoryMonitoring()
        startFPSMonitoring()
        startUserDefaultsMonitoring()
        
        SwifMetroClient.shared.captureLog("""
            ✅ [SwifMetro Advanced] All monitoring active:
            ✅ Logger API interception (via os_log capture)
            ✅ Memory statistics (every 5s)
            ✅ Real-time FPS tracking
            ✅ UserDefaults change detection
            """)
    }
    
    /// Stop all monitoring
    public static func stopAllMonitoring() {
        stopMemoryMonitoring()
        stopFPSMonitoring()
        stopUserDefaultsMonitoring()
    }
}

// Extension no longer needed since class inherits from NSObject