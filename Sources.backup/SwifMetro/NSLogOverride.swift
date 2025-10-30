// NSLogOverride.swift
// Direct override of NSLog and os_log functions

import Foundation
import os.log
import Darwin

// Store original NSLog function pointer
private let originalNSLog: UnsafeMutableRawPointer? = {
    return dlsym(dlopen(nil, RTLD_NOW), "NSLog")
}()

// NOTE: Removed @_silgen_name override to avoid linker conflicts
// We'll rely on other interception methods instead
public func SwifMetro_NSLog(_ format: String, _ args: CVarArg...) {
    // Create the formatted string
    let message = String(format: format, arguments: args)
    
    // Send to SwifMetro
    SwifMetroClient.shared.captureLog("📝 [NSLog] \(message)")
    
    // Also call original NSLog if available
    withVaList(args) { vaList in
        NSLogv(format, vaList)
    }
}

// Custom os_log wrapper that captures logs
public struct SwifMetroLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "SwifMetro"
    
    public static func log(_ type: OSLogType = .default, _ message: String) {
        // Capture for SwifMetro
        let prefix: String
        switch type {
        case .debug:
            prefix = "🐛 [os_log:debug]"
        case .info:
            prefix = "ℹ️ [os_log:info]"
        case .error:
            prefix = "❌ [os_log:error]"
        case .fault:
            prefix = "💥 [os_log:fault]"
        default:
            prefix = "📋 [os_log]"
        }
        
        SwifMetroClient.shared.captureLog("\(prefix) \(message)")
        
        // Also send to real os_log
        let logger = Logger(subsystem: subsystem, category: "SwifMetro")
        switch type {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .error:
            logger.error("\(message)")
        case .fault:
            logger.fault("\(message)")
        default:
            logger.log("\(message)")
        }
    }
}

// Extension to make os_log calls easier to intercept
public extension OSLog {
    static func swifmetro(_ message: String, type: OSLogType = .default) {
        SwifMetroLogger.log(type, message)
    }
}