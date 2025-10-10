// LogHooks.swift
// Aggressive log interception using multiple techniques

import Foundation
import Darwin
import os.log

@objc public class LogHooks: NSObject {
    
    private static var stderrPipe: [Int32] = [0, 0]
    private static var originalStderr: Int32 = 0
    private static var isHooked = false
    
    @objc public static func installHooks() {
        guard !isHooked else { return }
        isHooked = true
        
        print("🔧 SwifMetro: Installing comprehensive log hooks...")
        
        // Method 1: Redirect stderr (where NSLog writes on iOS)
        redirectStderr()
        
        // Method 2: Hook NSLog using dup2 on file descriptor 2
        hookFileDescriptor()
        
        // Method 3: Swizzle print to ensure we catch everything  
        swizzlePrint()
        
        print("✅ SwifMetro: All log hooks installed!")
    }
    
    private static func redirectStderr() {
        // Create a pipe
        if pipe(&stderrPipe) != 0 {
            print("❌ Failed to create stderr pipe")
            return
        }
        
        // Save original stderr
        originalStderr = dup(STDERR_FILENO)
        
        // Redirect stderr to our pipe
        dup2(stderrPipe[1], STDERR_FILENO)
        
        // Make read end non-blocking
        let flags = fcntl(stderrPipe[0], F_GETFL, 0)
        fcntl(stderrPipe[0], F_SETFL, flags | O_NONBLOCK)
        
        // Start reading from pipe in background
        DispatchQueue.global(qos: .background).async {
            let bufferSize = 4096
            var buffer = [CChar](repeating: 0, count: bufferSize)
            
            while true {
                let bytesRead = read(stderrPipe[0], &buffer, bufferSize - 1)
                if bytesRead > 0 {
                    buffer[bytesRead] = 0 // Null terminate
                    
                    // Write to original stderr
                    write(originalStderr, buffer, bytesRead)
                    
                    // Convert to string and send to SwifMetro
                    if let output = String(cString: buffer, encoding: .utf8) {
                        processStderrOutput(output)
                    }
                }
                usleep(1000) // 1ms delay
            }
        }
    }
    
    private static func processStderrOutput(_ output: String) {
        // Parse stderr output to detect NSLog format
        let lines = output.split(separator: "\n", omittingEmptySubSequences: false)
        for line in lines {
            let lineStr = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            if !lineStr.isEmpty {
                // Check if it looks like NSLog output (has timestamp pattern)
                if lineStr.contains(":") && lineStr.contains(".") {
                    // Extract the actual log message
                    if let lastColon = lineStr.lastIndex(of: ":") {
                        let messageStart = lineStr.index(after: lastColon)
                        let message = String(lineStr[messageStart...]).trimmingCharacters(in: .whitespaces)
                        SwifMetroClient.shared.captureLog("📝 [NSLog] \(message)")
                    } else {
                        SwifMetroClient.shared.captureLog("📝 [NSLog] \(lineStr)")
                    }
                } else if lineStr.contains("TEST") || lineStr.contains("fputs") {
                    // Capture our test messages
                    SwifMetroClient.shared.captureLog("⚠️ [stderr] \(lineStr)")
                } else if !lineStr.contains("SwifMetro") {
                    // Generic stderr output
                    SwifMetroClient.shared.captureLog("⚠️ [stderr] \(lineStr)")
                }
            }
        }
    }
    
    private static func hookFileDescriptor() {
        // Additional file descriptor hooking
        let stderrFD = STDERR_FILENO
        
        // Try to intercept writes to stderr directly
        class_addMethod(
            NSObject.self,
            NSSelectorFromString("_logToStderr:"),
            { (self: AnyObject, _: Selector, message: String) in
                SwifMetroClient.shared.captureLog("📝 [NSLog-hook] \(message)")
            } as @convention(block) (AnyObject, Selector, String) -> Void,
            "v@:@"
        )
    }
    
    private static func swizzlePrint() {
        // Swizzle Swift print if possible
        // This is already handled by stdout redirection in SwifMetroInterceptor
    }
}

// Global function to make NSLog interception easier
public func NSLogIntercepted(_ format: String, _ args: CVarArg...) {
    let message = String(format: format, arguments: args)
    SwifMetroClient.shared.captureLog("📝 [NSLog] \(message)")
    
    // Call original NSLog
    withVaList(args) { vaList in
        NSLogv(format as NSString, vaList)
    }
}

// Macro-like function for os_log interception
public func os_log_intercepted(_ type: OSLogType = .default, _ message: String) {
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
    os_log("%{public}@", type: type, message as NSString)
}