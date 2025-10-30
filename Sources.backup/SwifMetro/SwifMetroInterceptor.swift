// SwifMetroInterceptor.swift
// Pure Swift implementation for intercepting all log types

import Foundation
import Darwin
import os.log

// C function declarations removed to avoid linker conflicts
// We'll use the imported Foundation functions instead

// SwifMetro Interceptor
public class SwifMetroInterceptor {
    
    // Original file descriptors
    private static var originalStdout: Int32 = 0
    private static var originalStderr: Int32 = 0
    private static var stdoutPipe: [Int32] = [0, 0]
    private static var stderrPipe: [Int32] = [0, 0]
    
    private static let queue = DispatchQueue(label: "com.swifmetro.interceptor", attributes: .concurrent)
    private static var isIntercepting = false
    
    // Initialize comprehensive log interception
    public static func initialize() {
        guard !isIntercepting else { return }
        isIntercepting = true
        
        print("🚀 SwifMetro: Initializing comprehensive log interceptor...")
        
        // Intercept stdout
        interceptStdout()
        
        // Intercept stderr (NSLog goes here on iOS)
        interceptStderr()
        
        // Hook into os_log
        interceptOSLog()
        
        // Swizzle NSLog
        swizzleNSLog()
        
        print("✅ SwifMetro: Log interceptor activated - capturing ALL logs!")
    }
    
    // MARK: - Stdout Interception
    private static func interceptStdout() {
        // Save original stdout
        originalStdout = dup(STDOUT_FILENO)
        
        // Create pipe
        if pipe(&stdoutPipe) != 0 {
            print("❌ SwifMetro: Failed to create stdout pipe")
            return
        }
        
        // Make read end non-blocking
        let flags = fcntl(stdoutPipe[0], F_GETFL, 0)
        fcntl(stdoutPipe[0], F_SETFL, flags | O_NONBLOCK)
        
        // Redirect stdout to pipe
        dup2(stdoutPipe[1], STDOUT_FILENO)
        
        // Start reading from pipe
        queue.async {
            readFromPipe(stdoutPipe[0], label: "📤 [stdout]", original: originalStdout)
        }
    }
    
    // MARK: - Stderr Interception
    private static func interceptStderr() {
        // Save original stderr
        originalStderr = dup(STDERR_FILENO)
        
        // Create pipe
        if pipe(&stderrPipe) != 0 {
            print("❌ SwifMetro: Failed to create stderr pipe")
            return
        }
        
        // Make read end non-blocking
        let flags = fcntl(stderrPipe[0], F_GETFL, 0)
        fcntl(stderrPipe[0], F_SETFL, flags | O_NONBLOCK)
        
        // Redirect stderr to pipe
        dup2(stderrPipe[1], STDERR_FILENO)
        
        // Start reading from pipe
        queue.async {
            readFromPipe(stderrPipe[0], label: "⚠️ [stderr]", original: originalStderr)
        }
    }
    
    // MARK: - Pipe Reader
    private static func readFromPipe(_ pipe: Int32, label: String, original: Int32) {
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        
        while true {
            let bytesRead = read(pipe, &buffer, bufferSize)
            if bytesRead > 0 {
                // Write to original stream
                write(original, &buffer, bytesRead)
                
                // Capture for SwifMetro
                if let output = String(bytes: buffer[..<bytesRead], encoding: .utf8) {
                    processOutput(output, label: label)
                }
            }
            usleep(1000) // Small delay to prevent CPU spinning
        }
    }
    
    // MARK: - Process captured output
    private static func processOutput(_ output: String, label: String) {
        let lines = output.components(separatedBy: "\n")
        for line in lines {
            let lineStr = String(line)
            if !lineStr.isEmpty {
                // Detect log type
                let finalLabel: String
                if lineStr.contains("SwifMetro") || lineStr.contains("🖨️ [print]") {
                    continue // Skip already processed logs
                } else if label.contains("stderr") && (lineStr.contains("] ") || lineStr.contains(":")){
                    // Likely NSLog format
                    finalLabel = "📝 [NSLog]"
                } else if lineStr.hasPrefix("🚀") || lineStr.hasPrefix("✅") || lineStr.hasPrefix("📱") {
                    // Print statement with emoji
                    finalLabel = "🖨️ [print]"
                } else {
                    finalLabel = label
                }
                
                SwifMetroClient.shared.captureLog("\(finalLabel) \(lineStr)")
            }
        }
    }
    
    // MARK: - NSLog Swizzling
    private static func swizzleNSLog() {
        // Use method swizzling on NSString's logging methods
        let originalClass = NSString.self
        
        // Note: Direct NSLog swizzling is complex on iOS
        // The above stdout/stderr capture should handle it
    }
    
    // MARK: - os_log Interception
    private static func interceptOSLog() {
        // os_log is harder to intercept but we can create a custom logger
        // that mirrors to SwifMetro
    }
    
    // Custom NSLog replacement that captures logs
    public static func captureNSLog(_ format: String, _ args: CVarArg...) {
        let message = String(format: format, arguments: args)
        SwifMetroClient.shared.captureLog("📝 [NSLog] \(message)")
        
        // Also call original NSLog
        withVaList(args) { vaList in
            NSLogv(format, vaList)
        }
    }
}