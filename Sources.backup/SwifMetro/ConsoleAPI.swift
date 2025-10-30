// ConsoleAPI.swift
// Full console API implementation to match React Native Metro

import Foundation
import UIKit

/// Console API matching React Native's console methods
public class Console {
    // Shared instance
    public static let shared = Console()
    
    // Private storage
    private var timers: [String: Date] = [:]
    private var counters: [String: Int] = [:]
    private var groupStack: [String] = []
    private let queue = DispatchQueue(label: "com.swifmetro.console")
    
    private init() {}
    
    // MARK: - Basic Logging (like console.log, console.info, etc.)
    
    /// Equivalent to console.log()
    public func log(_ items: Any...) {
        let message = items.map { "\($0)" }.joined(separator: " ")
        SwifMetroClient.shared.captureLog("📝 [console.log] \(message)")
    }
    
    /// Equivalent to console.info()
    public func info(_ items: Any...) {
        let message = items.map { "\($0)" }.joined(separator: " ")
        SwifMetroClient.shared.captureLog("ℹ️ [console.info] \(message)")
    }
    
    /// Equivalent to console.debug()
    public func debug(_ items: Any...) {
        let message = items.map { "\($0)" }.joined(separator: " ")
        SwifMetroClient.shared.captureLog("🐛 [console.debug] \(message)")
    }
    
    /// Equivalent to console.warn()
    public func warn(_ items: Any...) {
        let message = items.map { "\($0)" }.joined(separator: " ")
        SwifMetroClient.shared.captureLog("⚠️ [console.warn] \(message)")
    }
    
    /// Equivalent to console.error()
    public func error(_ items: Any...) {
        let message = items.map { "\($0)" }.joined(separator: " ")
        SwifMetroClient.shared.captureLog("❌ [console.error] \(message)")
    }
    
    // MARK: - Performance Timing (console.time/timeEnd)
    
    /// Start a timer - equivalent to console.time()
    public func time(_ label: String = "default") {
        queue.sync {
            timers[label] = Date()
        }
        SwifMetroClient.shared.captureLog("⏱️ [console.time] Timer '\(label)' started")
    }
    
    /// End a timer and log duration - equivalent to console.timeEnd()
    public func timeEnd(_ label: String = "default") {
        queue.sync {
            guard let startTime = timers.removeValue(forKey: label) else {
                SwifMetroClient.shared.captureLog("⚠️ [console.timeEnd] Timer '\(label)' does not exist")
                return
            }
            let duration = Date().timeIntervalSince(startTime) * 1000
            SwifMetroClient.shared.captureLog("⏱️ [console.timeEnd] \(label): \(String(format: "%.2f", duration))ms")
        }
    }
    
    /// Log current timer value without stopping - equivalent to console.timeLog()
    public func timeLog(_ label: String = "default", _ data: Any...) {
        queue.sync {
            guard let startTime = timers[label] else {
                SwifMetroClient.shared.captureLog("⚠️ [console.timeLog] Timer '\(label)' does not exist")
                return
            }
            let duration = Date().timeIntervalSince(startTime) * 1000
            let extra = data.isEmpty ? "" : " " + data.map { "\($0)" }.joined(separator: " ")
            SwifMetroClient.shared.captureLog("⏱️ [console.timeLog] \(label): \(String(format: "%.2f", duration))ms\(extra)")
        }
    }
    
    // MARK: - Grouping (console.group/groupEnd)
    
    /// Start a log group - equivalent to console.group()
    public func group(_ label: String? = nil) {
        queue.sync {
            let groupLabel = label ?? "Group \(groupStack.count + 1)"
            groupStack.append(groupLabel)
            let indent = String(repeating: "  ", count: groupStack.count - 1)
            SwifMetroClient.shared.captureLog("\(indent)📁 [console.group] ▼ \(groupLabel)")
        }
    }
    
    /// Start a collapsed log group - equivalent to console.groupCollapsed()
    public func groupCollapsed(_ label: String? = nil) {
        queue.sync {
            let groupLabel = label ?? "Group \(groupStack.count + 1)"
            groupStack.append(groupLabel)
            let indent = String(repeating: "  ", count: groupStack.count - 1)
            SwifMetroClient.shared.captureLog("\(indent)📁 [console.groupCollapsed] ▶ \(groupLabel)")
        }
    }
    
    /// End a log group - equivalent to console.groupEnd()
    public func groupEnd() {
        queue.sync {
            guard !groupStack.isEmpty else {
                SwifMetroClient.shared.captureLog("⚠️ [console.groupEnd] No group to end")
                return
            }
            let groupLabel = groupStack.removeLast()
            let indent = String(repeating: "  ", count: groupStack.count)
            SwifMetroClient.shared.captureLog("\(indent)📁 [console.groupEnd] \(groupLabel)")
        }
    }
    
    // MARK: - Counting (console.count/countReset)
    
    /// Count calls with a label - equivalent to console.count()
    public func count(_ label: String = "default") {
        queue.sync {
            counters[label, default: 0] += 1
            SwifMetroClient.shared.captureLog("🔢 [console.count] \(label): \(counters[label]!)")
        }
    }
    
    /// Reset a counter - equivalent to console.countReset()
    public func countReset(_ label: String = "default") {
        queue.sync {
            counters[label] = 0
            SwifMetroClient.shared.captureLog("🔄 [console.countReset] \(label) reset to 0")
        }
    }
    
    // MARK: - Assertions (console.assert)
    
