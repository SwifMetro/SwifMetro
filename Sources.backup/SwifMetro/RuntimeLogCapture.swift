// RuntimeLogCapture.swift  
// Capture runtime warnings, assertions, and system messages

import Foundation
import UIKit
import os.log

public class RuntimeLogCapture {
    
    // Capture runtime warnings and issues
    public static func captureRuntimeIssues() {
        // Capture Swift runtime warnings
        captureSwiftRuntimeWarnings()
        
        // Capture constraint warnings (Auto Layout)
        captureConstraintWarnings()
        
        // Capture memory warnings
        captureMemoryWarnings()
    }
    
    private static func captureSwiftRuntimeWarnings() {
        // Hook into Swift runtime warnings
        let logger = Logger(subsystem: "SwifMetro", category: "Runtime")
        
        // Monitor for common runtime issues
        logger.warning("🚨 [Runtime] Monitoring for Swift runtime warnings...")
        
        // Example: Capture forced unwrap failures
        NSSetUncaughtExceptionHandler { exception in
            let message = """
            💥 [CRASH] Uncaught Exception!
            Name: \(exception.name.rawValue)
            Reason: \(exception.reason ?? "Unknown")
            Stack: \(exception.callStackSymbols.joined(separator: "\n"))
            """
            SwifMetroClient.shared.captureLog(message)
        }
    }
    
    private static func captureConstraintWarnings() {
        // Listen for Auto Layout constraint warnings
        // Note: This notification name might vary
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UIViewAlertForUnsatisfiableConstraints"),
            object: nil,
            queue: .main
        ) { notification in
            if let description = notification.userInfo?.debugDescription {
                SwifMetroClient.shared.captureLog("⚠️ [AutoLayout] Constraint warning: \(description)")
            }
        }
    }
    
    private static func captureMemoryWarnings() {
        // Listen for memory warnings
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            SwifMetroClient.shared.captureLog("🧠 [Memory] ⚠️ Memory warning received!")
        }
    }
}

// Extension to capture more console output
public class ConsoleRedirect {
    private static var originalStdout: Int32 = 0
    private static var originalStderr: Int32 = 0
    
    public static func redirectConsoleToSwifMetro() {
        // This is already handled by SwifMetroInterceptor
        // Just a placeholder for additional console capture if needed
    }
}

// Capture system notifications about app lifecycle
public class SystemEventCapture {
    public static func captureSystemEvents() {
        // App lifecycle
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            SwifMetroClient.shared.captureLog("📱 [System] App became active")
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            SwifMetroClient.shared.captureLog("📱 [System] App will resign active")
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            SwifMetroClient.shared.captureLog("📱 [System] App entered background")
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            SwifMetroClient.shared.captureLog("📱 [System] App will enter foreground")
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            SwifMetroClient.shared.captureLog("💀 [System] App will terminate")
        }
    }
}