    /// Log if condition is false - equivalent to console.assert()
    public func assert(_ condition: Bool, _ message: String = "Assertion failed", file: String = #file, line: Int = #line) {
        if !condition {
            SwifMetroClient.shared.captureLog("🚫 [console.assert] \(message) at \(file):\(line)")
            // Include stack trace
            let stack = Thread.callStackSymbols
                .dropFirst(2) // Remove assert and its caller
                .prefix(5) // Show only top 5 frames
                .enumerated()
                .map { "    \($0.offset + 1). \($0.element)" }
                .joined(separator: "\n")
            SwifMetroClient.shared.captureLog("📍 [console.assert] Stack:\n\(stack)")
        }
    }
    
    // MARK: - Stack Traces (console.trace)
    
    /// Log a stack trace - equivalent to console.trace()
    public func trace(_ label: String = "Trace") {
        let stack = Thread.callStackSymbols
            .dropFirst(2) // Remove trace and its caller
            .enumerated()
            .map { "  \($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
        SwifMetroClient.shared.captureLog("🔍 [console.trace] \(label)\n\(stack)")
    }
    
    // MARK: - Table Display (console.table)
    
    /// Display data in table format - equivalent to console.table()
    public func table<T>(_ data: [T], columns: [String]? = nil) {
        var output = "📊 [console.table]\n"
        
        if let array = data as? [[String: Any]] {
            // Handle array of dictionaries
            let keys = columns ?? Array(Set(array.flatMap { $0.keys })).sorted()
            
            // Header
            output += "┌─────┬" + keys.map { "─" + String(repeating: "─", count: max(15, $0.count)) + "─┬" }.joined()
            output = String(output.dropLast()) + "┐\n"
            output += "│ idx │" + keys.map { " \($0.padding(toLength: max(15, $0.count), withPad: " ", startingAt: 0)) │" }.joined() + "\n"
            output += "├─────┼" + keys.map { "─" + String(repeating: "─", count: max(15, $0.count)) + "─┼" }.joined()
            output = String(output.dropLast()) + "┤\n"
            
            // Rows
            for (index, dict) in array.enumerated() {
                output += "│ \(String(index).padding(toLength: 3, withPad: " ", startingAt: 0)) │"
                for key in keys {
                    let value = String(describing: dict[key] ?? "null")
                    output += " \(value.padding(toLength: max(15, key.count), withPad: " ", startingAt: 0)) │"
                }
                output += "\n"
            }
            
            // Footer
            output += "└─────┴" + keys.map { "─" + String(repeating: "─", count: max(15, $0.count)) + "─┴" }.joined()
            output = String(output.dropLast()) + "┘"
        } else {
            // Handle simple array
            output += "┌─────┬────────────────┐\n"
            output += "│ idx │ value          │\n"
            output += "├─────┼────────────────┤\n"
            for (index, item) in data.enumerated() {
                let value = String(describing: item)
                output += "│ \(String(index).padding(toLength: 3, withPad: " ", startingAt: 0)) │ \(value.padding(toLength: 14, withPad: " ", startingAt: 0)) │\n"
            }
            output += "└─────┴────────────────┘"
        }
        
        SwifMetroClient.shared.captureLog(output)
    }
    
    // MARK: - Object Inspection (console.dir)
    
    /// Deep object inspection - equivalent to console.dir()
    public func dir<T>(_ object: T, options: [String: Any] = [:]) {
        let depth = options["depth"] as? Int ?? 2
        let showHidden = options["showHidden"] as? Bool ?? false
        
        var output = "🔍 [console.dir] \(type(of: object))\n"
        output += inspectObject(object, depth: depth, currentDepth: 0, showHidden: showHidden)
        SwifMetroClient.shared.captureLog(output)
    }
    
    private func inspectObject<T>(_ object: T, depth: Int, currentDepth: Int, showHidden: Bool) -> String {
        guard currentDepth < depth else { return "  [Max depth reached]" }
        
        let mirror = Mirror(reflecting: object)
        var output = ""
        let indent = String(repeating: "  ", count: currentDepth + 1)
        
        for (label, value) in mirror.children {
            let propertyName = label ?? "<unnamed>"
            let valueType = type(of: value)
            
            // Skip private properties unless showHidden is true
            if !showHidden && propertyName.hasPrefix("_") {
                continue
            }
            
            output += "\(indent)\(propertyName): "
            
            // Handle different types
            if let array = value as? [Any] {
                output += "Array[\(array.count)] "
                if currentDepth + 1 < depth {
                    output += "[\n"
                    for (idx, item) in array.enumerated() {
                        output += "\(indent)  [\(idx)]: \(item)\n"
                    }
                    output += "\(indent)]"
                }
            } else if let dict = value as? [String: Any] {
                output += "Dictionary[\(dict.count)] "
                if currentDepth + 1 < depth {
                    output += "{\n"
                    for (key, val) in dict {
                        output += "\(indent)  \(key): \(val)\n"
                    }
                    output += "\(indent)}"
                }
            } else if let str = value as? String {
                output += "\"\(str)\" (String)"
            } else if let num = value as? NSNumber {
                output += "\(num) (\(valueType))"
            } else {
                output += "\(value) (\(valueType))"
            }
            output += "\n"
        }
        
        return output
    }
    
    // MARK: - Clear (console.clear)
    
    /// Clear the console - equivalent to console.clear()
    public func clear() {
        SwifMetroClient.shared.captureLog("🧹 [console.clear] ════════════════════════════════")
        // In a real console this would clear the screen
    }
}

// MARK: - Global console object for easy access

public let console = Console.shared

// MARK: - Convenience functions matching JavaScript style

public func console_log(_ items: Any...) {
    console.log(items)
}

public func console_error(_ items: Any...) {
    console.error(items)
}

public func console_warn(_ items: Any...) {
    console.warn(items)
}